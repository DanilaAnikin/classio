import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/entities/app_user.dart';
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
/// Provides admin functionality using Supabase as the data source.
/// This includes operations for managing schools, users, classes,
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
  Future<List<SchoolEntity>> getSchools() async {
    try {
      final response = await _supabase
          .from('schools')
          .select('id, name, created_at')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => SchoolEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AdminException('Failed to fetch schools: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch schools: ${e.toString()}');
    }
  }

  @override
  Future<SchoolEntity> createSchool(String name) async {
    try {
      final response = await _supabase
          .from('schools')
          .insert({'name': name})
          .select('id, name, created_at')
          .single();

      return SchoolEntity.fromJson(response);
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
      // For now, we'll use a placeholder email
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
  Future<List<ClassEntity>> getSchoolClasses(String schoolId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .eq('school_id', schoolId)
          .order('grade_level', ascending: true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ClassEntity.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AdminException('Failed to fetch school classes: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to fetch school classes: ${e.toString()}');
    }
  }

  @override
  Future<ClassEntity> createClass({
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

      return ClassEntity.fromJson(response);
    } on PostgrestException catch (e) {
      throw AdminException('Failed to create class: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to create class: ${e.toString()}');
    }
  }

  @override
  Future<String> createInviteCode({
    required String schoolId,
    required String role,
    String? classId,
    int usageLimit = 1,
    DateTime? expiresAt,
  }) async {
    try {
      // Generate a random 8-character alphanumeric code
      final code = _generateRandomCode(8);

      await _supabase.from('invite_codes').insert({
        'code': code,
        'role': role,
        'school_id': schoolId,
        'class_id': classId,
        'usage_limit': usageLimit,
        'times_used': 0,
        'is_active': true,
        'expires_at': expiresAt?.toIso8601String(),
      });

      return code;
    } on PostgrestException catch (e) {
      throw AdminException('Failed to generate invite code: ${e.message}');
    } catch (e) {
      if (e is AdminException) rethrow;
      throw AdminException('Failed to generate invite code: ${e.toString()}');
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
