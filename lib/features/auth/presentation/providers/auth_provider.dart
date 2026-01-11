import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/supabase_auth_repository.dart'
    show SupabaseAuthRepository, AuthException;

part 'auth_provider.g.dart';

// Auth Repository Provider
@riverpod
AuthRepository authRepository(Ref ref) {
  // Returns SupabaseAuthRepository for production use
  return SupabaseAuthRepository();
}

// Auth State Class
class AuthState {
  final bool isLoading;
  final bool isRegistering;
  final AppUser? user;
  final String? errorMessage;

  const AuthState({
    required this.isLoading,
    this.isRegistering = false,
    this.user,
    this.errorMessage,
  });

  // Factory constructors
  factory AuthState.initial() {
    return const AuthState(
      isLoading: true,
      isRegistering: false,
      user: null,
      errorMessage: null,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      isLoading: true,
      isRegistering: false,
      user: null,
      errorMessage: null,
    );
  }

  factory AuthState.registering() {
    return const AuthState(
      isLoading: false,
      isRegistering: true,
      user: null,
      errorMessage: null,
    );
  }

  factory AuthState.authenticated(AppUser user) {
    return AuthState(
      isLoading: false,
      isRegistering: false,
      user: user,
      errorMessage: null,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      isLoading: false,
      isRegistering: false,
      user: null,
      errorMessage: null,
    );
  }

  factory AuthState.error(String message) {
    return AuthState(
      isLoading: false,
      isRegistering: false,
      user: null,
      errorMessage: message,
    );
  }

  // Getter for authentication status
  bool get isAuthenticated => user != null;

  // RBAC Helper Getters

  /// Gets the current user's role, or null if not authenticated.
  UserRole? get userRole => user?.role;

  /// Checks if the current user is a superadmin.
  bool get isSuperAdmin => user?.isSuperAdmin ?? false;

  /// Checks if the current user is an admin.
  bool get isAdmin => user?.isAdmin ?? false;

  /// Checks if the current user is a teacher.
  bool get isTeacher => user?.isTeacher ?? false;

  /// Checks if the current user is a student.
  bool get isStudent => user?.isStudent ?? false;

  /// Checks if the current user is a parent.
  bool get isParent => user?.isParent ?? false;

  /// Checks if the current user is a bigadmin.
  bool get isBigAdmin => user?.isBigAdmin ?? false;

  /// Checks if the current user has admin privileges (superadmin, bigadmin, or admin).
  bool get hasAdminPrivileges => user?.hasAdminPrivileges ?? false;

  /// Checks if the current user can manage school staff (superadmin or bigadmin).
  bool get canManageSchoolStaff => user?.canManageSchoolStaff ?? false;

  /// Checks if the current user can manage users.
  bool get canManageUsers => user?.canManageUsers ?? false;

  /// Checks if the current user can manage classes.
  bool get canManageClasses => user?.canManageClasses ?? false;

  /// Checks if the current user can access all schools.
  bool get canAccessAllSchools => user?.canAccessAllSchools ?? false;

  /// Gets the current user's school ID.
  String? get userSchoolId => user?.schoolId;

  /// Checks if the current user belongs to a specific school.
  bool belongsToSchool(String? schoolId) =>
      user?.belongsToSchool(schoolId) ?? false;

  /// Checks if the current user has a specific role or higher.
  bool hasRoleOrHigher(UserRole role) =>
      user?.hasRoleOrHigher(role) ?? false;

  // CopyWith method
  AuthState copyWith({
    bool? isLoading,
    bool? isRegistering,
    AppUser? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isRegistering: isRegistering ?? this.isRegistering,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth Notifier
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  late SupabaseAuthRepository _authRepository;

  @override
  AuthState build() {
    // Get the auth repository (cast to SupabaseAuthRepository for signUp access)
    _authRepository = ref.read(authRepositoryProvider) as SupabaseAuthRepository;

    // Initialize and check current user
    _checkAuthStatus();

    return AuthState.initial();
  }

  // Check authentication status (for app start)
  Future<void> checkAuthStatus() async {
    await _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      state = AuthState.loading();

      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Sign in method
  Future<void> signIn(String email, String password) async {
    try {
      state = AuthState.loading();

      final user = await _authRepository.signIn(email, password);

      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = AuthState.error('Sign in failed. Please check your credentials.');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Sign up method with invite code validation
  Future<void> signUp({
    required String email,
    required String password,
    required String inviteCode,
    String? firstName,
    String? lastName,
  }) async {
    try {
      state = AuthState.registering();

      // Call the repository's signUp method which validates the invite code
      // against the Supabase database and creates the user
      final user = await _authRepository.signUp(
        email: email,
        password: password,
        inviteCode: inviteCode,
        firstName: firstName,
        lastName: lastName,
      );

      state = AuthState.authenticated(user);
    } on AuthException catch (e) {
      // Handle specific auth exceptions (like "Invalid Invite Code")
      state = AuthState.error(e.message);
    } catch (e) {
      // Handle generic errors
      final errorMessage = e.toString();
      if (errorMessage.contains('Invalid Invite Code')) {
        state = AuthState.error('Invalid Invite Code');
      } else {
        state = AuthState.error(errorMessage);
      }
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      state = AuthState.loading();

      await _authRepository.signOut();

      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  // Clear error state
  void clearError() {
    if (state.errorMessage != null) {
      state = AuthState.unauthenticated();
    }
  }
}

// Helper Providers

// Provider that returns authentication status
@riverpod
bool isAuthenticated(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAuthenticated;
}

// Provider that returns current user
@riverpod
AppUser? currentUser(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
}

// RBAC Convenience Providers

/// Provider that returns the current user's role.
@riverpod
UserRole? currentUserRole(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userRole;
}

/// Provider that checks if the current user is a superadmin.
@riverpod
bool isSuperAdmin(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isSuperAdmin;
}

/// Provider that checks if the current user is a bigadmin.
@riverpod
bool isBigAdmin(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isBigAdmin;
}

/// Provider that checks if the current user is an admin.
@riverpod
bool isAdmin(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isAdmin;
}

/// Provider that checks if the current user is a teacher.
@riverpod
bool isTeacher(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isTeacher;
}

/// Provider that checks if the current user is a student.
@riverpod
bool isStudent(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isStudent;
}

/// Provider that checks if the current user is a parent.
@riverpod
bool isParent(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isParent;
}

/// Provider that checks if the current user has admin privileges.
@riverpod
bool hasAdminPrivileges(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.hasAdminPrivileges;
}

/// Provider that checks if the current user can manage users.
@riverpod
bool canManageUsers(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.canManageUsers;
}

/// Provider that checks if the current user can manage classes.
@riverpod
bool canManageClasses(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.canManageClasses;
}

/// Provider that checks if the current user can manage school staff (superadmin or bigadmin).
@riverpod
bool canManageSchoolStaff(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.canManageSchoolStaff;
}

/// Provider that returns the current user's school ID.
@riverpod
String? userSchoolId(Ref ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.userSchoolId;
}
