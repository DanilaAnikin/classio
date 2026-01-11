// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardDataHash() => r'f28dbb50666acf84ff2199c5eb9a030621b5ac7b';

/// Provider that returns the current dashboard data or null.
///
/// Copied from [dashboardData].
@ProviderFor(dashboardData)
final dashboardDataProvider = AutoDisposeProvider<DashboardData?>.internal(
  dashboardData,
  name: r'dashboardDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dashboardDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardDataRef = AutoDisposeProviderRef<DashboardData?>;
String _$todayLessonsHash() => r'b3fd406749e21e10cc586152de2ec251bf6f1549';

/// Provider that returns today's lessons.
///
/// Copied from [todayLessons].
@ProviderFor(todayLessons)
final todayLessonsProvider = AutoDisposeProvider<List<Lesson>>.internal(
  todayLessons,
  name: r'todayLessonsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayLessonsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayLessonsRef = AutoDisposeProviderRef<List<Lesson>>;
String _$upcomingAssignmentsHash() =>
    r'b6adc4cb6938b5b63eae19ad0d90cd7773e0964e';

/// Provider that returns upcoming assignments.
///
/// Copied from [upcomingAssignments].
@ProviderFor(upcomingAssignments)
final upcomingAssignmentsProvider =
    AutoDisposeProvider<List<Assignment>>.internal(
      upcomingAssignments,
      name: r'upcomingAssignmentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$upcomingAssignmentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingAssignmentsRef = AutoDisposeProviderRef<List<Assignment>>;
String _$currentLessonHash() => r'f618f5146c822151c9a49cfb722325b4e5784cb2';

/// Provider that returns the current active lesson if any.
///
/// Copied from [currentLesson].
@ProviderFor(currentLesson)
final currentLessonProvider = AutoDisposeProvider<Lesson?>.internal(
  currentLesson,
  name: r'currentLessonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLessonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLessonRef = AutoDisposeProviderRef<Lesson?>;
String _$nextLessonHash() => r'74628245f09d326f2de5e385d983d40cb5d8f843';

/// Provider that returns the next upcoming lesson if any.
///
/// Copied from [nextLesson].
@ProviderFor(nextLesson)
final nextLessonProvider = AutoDisposeProvider<Lesson?>.internal(
  nextLesson,
  name: r'nextLessonProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$nextLessonHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NextLessonRef = AutoDisposeProviderRef<Lesson?>;
String _$dashboardNotifierHash() => r'c1155170e7d83c7a0e6ca93939713914f73a015e';

/// Riverpod notifier for managing dashboard state.
///
/// Handles loading, refreshing, and managing dashboard data.
/// Uses [DashboardRepository] to fetch data and updates [DashboardState] accordingly.
///
/// Copied from [DashboardNotifier].
@ProviderFor(DashboardNotifier)
final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardState>.internal(
      DashboardNotifier.new,
      name: r'dashboardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DashboardNotifier = Notifier<DashboardState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
