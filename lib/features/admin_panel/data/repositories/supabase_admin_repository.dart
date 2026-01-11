import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Default colors for subjects that don't have a specified color.
  static const List<Color> _subjectColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.pink,
    Colors.lime,
    Colors.brown,
  ];

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

      // Note: profiles table doesn't have email, we need to join or get it separately
      // For now, we'll use empty string for email and it should be populated from auth
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        // Add a placeholder email since profiles table might not have it directly
        data['email'] = data['email'] ?? '${data['id']}@placeholder.com';
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
      // Generate a random 8-character alphanumeric code
      final code = _generateRandomCode(8);

      final response = await _supabase
          .from('invite_codes')
          .insert({
            'code': code,
            'role': role.toJson(),
            'school_id': schoolId,
            'class_id': classId,
            'usage_limit': usageLimit,
            'times_used': 0,
            'is_active': true,
            'expires_at': expiresAt?.toIso8601String(),
          })
          .select('''
            id,
            code,
            role,
            school_id,
            class_id,
            usage_limit,
            times_used,
            is_active,
            expires_at,
            created_at
          ''')
          .single();

      return InviteCode.fromJson(response);
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
        final color = _subjectColors[colorIndex % _subjectColors.length];
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
          .from('invite_codes')
          .select('''
            id,
            code,
            role,
            school_id,
            class_id,
            usage_limit,
            times_used,
            is_active,
            expires_at,
            created_at
          ''')
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InviteCode.fromJson(json as Map<String, dynamic>))
          .toList();
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
      final response = await _supabase
          .from('invite_codes')
          .update({'is_active': false})
          .eq('id', codeId)
          .select('''
            id,
            code,
            role,
            school_id,
            class_id,
            usage_limit,
            times_used,
            is_active,
            expires_at,
            created_at
          ''')
          .single();

      return InviteCode.fromJson(response);
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

      response['email'] = response['email'] ?? '${response['id']}@placeholder.com';
      return AppUser.fromJson(response);
    } on PostgrestException catch (e) {
      throw AdminException('Failed to update user role: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to update user role: ${e.toString()}');
    }
  }

  /// Generates a random alphanumeric code of the specified length.
  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
