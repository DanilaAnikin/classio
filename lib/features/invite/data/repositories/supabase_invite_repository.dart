import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:classio/features/auth/domain/entities/app_user.dart';
import '../../domain/entities/invite_token.dart';
import '../../domain/repositories/invite_repository.dart';

/// Exception thrown when invite token operations fail.
class InviteException implements Exception {
  const InviteException(this.message);

  final String message;

  @override
  String toString() => 'InviteException: $message';
}

/// Supabase implementation of [InviteRepository].
///
/// Handles invite token generation and management using Supabase database.
/// Enforces hierarchical permission rules for token creation.
class SupabaseInviteRepository implements InviteRepository {
  /// Creates a [SupabaseInviteRepository] instance.
  SupabaseInviteRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Generates a cryptographically secure random token string.
  /// Uses 62 characters (uppercase, lowercase, digits) for maximum entropy.
  /// Generates a 16-character token for strong security.
  String _generateTokenString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    // Generate a 16-character token with high entropy (62^16 combinations)
    return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  bool canGenerateInviteFor(UserRole creatorRole, UserRole targetRole) {
    switch (creatorRole) {
      case UserRole.superadmin:
        return targetRole == UserRole.bigadmin;
      case UserRole.bigadmin:
        return [UserRole.admin, UserRole.teacher].contains(targetRole);
      case UserRole.admin:
        return [UserRole.teacher, UserRole.parent].contains(targetRole);
      case UserRole.teacher:
        return targetRole == UserRole.student;
      case UserRole.student:
      case UserRole.parent:
        return false;
    }
  }

  @override
  List<UserRole> getInvitableRoles(UserRole creatorRole) {
    switch (creatorRole) {
      case UserRole.superadmin:
        return [UserRole.bigadmin];
      case UserRole.bigadmin:
        return [UserRole.admin, UserRole.teacher];
      case UserRole.admin:
        return [UserRole.teacher, UserRole.parent];
      case UserRole.teacher:
        return [UserRole.student];
      case UserRole.student:
      case UserRole.parent:
        return [];
    }
  }

  @override
  Future<String> generateToken({
    required UserRole targetRole,
    required String schoolId,
    String? classId,
    DateTime? expiresAt,
  }) async {
    // Step 1: Verify user is authenticated
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const InviteException('Not authenticated');
    }

