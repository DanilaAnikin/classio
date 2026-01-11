// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scheduleRepositoryHash() =>
    r'8987a4098b3bb6c4a484d169867d3776b802f3a1';

/// Provider for the schedule repository.
///
/// Can be overridden in tests to provide a mock implementation.
///
/// Copied from [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider =
    AutoDisposeProvider<ScheduleRepository>.internal(
      scheduleRepository,
      name: r'scheduleRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$scheduleRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleRepositoryRef = AutoDisposeProviderRef<ScheduleRepository>;
String _$weekLessonsHash() => r'e0197eb33523f75f406eb04fc1db052273040290';

/// Provider that fetches lessons for the entire week.
///
/// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
/// and values are lists of lessons for that day.
///
/// Copied from [weekLessons].
@ProviderFor(weekLessons)
final weekLessonsProvider =
    AutoDisposeFutureProvider<Map<int, List<Lesson>>>.internal(
      weekLessons,
      name: r'weekLessonsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weekLessonsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeekLessonsRef = AutoDisposeFutureProviderRef<Map<int, List<Lesson>>>;
String _$selectedDayLessonsHash() =>
    r'2958ecb39908b4af6e87a2f26acd89487cc83392';

/// Provider that returns lessons for the currently selected day.
///
/// Filters the week lessons based on the selected day provider.
///
/// Copied from [selectedDayLessons].
@ProviderFor(selectedDayLessons)
final selectedDayLessonsProvider = AutoDisposeProvider<List<Lesson>>.internal(
  selectedDayLessons,
  name: r'selectedDayLessonsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedDayLessonsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedDayLessonsRef = AutoDisposeProviderRef<List<Lesson>>;
String _$isScheduleLoadingHash() => r'4e57540c8449abcdd82447ee9976459755f76281';

/// Provider that returns the loading state of the week lessons.
///
/// Copied from [isScheduleLoading].
@ProviderFor(isScheduleLoading)
final isScheduleLoadingProvider = AutoDisposeProvider<bool>.internal(
  isScheduleLoading,
  name: r'isScheduleLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isScheduleLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsScheduleLoadingRef = AutoDisposeProviderRef<bool>;
String _$scheduleErrorHash() => r'53c1d00588d7723da3cc4bfaccb48640069bc0e9';

/// Provider that returns any error from loading the schedule.
///
/// Copied from [scheduleError].
@ProviderFor(scheduleError)
final scheduleErrorProvider = AutoDisposeProvider<String?>.internal(
  scheduleError,
  name: r'scheduleErrorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleErrorRef = AutoDisposeProviderRef<String?>;
String _$selectedDayHash() => r'cc8761b8e2282caad0147ea78ee4a96e11e814a9';

/// Provider for the selected weekday in the schedule view.
///
/// Uses weekday numbering where 1=Monday and 7=Sunday.
/// Defaults to the current weekday.
///
/// Copied from [SelectedDay].
@ProviderFor(SelectedDay)
final selectedDayProvider =
    AutoDisposeNotifierProvider<SelectedDay, int>.internal(
      SelectedDay.new,
      name: r'selectedDayProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDayHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDay = AutoDisposeNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
