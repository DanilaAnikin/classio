// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'441b94f208778134226f4c69971f75fec1f333a4';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$isAuthenticatedHash() => r'ac761310d7c2437ba714598d6ac3bf65cffd5542';

/// See also [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$currentUserHash() => r'0d98f525ad3212bd32d9e884850269b7cf18cb52';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<AppUser?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<AppUser?>;
String _$currentUserRoleHash() => r'25efc36e81ef0bded5b89a87bd5bb1c35806f6c5';

/// Provider that returns the current user's role.
///
/// Copied from [currentUserRole].
@ProviderFor(currentUserRole)
final currentUserRoleProvider = AutoDisposeProvider<UserRole?>.internal(
  currentUserRole,
  name: r'currentUserRoleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserRoleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRoleRef = AutoDisposeProviderRef<UserRole?>;
String _$isSuperAdminHash() => r'f1074cabe0ecd588752870f61d6ba0d3f377d247';

/// Provider that checks if the current user is a superadmin.
///
/// Copied from [isSuperAdmin].
@ProviderFor(isSuperAdmin)
final isSuperAdminProvider = AutoDisposeProvider<bool>.internal(
  isSuperAdmin,
  name: r'isSuperAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isSuperAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsSuperAdminRef = AutoDisposeProviderRef<bool>;
String _$isBigAdminHash() => r'a7e461408e94a34ef05deb3db3608973b993f03b';

/// Provider that checks if the current user is a bigadmin.
///
/// Copied from [isBigAdmin].
@ProviderFor(isBigAdmin)
final isBigAdminProvider = AutoDisposeProvider<bool>.internal(
  isBigAdmin,
  name: r'isBigAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isBigAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsBigAdminRef = AutoDisposeProviderRef<bool>;
String _$isAdminHash() => r'8ca4a81211e77f6c247542865465e8ba4bf2cae5';

/// Provider that checks if the current user is an admin.
///
/// Copied from [isAdmin].
@ProviderFor(isAdmin)
final isAdminProvider = AutoDisposeProvider<bool>.internal(
  isAdmin,
  name: r'isAdminProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAdminHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAdminRef = AutoDisposeProviderRef<bool>;
String _$isTeacherHash() => r'c30df78ae8f12a2c4637e30177f224dcc4ff1b64';

/// Provider that checks if the current user is a teacher.
///
/// Copied from [isTeacher].
@ProviderFor(isTeacher)
final isTeacherProvider = AutoDisposeProvider<bool>.internal(
  isTeacher,
  name: r'isTeacherProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isTeacherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsTeacherRef = AutoDisposeProviderRef<bool>;
String _$isStudentHash() => r'859008fda6d63f131ea8fd592a231efa9cbc0fb9';

/// Provider that checks if the current user is a student.
///
/// Copied from [isStudent].
@ProviderFor(isStudent)
final isStudentProvider = AutoDisposeProvider<bool>.internal(
  isStudent,
  name: r'isStudentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isStudentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsStudentRef = AutoDisposeProviderRef<bool>;
String _$isParentHash() => r'0ccf760ffbdd73ba88522bf0c8d0fe953d218428';

/// Provider that checks if the current user is a parent.
///
/// Copied from [isParent].
@ProviderFor(isParent)
final isParentProvider = AutoDisposeProvider<bool>.internal(
  isParent,
  name: r'isParentProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isParentHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsParentRef = AutoDisposeProviderRef<bool>;
String _$hasAdminPrivilegesHash() =>
    r'27128a28450f376c7fa2a68110aab81ab9d1a2fb';

/// Provider that checks if the current user has admin privileges.
///
/// Copied from [hasAdminPrivileges].
@ProviderFor(hasAdminPrivileges)
final hasAdminPrivilegesProvider = AutoDisposeProvider<bool>.internal(
  hasAdminPrivileges,
  name: r'hasAdminPrivilegesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasAdminPrivilegesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasAdminPrivilegesRef = AutoDisposeProviderRef<bool>;
String _$canManageUsersHash() => r'ac17eea98e0ed23f76a6d8d4f708e7fe4dc352b4';

/// Provider that checks if the current user can manage users.
///
/// Copied from [canManageUsers].
@ProviderFor(canManageUsers)
final canManageUsersProvider = AutoDisposeProvider<bool>.internal(
  canManageUsers,
  name: r'canManageUsersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canManageUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanManageUsersRef = AutoDisposeProviderRef<bool>;
String _$canManageClassesHash() => r'0b5899d3e51a0e032be201ba9b27c880a305fe80';

/// Provider that checks if the current user can manage classes.
///
/// Copied from [canManageClasses].
@ProviderFor(canManageClasses)
final canManageClassesProvider = AutoDisposeProvider<bool>.internal(
  canManageClasses,
  name: r'canManageClassesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canManageClassesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanManageClassesRef = AutoDisposeProviderRef<bool>;
String _$canManageSchoolStaffHash() =>
    r'e9e543a0f2741ddb29bb80cecb1feec36d5f2ae4';

/// Provider that checks if the current user can manage school staff (superadmin or bigadmin).
///
/// Copied from [canManageSchoolStaff].
@ProviderFor(canManageSchoolStaff)
final canManageSchoolStaffProvider = AutoDisposeProvider<bool>.internal(
  canManageSchoolStaff,
  name: r'canManageSchoolStaffProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canManageSchoolStaffHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanManageSchoolStaffRef = AutoDisposeProviderRef<bool>;
String _$userSchoolIdHash() => r'e99d8fca0c7edf8df2f0f45c15638ec896b2b386';

/// Provider that returns the current user's school ID.
///
/// Copied from [userSchoolId].
@ProviderFor(userSchoolId)
final userSchoolIdProvider = AutoDisposeProvider<String?>.internal(
  userSchoolId,
  name: r'userSchoolIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userSchoolIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserSchoolIdRef = AutoDisposeProviderRef<String?>;
String _$authNotifierHash() => r'355cfe28b2f935e7bd396ef03650ec9f3f285cf2';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = Notifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
