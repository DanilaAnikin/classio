import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/invite_code.dart';
import '../../domain/repositories/auth_repository.dart';

/// Exception thrown when authentication operations fail.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Supabase implementation of [AuthRepository].
///
/// Handles authentication using Supabase Auth service with invite code
/// registration flow.
class SupabaseAuthRepository implements AuthRepository {
  /// Creates a [SupabaseAuthRepository] instance.
  SupabaseAuthRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();
  StreamSubscription<AuthState>? _authSubscription;

  /// Initializes the repository and sets up auth state listener.
  void initialize() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        _authStateController.add(null);
      } else {
        _loadUserProfile(session.user.id);
      }
    });
  }

  /// Loads user profile from the database.
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select(
              'id, email, role, first_name, last_name, school_id, avatar_url, created_at')
          .eq('id', userId)
          .single();

      final user = AppUser.fromJson(response);
      _authStateController.add(user);
    } catch (e) {
      // If profile doesn't exist, create a basic user from auth data
      final authUser = _supabase.auth.currentUser;
      if (authUser != null) {
        final roleString = authUser.userMetadata?['role'] as String?;
        final role = UserRole.fromString(roleString) ?? UserRole.student;

        final user = AppUser(
          id: authUser.id,
          email: authUser.email ?? '',
          role: role,
          schoolId: authUser.userMetadata?['school_id'] as String?,
        );
        _authStateController.add(user);
      }
    }
  }

  @override
  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  @override
  Future<AppUser?> getCurrentUser() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return null;

    // Try to get full profile from database
    try {
      final response = await _supabase
          .from('profiles')
          .select(
              'id, email, role, first_name, last_name, school_id, avatar_url, created_at')
          .eq('id', authUser.id)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      // Fallback to metadata if profile not found
      final roleString = authUser.userMetadata?['role'] as String?;
      final role = UserRole.fromString(roleString) ?? UserRole.student;

      return AppUser(
        id: authUser.id,
        email: authUser.email ?? '',
        role: role,
        schoolId: authUser.userMetadata?['school_id'] as String?,
      );
    }
  }

  @override
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  @override
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign in failed: No user returned');
      }

      // Try to load full user profile from database
      try {
        final profileResponse = await _supabase
            .from('profiles')
            .select(
                'id, email, role, first_name, last_name, school_id, avatar_url, created_at')
            .eq('id', user.id)
            .single();

        return AppUser.fromJson(profileResponse);
      } catch (e) {
        // Fallback to basic user info from auth metadata
        final roleString = user.userMetadata?['role'] as String?;
        final role = UserRole.fromString(roleString) ?? UserRole.student;

        return AppUser(
          id: user.id,
          email: user.email ?? email,
          role: role,
          schoolId: user.userMetadata?['school_id'] as String?,
        );
      }
    } on AuthApiException catch (e) {
      throw AuthException('Sign in failed: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Signs up a new user with email, password, and invite code.
  ///
  /// The invite code is validated before registration. If valid, the user
  /// is created with the role and school_id from the invite code.
  ///
  /// Throws [AuthException] if:
  /// - The invite code is invalid or inactive
  /// - The invite code has expired
  /// - The invite code has reached its usage limit
  /// - Supabase auth registration fails
  ///
  /// Parameters:
  /// - [email]: The user's email address
  /// - [password]: The user's password
  /// - [inviteCode]: The invite code string to validate
  /// - [firstName]: Optional first name
  /// - [lastName]: Optional last name
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String inviteCode,
    String? firstName,
    String? lastName,
  }) async {
    // Step 1: Validate invite code
    final inviteData = await _validateInviteCode(inviteCode);

    try {
      // Step 2: Sign up user with Supabase Auth
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': inviteData.role.name,
          'school_id': inviteData.schoolId,
          'first_name': firstName,
          'last_name': lastName,
          if (inviteData.classId != null) 'class_id': inviteData.classId,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign up failed: No user returned');
      }

      // Profile is automatically created by database trigger (handle_new_user)
      // No manual insertion needed - the trigger extracts metadata from raw_user_meta_data
      debugPrint('User created - profile will be created by database trigger');

      // Optional: Verify profile was created by trigger
      await Future.delayed(const Duration(milliseconds: 300));
      final profileCheck = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (profileCheck == null) {
        debugPrint('Warning: Profile not found after trigger - this may indicate a trigger issue');
      }

      // Step 3: Decrement invite code usage
      await _decrementInviteCodeUsage(inviteData);

      // Step 4: If invite code has class_id, enroll student in class
      if (inviteData.classId != null &&
          inviteData.role == UserRole.student) {
        try {
          await _supabase.from('class_students').insert({
            'class_id': inviteData.classId,
            'student_id': user.id,
            'enrolled_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          // Class enrollment may fail due to RLS, but user registration
          // should still succeed. Admin can manually enroll later.
        }
      }

      return AppUser(
        id: user.id,
        email: email,
        role: inviteData.role,
        firstName: firstName,
        lastName: lastName,
        schoolId: inviteData.schoolId,
        createdAt: DateTime.now(),
      );
    } on AuthApiException catch (e) {
      throw AuthException('Sign up failed: ${e.message}');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Validates an invite code and returns the invite data if valid.
  ///
  /// Checks that the code:
  /// - Exists in the database
  /// - Is active (is_active = true)
  /// - Has not expired (expires_at is null or in the future)
  /// - Has remaining uses (times_used < usage_limit)
  Future<InviteCode> _validateInviteCode(String code) async {
    try {
      final response = await _supabase
          .from('invite_codes')
          .select()
          .eq('code', code)
          .eq('is_active', true)
          .single();

      final inviteCode = InviteCode.fromJson(response);

      // Check if code has expired
      if (inviteCode.expiresAt != null &&
          DateTime.now().isAfter(inviteCode.expiresAt!)) {
        throw const AuthException('Invalid Invite Code');
      }

      // Check if code has remaining uses
      if (inviteCode.timesUsed >= inviteCode.usageLimit) {
        throw const AuthException('Invalid Invite Code');
      }

      return inviteCode;
    } on PostgrestException catch (_) {
      throw const AuthException('Invalid Invite Code');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException('Invalid Invite Code');
    }
  }

  /// Decrements the usage count of an invite code.
  ///
  /// Updates `times_used` by incrementing it by 1.
  /// If `times_used >= usage_limit` after update, sets `is_active` to false.
  Future<void> _decrementInviteCodeUsage(InviteCode inviteCode) async {
    try {
      final newTimesUsed = inviteCode.timesUsed + 1;
      final shouldDeactivate = newTimesUsed >= inviteCode.usageLimit;

      await _supabase.from('invite_codes').update({
        'times_used': newTimesUsed,
        if (shouldDeactivate) 'is_active': false,
      }).eq('id', inviteCode.id);
    } catch (e) {
      // Log error but don't fail registration
      // The code usage update is not critical to user registration
    }
  }

  /// Signs up a new user with email and password (legacy method).
  ///
  /// This method is kept for backwards compatibility but [signUp] with
  /// invite code validation should be preferred.
  @Deprecated('Use signUp() with invite code validation instead')
  Future<AppUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
    String? schoolId,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role.name,
          'first_name': firstName,
          'last_name': lastName,
          'school_id': schoolId,
        },
      );

      final user = response.user;
      if (user == null) return null;

      // Create profile in database
      try {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': email,
          'role': role.name,
          'first_name': firstName,
          'last_name': lastName,
          'school_id': schoolId,
          'created_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Profile creation failed, but auth user was created
        // Continue with the auth user
      }

      return AppUser(
        id: user.id,
        email: email,
        role: role,
        firstName: firstName,
        lastName: lastName,
        schoolId: schoolId,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException('Sign out failed: ${e.message}');
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Signs out and returns a boolean indicating success.
  Future<bool> signOutWithResult() async {
    try {
      await signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sends a password reset email to the specified email address.
  Future<bool> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validates an invite code without using it.
  ///
  /// Returns the [InviteCode] if valid, throws [AuthException] otherwise.
  /// This can be used to show the role/school info before registration.
  Future<InviteCode> validateInviteCode(String code) async {
    return _validateInviteCode(code);
  }

  /// Disposes of resources.
  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }
}
