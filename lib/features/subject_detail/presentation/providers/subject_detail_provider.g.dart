// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subjectDetailRepositoryHash() =>
    r'2d33312870bebe1a0125a05621c92c044b4df594';

/// Provider for the SubjectDetailRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
///
/// Copied from [subjectDetailRepository].
@ProviderFor(subjectDetailRepository)
final subjectDetailRepositoryProvider =
    AutoDisposeProvider<SubjectDetailRepository>.internal(
      subjectDetailRepository,
      name: r'subjectDetailRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subjectDetailRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubjectDetailRepositoryRef =
    AutoDisposeProviderRef<SubjectDetailRepository>;
String _$subjectDetailDataHash() => r'6c755571e007af62ad52ef2d8fca3d86069e6c54';

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

/// Provider that returns the current subject detail data or null.
///
/// Copied from [subjectDetailData].
@ProviderFor(subjectDetailData)
const subjectDetailDataProvider = SubjectDetailDataFamily();

/// Provider that returns the current subject detail data or null.
///
/// Copied from [subjectDetailData].
class SubjectDetailDataFamily extends Family<SubjectDetail?> {
  /// Provider that returns the current subject detail data or null.
  ///
  /// Copied from [subjectDetailData].
  const SubjectDetailDataFamily();

  /// Provider that returns the current subject detail data or null.
  ///
  /// Copied from [subjectDetailData].
  SubjectDetailDataProvider call(String subjectId) {
    return SubjectDetailDataProvider(subjectId);
  }

  @override
  SubjectDetailDataProvider getProviderOverride(
    covariant SubjectDetailDataProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectDetailDataProvider';
}

/// Provider that returns the current subject detail data or null.
///
/// Copied from [subjectDetailData].
class SubjectDetailDataProvider extends AutoDisposeProvider<SubjectDetail?> {
  /// Provider that returns the current subject detail data or null.
  ///
  /// Copied from [subjectDetailData].
  SubjectDetailDataProvider(String subjectId)
    : this._internal(
        (ref) => subjectDetailData(ref as SubjectDetailDataRef, subjectId),
        from: subjectDetailDataProvider,
        name: r'subjectDetailDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subjectDetailDataHash,
        dependencies: SubjectDetailDataFamily._dependencies,
        allTransitiveDependencies:
            SubjectDetailDataFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  SubjectDetailDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    SubjectDetail? Function(SubjectDetailDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectDetailDataProvider._internal(
        (ref) => create(ref as SubjectDetailDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<SubjectDetail?> createElement() {
    return _SubjectDetailDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectDetailDataProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectDetailDataRef on AutoDisposeProviderRef<SubjectDetail?> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _SubjectDetailDataProviderElement
    extends AutoDisposeProviderElement<SubjectDetail?>
    with SubjectDetailDataRef {
  _SubjectDetailDataProviderElement(super.provider);

  @override
  String get subjectId => (origin as SubjectDetailDataProvider).subjectId;
}

String _$subjectPostsHash() => r'a0b20d4dd41f82d606fdbb2d4074b7acd4f217c8';

/// Provider that returns the subject's posts.
///
/// Copied from [subjectPosts].
@ProviderFor(subjectPosts)
const subjectPostsProvider = SubjectPostsFamily();

/// Provider that returns the subject's posts.
///
/// Copied from [subjectPosts].
class SubjectPostsFamily extends Family<List<CoursePost>> {
  /// Provider that returns the subject's posts.
  ///
  /// Copied from [subjectPosts].
  const SubjectPostsFamily();

  /// Provider that returns the subject's posts.
  ///
  /// Copied from [subjectPosts].
  SubjectPostsProvider call(String subjectId) {
    return SubjectPostsProvider(subjectId);
  }

  @override
  SubjectPostsProvider getProviderOverride(
    covariant SubjectPostsProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectPostsProvider';
}

/// Provider that returns the subject's posts.
///
/// Copied from [subjectPosts].
class SubjectPostsProvider extends AutoDisposeProvider<List<CoursePost>> {
  /// Provider that returns the subject's posts.
  ///
  /// Copied from [subjectPosts].
  SubjectPostsProvider(String subjectId)
    : this._internal(
        (ref) => subjectPosts(ref as SubjectPostsRef, subjectId),
        from: subjectPostsProvider,
        name: r'subjectPostsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subjectPostsHash,
        dependencies: SubjectPostsFamily._dependencies,
        allTransitiveDependencies:
            SubjectPostsFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  SubjectPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    List<CoursePost> Function(SubjectPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectPostsProvider._internal(
        (ref) => create(ref as SubjectPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<CoursePost>> createElement() {
    return _SubjectPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectPostsProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectPostsRef on AutoDisposeProviderRef<List<CoursePost>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _SubjectPostsProviderElement
    extends AutoDisposeProviderElement<List<CoursePost>>
    with SubjectPostsRef {
  _SubjectPostsProviderElement(super.provider);

  @override
  String get subjectId => (origin as SubjectPostsProvider).subjectId;
}

String _$subjectMaterialsHash() => r'3aa0589d26c2303524cdf00815d65c3ba9d3969e';

/// Provider that returns the subject's materials.
///
/// Copied from [subjectMaterials].
@ProviderFor(subjectMaterials)
const subjectMaterialsProvider = SubjectMaterialsFamily();

/// Provider that returns the subject's materials.
///
/// Copied from [subjectMaterials].
class SubjectMaterialsFamily extends Family<List<CourseMaterial>> {
  /// Provider that returns the subject's materials.
  ///
  /// Copied from [subjectMaterials].
  const SubjectMaterialsFamily();

  /// Provider that returns the subject's materials.
  ///
  /// Copied from [subjectMaterials].
  SubjectMaterialsProvider call(String subjectId) {
    return SubjectMaterialsProvider(subjectId);
  }

  @override
  SubjectMaterialsProvider getProviderOverride(
    covariant SubjectMaterialsProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectMaterialsProvider';
}

/// Provider that returns the subject's materials.
///
/// Copied from [subjectMaterials].
class SubjectMaterialsProvider
    extends AutoDisposeProvider<List<CourseMaterial>> {
  /// Provider that returns the subject's materials.
  ///
  /// Copied from [subjectMaterials].
  SubjectMaterialsProvider(String subjectId)
    : this._internal(
        (ref) => subjectMaterials(ref as SubjectMaterialsRef, subjectId),
        from: subjectMaterialsProvider,
        name: r'subjectMaterialsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subjectMaterialsHash,
        dependencies: SubjectMaterialsFamily._dependencies,
        allTransitiveDependencies:
            SubjectMaterialsFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  SubjectMaterialsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    List<CourseMaterial> Function(SubjectMaterialsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectMaterialsProvider._internal(
        (ref) => create(ref as SubjectMaterialsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<CourseMaterial>> createElement() {
    return _SubjectMaterialsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectMaterialsProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectMaterialsRef on AutoDisposeProviderRef<List<CourseMaterial>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _SubjectMaterialsProviderElement
    extends AutoDisposeProviderElement<List<CourseMaterial>>
    with SubjectMaterialsRef {
  _SubjectMaterialsProviderElement(super.provider);

  @override
  String get subjectId => (origin as SubjectMaterialsProvider).subjectId;
}

String _$subjectAssignmentsHash() =>
    r'868f82ef6245867aaf9907527d60e2c049a46cc0';

/// Provider that returns the subject's assignments.
///
/// Copied from [subjectAssignments].
@ProviderFor(subjectAssignments)
const subjectAssignmentsProvider = SubjectAssignmentsFamily();

/// Provider that returns the subject's assignments.
///
/// Copied from [subjectAssignments].
class SubjectAssignmentsFamily extends Family<List<Assignment>> {
  /// Provider that returns the subject's assignments.
  ///
  /// Copied from [subjectAssignments].
  const SubjectAssignmentsFamily();

  /// Provider that returns the subject's assignments.
  ///
  /// Copied from [subjectAssignments].
  SubjectAssignmentsProvider call(String subjectId) {
    return SubjectAssignmentsProvider(subjectId);
  }

  @override
  SubjectAssignmentsProvider getProviderOverride(
    covariant SubjectAssignmentsProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectAssignmentsProvider';
}

/// Provider that returns the subject's assignments.
///
/// Copied from [subjectAssignments].
class SubjectAssignmentsProvider extends AutoDisposeProvider<List<Assignment>> {
  /// Provider that returns the subject's assignments.
  ///
  /// Copied from [subjectAssignments].
  SubjectAssignmentsProvider(String subjectId)
    : this._internal(
        (ref) => subjectAssignments(ref as SubjectAssignmentsRef, subjectId),
        from: subjectAssignmentsProvider,
        name: r'subjectAssignmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subjectAssignmentsHash,
        dependencies: SubjectAssignmentsFamily._dependencies,
        allTransitiveDependencies:
            SubjectAssignmentsFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  SubjectAssignmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    List<Assignment> Function(SubjectAssignmentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectAssignmentsProvider._internal(
        (ref) => create(ref as SubjectAssignmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Assignment>> createElement() {
    return _SubjectAssignmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectAssignmentsProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectAssignmentsRef on AutoDisposeProviderRef<List<Assignment>> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _SubjectAssignmentsProviderElement
    extends AutoDisposeProviderElement<List<Assignment>>
    with SubjectAssignmentsRef {
  _SubjectAssignmentsProviderElement(super.provider);

  @override
  String get subjectId => (origin as SubjectAssignmentsProvider).subjectId;
}

String _$isSubjectDetailLoadingHash() =>
    r'54eefb1e44311d7ea1520d7e4ebb4df96c777055';

/// Provider that returns whether the subject detail is loading.
///
/// Copied from [isSubjectDetailLoading].
@ProviderFor(isSubjectDetailLoading)
const isSubjectDetailLoadingProvider = IsSubjectDetailLoadingFamily();

/// Provider that returns whether the subject detail is loading.
///
/// Copied from [isSubjectDetailLoading].
class IsSubjectDetailLoadingFamily extends Family<bool> {
  /// Provider that returns whether the subject detail is loading.
  ///
  /// Copied from [isSubjectDetailLoading].
  const IsSubjectDetailLoadingFamily();

  /// Provider that returns whether the subject detail is loading.
  ///
  /// Copied from [isSubjectDetailLoading].
  IsSubjectDetailLoadingProvider call(String subjectId) {
    return IsSubjectDetailLoadingProvider(subjectId);
  }

  @override
  IsSubjectDetailLoadingProvider getProviderOverride(
    covariant IsSubjectDetailLoadingProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isSubjectDetailLoadingProvider';
}

/// Provider that returns whether the subject detail is loading.
///
/// Copied from [isSubjectDetailLoading].
class IsSubjectDetailLoadingProvider extends AutoDisposeProvider<bool> {
  /// Provider that returns whether the subject detail is loading.
  ///
  /// Copied from [isSubjectDetailLoading].
  IsSubjectDetailLoadingProvider(String subjectId)
    : this._internal(
        (ref) =>
            isSubjectDetailLoading(ref as IsSubjectDetailLoadingRef, subjectId),
        from: isSubjectDetailLoadingProvider,
        name: r'isSubjectDetailLoadingProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isSubjectDetailLoadingHash,
        dependencies: IsSubjectDetailLoadingFamily._dependencies,
        allTransitiveDependencies:
            IsSubjectDetailLoadingFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  IsSubjectDetailLoadingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    bool Function(IsSubjectDetailLoadingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsSubjectDetailLoadingProvider._internal(
        (ref) => create(ref as IsSubjectDetailLoadingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsSubjectDetailLoadingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsSubjectDetailLoadingProvider &&
        other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsSubjectDetailLoadingRef on AutoDisposeProviderRef<bool> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _IsSubjectDetailLoadingProviderElement
    extends AutoDisposeProviderElement<bool>
    with IsSubjectDetailLoadingRef {
  _IsSubjectDetailLoadingProviderElement(super.provider);

  @override
  String get subjectId => (origin as IsSubjectDetailLoadingProvider).subjectId;
}

String _$subjectDetailErrorHash() =>
    r'd7d0f109b224b7e05862dfe2add0ad0ac00b0c1b';

/// Provider that returns the error message if any.
///
/// Copied from [subjectDetailError].
@ProviderFor(subjectDetailError)
const subjectDetailErrorProvider = SubjectDetailErrorFamily();

/// Provider that returns the error message if any.
///
/// Copied from [subjectDetailError].
class SubjectDetailErrorFamily extends Family<String?> {
  /// Provider that returns the error message if any.
  ///
  /// Copied from [subjectDetailError].
  const SubjectDetailErrorFamily();

  /// Provider that returns the error message if any.
  ///
  /// Copied from [subjectDetailError].
  SubjectDetailErrorProvider call(String subjectId) {
    return SubjectDetailErrorProvider(subjectId);
  }

  @override
  SubjectDetailErrorProvider getProviderOverride(
    covariant SubjectDetailErrorProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectDetailErrorProvider';
}

/// Provider that returns the error message if any.
///
/// Copied from [subjectDetailError].
class SubjectDetailErrorProvider extends AutoDisposeProvider<String?> {
  /// Provider that returns the error message if any.
  ///
  /// Copied from [subjectDetailError].
  SubjectDetailErrorProvider(String subjectId)
    : this._internal(
        (ref) => subjectDetailError(ref as SubjectDetailErrorRef, subjectId),
        from: subjectDetailErrorProvider,
        name: r'subjectDetailErrorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subjectDetailErrorHash,
        dependencies: SubjectDetailErrorFamily._dependencies,
        allTransitiveDependencies:
            SubjectDetailErrorFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  SubjectDetailErrorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  Override overrideWith(
    String? Function(SubjectDetailErrorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubjectDetailErrorProvider._internal(
        (ref) => create(ref as SubjectDetailErrorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String?> createElement() {
    return _SubjectDetailErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectDetailErrorProvider && other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectDetailErrorRef on AutoDisposeProviderRef<String?> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _SubjectDetailErrorProviderElement
    extends AutoDisposeProviderElement<String?>
    with SubjectDetailErrorRef {
  _SubjectDetailErrorProviderElement(super.provider);

  @override
  String get subjectId => (origin as SubjectDetailErrorProvider).subjectId;
}

String _$subjectDetailNotifierHash() =>
    r'13d83c327664e8f645e4eebb4037143aacf57888';

abstract class _$SubjectDetailNotifier
    extends BuildlessAutoDisposeNotifier<SubjectDetailState> {
  late final String subjectId;

  SubjectDetailState build(String subjectId);
}

/// Riverpod notifier for managing subject detail state.
///
/// Handles loading, refreshing, and managing subject detail data.
/// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
///
/// Copied from [SubjectDetailNotifier].
@ProviderFor(SubjectDetailNotifier)
const subjectDetailNotifierProvider = SubjectDetailNotifierFamily();

/// Riverpod notifier for managing subject detail state.
///
/// Handles loading, refreshing, and managing subject detail data.
/// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
///
/// Copied from [SubjectDetailNotifier].
class SubjectDetailNotifierFamily extends Family<SubjectDetailState> {
  /// Riverpod notifier for managing subject detail state.
  ///
  /// Handles loading, refreshing, and managing subject detail data.
  /// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
  ///
  /// Copied from [SubjectDetailNotifier].
  const SubjectDetailNotifierFamily();

  /// Riverpod notifier for managing subject detail state.
  ///
  /// Handles loading, refreshing, and managing subject detail data.
  /// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
  ///
  /// Copied from [SubjectDetailNotifier].
  SubjectDetailNotifierProvider call(String subjectId) {
    return SubjectDetailNotifierProvider(subjectId);
  }

  @override
  SubjectDetailNotifierProvider getProviderOverride(
    covariant SubjectDetailNotifierProvider provider,
  ) {
    return call(provider.subjectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subjectDetailNotifierProvider';
}

/// Riverpod notifier for managing subject detail state.
///
/// Handles loading, refreshing, and managing subject detail data.
/// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
///
/// Copied from [SubjectDetailNotifier].
class SubjectDetailNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<
          SubjectDetailNotifier,
          SubjectDetailState
        > {
  /// Riverpod notifier for managing subject detail state.
  ///
  /// Handles loading, refreshing, and managing subject detail data.
  /// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
  ///
  /// Copied from [SubjectDetailNotifier].
  SubjectDetailNotifierProvider(String subjectId)
    : this._internal(
        () => SubjectDetailNotifier()..subjectId = subjectId,
        from: subjectDetailNotifierProvider,
        name: r'subjectDetailNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subjectDetailNotifierHash,
        dependencies: SubjectDetailNotifierFamily._dependencies,
        allTransitiveDependencies:
            SubjectDetailNotifierFamily._allTransitiveDependencies,
        subjectId: subjectId,
      );

  SubjectDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.subjectId,
  }) : super.internal();

  final String subjectId;

  @override
  SubjectDetailState runNotifierBuild(
    covariant SubjectDetailNotifier notifier,
  ) {
    return notifier.build(subjectId);
  }

  @override
  Override overrideWith(SubjectDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SubjectDetailNotifierProvider._internal(
        () => create()..subjectId = subjectId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        subjectId: subjectId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SubjectDetailNotifier, SubjectDetailState>
  createElement() {
    return _SubjectDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectDetailNotifierProvider &&
        other.subjectId == subjectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, subjectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubjectDetailNotifierRef
    on AutoDisposeNotifierProviderRef<SubjectDetailState> {
  /// The parameter `subjectId` of this provider.
  String get subjectId;
}

class _SubjectDetailNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          SubjectDetailNotifier,
          SubjectDetailState
        >
    with SubjectDetailNotifierRef {
  _SubjectDetailNotifierProviderElement(super.provider);

  @override
  String get subjectId => (origin as SubjectDetailNotifierProvider).subjectId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
