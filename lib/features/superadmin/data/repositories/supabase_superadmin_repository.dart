import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../admin_panel/domain/entities/school.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/superadmin_repository.dart';

/// Exception thrown when superadmin operations fail.
class SuperAdminException extends RepositoryException {
  const SuperAdminException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'SuperAdminException: $message';
}

/// Supabase implementation of [SuperAdminRepository].
///
/// Provides superadmin functionality using Supabase as the data source.
/// This includes operations for managing schools, users, subscriptions,
/// and platform-wide statistics.
class SupabaseSuperAdminRepository implements SuperAdminRepository {
  /// Creates a [SupabaseSuperAdminRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseSuperAdminRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<School> createSchool(String name) async {
    try {
      final response = await _supabase
          .from('schools')
          .insert({
            'name': name,
            'subscription_status': SubscriptionStatus.trial.toJson(),
          })
          .select('id, name, created_at')
          .maybeSingle();

      if (response == null) {
        throw const SuperAdminException('Failed to create school: no data returned');
      }

      return School.fromJson(response);
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to create school: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to create school: ${e.toString()}');
    }
  }

  @override
  Future<List<SchoolWithStats>> getAllSchools() async {
    try {
      // Get all schools with their basic info
      final schoolsResponse = await _supabase
          .from('schools')
          .select('id, name, subscription_status, subscription_expires_at, created_at')
          .order('name', ascending: true);

      final schools = schoolsResponse as List;

      // Early return if no schools
      if (schools.isEmpty) {
        return [];
      }

      // Extract all school IDs for batch queries
      final schoolIds = schools.map((s) => s['id'] as String).toList();

      // BATCH QUERY 1: Get all user counts grouped by school
      final usersResponse = await _supabase
          .from('profiles')
          .select('school_id, role')
          .inFilter('school_id', schoolIds);

      // Build a map: schoolId -> {role -> count}
      final userCountsMap = <String, Map<String, int>>{};
      for (final user in usersResponse as List) {
        final schoolId = user['school_id'] as String;
        final role = user['role'] as String;
        userCountsMap.putIfAbsent(schoolId, () => {});
        userCountsMap[schoolId]![role] = (userCountsMap[schoolId]![role] ?? 0) + 1;
      }

      // BATCH QUERY 2: Get all class counts grouped by school
      final classesResponse = await _supabase
          .from('classes')
          .select('school_id')
          .inFilter('school_id', schoolIds);

      // Build a map: schoolId -> class count
      final classCountsMap = <String, int>{};
      for (final cls in classesResponse as List) {
        final schoolId = cls['school_id'] as String;
        classCountsMap[schoolId] = (classCountsMap[schoolId] ?? 0) + 1;
      }

      // Build the results using the pre-fetched data
      final schoolsWithStats = <SchoolWithStats>[];
      for (final schoolJson in schools) {
        final schoolId = schoolJson['id'] as String;

        // Get counts from maps (O(1) lookup instead of O(n) queries)
        final userCounts = userCountsMap[schoolId] ?? {};
        final totalStudents = userCounts['student'] ?? 0;
        final totalTeachers = userCounts['teacher'] ?? 0;
        final totalUsers = userCounts.values.fold<int>(0, (sum, count) => sum + count);
        final totalClasses = classCountsMap[schoolId] ?? 0;

        schoolsWithStats.add(SchoolWithStats(
          id: schoolId,
          name: schoolJson['name'] as String,
          subscriptionStatus:
              SubscriptionStatus.fromString(schoolJson['subscription_status'] as String?) ??
                  SubscriptionStatus.trial,
          totalUsers: totalUsers,
          totalClasses: totalClasses,
          totalStudents: totalStudents,
          totalTeachers: totalTeachers,
          createdAt: schoolJson['created_at'] != null
              ? DateTime.tryParse(schoolJson['created_at'] as String)
              : null,
          subscriptionExpiresAt: schoolJson['subscription_expires_at'] != null
              ? DateTime.tryParse(schoolJson['subscription_expires_at'] as String)
              : null,
        ));
      }

      return schoolsWithStats;
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch schools: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch schools: ${e.toString()}');
    }
  }

  @override
  Future<School> getSchool(String id) async {
    try {
      final response = await _supabase
          .from('schools')
          .select('id, name, created_at')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw SuperAdminException('School not found with id $id');
      }

      return School.fromJson(response);
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch school: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch school: ${e.toString()}');
    }
  }

  @override
  Future<SchoolWithStats> getSchoolWithStats(String schoolId) async {
    try {
      // Get school info
      final schoolResponse = await _supabase
          .from('schools')
          .select('id, name, subscription_status, subscription_expires_at, created_at')
          .eq('id', schoolId)
          .maybeSingle();

      if (schoolResponse == null) {
        throw SuperAdminException('School not found with id $schoolId');
      }

      // Get user counts
      final usersResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('school_id', schoolId);

      final users = usersResponse as List;
      final totalUsers = users.length;
      final totalStudents = users.where((u) => u['role'] == UserRole.student.name).length;
      final totalTeachers = users.where((u) => u['role'] == UserRole.teacher.name).length;

      // Get class count
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('school_id', schoolId);

      final totalClasses = (classesResponse as List).length;

      return SchoolWithStats(
        id: schoolResponse['id'] as String,
        name: schoolResponse['name'] as String,
        subscriptionStatus:
            SubscriptionStatus.fromString(schoolResponse['subscription_status'] as String?) ??
                SubscriptionStatus.trial,
        totalUsers: totalUsers,
        totalClasses: totalClasses,
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        createdAt: schoolResponse['created_at'] != null
            ? DateTime.tryParse(schoolResponse['created_at'] as String)
            : null,
        subscriptionExpiresAt: schoolResponse['subscription_expires_at'] != null
            ? DateTime.tryParse(schoolResponse['subscription_expires_at'] as String)
            : null,
      );
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch school details: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch school details: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSubscriptionStatus(
    String schoolId,
    SubscriptionStatus status,
  ) async {
    try {
      await _supabase
          .from('schools')
          .update({'subscription_status': status.toJson()})
          .eq('id', schoolId);
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to update subscription status: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to update subscription status: ${e.toString()}');
    }
  }

  @override
  Future<void> updateSubscription(
    String schoolId,
    SubscriptionStatus status,
    DateTime? expiresAt,
  ) async {
    try {
      await _supabase.from('schools').update({
        'subscription_status': status.toJson(),
        'subscription_expires_at': expiresAt?.toIso8601String(),
      }).eq('id', schoolId);
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to update subscription: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to update subscription: ${e.toString()}');
    }
  }

  @override
  Future<List<AppUser>> getSchoolBigAdmins(String schoolId) async {
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
          .eq('role', UserRole.bigadmin.name)
          .order('last_name', ascending: true);

      // Email may be null if not available - UI should handle this gracefully
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        return AppUser.fromJson(data);
      }).toList();
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch school admins: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch school admins: ${e.toString()}');
    }
  }

  @override
  Future<String> createPrincipalToken(String schoolId) async {
    try {
      // Generate a random 16-character alphanumeric token (cryptographically secure)
      final token = _generateRandomCode(16);

      // Get current user ID for created_by_user_id
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const SuperAdminException('Not authenticated');
      }

      await _supabase.from('invite_tokens').insert({
        'token': token,
        'role': UserRole.bigadmin.name,
        'school_id': schoolId,
        'created_by_user_id': currentUserId,
        'times_used': 0,
        'usage_limit': 1,
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      });

      return token;
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to create principal token: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to create principal token: ${e.toString()}');
    }
  }

  @override
  Future<PlatformStats> getPlatformStats() async {
    try {
      // Get all schools
      final schoolsResponse = await _supabase
          .from('schools')
          .select('subscription_status');

      final schools = schoolsResponse as List;
      final totalSchools = schools.length;
      final activeSubscriptions =
          schools.where((s) => s['subscription_status'] == 'active').length;
      final trialSubscriptions =
          schools.where((s) => s['subscription_status'] == 'trial').length;
      final expiredSubscriptions =
          schools.where((s) => s['subscription_status'] == 'expired').length;
      final suspendedSchools =
          schools.where((s) => s['subscription_status'] == 'suspended').length;

      // Get all users
      final usersResponse = await _supabase
          .from('profiles')
          .select('role');

      final users = usersResponse as List;
      final totalUsers = users.length;
      final totalStudents = users.where((u) => u['role'] == UserRole.student.name).length;
      final totalTeachers = users.where((u) => u['role'] == UserRole.teacher.name).length;

      // Get all classes
      final classesResponse = await _supabase
          .from('classes')
          .select('id');

      final totalClasses = (classesResponse as List).length;

      return PlatformStats(
        totalSchools: totalSchools,
        totalUsers: totalUsers,
        activeSubscriptions: activeSubscriptions,
        trialSubscriptions: trialSubscriptions,
        expiredSubscriptions: expiredSubscriptions,
        suspendedSchools: suspendedSchools,
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        totalClasses: totalClasses,
      );
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch platform stats: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch platform stats: ${e.toString()}');
    }
  }

  @override
  Future<void> suspendSchool(String schoolId) async {
    await updateSubscriptionStatus(schoolId, SubscriptionStatus.suspended);
  }

  @override
  Future<void> activateSchool(String schoolId) async {
    await updateSubscriptionStatus(schoolId, SubscriptionStatus.pro);
  }

  @override
  Future<bool> deleteSchool(String schoolId) async {
    try {
      // Delete the school (cascading deletes should handle related data)
      await _supabase.from('schools').delete().eq('id', schoolId);
      return true;
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to delete school: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to delete school: ${e.toString()}');
    }
  }

  @override
  Future<School> updateSchoolName(String schoolId, String newName) async {
    try {
      final response = await _supabase
          .from('schools')
          .update({'name': newName})
          .eq('id', schoolId)
          .select('id, name, created_at')
          .maybeSingle();

      if (response == null) {
        throw SuperAdminException('Failed to update school: school not found with id $schoolId');
      }

      return School.fromJson(response);
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to update school name: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to update school name: ${e.toString()}');
    }
  }

  @override
  Future<String?> getActivePrincipalToken(String schoolId) async {
    try {
      // Fetch tokens and filter for times_used < usage_limit in Dart
      final response = await _supabase
          .from('invite_tokens')
          .select('token, times_used, usage_limit')
          .eq('school_id', schoolId)
          .eq('role', UserRole.bigadmin.name)
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      // Find the first active token (times_used < usage_limit)
      for (final tokenData in response as List) {
        final timesUsed = tokenData['times_used'] as int;
        final usageLimit = tokenData['usage_limit'] as int;
        if (timesUsed < usageLimit) {
          return tokenData['token'] as String?;
        }
      }

      return null;
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to get principal token: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to get principal token: ${e.toString()}');
    }
  }

  @override
  Future<SchoolAnalytics> getSchoolAnalytics(String schoolId) async {
    try {
      // Get school info
      final schoolResponse = await _supabase
          .from('schools')
          .select('id, name')
          .eq('id', schoolId)
          .maybeSingle();

      if (schoolResponse == null) {
        throw SuperAdminException('School not found with id $schoolId');
      }

      // Get user counts by role
      final usersResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('school_id', schoolId);

      final users = usersResponse as List;
      final totalUsers = users.length;
      final totalStudents = users.where((u) => u['role'] == UserRole.student.name).length;
      final totalTeachers = users.where((u) => u['role'] == UserRole.teacher.name).length;
      final totalAdmins = users
          .where((u) => u['role'] == UserRole.bigadmin.name || u['role'] == UserRole.admin.name)
          .length;
      final totalParents = users.where((u) => u['role'] == UserRole.parent.name).length;

      // Get class count
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('school_id', schoolId);

      final totalClasses = (classesResponse as List).length;

      // Get subject count - subjects have school_id directly
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('school_id', schoolId);

      final totalSubjects = (subjectsResponse as List).length;

      return SchoolAnalytics(
        schoolId: schoolResponse['id'] as String,
        schoolName: schoolResponse['name'] as String,
        totalUsers: totalUsers,
        totalStudents: totalStudents,
        totalTeachers: totalTeachers,
        totalAdmins: totalAdmins,
        totalClasses: totalClasses,
        totalSubjects: totalSubjects,
        totalParents: totalParents,
      );
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch school analytics: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch school analytics: ${e.toString()}');
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
          .order('role', ascending: true)
          .order('last_name', ascending: true);

      // Email may be null if not available - UI should handle this gracefully
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        return AppUser.fromJson(data);
      }).toList();
    } on PostgrestException catch (e) {
      throw SuperAdminException('Failed to fetch school users: ${e.message}');
    } catch (e) {
      if (e is SuperAdminException) rethrow;
      throw SuperAdminException('Failed to fetch school users: ${e.toString()}');
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
