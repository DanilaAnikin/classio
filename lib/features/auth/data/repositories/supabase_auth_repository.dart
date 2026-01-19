import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../invite/domain/entities/invite_token.dart';

/// Exception thrown when authentication operations fail.
class AuthException extends RepositoryException {
  const AuthException(super.message, {super.code, super.originalError});

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

  /// Validates email format using a standard email regex pattern.
  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    // RFC 5322 compliant email regex (simplified version)
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength and returns an error message if invalid.
  ///
  /// Password requirements:
  /// - Minimum 12 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character (!@#$%^&*(),.?":{}|<>)
  ///
  /// Returns null if password is valid, otherwise returns an error message.
  String? _validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 12) {
      return 'Password must be at least 12 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
    }
    return null; // Password is valid
  }

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
          .maybeSingle();

      if (response == null) {
        throw Exception('Profile not found for user: $userId');
      }

      final user = AppUser.fromJson(response);
      _authStateController.add(user);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error loading user profile for $userId: $e');
        debugPrint('$stackTrace');
      }
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
          .maybeSingle();

      if (response == null) {
        throw Exception('Profile not found for user: ${authUser.id}');
      }

      return AppUser.fromJson(response);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error fetching current user profile: $e');
        debugPrint('$stackTrace');
      }
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
    // Input validation
    if (!_isValidEmail(email)) {
      throw const AuthException('Invalid email format');
    }
    final passwordError = _validatePasswordStrength(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }

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
            .maybeSingle();

        if (profileResponse == null) {
          throw Exception('Profile not found for user: ${user.id}');
        }

        return AppUser.fromJson(profileResponse);
      } catch (e, stackTrace) {
        if (kDebugMode) {
          debugPrint('Error loading profile after sign in: $e');
          debugPrint('$stackTrace');
        }
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
      if (kDebugMode) {
        debugPrint('AuthApiException during sign in: ${e.message}');
      }
      throw AuthException('Sign in failed: ${e.message}');
    } catch (e, stackTrace) {
      if (e is AuthException) rethrow;
      if (kDebugMode) {
        debugPrint('Unexpected error during sign in: $e');
        debugPrint('$stackTrace');
      }
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
    // Input validation
    if (!_isValidEmail(email)) {
      throw const AuthException('Invalid email format');
    }
    final passwordError = _validatePasswordStrength(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }
    if (inviteCode.isEmpty) {
      throw const AuthException('Invite code cannot be empty');
    }

    // Step 1: Validate invite token (uses invite_tokens or parent_invites table)
    final tokenData = await _validateInviteToken(inviteCode);

    // Check if this is a parent invite (P- prefix)
    // For parent invites, specificClassId contains student_id, not class_id
    final isParentInvite = inviteCode.startsWith('P-');

    try {
      // Step 2: Sign up user with Supabase Auth
      // Include the invite_token in metadata for the database trigger
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': tokenData.role.name,
          'school_id': tokenData.schoolId,
          'first_name': firstName,
          'last_name': lastName,
          'invite_token': inviteCode,
          // Only include class_id for student invites, not parent invites
          // (for parent invites, specificClassId contains student_id)
          if (tokenData.specificClassId != null && !isParentInvite)
            'class_id': tokenData.specificClassId,
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

      // Step 3: Mark invite token as used
      // For parent invites, this also creates the parent-student link
      await _markInviteTokenAsUsed(inviteCode);

      // Step 4: Handle role-specific post-registration tasks
      // For students: If invite token has class_id, enroll student in class
      // For parents: specificClassId contains student_id (linking handled in _markParentInviteAsUsed)
      if (tokenData.specificClassId != null &&
          tokenData.role == UserRole.student) {
        try {
          await _supabase.from('class_students').insert({
            'class_id': tokenData.specificClassId,
            'student_id': user.id,
            'enrolled_at': DateTime.now().toIso8601String(),
          });
        } catch (e, stackTrace) {
          // Class enrollment may fail due to RLS, but user registration
          // should still succeed. Admin can manually enroll later.
          if (kDebugMode) {
            debugPrint('Class enrollment failed (may be handled by admin): $e');
            debugPrint('$stackTrace');
          }
        }
      }

      return AppUser(
        id: user.id,
        email: email,
        role: tokenData.role,
        firstName: firstName,
        lastName: lastName,
        schoolId: tokenData.schoolId,
        createdAt: DateTime.now(),
      );
    } on AuthApiException catch (e) {
      if (kDebugMode) {
        debugPrint('AuthApiException during sign up: ${e.message}');
      }
      throw AuthException('Sign up failed: ${e.message}');
    } catch (e, stackTrace) {
      if (e is AuthException) rethrow;
      if (kDebugMode) {
        debugPrint('Unexpected error during sign up: $e');
        debugPrint('$stackTrace');
      }
      throw AuthException('Sign up failed: ${e.toString()}');
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
      } catch (e, stackTrace) {
        // Profile creation failed, but auth user was created
        // Continue with the auth user
        if (kDebugMode) {
          debugPrint('Error creating profile for legacy signUp: $e');
          debugPrint('$stackTrace');
        }
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in legacy signUpWithEmailAndPassword: $e');
        debugPrint('$stackTrace');
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthApiException catch (e) {
      if (kDebugMode) {
        debugPrint('AuthApiException during sign out: ${e.message}');
      }
      throw AuthException('Sign out failed: ${e.message}');
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Unexpected error during sign out: $e');
        debugPrint('$stackTrace');
      }
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Signs out and returns a boolean indicating success.
  Future<bool> signOutWithResult() async {
    try {
      await signOut();
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error in signOutWithResult: $e');
        debugPrint('$stackTrace');
      }
      return false;
    }
  }

  /// Sends a password reset email to the specified email address.
  Future<bool> resetPassword({required String email}) async {
    // Input validation
    if (!_isValidEmail(email)) {
      throw const AuthException('Invalid email format');
    }

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error sending password reset email: $e');
      }
      return false;
    }
  }

  /// Validates an invite token without using it.
  ///
  /// Returns the [InviteToken] if valid, throws [AuthException] otherwise.
  /// This can be used to show the role/school info before registration.
  Future<InviteToken> validateInviteCode(String code) async {
    return _validateInviteToken(code);
  }

  /// Disposes of resources.
  void dispose() {
    _authSubscription?.cancel();
    _authStateController.close();
  }

  // ==========================================
  // INVITE TOKEN SUPPORT (New Single-Use Tokens)
  // ==========================================

  /// Signs up a new user with an invite token (new single-use token system).
  ///
  /// This method uses the new invite_tokens table which supports:
  /// - Single-use tokens (each token can only be used once)
  /// - Hierarchical permission enforcement
  /// - Optional class assignment for students
  ///
  /// Throws [AuthException] if:
  /// - The invite token is invalid, used, or expired
  /// - Supabase auth registration fails
  ///
  /// Parameters:
  /// - [email]: The user's email address
  /// - [password]: The user's password
  /// - [inviteToken]: The invite token string to validate
  /// - [firstName]: Optional first name
  /// - [lastName]: Optional last name
  Future<AppUser> signUpWithInviteToken({
    required String email,
    required String password,
    required String inviteToken,
    String? firstName,
    String? lastName,
  }) async {
    // Input validation
    if (!_isValidEmail(email)) {
      throw const AuthException('Invalid email format');
    }
    final passwordError = _validatePasswordStrength(password);
    if (passwordError != null) {
      throw AuthException(passwordError);
    }
    if (inviteToken.isEmpty) {
      throw const AuthException('Invite token cannot be empty');
    }

    // Step 1: Validate invite token (uses invite_tokens or parent_invites table)
    final tokenData = await _validateInviteToken(inviteToken);

    // Check if this is a parent invite (P- prefix)
    // For parent invites, specificClassId contains student_id, not class_id
    final isParentInvite = inviteToken.startsWith('P-');

    try {
      // Step 2: Sign up user with Supabase Auth
      // Include the invite_token in metadata for the database trigger
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': tokenData.role.name,
          'school_id': tokenData.schoolId,
          'first_name': firstName,
          'last_name': lastName,
          'invite_token': inviteToken,
          // Only include class_id for student invites, not parent invites
          // (for parent invites, specificClassId contains student_id)
          if (tokenData.specificClassId != null && !isParentInvite)
            'class_id': tokenData.specificClassId,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Sign up failed: No user returned');
      }

      // Profile is automatically created by database trigger (handle_new_user)
      debugPrint('User created with invite token - profile will be created by database trigger');

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

      // Step 3: Mark invite token as used
      // For parent invites, this also creates the parent-student link
      await _markInviteTokenAsUsed(inviteToken);

      // Step 4: Handle role-specific post-registration tasks
      // For students: If invite token has class_id, enroll student in class
      // For parents: specificClassId contains student_id (linking handled in _markParentInviteAsUsed)
      if (tokenData.specificClassId != null &&
          tokenData.role == UserRole.student) {
        try {
          await _supabase.from('class_students').insert({
            'class_id': tokenData.specificClassId,
            'student_id': user.id,
            'enrolled_at': DateTime.now().toIso8601String(),
          });
        } catch (e, stackTrace) {
          // Class enrollment may fail due to RLS, but user registration
          // should still succeed. Admin can manually enroll later.
          if (kDebugMode) {
            debugPrint('Class enrollment failed (may be handled by admin): $e');
            debugPrint('$stackTrace');
          }
        }
      }

      return AppUser(
        id: user.id,
        email: email,
        role: tokenData.role,
        firstName: firstName,
        lastName: lastName,
        schoolId: tokenData.schoolId,
        createdAt: DateTime.now(),
      );
    } on AuthApiException catch (e) {
      if (kDebugMode) {
        debugPrint('AuthApiException during sign up: ${e.message}');
      }
      throw AuthException('Sign up failed: ${e.message}');
    } catch (e, stackTrace) {
      if (e is AuthException) rethrow;
      if (kDebugMode) {
        debugPrint('Unexpected error during sign up: $e');
        debugPrint('$stackTrace');
      }
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Validates an invite token and returns the token data if valid.
  ///
  /// Checks that the token:
  /// - Exists in the invite_tokens table (or parent_invites for P- prefixed codes)
  /// - Has not reached its usage limit (times_used < usage_limit)
  /// - Has not expired (expires_at is null or in the future)
  Future<InviteToken> _validateInviteToken(String token) async {
    if (kDebugMode) {
      debugPrint('Validating invite token');
    }

    // Check if this is a parent invite code (prefixed with P-)
    // Parent invite codes are stored in parent_invites table, not invite_tokens
    if (token.startsWith('P-')) {
      return _validateParentInviteToken(token);
    }

    try {
      // Fetch the token and check times_used < usage_limit in Dart
      final response = await _supabase
          .from('invite_tokens')
          .select()
          .eq('token', token)
          .maybeSingle();

      if (response == null) {
        if (kDebugMode) {
          debugPrint('Token not found in invite_tokens table');
        }
        throw const AuthException('Invalid Invite Token');
      }

      final inviteToken = InviteToken.fromJson(response);
      if (kDebugMode) {
        debugPrint('Parsed token: role=${inviteToken.role}, schoolId=${inviteToken.schoolId}');
      }

      // Check if token has reached its usage limit
      if (!inviteToken.isActive) {
        if (kDebugMode) {
          debugPrint('Token has reached its usage limit: ${inviteToken.timesUsed}/${inviteToken.usageLimit}');
        }
        throw const AuthException('Invalid Invite Token');
      }

      // Check if token has expired
      if (inviteToken.expiresAt != null &&
          DateTime.now().isAfter(inviteToken.expiresAt!)) {
        if (kDebugMode) {
          debugPrint('Token expired: ${inviteToken.expiresAt}');
        }
        throw const AuthException('Invalid Invite Token');
      }

      if (kDebugMode) {
        debugPrint('Token validated successfully');
      }
      return inviteToken;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('PostgrestException: ${e.message}, code: ${e.code}');
      }
      throw const AuthException('Invalid Invite Token');
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Exception validating invite token: $e');
        debugPrint('$stackTrace');
      }
      throw const AuthException('Invalid Invite Token');
    }
  }

  /// Validates a parent invite code (P- prefixed) from the parent_invites table.
  ///
  /// Parent invite codes are used to link an existing parent to a student,
  /// not for general user registration. This method converts parent invite data
  /// to an InviteToken for consistent handling in the registration flow.
  Future<InviteToken> _validateParentInviteToken(String code) async {
    if (kDebugMode) {
      debugPrint('Validating parent invite code');
    }

    try {
      final response = await _supabase
          .from('parent_invites')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (response == null) {
        if (kDebugMode) {
          debugPrint('Parent invite code not found');
        }
        throw const AuthException('Invalid Invite Token');
      }

      final timesUsed = response['times_used'] as int? ?? 0;
      final usageLimit = response['usage_limit'] as int? ?? 1;
      final expiresAtStr = response['expires_at'] as String?;
      final createdAtStr = response['created_at'] as String?;

      DateTime? expiresAt;
      if (expiresAtStr != null) {
        try {
          expiresAt = DateTime.parse(expiresAtStr);
        } catch (_) {}
      }

      DateTime createdAt = DateTime.now();
      if (createdAtStr != null) {
        try {
          createdAt = DateTime.parse(createdAtStr);
        } catch (_) {}
      }

      // Check if invite has reached its usage limit
      if (timesUsed >= usageLimit) {
        if (kDebugMode) {
          debugPrint('Parent invite has reached its usage limit: $timesUsed/$usageLimit');
        }
        throw const AuthException('Invalid Invite Token');
      }

      // Check if invite has expired
      if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
        if (kDebugMode) {
          debugPrint('Parent invite expired: $expiresAt');
        }
        throw const AuthException('Invalid Invite Token');
      }

      // Convert parent invite to InviteToken format
      // Parent invites always create users with the 'parent' role
      final studentId = response['student_id'] as String?;
      final inviteToken = InviteToken(
        token: code,
        role: UserRole.parent,
        schoolId: response['school_id'] as String?,
        createdByUserId: response['created_by'] as String?,
        timesUsed: timesUsed,
        usageLimit: usageLimit,
        createdAt: createdAt,
        expiresAt: expiresAt,
        // Store student_id in specificClassId field for later use in linking
        specificClassId: studentId,
      );

      if (kDebugMode) {
        debugPrint('Parent invite validated successfully:');
        debugPrint('  - role: parent');
        debugPrint('  - schoolId: ${inviteToken.schoolId}');
        debugPrint('  - studentId: $studentId');
      }
      return inviteToken;
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('PostgrestException validating parent invite: ${e.message}, code: ${e.code}');
      }
      throw const AuthException('Invalid Invite Token');
    } on AuthException {
      rethrow;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Exception validating parent invite: $e');
        debugPrint('$stackTrace');
      }
      throw const AuthException('Invalid Invite Token');
    }
  }

  /// Marks an invite token as used by incrementing times_used.
  ///
  /// Handles both regular invite tokens and parent invite codes (P- prefix).
  Future<void> _markInviteTokenAsUsed(String token) async {
    try {
      // Check if this is a parent invite code
      if (token.startsWith('P-')) {
        await _markParentInviteAsUsed(token);
        return;
      }

      // First get current times_used value for regular invite tokens
      final tokenData = await _supabase
          .from('invite_tokens')
          .select('times_used')
          .eq('token', token)
          .maybeSingle();

      if (tokenData == null) {
        if (kDebugMode) {
          debugPrint('Token not found when marking as used: $token');
        }
        return;
      }

      final currentTimesUsed = tokenData['times_used'] as int;

      // Increment times_used by 1
      await _supabase.from('invite_tokens').update({
        'times_used': currentTimesUsed + 1,
      }).eq('token', token);
    } catch (e, stackTrace) {
      // Log error but don't fail registration
      // The token usage update is not critical to user registration
      if (kDebugMode) {
        debugPrint('Failed to mark invite token as used: $e');
        debugPrint('$stackTrace');
      }
    }
  }

  /// Marks a parent invite code as used and links the parent to the student.
  ///
  /// Uses the `use_parent_invite` RPC function which runs as SECURITY DEFINER
  /// to bypass RLS policies. This is necessary because:
  /// 1. The newly registered parent user is not an admin
  /// 2. RLS policies on parent_student table require admin privileges
  /// 3. RLS policies on parent_invites table may not allow updates from parents
  ///
  /// If the primary RPC fails, it tries a fallback RPC function.
  Future<void> _markParentInviteAsUsed(String code) async {
    debugPrint('========================================');
    debugPrint('PARENT INVITE LINKING - START');
    debugPrint('========================================');
    debugPrint('Invite code: $code');

    try {
      final userId = _supabase.auth.currentUser?.id;
      debugPrint('Current user ID: $userId');

      if (userId == null) {
        debugPrint('ERROR: No current user when marking parent invite as used');
        debugPrint('Waiting for session to be established...');
        // Wait a bit for the session to be established after signup
        await Future.delayed(const Duration(milliseconds: 500));
        final retryUserId = _supabase.auth.currentUser?.id;
        debugPrint('Retry user ID after delay: $retryUserId');
        if (retryUserId == null) {
          debugPrint('FATAL: Still no user after waiting');
          return;
        }
      }

      final finalUserId = _supabase.auth.currentUser?.id;
      debugPrint('Final user ID for linking: $finalUserId');

      debugPrint('Calling use_parent_invite RPC...');
      debugPrint('  - p_code: $code');
      debugPrint('  - p_parent_id: $finalUserId');

      // Use the SECURITY DEFINER function to:
      // 1. Validate the invite code
      // 2. Increment times_used
      // 3. Set parent_id and used_at
      // 4. Create the parent_student relationship
      // This bypasses RLS which would otherwise block the parent from inserting
      final response = await _supabase.rpc(
        'use_parent_invite',
        params: {
          'p_code': code,
          'p_parent_id': finalUserId,
        },
      );

      debugPrint('use_parent_invite RPC response:');
      debugPrint('  - Type: ${response.runtimeType}');
      debugPrint('  - Value: $response');

      bool success = false;
      String? message;
      String? studentId;

      // Handle different response formats from Supabase RPC
      if (response != null) {
        if (response is List && response.isNotEmpty) {
          debugPrint('Response is a non-empty List');
          final result = response[0] as Map<String, dynamic>;
          success = result['success'] as bool? ?? false;
          message = result['message'] as String?;
          studentId = result['student_id'] as String?;
          debugPrint('  - Parsed success: $success');
          debugPrint('  - Parsed message: $message');
          debugPrint('  - Parsed studentId: $studentId');
        } else if (response is List && response.isEmpty) {
          debugPrint('Response is an EMPTY List - RPC may have failed silently');
        } else if (response is Map<String, dynamic>) {
          debugPrint('Response is a Map');
          success = response['success'] as bool? ?? false;
          message = response['message'] as String?;
          studentId = response['student_id'] as String?;
          debugPrint('  - Parsed success: $success');
          debugPrint('  - Parsed message: $message');
          debugPrint('  - Parsed studentId: $studentId');
        } else {
          debugPrint('Response is unexpected type: ${response.runtimeType}');
        }
      } else {
        debugPrint('Response is NULL - RPC returned nothing');
      }

      if (success) {
        debugPrint('SUCCESS: Linked parent $finalUserId to student $studentId');
        debugPrint('========================================');
        debugPrint('PARENT INVITE LINKING - COMPLETE');
        debugPrint('========================================');
        return;
      }

      debugPrint('use_parent_invite RPC failed or returned no success');
      debugPrint('Message: $message');
      debugPrint('Trying fallback function...');

      // Try fallback function that uses current user context
      await _linkParentToStudentFallback(code);
    } catch (e, stackTrace) {
      debugPrint('EXCEPTION in _markParentInviteAsUsed:');
      debugPrint('  - Error: $e');
      debugPrint('  - Stack: $stackTrace');
      debugPrint('Trying fallback function...');
      // Try fallback even if the primary call threw an exception
      await _linkParentToStudentFallback(code);
    }

    debugPrint('========================================');
    debugPrint('PARENT INVITE LINKING - END');
    debugPrint('========================================');
  }

  /// Fallback method to link parent to student using a simpler RPC function.
  ///
  /// This function uses the current authenticated user context and only requires
  /// the invite code. It serves as a backup if use_parent_invite fails.
  Future<void> _linkParentToStudentFallback(String code) async {
    debugPrint('');
    debugPrint('FALLBACK: Attempting link_parent_to_student_from_invite');
    debugPrint('  - p_invite_code: $code');

    try {
      final response = await _supabase.rpc(
        'link_parent_to_student_from_invite',
        params: {'p_invite_code': code},
      );

      debugPrint('Fallback RPC response:');
      debugPrint('  - Type: ${response.runtimeType}');
      debugPrint('  - Value: $response');

      bool success = false;
      String? message;
      String? studentId;

      if (response != null) {
        if (response is List && response.isNotEmpty) {
          debugPrint('Fallback response is a non-empty List');
          final result = response[0] as Map<String, dynamic>;
          success = result['success'] as bool? ?? false;
          message = result['message'] as String?;
          studentId = result['student_id'] as String?;
        } else if (response is List && response.isEmpty) {
          debugPrint('Fallback response is an EMPTY List');
        } else if (response is Map<String, dynamic>) {
          debugPrint('Fallback response is a Map');
          success = response['success'] as bool? ?? false;
          message = response['message'] as String?;
          studentId = response['student_id'] as String?;
        } else {
          debugPrint('Fallback response is unexpected type');
        }
      } else {
        debugPrint('Fallback response is NULL');
      }

      if (success) {
        debugPrint('FALLBACK SUCCESS: $message');
        debugPrint('  - Student ID: $studentId');
      } else {
        debugPrint('FALLBACK FAILED: $message');
        debugPrint('Attempting DIRECT INSERT as last resort...');
        await _directInsertParentStudentLink(code);
      }
    } catch (e, stackTrace) {
      debugPrint('FALLBACK EXCEPTION: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('Attempting DIRECT INSERT as last resort...');
      await _directInsertParentStudentLink(code);
    }
  }

  /// Last resort: Try the super simple RPC function.
  ///
  /// This function uses simple_link_parent which is the simplest possible
  /// SECURITY DEFINER function to link parent to student.
  Future<void> _directInsertParentStudentLink(String code) async {
    debugPrint('');
    debugPrint('SIMPLE LINK: Attempting simple_link_parent RPC');
    debugPrint('  - p_code: $code');

    try {
      // First try the super simple RPC function
      final response = await _supabase.rpc(
        'simple_link_parent',
        params: {'p_code': code},
      );

      debugPrint('simple_link_parent response:');
      debugPrint('  - Type: ${response.runtimeType}');
      debugPrint('  - Value: $response');

      if (response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        if (success) {
          debugPrint('SIMPLE LINK SUCCESS!');
          debugPrint('  - parent_id: ${response['parent_id']}');
          debugPrint('  - student_id: ${response['student_id']}');
          return;
        }
        debugPrint('SIMPLE LINK FAILED: ${response['error']}');
      }

      // If simple RPC failed, try direct insert
      debugPrint('Trying direct table insert...');
      await _directTableInsert(code);
    } catch (e, stackTrace) {
      debugPrint('SIMPLE LINK EXCEPTION: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('Trying direct table insert...');
      await _directTableInsert(code);
    }
  }

  /// Absolute last resort: Direct table insert.
  Future<void> _directTableInsert(String code) async {
    debugPrint('');
    debugPrint('DIRECT TABLE INSERT: Attempting direct parent_student insert');

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('DIRECT INSERT FAILED: No current user');
        return;
      }

      // First, get the student_id from the parent_invites table
      debugPrint('Looking up parent invite for code: $code');
      final inviteResponse = await _supabase
          .from('parent_invites')
          .select('student_id')
          .eq('code', code)
          .maybeSingle();

      debugPrint('Invite lookup response: $inviteResponse');

      if (inviteResponse == null) {
        debugPrint('DIRECT INSERT FAILED: Invite not found');
        return;
      }

      final studentId = inviteResponse['student_id'] as String?;
      if (studentId == null) {
        debugPrint('DIRECT INSERT FAILED: No student_id in invite');
        return;
      }

      debugPrint('Found student_id: $studentId');
      debugPrint('Attempting insert into parent_student...');
      debugPrint('  - parent_id: $userId');
      debugPrint('  - student_id: $studentId');

      // Try to insert directly - this may fail due to RLS but we try anyway
      await _supabase.from('parent_student').insert({
        'parent_id': userId,
        'student_id': studentId,
        'relationship': 'parent',
      });

      debugPrint('DIRECT INSERT SUCCESS!');

      // Also update the parent_invites record
      debugPrint('Updating parent_invites record...');
      await _supabase.from('parent_invites').update({
        'times_used': 1,
        'parent_id': userId,
        'used_at': DateTime.now().toIso8601String(),
      }).eq('code', code);

      debugPrint('Parent invite updated successfully');
    } catch (e, stackTrace) {
      debugPrint('DIRECT INSERT EXCEPTION: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('');
      debugPrint('========================================');
      debugPrint('ALL LINKING METHODS HAVE FAILED!');
      debugPrint('========================================');
      debugPrint('The parent will need to be linked manually by an admin.');
      debugPrint('Please check:');
      debugPrint('  1. The database migration has been applied');
      debugPrint('  2. The RPC functions exist in the database');
      debugPrint('  3. The RLS policies are correct');
      debugPrint('========================================');
    }
  }

  /// Validates an invite token without using it.
  ///
  /// Returns the [InviteToken] if valid, throws [AuthException] otherwise.
  /// This can be used to show the role/school info before registration.
  Future<InviteToken> validateInviteToken(String token) async {
    return _validateInviteToken(token);
  }
}
