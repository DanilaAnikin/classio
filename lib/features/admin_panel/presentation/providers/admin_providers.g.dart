// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adminRepositoryHash() => r'3420cd242b920cde03caa6c198cbe189ef99dedb';

/// Provider for the AdminRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
///
/// Copied from [adminRepository].
@ProviderFor(adminRepository)
final adminRepositoryProvider = AutoDisposeProvider<AdminRepository>.internal(
  adminRepository,
  name: r'adminRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adminRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdminRepositoryRef = AutoDisposeProviderRef<AdminRepository>;
String _$schoolsHash() => r'8a9ee988d3dc1144d47381d33f9a561fd3774ce0';

/// Provider that fetches all schools.
///
/// Returns an async value containing the list of all schools.
/// Used by superadmins to view and manage all schools in the system.
///
/// Copied from [schools].
@ProviderFor(schools)
final schoolsProvider = AutoDisposeFutureProvider<List<School>>.internal(
  schools,
  name: r'schoolsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$schoolsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SchoolsRef = AutoDisposeFutureProviderRef<List<School>>;
String _$schoolUsersHash() => r'62cbfa062a225bf4d95e5b0c310109c251f89c32';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider that fetches users for a specific school.
///
/// The [schoolId] parameter identifies which school's users to fetch.
/// Returns an async value containing the list of users for that school.
///
/// Copied from [schoolUsers].
@ProviderFor(schoolUsers)
const schoolUsersProvider = SchoolUsersFamily();

/// Provider that fetches users for a specific school.
///
/// The [schoolId] parameter identifies which school's users to fetch.
/// Returns an async value containing the list of users for that school.
///
/// Copied from [schoolUsers].
class SchoolUsersFamily extends Family<AsyncValue<List<AppUser>>> {
  /// Provider that fetches users for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's users to fetch.
  /// Returns an async value containing the list of users for that school.
  ///
  /// Copied from [schoolUsers].
  const SchoolUsersFamily();

  /// Provider that fetches users for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's users to fetch.
  /// Returns an async value containing the list of users for that school.
  ///
  /// Copied from [schoolUsers].
  SchoolUsersProvider call(String schoolId) {
    return SchoolUsersProvider(schoolId);
  }

  @override
  SchoolUsersProvider getProviderOverride(
    covariant SchoolUsersProvider provider,
  ) {
    return call(provider.schoolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schoolUsersProvider';
}

/// Provider that fetches users for a specific school.
///
/// The [schoolId] parameter identifies which school's users to fetch.
/// Returns an async value containing the list of users for that school.
///
/// Copied from [schoolUsers].
class SchoolUsersProvider extends AutoDisposeFutureProvider<List<AppUser>> {
  /// Provider that fetches users for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's users to fetch.
  /// Returns an async value containing the list of users for that school.
  ///
  /// Copied from [schoolUsers].
  SchoolUsersProvider(String schoolId)
    : this._internal(
        (ref) => schoolUsers(ref as SchoolUsersRef, schoolId),
        from: schoolUsersProvider,
        name: r'schoolUsersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$schoolUsersHash,
        dependencies: SchoolUsersFamily._dependencies,
        allTransitiveDependencies: SchoolUsersFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  SchoolUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.schoolId,
  }) : super.internal();

  final String schoolId;

  @override
  Override overrideWith(
    FutureOr<List<AppUser>> Function(SchoolUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SchoolUsersProvider._internal(
        (ref) => create(ref as SchoolUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        schoolId: schoolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AppUser>> createElement() {
    return _SchoolUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchoolUsersProvider && other.schoolId == schoolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, schoolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SchoolUsersRef on AutoDisposeFutureProviderRef<List<AppUser>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _SchoolUsersProviderElement
    extends AutoDisposeFutureProviderElement<List<AppUser>>
    with SchoolUsersRef {
  _SchoolUsersProviderElement(super.provider);

  @override
  String get schoolId => (origin as SchoolUsersProvider).schoolId;
}

String _$schoolClassesHash() => r'55f5d0d50aab6e843fcdca08b2bd0b9e1cce98be';

/// Provider that fetches classes for a specific school.
///
/// The [schoolId] parameter identifies which school's classes to fetch.
/// Returns an async value containing the list of classes for that school.
///
/// Copied from [schoolClasses].
@ProviderFor(schoolClasses)
const schoolClassesProvider = SchoolClassesFamily();

/// Provider that fetches classes for a specific school.
///
/// The [schoolId] parameter identifies which school's classes to fetch.
/// Returns an async value containing the list of classes for that school.
///
/// Copied from [schoolClasses].
class SchoolClassesFamily extends Family<AsyncValue<List<ClassInfo>>> {
  /// Provider that fetches classes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's classes to fetch.
  /// Returns an async value containing the list of classes for that school.
  ///
  /// Copied from [schoolClasses].
  const SchoolClassesFamily();

  /// Provider that fetches classes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's classes to fetch.
  /// Returns an async value containing the list of classes for that school.
  ///
  /// Copied from [schoolClasses].
  SchoolClassesProvider call(String schoolId) {
    return SchoolClassesProvider(schoolId);
  }

  @override
  SchoolClassesProvider getProviderOverride(
    covariant SchoolClassesProvider provider,
  ) {
    return call(provider.schoolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schoolClassesProvider';
}

/// Provider that fetches classes for a specific school.
///
/// The [schoolId] parameter identifies which school's classes to fetch.
/// Returns an async value containing the list of classes for that school.
///
/// Copied from [schoolClasses].
class SchoolClassesProvider extends AutoDisposeFutureProvider<List<ClassInfo>> {
  /// Provider that fetches classes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's classes to fetch.
  /// Returns an async value containing the list of classes for that school.
  ///
  /// Copied from [schoolClasses].
  SchoolClassesProvider(String schoolId)
    : this._internal(
        (ref) => schoolClasses(ref as SchoolClassesRef, schoolId),
        from: schoolClassesProvider,
        name: r'schoolClassesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$schoolClassesHash,
        dependencies: SchoolClassesFamily._dependencies,
        allTransitiveDependencies:
            SchoolClassesFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  SchoolClassesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.schoolId,
  }) : super.internal();

  final String schoolId;

  @override
  Override overrideWith(
    FutureOr<List<ClassInfo>> Function(SchoolClassesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SchoolClassesProvider._internal(
        (ref) => create(ref as SchoolClassesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        schoolId: schoolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ClassInfo>> createElement() {
    return _SchoolClassesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchoolClassesProvider && other.schoolId == schoolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, schoolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SchoolClassesRef on AutoDisposeFutureProviderRef<List<ClassInfo>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _SchoolClassesProviderElement
    extends AutoDisposeFutureProviderElement<List<ClassInfo>>
    with SchoolClassesRef {
  _SchoolClassesProviderElement(super.provider);

  @override
  String get schoolId => (origin as SchoolClassesProvider).schoolId;
}

String _$teacherSubjectsHash() => r'a12acb43a9f9ff9586dab996fd51e6765f62fd38';

/// Provider that fetches subjects for a specific teacher.
///
/// The [teacherId] parameter identifies which teacher's subjects to fetch.
/// Returns an async value containing the list of subjects assigned to the teacher.
///
/// Copied from [teacherSubjects].
@ProviderFor(teacherSubjects)
const teacherSubjectsProvider = TeacherSubjectsFamily();

/// Provider that fetches subjects for a specific teacher.
///
/// The [teacherId] parameter identifies which teacher's subjects to fetch.
/// Returns an async value containing the list of subjects assigned to the teacher.
///
/// Copied from [teacherSubjects].
class TeacherSubjectsFamily extends Family<AsyncValue<List<Subject>>> {
  /// Provider that fetches subjects for a specific teacher.
  ///
  /// The [teacherId] parameter identifies which teacher's subjects to fetch.
  /// Returns an async value containing the list of subjects assigned to the teacher.
  ///
  /// Copied from [teacherSubjects].
  const TeacherSubjectsFamily();

  /// Provider that fetches subjects for a specific teacher.
  ///
  /// The [teacherId] parameter identifies which teacher's subjects to fetch.
  /// Returns an async value containing the list of subjects assigned to the teacher.
  ///
  /// Copied from [teacherSubjects].
  TeacherSubjectsProvider call(String teacherId) {
    return TeacherSubjectsProvider(teacherId);
  }

  @override
  TeacherSubjectsProvider getProviderOverride(
    covariant TeacherSubjectsProvider provider,
  ) {
    return call(provider.teacherId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'teacherSubjectsProvider';
}

/// Provider that fetches subjects for a specific teacher.
///
/// The [teacherId] parameter identifies which teacher's subjects to fetch.
/// Returns an async value containing the list of subjects assigned to the teacher.
///
/// Copied from [teacherSubjects].
class TeacherSubjectsProvider extends AutoDisposeFutureProvider<List<Subject>> {
  /// Provider that fetches subjects for a specific teacher.
  ///
  /// The [teacherId] parameter identifies which teacher's subjects to fetch.
  /// Returns an async value containing the list of subjects assigned to the teacher.
  ///
  /// Copied from [teacherSubjects].
  TeacherSubjectsProvider(String teacherId)
    : this._internal(
        (ref) => teacherSubjects(ref as TeacherSubjectsRef, teacherId),
        from: teacherSubjectsProvider,
        name: r'teacherSubjectsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teacherSubjectsHash,
        dependencies: TeacherSubjectsFamily._dependencies,
        allTransitiveDependencies:
            TeacherSubjectsFamily._allTransitiveDependencies,
        teacherId: teacherId,
      );

  TeacherSubjectsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.teacherId,
  }) : super.internal();

  final String teacherId;

  @override
  Override overrideWith(
    FutureOr<List<Subject>> Function(TeacherSubjectsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeacherSubjectsProvider._internal(
        (ref) => create(ref as TeacherSubjectsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        teacherId: teacherId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Subject>> createElement() {
    return _TeacherSubjectsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherSubjectsProvider && other.teacherId == teacherId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, teacherId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TeacherSubjectsRef on AutoDisposeFutureProviderRef<List<Subject>> {
  /// The parameter `teacherId` of this provider.
  String get teacherId;
}

class _TeacherSubjectsProviderElement
    extends AutoDisposeFutureProviderElement<List<Subject>>
    with TeacherSubjectsRef {
  _TeacherSubjectsProviderElement(super.provider);

  @override
  String get teacherId => (origin as TeacherSubjectsProvider).teacherId;
}

String _$schoolInviteCodesHash() => r'c257c67d6722330296ca5a1cc484cdb25ebcaf7a';

/// Provider that fetches invite codes for a specific school.
///
/// The [schoolId] parameter identifies which school's invite codes to fetch.
/// Returns an async value containing the list of invite codes for that school.
///
/// Copied from [schoolInviteCodes].
@ProviderFor(schoolInviteCodes)
const schoolInviteCodesProvider = SchoolInviteCodesFamily();

/// Provider that fetches invite codes for a specific school.
///
/// The [schoolId] parameter identifies which school's invite codes to fetch.
/// Returns an async value containing the list of invite codes for that school.
///
/// Copied from [schoolInviteCodes].
class SchoolInviteCodesFamily extends Family<AsyncValue<List<InviteCode>>> {
  /// Provider that fetches invite codes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's invite codes to fetch.
  /// Returns an async value containing the list of invite codes for that school.
  ///
  /// Copied from [schoolInviteCodes].
  const SchoolInviteCodesFamily();

  /// Provider that fetches invite codes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's invite codes to fetch.
  /// Returns an async value containing the list of invite codes for that school.
  ///
  /// Copied from [schoolInviteCodes].
  SchoolInviteCodesProvider call(String schoolId) {
    return SchoolInviteCodesProvider(schoolId);
  }

  @override
  SchoolInviteCodesProvider getProviderOverride(
    covariant SchoolInviteCodesProvider provider,
  ) {
    return call(provider.schoolId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'schoolInviteCodesProvider';
}

/// Provider that fetches invite codes for a specific school.
///
/// The [schoolId] parameter identifies which school's invite codes to fetch.
/// Returns an async value containing the list of invite codes for that school.
///
/// Copied from [schoolInviteCodes].
class SchoolInviteCodesProvider
    extends AutoDisposeFutureProvider<List<InviteCode>> {
  /// Provider that fetches invite codes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's invite codes to fetch.
  /// Returns an async value containing the list of invite codes for that school.
  ///
  /// Copied from [schoolInviteCodes].
  SchoolInviteCodesProvider(String schoolId)
    : this._internal(
        (ref) => schoolInviteCodes(ref as SchoolInviteCodesRef, schoolId),
        from: schoolInviteCodesProvider,
        name: r'schoolInviteCodesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$schoolInviteCodesHash,
        dependencies: SchoolInviteCodesFamily._dependencies,
        allTransitiveDependencies:
            SchoolInviteCodesFamily._allTransitiveDependencies,
        schoolId: schoolId,
      );

  SchoolInviteCodesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.schoolId,
  }) : super.internal();

  final String schoolId;

  @override
  Override overrideWith(
    FutureOr<List<InviteCode>> Function(SchoolInviteCodesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SchoolInviteCodesProvider._internal(
        (ref) => create(ref as SchoolInviteCodesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        schoolId: schoolId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<InviteCode>> createElement() {
    return _SchoolInviteCodesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SchoolInviteCodesProvider && other.schoolId == schoolId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, schoolId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SchoolInviteCodesRef on AutoDisposeFutureProviderRef<List<InviteCode>> {
  /// The parameter `schoolId` of this provider.
  String get schoolId;
}

class _SchoolInviteCodesProviderElement
    extends AutoDisposeFutureProviderElement<List<InviteCode>>
    with SchoolInviteCodesRef {
  _SchoolInviteCodesProviderElement(super.provider);

  @override
  String get schoolId => (origin as SchoolInviteCodesProvider).schoolId;
}

String _$adminNotifierHash() => r'12a3b53fd40e7380bbd083a1ce1666177ab53536';

/// Notifier for managing admin panel state and operations.
///
/// Provides methods for creating schools, classes, and invite codes,
/// as well as managing users and their roles.
///
/// Copied from [AdminNotifier].
@ProviderFor(AdminNotifier)
final adminNotifierProvider =
    NotifierProvider<AdminNotifier, AdminState>.internal(
      AdminNotifier.new,
      name: r'adminNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adminNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdminNotifier = Notifier<AdminState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
