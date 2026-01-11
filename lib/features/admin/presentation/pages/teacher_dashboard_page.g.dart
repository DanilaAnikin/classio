// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'teacher_dashboard_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mySubjectsHash() => r'505374bde50e1123d395c178e33ce672fbd7e2b1';

/// Provider that fetches subjects assigned to the current teacher.
///
/// Uses [TeacherRepository.getMySubjects] to fetch subjects where
/// teacher_id matches the current user's ID.
///
/// Copied from [mySubjects].
@ProviderFor(mySubjects)
final mySubjectsProvider = AutoDisposeFutureProvider<List<Subject>>.internal(
  mySubjects,
  name: r'mySubjectsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mySubjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MySubjectsRef = AutoDisposeFutureProviderRef<List<Subject>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
