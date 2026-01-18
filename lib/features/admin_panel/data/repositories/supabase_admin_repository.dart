import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/subject_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/admin_repository.dart';

/// Exception thrown when admin operations fail.
class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => 'AdminException: $message';
}

/// Supabase implementation of [AdminRepository].
///
/// Provides admin panel functionality using Supabase as the data source.
/// This includes operations for managing schools, users, classes, subjects,
/// and invite codes.
class SupabaseAdminRepository implements AdminRepository {
  /// Creates a [SupabaseAdminRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseAdminRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<List<School>> getSchools() async {
    try {
      final response = await _supabase
          .from('schools')
          .select('id, name, created_at')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => School.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AdminException('Failed to fetch schools: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch schools: ${e.toString()}');
    }
  }

  @override
  Future<School> createSchool(String name) async {
    try {
      final response = await _supabase
          .from('schools')
          .insert({'name': name})
          .select('id, name, created_at')
          .single();

      return School.fromJson(response);
    } on PostgrestException catch (e) {
      throw AdminException('Failed to create school: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to create school: ${e.toString()}');
    }
  }

  @override
  Future<List<AppUser>> getSchoolUsers(String schoolId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('''
            id,
            school_id,
            role,
            first_name,
            last_name,
            avatar_url,
            created_at
          ''')
          .eq('school_id', schoolId)
          .order('last_name', ascending: true);

      // Note: profiles table doesn't have email directly accessible
      // Email will be null if not available - UI should handle this gracefully
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        return AppUser.fromJson(data);
      }).toList();
    } on PostgrestException catch (e) {
      throw AdminException('Failed to fetch school users: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch school users: ${e.toString()}');
    }
  }

  @override
  Future<List<ClassInfo>> getSchoolClasses(String schoolId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .eq('school_id', schoolId)
          .order('grade_level', ascending: true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ClassInfo.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AdminException('Failed to fetch school classes: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch school classes: ${e.toString()}');
    }
  }

  @override
  Future<ClassInfo> createClass({
    required String schoolId,
    required String name,
    required int gradeLevel,
    required String academicYear,
  }) async {
    try {
      final response = await _supabase
          .from('classes')
          .insert({
            'school_id': schoolId,
            'name': name,
            'grade_level': gradeLevel,
            'academic_year': academicYear,
          })
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .single();

      return ClassInfo.fromJson(response);
    } on PostgrestException catch (e) {
      throw AdminException('Failed to create class: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to create class: ${e.toString()}');
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
            'times_used': 0,
            'usage_limit': usageLimit,
            'expires_at': expiresAt?.toIso8601String() ??
                DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          })
          .select('''
            token,
            role,
            school_id,
            specific_class_id,
            times_used,
            usage_limit,
            expires_at,
            created_at
          ''')
          .single();

      // Map invite_tokens schema to InviteCode entity
      final timesUsed = response['times_used'] as int;
      final responseUsageLimit = response['usage_limit'] as int;
      return InviteCode(
        id: response['token'] as String,
        code: response['token'] as String,
        role: UserRole.fromString(response['role'] as String?) ?? UserRole.student,
        schoolId: response['school_id'] as String,
        classId: response['specific_class_id'] as String?,
        usageLimit: responseUsageLimit,
        timesUsed: timesUsed,
        isActive: timesUsed < responseUsageLimit,
        expiresAt: response['expires_at'] != null
            ? DateTime.tryParse(response['expires_at'] as String)
            : null,
        createdAt: response['created_at'] != null
            ? DateTime.tryParse(response['created_at'] as String)
            : null,
      );
    } on PostgrestException catch (e) {
      throw AdminException('Failed to generate invite code: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to generate invite code: ${e.toString()}');
    }
  }

  @override
  Future<List<Subject>> getTeacherSubjects(String teacherId) async {
    try {
      final response = await _supabase
          .from('subjects')
          .select('id, name, description, teacher_id')
          .eq('teacher_id', teacherId)
          .order('name', ascending: true);

      var colorIndex = 0;
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final color = SubjectColors.getColorForIndex(colorIndex);
        colorIndex++;

        return Subject(
          id: data['id'] as String,
          name: data['name'] as String,
          color: color,
          teacherName: null, // Teacher is the current user
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw AdminException('Failed to fetch teacher subjects: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch teacher subjects: ${e.toString()}');
    }
  }

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
            times_used,
            usage_limit,
            expires_at,
            created_at
          ''')
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      // Map invite_tokens schema to InviteCode entities
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final timesUsed = data['times_used'] as int;
        final usageLimit = data['usage_limit'] as int;
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
      throw AdminException('Failed to fetch invite codes: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch invite codes: ${e.toString()}');
    }
  }

  @override
  Future<InviteCode> deactivateInviteCode(String codeId) async {
    try {
      // In invite_tokens, codeId is the token itself (primary key)
      // First get the usage_limit to set times_used equal to it
      final tokenData = await _supabase
          .from('invite_tokens')
          .select('usage_limit')
          .eq('token', codeId)
          .single();
      final usageLimit = tokenData['usage_limit'] as int;

      // Deactivate by setting times_used to usage_limit
      final response = await _supabase
          .from('invite_tokens')
          .update({'times_used': usageLimit})
          .eq('token', codeId)
          .select('''
            token,
            role,
            school_id,
            specific_class_id,
            times_used,
            usage_limit,
            expires_at,
            created_at
          ''')
          .single();

      // Map invite_tokens schema to InviteCode entity
      final timesUsed = response['times_used'] as int;
      final responseUsageLimit = response['usage_limit'] as int;
      return InviteCode(
        id: response['token'] as String,
        code: response['token'] as String,
        role: UserRole.fromString(response['role'] as String?) ?? UserRole.student,
        schoolId: response['school_id'] as String,
        classId: response['specific_class_id'] as String?,
        usageLimit: responseUsageLimit,
        timesUsed: timesUsed,
        isActive: timesUsed < responseUsageLimit,
        expiresAt: response['expires_at'] != null
            ? DateTime.tryParse(response['expires_at'] as String)
            : null,
        createdAt: response['created_at'] != null
            ? DateTime.tryParse(response['created_at'] as String)
            : null,
      );
    } on PostgrestException catch (e) {
      throw AdminException('Failed to deactivate invite code: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to deactivate invite code: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteClass(String classId) async {
    try {
      await _supabase.from('classes').delete().eq('id', classId);
      return true;
    } on PostgrestException catch (e) {
      throw AdminException('Failed to delete class: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to delete class: ${e.toString()}');
    }
  }

  @override
  Future<AppUser> updateUserRole(String userId, UserRole newRole) async {
    try {
      final response = await _supabase
          .from('profiles')
          .update({'role': newRole.toJson()})
          .eq('id', userId)
          .select('''
            id,
            school_id,
            role,
            first_name,
            last_name,
            avatar_url,
            created_at
          ''')
          .single();

      // Email may be null if not available - UI should handle this gracefully
      return AppUser.fromJson(response);
    } on PostgrestException catch (e) {
      throw AdminException('Failed to update user role: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to update user role: ${e.toString()}');
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
