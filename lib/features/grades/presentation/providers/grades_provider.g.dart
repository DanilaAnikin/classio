// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gradesRepositoryHash() => r'f9b12b16823b6cc9366337b91684c0a0f3a7af11';

/// Provider for the GradesRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
///
/// Copied from [gradesRepository].
@ProviderFor(gradesRepository)
final gradesRepositoryProvider = AutoDisposeProvider<GradesRepository>.internal(
  gradesRepository,
  name: r'gradesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gradesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GradesRepositoryRef = AutoDisposeProviderRef<GradesRepository>;
String _$subjectGradesListHash() => r'c91b254ef501f682b7a1728643bf66b55f17df4c';

/// Provider that returns the list of SubjectGradeStats or an empty list.
///
/// Returns an empty list if data is not yet loaded or if there's an error.
///
/// Copied from [subjectGradesList].
@ProviderFor(subjectGradesList)
final subjectGradesListProvider =
    AutoDisposeProvider<List<SubjectGradeStats>>.internal(
      subjectGradesList,
      name: r'subjectGradesListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subjectGradesListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SubjectGradesListRef = AutoDisposeProviderRef<List<SubjectGradeStats>>;
String _$overallAverageHash() => r'cf1102d6b80a5be172dfc4fd48bd2a683de1c1db';

/// Provider that calculates the overall average across all subjects.
///
/// Calculates the average of all subject averages.
/// Returns 0.0 if there are no subjects or data is not yet loaded.
///
/// Copied from [overallAverage].
@ProviderFor(overallAverage)
final overallAverageProvider = AutoDisposeProvider<double>.internal(
  overallAverage,
  name: r'overallAverageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overallAverageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverallAverageRef = AutoDisposeProviderRef<double>;
String _$gradesNotifierHash() => r'9b9589571dae9b99014f17512f8f804d5fdb944e';

/// Riverpod notifier for managing grades state.
///
/// Handles loading, refreshing, and managing grade data for all subjects.
/// Uses [GradesRepository] to fetch data and updates [AsyncValue<List<SubjectGradeStats>>] accordingly.
///
/// Copied from [GradesNotifier].
@ProviderFor(GradesNotifier)
final gradesNotifierProvider =
    AsyncNotifierProvider<GradesNotifier, List<SubjectGradeStats>>.internal(
      GradesNotifier.new,
      name: r'gradesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gradesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GradesNotifier = AsyncNotifier<List<SubjectGradeStats>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
