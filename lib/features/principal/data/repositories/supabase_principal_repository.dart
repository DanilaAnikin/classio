import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../admin_panel/domain/entities/invite_code.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/principal_repository.dart';

/// Exception thrown when principal operations fail.
class PrincipalException implements Exception {
  const PrincipalException(this.message);

  final String message;

  @override
  String toString() => 'PrincipalException: $message';
}

/// Supabase implementation of [PrincipalRepository].
///
/// Provides principal panel functionality using Supabase as the data source.
class SupabasePrincipalRepository implements PrincipalRepository {
  /// Creates a [SupabasePrincipalRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  SupabasePrincipalRepository([SupabaseClient? client])
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ==================== Staff Management ====================

  @override
  Future<List<AppUser>> getSchoolStaff(String schoolId) async {
    // Input validation
    if (schoolId.isEmpty) {
      throw PrincipalException('schoolId cannot be empty');
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            email,
            school_id,
            role,
            first_name,
            last_name,
            avatar_url,
            created_at
          ''')
          .eq('school_id', schoolId)
          .inFilter('role', [UserRole.admin.name, UserRole.bigadmin.name, UserRole.teacher.name])
          .order('role', ascending: true)
          .order('last_name', ascending: true);

      // Email may be null if not available - UI should handle this gracefully
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        return AppUser.fromJson(data);
      }).toList();
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to fetch school staff: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to fetch school staff: $e');
    }
  }

  @override
  Future<List<AppUser>> getSchoolTeachers(String schoolId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            email,
            school_id,
            role,
            first_name,
            last_name,
            avatar_url,
            created_at
          ''')
          .eq('school_id', schoolId)
          .eq('role', UserRole.teacher.name)
          .order('last_name', ascending: true);

      // Email may be null if not available - UI should handle this gracefully
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        return AppUser.fromJson(data);
      }).toList();
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to fetch teachers: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to fetch teachers: $e');
    }
  }

  @override
  Future<bool> removeStaffMember(String userId) async {
    try {
      // Soft delete: Set school_id to null and role to a disabled state
      // Or mark as inactive if there's an is_active column
      await _supabase
          .from('profiles')
          .update({
            'school_id': null,
            // Optionally set a disabled role or is_active flag
          })
          .eq('id', userId);

      return true;
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to remove staff member: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to remove staff member: $e');
    }
  }

  // ==================== Class Management ====================

  @override
  Future<List<ClassWithDetails>> getSchoolClassesWithDetails(
      String schoolId) async {
    try {
      // Fetch classes with head teacher info
      final response = await _supabase.from('classes').select('''
            id,
            school_id,
            name,
            grade_level,
            academic_year,
            head_teacher_id,
            created_at,
            head_teacher:profiles!classes_head_teacher_id_fkey(
              id,
              email,
              first_name,
              last_name,
              avatar_url,
              role
            )
          ''').eq('school_id', schoolId).order('grade_level', ascending: true);

      final classes = <ClassWithDetails>[];

      // OPTIMIZATION: Batch fetch all student counts to avoid N+1 queries
      final classIds = (response as List)
          .map((r) => r['id'] as String)
          .toList();

      final studentCountsMap = <String, int>{};
      if (classIds.isNotEmpty) {
        try {
          // Try student_classes table first
          final studentCountsResponse = await _supabase
              .from('student_classes')
              .select('class_id')
              .inFilter('class_id', classIds);

          // Build count map from student_classes results
          for (final row in studentCountsResponse as List) {
            final classId = row['class_id'] as String;
            studentCountsMap[classId] = (studentCountsMap[classId] ?? 0) + 1;
          }
        } on PostgrestException {
          // If student_classes table doesn't exist, try profiles table
          try {
            final profilesResponse = await _supabase
                .from('profiles')
                .select('class_id')
                .inFilter('class_id', classIds)
                .eq('role', UserRole.student.name);

            // Build count map from profiles results
            for (final row in profilesResponse as List) {
              final classId = row['class_id'] as String?;
              if (classId != null) {
                studentCountsMap[classId] = (studentCountsMap[classId] ?? 0) + 1;
              }
            }
          } catch (e, stackTrace) {
            if (kDebugMode) {
              debugPrint('Error fetching student counts from profiles table: $e');
              debugPrint('$stackTrace');
            }
            // If both approaches fail, leave studentCountsMap empty
          }
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('Error fetching student counts from student_classes table: $e');
            debugPrint('$stackTrace');
          }
          // If query fails, leave studentCountsMap empty
        }
      }

      for (final data in response) {
        // Parse gradeLevel from either int or String
        int? gradeLevel;
        final gradeLevelValue = data['grade_level'];
        if (gradeLevelValue != null) {
          if (gradeLevelValue is int) {
            gradeLevel = gradeLevelValue;
          } else if (gradeLevelValue is String) {
            gradeLevel = int.tryParse(gradeLevelValue);
          }
        }

        // Parse class info
        final classInfo = ClassInfo(
          id: data['id'] as String,
          schoolId: data['school_id'] as String,
          name: data['name'] as String,
          gradeLevel: gradeLevel,
          academicYear: data['academic_year'] as String?,
          createdAt: data['created_at'] != null
              ? DateTime.tryParse(data['created_at'] as String)
              : null,
        );

        // Parse head teacher if present
        // Email may be null if not available - UI should handle this gracefully
        AppUser? headTeacher;
        if (data['head_teacher'] != null) {
          final teacherData = data['head_teacher'] as Map<String, dynamic>;
          teacherData['school_id'] = schoolId;
          headTeacher = AppUser.fromJson(teacherData);
        }

        // Get student count from pre-computed map (O(1) lookup)
        final studentCount = studentCountsMap[classInfo.id] ?? 0;

        classes.add(ClassWithDetails(
          classInfo: classInfo,
          headTeacher: headTeacher,
          studentCount: studentCount,
        ));
      }

      return classes;
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to fetch classes: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to fetch classes: $e');
    }
  }

  @override
  Future<ClassInfo> createClass({
    required String schoolId,
    required String name,
    String? gradeLevel,
    String? academicYear,
    String? headTeacherId,
  }) async {
    // Input validation
    if (schoolId.isEmpty) {
      throw PrincipalException('schoolId cannot be empty');
    }
    if (name.isEmpty) {
      throw PrincipalException('Class name cannot be empty');
    }

    try {
      final response = await _supabase
          .from('classes')
          .insert({
            'school_id': schoolId,
            'name': name,
            'grade_level':
                gradeLevel != null ? int.tryParse(gradeLevel) : null,
            'academic_year': academicYear,
            'head_teacher_id': headTeacherId,
          })
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .single();

      return ClassInfo.fromJson(response);
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to create class: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to create class: $e');
    }
  }

  @override
  Future<ClassInfo> updateClass(
    ClassInfo classInfo, {
    String? headTeacherId,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'name': classInfo.name,
        'grade_level': classInfo.gradeLevel,
        'academic_year': classInfo.academicYear,
        // Always include head_teacher_id (can be null to remove the teacher)
        'head_teacher_id': headTeacherId,
      };

      final response = await _supabase
          .from('classes')
          .update(updateData)
          .eq('id', classInfo.id)
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .single();

      return ClassInfo.fromJson(response);
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to update class: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to update class: $e');
    }
  }

  @override
  Future<bool> assignHeadTeacher(String classId, String teacherId) async {
    try {
      await _supabase
          .from('classes')
          .update({'head_teacher_id': teacherId}).eq('id', classId);

      return true;
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to assign head teacher: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to assign head teacher: $e');
    }
  }

  @override
  Future<bool> removeHeadTeacher(String classId) async {
    try {
      await _supabase
          .from('classes')
          .update({'head_teacher_id': null}).eq('id', classId);

      return true;
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to remove head teacher: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to remove head teacher: $e');
    }
  }

  @override
  Future<int> getClassStudentCount(String classId) async {
    try {
      // Assuming there's a student_classes or enrollments table
      // or students have a class_id field
      final response = await _supabase
          .from('student_classes')
          .select('id')
          .eq('class_id', classId);

      return (response as List).length;
    } on PostgrestException catch (e) {
      // If table doesn't exist, try alternative approach
      if (kDebugMode) {
        debugPrint('PostgrestException in getClassStudentCount (student_classes): ${e.message}');
      }
      try {
        final response = await _supabase
            .from('profiles')
            .select('id')
            .eq('class_id', classId)
            .eq('role', UserRole.student.name);
        return (response as List).length;
      } catch (e2, stackTrace2) {
        if (kDebugMode) {
          debugPrint('Error getting student count for class $classId from profiles: $e2');
          debugPrint('$stackTrace2');
        }
        return 0;
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected error getting student count for class $classId: $e');
        debugPrint('$stackTrace');
      }
      return 0;
    }
  }

  @override
  Future<bool> deleteClass(String classId) async {
    try {
      await _supabase.from('classes').delete().eq('id', classId);
      return true;
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to delete class: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to delete class: $e');
    }
  }

  // ==================== Statistics ====================

  @override
  Future<SchoolStats> getSchoolStats(String schoolId) async {
    try {
      // Fetch user counts by role
      final usersResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('school_id', schoolId);

      final users = usersResponse as List;

      int teachers = 0;
      int admins = 0;
      int students = 0;
      int parents = 0;

      for (final user in users) {
        final role = user['role'] as String?;
        switch (role) {
          case 'teacher':
            teachers++;
            break;
          case 'admin':
          case 'bigadmin':
            admins++;
            break;
          case 'student':
            students++;
            break;
          case 'parent':
            parents++;
            break;
        }
      }

      // Fetch class count
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('school_id', schoolId);

      final totalClasses = (classesResponse as List).length;

      // Fetch active invite tokens count (still has remaining uses and not expired)
      final inviteTokensResponse = await _supabase
          .from('invite_tokens')
          .select('token, times_used, usage_limit')
          .eq('school_id', schoolId);

      // Filter in Dart: count tokens where times_used < usage_limit
      final activeInviteCodes = (inviteTokensResponse as List).where((token) {
        final timesUsed = token['times_used'] as int? ?? 0;
        final usageLimit = token['usage_limit'] as int? ?? 1;
        return timesUsed < usageLimit;
      }).length;

      return SchoolStats(
        totalStaff: teachers + admins,
        totalTeachers: teachers,
        totalAdmins: admins,
        totalClasses: totalClasses,
        totalStudents: students,
        totalParents: parents,
        activeInviteCodes: activeInviteCodes,
      );
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to fetch school stats: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to fetch school stats: $e');
    }
  }

  // ==================== Invite Codes ====================

  @override
  Future<List<InviteCode>> getSchoolInviteCodes(String schoolId) async {
    try {
      final response = await _supabase
          .from('invite_tokens')
          .select('''
            token,
            role,
            school_id,
            specific_class_id,
            usage_limit,
            times_used,
            expires_at,
            created_at
          ''')
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      // Map invite_tokens schema to InviteCode entities
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final usageLimit = data['usage_limit'] as int? ?? 1;
        final timesUsed = data['times_used'] as int? ?? 0;
        return InviteCode(
          id: data['token'] as String,
          code: data['token'] as String,
          role: UserRole.fromString(data['role'] as String?) ?? UserRole.student,
          schoolId: data['school_id'] as String,
          classId: data['specific_class_id'] as String?,
          usageLimit: usageLimit,
          timesUsed: timesUsed,
          isActive: timesUsed < usageLimit,
          expiresAt: data['expires_at'] != null
              ? DateTime.tryParse(data['expires_at'] as String)
              : null,
          createdAt: data['created_at'] != null
              ? DateTime.tryParse(data['created_at'] as String)
              : null,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to fetch invite codes: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to fetch invite codes: $e');
    }
  }

  @override
  Future<InviteCode> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
  }) async {
    // Input validation
    if (schoolId.isEmpty) {
      throw PrincipalException('schoolId cannot be empty');
    }
    if (usageLimit < 1) {
      throw PrincipalException('usageLimit must be at least 1, got $usageLimit');
    }

    try {
      // Generate a random 16-character alphanumeric code (cryptographically secure)
      final token = _generateRandomCode(16);

      // Get current user ID for created_by_user_id
      final currentUserId = _supabase.auth.currentUser?.id;

      final response = await _supabase
          .from('invite_tokens')
          .insert({
            'token': token,
            'role': role.toJson(),
            'school_id': schoolId,
            'specific_class_id': classId,
            'created_by_user_id': currentUserId,
            'usage_limit': usageLimit,
            'times_used': 0,
            'expires_at': expiresAt?.toIso8601String() ??
                DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          })
          .select('''
            token,
            role,
            school_id,
            specific_class_id,
            usage_limit,
            times_used,
            expires_at,
            created_at
          ''')
          .single();

      // Map invite_tokens schema to InviteCode entity
      final responseUsageLimit = response['usage_limit'] as int? ?? usageLimit;
      final responseTimesUsed = response['times_used'] as int? ?? 0;
      return InviteCode(
        id: response['token'] as String,
        code: response['token'] as String,
        role: UserRole.fromString(response['role'] as String?) ?? UserRole.student,
        schoolId: response['school_id'] as String,
        classId: response['specific_class_id'] as String?,
        usageLimit: responseUsageLimit,
        timesUsed: responseTimesUsed,
        isActive: responseTimesUsed < responseUsageLimit,
        expiresAt: response['expires_at'] != null
            ? DateTime.tryParse(response['expires_at'] as String)
            : null,
        createdAt: response['created_at'] != null
            ? DateTime.tryParse(response['created_at'] as String)
            : null,
      );
    } on PostgrestException catch (e) {
      throw PrincipalException('Failed to generate invite code: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to generate invite code: $e');
    }
  }

  @override
  Future<bool> deactivateInviteCode(String codeId) async {
    try {
      // In invite_tokens, codeId is the token itself (primary key)
      // To deactivate, we need to first get the usage_limit and set times_used to match it
      // This effectively exhausts all remaining uses
      final tokenResponse = await _supabase
          .from('invite_tokens')
          .select('usage_limit')
          .eq('token', codeId)
          .single();

      final usageLimit = tokenResponse['usage_limit'] as int? ?? 1;

      // Set times_used equal to usage_limit to deactivate the token
      await _supabase
          .from('invite_tokens')
          .update({'times_used': usageLimit}).eq('token', codeId);

      return true;
    } on PostgrestException catch (e) {
      throw PrincipalException(
          'Failed to deactivate invite code: ${e.message}');
    } catch (e) {
      if (e is PrincipalException) rethrow;
      throw PrincipalException('Failed to deactivate invite code: $e');
    }
  }

  /// Generates a cryptographically secure random alphanumeric code of the specified length.
  /// Uses 62 characters (uppercase, lowercase, digits) for maximum entropy.
  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
