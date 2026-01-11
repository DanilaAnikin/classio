// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$teacherRepositoryHash() => r'3a0185d602bd0eccba0ba2060db63f9c3e59da5f';

/// Provider for the [TeacherRepository] implementation.
///
/// Returns a [SupabaseTeacherRepository] for production use.
///
/// Copied from [teacherRepository].
@ProviderFor(teacherRepository)
final teacherRepositoryProvider =
    AutoDisposeProvider<TeacherRepository>.internal(
      teacherRepository,
      name: r'teacherRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$teacherRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TeacherRepositoryRef = AutoDisposeProviderRef<TeacherRepository>;
String _$teacherDashboardSubjectsHash() =>
    r'64bcec5481fb743caaeeb9d9c93f66e9c0e0a4a2';

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

/// Provider that fetches subjects for the teacher dashboard.
///
/// [teacherId] - The ID of the teacher to fetch subjects for.
///
/// Returns an [AsyncValue] containing the list of [TeacherSubject]s
/// with their class counts. Unlike the basic teacherSubjects provider,
/// this returns TeacherSubject entities with additional dashboard-specific
/// fields like classCount and description.
///
/// Copied from [teacherDashboardSubjects].
@ProviderFor(teacherDashboardSubjects)
const teacherDashboardSubjectsProvider = TeacherDashboardSubjectsFamily();

/// Provider that fetches subjects for the teacher dashboard.
///
/// [teacherId] - The ID of the teacher to fetch subjects for.
///
/// Returns an [AsyncValue] containing the list of [TeacherSubject]s
/// with their class counts. Unlike the basic teacherSubjects provider,
/// this returns TeacherSubject entities with additional dashboard-specific
/// fields like classCount and description.
///
/// Copied from [teacherDashboardSubjects].
class TeacherDashboardSubjectsFamily
    extends Family<AsyncValue<List<TeacherSubject>>> {
  /// Provider that fetches subjects for the teacher dashboard.
  ///
  /// [teacherId] - The ID of the teacher to fetch subjects for.
  ///
  /// Returns an [AsyncValue] containing the list of [TeacherSubject]s
  /// with their class counts. Unlike the basic teacherSubjects provider,
  /// this returns TeacherSubject entities with additional dashboard-specific
  /// fields like classCount and description.
  ///
  /// Copied from [teacherDashboardSubjects].
  const TeacherDashboardSubjectsFamily();

  /// Provider that fetches subjects for the teacher dashboard.
  ///
  /// [teacherId] - The ID of the teacher to fetch subjects for.
  ///
  /// Returns an [AsyncValue] containing the list of [TeacherSubject]s
  /// with their class counts. Unlike the basic teacherSubjects provider,
  /// this returns TeacherSubject entities with additional dashboard-specific
  /// fields like classCount and description.
  ///
  /// Copied from [teacherDashboardSubjects].
  TeacherDashboardSubjectsProvider call(String teacherId) {
    return TeacherDashboardSubjectsProvider(teacherId);
  }

  @override
  TeacherDashboardSubjectsProvider getProviderOverride(
    covariant TeacherDashboardSubjectsProvider provider,
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
  String? get name => r'teacherDashboardSubjectsProvider';
}

/// Provider that fetches subjects for the teacher dashboard.
///
/// [teacherId] - The ID of the teacher to fetch subjects for.
///
/// Returns an [AsyncValue] containing the list of [TeacherSubject]s
/// with their class counts. Unlike the basic teacherSubjects provider,
/// this returns TeacherSubject entities with additional dashboard-specific
/// fields like classCount and description.
///
/// Copied from [teacherDashboardSubjects].
class TeacherDashboardSubjectsProvider
    extends AutoDisposeFutureProvider<List<TeacherSubject>> {
  /// Provider that fetches subjects for the teacher dashboard.
  ///
  /// [teacherId] - The ID of the teacher to fetch subjects for.
  ///
  /// Returns an [AsyncValue] containing the list of [TeacherSubject]s
  /// with their class counts. Unlike the basic teacherSubjects provider,
  /// this returns TeacherSubject entities with additional dashboard-specific
  /// fields like classCount and description.
  ///
  /// Copied from [teacherDashboardSubjects].
  TeacherDashboardSubjectsProvider(String teacherId)
    : this._internal(
        (ref) => teacherDashboardSubjects(
          ref as TeacherDashboardSubjectsRef,
          teacherId,
        ),
        from: teacherDashboardSubjectsProvider,
        name: r'teacherDashboardSubjectsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teacherDashboardSubjectsHash,
        dependencies: TeacherDashboardSubjectsFamily._dependencies,
        allTransitiveDependencies:
            TeacherDashboardSubjectsFamily._allTransitiveDependencies,
        teacherId: teacherId,
      );

  TeacherDashboardSubjectsProvider._internal(
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
    FutureOr<List<TeacherSubject>> Function(
      TeacherDashboardSubjectsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TeacherDashboardSubjectsProvider._internal(
        (ref) => create(ref as TeacherDashboardSubjectsRef),
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
  AutoDisposeFutureProviderElement<List<TeacherSubject>> createElement() {
    return _TeacherDashboardSubjectsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherDashboardSubjectsProvider &&
        other.teacherId == teacherId;
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
mixin TeacherDashboardSubjectsRef
    on AutoDisposeFutureProviderRef<List<TeacherSubject>> {
  /// The parameter `teacherId` of this provider.
  String get teacherId;
}

class _TeacherDashboardSubjectsProviderElement
    extends AutoDisposeFutureProviderElement<List<TeacherSubject>>
    with TeacherDashboardSubjectsRef {
  _TeacherDashboardSubjectsProviderElement(super.provider);

  @override
  String get teacherId =>
      (origin as TeacherDashboardSubjectsProvider).teacherId;
}

String _$teacherDashboardNotifierHash() =>
    r'23539e2bcb61da180a2ddb98bf46136bc7c11a43';

abstract class _$TeacherDashboardNotifier
    extends BuildlessAutoDisposeNotifier<TeacherDashboardState> {
  late final String teacherId;

  TeacherDashboardState build(String teacherId);
}

/// Notifier for managing the teacher dashboard state.
///
/// Handles fetching and refreshing of teacher subjects data.
///
/// Copied from [TeacherDashboardNotifier].
@ProviderFor(TeacherDashboardNotifier)
const teacherDashboardNotifierProvider = TeacherDashboardNotifierFamily();

/// Notifier for managing the teacher dashboard state.
///
/// Handles fetching and refreshing of teacher subjects data.
///
/// Copied from [TeacherDashboardNotifier].
class TeacherDashboardNotifierFamily extends Family<TeacherDashboardState> {
  /// Notifier for managing the teacher dashboard state.
  ///
  /// Handles fetching and refreshing of teacher subjects data.
  ///
  /// Copied from [TeacherDashboardNotifier].
  const TeacherDashboardNotifierFamily();

  /// Notifier for managing the teacher dashboard state.
  ///
  /// Handles fetching and refreshing of teacher subjects data.
  ///
  /// Copied from [TeacherDashboardNotifier].
  TeacherDashboardNotifierProvider call(String teacherId) {
    return TeacherDashboardNotifierProvider(teacherId);
  }

  @override
  TeacherDashboardNotifierProvider getProviderOverride(
    covariant TeacherDashboardNotifierProvider provider,
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
  String? get name => r'teacherDashboardNotifierProvider';
}

/// Notifier for managing the teacher dashboard state.
///
/// Handles fetching and refreshing of teacher subjects data.
///
/// Copied from [TeacherDashboardNotifier].
class TeacherDashboardNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          TeacherDashboardNotifier,
          TeacherDashboardState
        > {
  /// Notifier for managing the teacher dashboard state.
  ///
  /// Handles fetching and refreshing of teacher subjects data.
  ///
  /// Copied from [TeacherDashboardNotifier].
  TeacherDashboardNotifierProvider(String teacherId)
    : this._internal(
        () => TeacherDashboardNotifier()..teacherId = teacherId,
        from: teacherDashboardNotifierProvider,
        name: r'teacherDashboardNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$teacherDashboardNotifierHash,
        dependencies: TeacherDashboardNotifierFamily._dependencies,
        allTransitiveDependencies:
            TeacherDashboardNotifierFamily._allTransitiveDependencies,
        teacherId: teacherId,
      );

  TeacherDashboardNotifierProvider._internal(
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
  TeacherDashboardState runNotifierBuild(
    covariant TeacherDashboardNotifier notifier,
  ) {
    return notifier.build(teacherId);
  }

  @override
  Override overrideWith(TeacherDashboardNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: TeacherDashboardNotifierProvider._internal(
        () => create()..teacherId = teacherId,
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
  AutoDisposeNotifierProviderElement<
    TeacherDashboardNotifier,
    TeacherDashboardState
  >
  createElement() {
    return _TeacherDashboardNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TeacherDashboardNotifierProvider &&
        other.teacherId == teacherId;
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
mixin TeacherDashboardNotifierRef
    on AutoDisposeNotifierProviderRef<TeacherDashboardState> {
  /// The parameter `teacherId` of this provider.
  String get teacherId;
}

class _TeacherDashboardNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          TeacherDashboardNotifier,
          TeacherDashboardState
        >
    with TeacherDashboardNotifierRef {
  _TeacherDashboardNotifierProviderElement(super.provider);

  @override
  String get teacherId =>
      (origin as TeacherDashboardNotifierProvider).teacherId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
