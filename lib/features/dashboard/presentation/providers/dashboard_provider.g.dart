// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dashboardRepositoryHash() =>
    r'69e7d397cf2439b8619428de06916547081ba024';

/// Provider for the DashboardRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
///
/// Copied from [dashboardRepository].
@ProviderFor(dashboardRepository)
final dashboardRepositoryProvider =
    AutoDisposeProvider<DashboardRepository>.internal(
      dashboardRepository,
      name: r'dashboardRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dashboardRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DashboardRepositoryRef = AutoDisposeProviderRef<DashboardRepository>;
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
String _$dashboardNotifierHash() => r'b793e401f41517a4b886ae63c3a736b1c59e26aa';

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