    // Step 2: Get current user's role from profile
    final UserRole creatorRole;
    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      final roleString = profileResponse['role'] as String?;
      final role = UserRole.fromString(roleString);
      if (role == null) {
        throw const InviteException('Invalid user role');
      }
      creatorRole = role;
    } on PostgrestException catch (e) {
      throw InviteException('Failed to get user profile: ${e.message}');
    }

    // Step 3: Validate hierarchical permission
    if (!canGenerateInviteFor(creatorRole, targetRole)) {
      throw InviteException(
        'You do not have permission to create invites for ${targetRole.name}s',
      );
    }

    // Step 4: For teachers creating student invites, class_id is REQUIRED
    if (creatorRole == UserRole.teacher && targetRole == UserRole.student) {
      if (classId == null || classId.isEmpty) {
        throw const InviteException(
          'Class ID is required when inviting students',
        );
      }

      // Verify teacher teaches this class (has at least one subject in the class)
      try {
        final teachesClass = await _supabase
            .from('subjects')
            .select('id')
            .eq('teacher_id', userId)
            .eq('class_id', classId)
            .limit(1);

        if (teachesClass.isEmpty) {
          throw const InviteException(
            'You do not teach any subjects in this class',
          );
        }
      } on PostgrestException catch (e) {
        throw InviteException('Failed to verify class assignment: ${e.message}');
      }
    }

    // Step 5: Generate unique token with retry pattern for race condition safety
    const maxAttempts = 5;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final token = _generateTokenString();

      try {
        // Attempt to insert the token directly - let the database handle uniqueness
        await _supabase.from('invite_tokens').insert({
          'token': token,
          'role': targetRole.name,
          'school_id': schoolId,
          'created_by_user_id': userId,
          'specific_class_id': classId,
          'times_used': 0,
          'usage_limit': 1,
          'expires_at': expiresAt?.toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });

        debugPrint('Invite token created: $token for role ${targetRole.name}');
        return token; // Success!
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          // Unique constraint violation - try again with new token
          debugPrint('Token collision on attempt $attempt, retrying...');
          continue;
        }
        // Other errors should propagate
        throw InviteException('Failed to create invite token: ${e.message}');
      }
    }

    throw InviteException('Failed to generate unique token after $maxAttempts attempts');
  }

  @override
  Future<List<InviteToken>> getMyCreatedTokens() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const InviteException('Not authenticated');
    }

    try {
      final response = await _supabase
          .from('invite_tokens')
          .select()
          .eq('created_by_user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InviteToken.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw InviteException('Failed to fetch tokens: ${e.message}');
    }
  }

  @override
  Future<List<InviteToken>> getSchoolTokens(String schoolId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const InviteException('Not authenticated');
    }

    // Verify user has admin privileges for this school
    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select('role, school_id')
          .eq('id', userId)
          .single();

      final roleString = profileResponse['role'] as String?;
      final userSchoolId = profileResponse['school_id'] as String?;
      final role = UserRole.fromString(roleString);

      // Check permissions
      final hasPermission = role == UserRole.superadmin ||
          (role == UserRole.bigadmin) ||
          (role == UserRole.admin && userSchoolId == schoolId);

      if (!hasPermission) {
        throw const InviteException(
          'You do not have permission to view school tokens',
        );
      }
    } on PostgrestException catch (e) {
      throw InviteException('Failed to verify permissions: ${e.message}');
    }

    try {
      final response = await _supabase
          .from('invite_tokens')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => InviteToken.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw InviteException('Failed to fetch school tokens: ${e.message}');
    }
  }

  @override
  Future<void> revokeToken(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const InviteException('Not authenticated');
    }

    try {
      // First, check if the token exists and user has permission
      final tokenResponse = await _supabase
          .from('invite_tokens')
          .select('created_by_user_id, school_id')
          .eq('token', token)
          .maybeSingle();

      if (tokenResponse == null) {
        throw const InviteException('Token not found');
      }

      // Check if user created the token or is an admin
      final createdBy = tokenResponse['created_by_user_id'] as String;
      final tokenSchoolId = tokenResponse['school_id'] as String;

      if (createdBy != userId) {
        // Check if user is admin
        final profileResponse = await _supabase
            .from('profiles')
            .select('role, school_id')
            .eq('id', userId)
            .single();

        final roleString = profileResponse['role'] as String?;
        final userSchoolId = profileResponse['school_id'] as String?;
        final role = UserRole.fromString(roleString);

        final hasPermission = role == UserRole.superadmin ||
            (role == UserRole.bigadmin) ||
            (role == UserRole.admin && userSchoolId == tokenSchoolId);

        if (!hasPermission) {
          throw const InviteException(
            'You do not have permission to revoke this token',
          );
        }
      }

      // Revoke the token by setting times_used to usage_limit
      // First get the current usage_limit
      final tokenData = await _supabase
          .from('invite_tokens')
          .select('usage_limit')
          .eq('token', token)
          .single();
      final usageLimit = tokenData['usage_limit'] as int;

      await _supabase
          .from('invite_tokens')
          .update({'times_used': usageLimit})
          .eq('token', token);

      debugPrint('Token revoked: $token');
    } on PostgrestException catch (e) {
      throw InviteException('Failed to revoke token: ${e.message}');
    }
  }

  @override
  Future<int> cleanupExpiredTokens(String schoolId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const InviteException('Not authenticated');
    }

    // Verify user has admin privileges
    try {
      final profileResponse = await _supabase
          .from('profiles')
          .select('role, school_id')
          .eq('id', userId)
          .single();

      final roleString = profileResponse['role'] as String?;
      final userSchoolId = profileResponse['school_id'] as String?;
      final role = UserRole.fromString(roleString);

      final hasPermission = role == UserRole.superadmin ||
          (role == UserRole.bigadmin) ||
          (role == UserRole.admin && userSchoolId == schoolId);

      if (!hasPermission) {
        throw const InviteException(
          'You do not have permission to cleanup school tokens',
        );
      }
    } on PostgrestException catch (e) {
      throw InviteException('Failed to verify permissions: ${e.message}');
    }

    try {
      // Get count of expired tokens first
      final expiredTokens = await _supabase
          .from('invite_tokens')
          .select('token')
          .eq('school_id', schoolId)
          .lt('expires_at', DateTime.now().toIso8601String());

      final count = (expiredTokens as List).length;

      if (count > 0) {
        // Delete expired tokens
        await _supabase
            .from('invite_tokens')
            .delete()
            .eq('school_id', schoolId)
            .lt('expires_at', DateTime.now().toIso8601String());

        debugPrint('Cleaned up $count expired tokens for school $schoolId');
      }

      return count;
    } on PostgrestException catch (e) {
      throw InviteException('Failed to cleanup tokens: ${e.message}');
    }
  }

  @override
  Future<InviteToken> validateToken(String token) async {
    try {
      // Fetch the token and check times_used < usage_limit in Dart
      final response = await _supabase
          .from('invite_tokens')
          .select()
          .eq('token', token)
          .single();

      final inviteToken = InviteToken.fromJson(response);

      // Check if token has reached its usage limit
      if (!inviteToken.isActive) {
        throw const InviteException('Token has reached its usage limit');
      }

      // Check if token has expired
      if (inviteToken.isExpired) {
        throw const InviteException('Token has expired');
      }

      return inviteToken;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // Not found - this is expected for invalid tokens
        throw const InviteException('Invalid or used token');
      }
      // Other database errors should be reported
      debugPrint('Database error validating token: ${e.message}');
      throw InviteException('Database error: ${e.message}');
    }
  }
}
