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
String _$weekLessonsHash() => r'552128733d8a3f9ea62c8cd63c30adb1b07ec6b3';

/// Provider that fetches lessons for the entire week.
///
/// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
/// and values are lists of lessons for that day.
/// Reacts to the selected week view from the week selector.
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
String _$stableTimetableHash() => r'7013bad3d02ebf001add55bdc2a63bd95b20e5c3';

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

/// Provider for the stable timetable for a specific class.
///
/// Takes a class ID as a parameter and returns the stable lessons.
///
/// Copied from [stableTimetable].
@ProviderFor(stableTimetable)
const stableTimetableProvider = StableTimetableFamily();

/// Provider for the stable timetable for a specific class.
///
/// Takes a class ID as a parameter and returns the stable lessons.
///
/// Copied from [stableTimetable].
class StableTimetableFamily extends Family<AsyncValue<Map<int, List<Lesson>>>> {
  /// Provider for the stable timetable for a specific class.
  ///
  /// Takes a class ID as a parameter and returns the stable lessons.
  ///
  /// Copied from [stableTimetable].
  const StableTimetableFamily();

  /// Provider for the stable timetable for a specific class.
  ///
  /// Takes a class ID as a parameter and returns the stable lessons.
  ///
  /// Copied from [stableTimetable].
  StableTimetableProvider call(String classId) {
    return StableTimetableProvider(classId);
  }

  @override
  StableTimetableProvider getProviderOverride(
    covariant StableTimetableProvider provider,
  ) {
    return call(provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'stableTimetableProvider';
}

/// Provider for the stable timetable for a specific class.
///
/// Takes a class ID as a parameter and returns the stable lessons.
///
/// Copied from [stableTimetable].
class StableTimetableProvider
    extends AutoDisposeFutureProvider<Map<int, List<Lesson>>> {
  /// Provider for the stable timetable for a specific class.
  ///
  /// Takes a class ID as a parameter and returns the stable lessons.
  ///
  /// Copied from [stableTimetable].
  StableTimetableProvider(String classId)
    : this._internal(
        (ref) => stableTimetable(ref as StableTimetableRef, classId),
        from: stableTimetableProvider,
        name: r'stableTimetableProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$stableTimetableHash,
        dependencies: StableTimetableFamily._dependencies,
        allTransitiveDependencies:
            StableTimetableFamily._allTransitiveDependencies,
        classId: classId,
      );

  StableTimetableProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final String classId;

  @override
  Override overrideWith(
    FutureOr<Map<int, List<Lesson>>> Function(StableTimetableRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StableTimetableProvider._internal(
        (ref) => create(ref as StableTimetableRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, List<Lesson>>> createElement() {
    return _StableTimetableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StableTimetableProvider && other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StableTimetableRef
    on AutoDisposeFutureProviderRef<Map<int, List<Lesson>>> {
  /// The parameter `classId` of this provider.
  String get classId;
}

class _StableTimetableProviderElement
    extends AutoDisposeFutureProviderElement<Map<int, List<Lesson>>>
    with StableTimetableRef {
  _StableTimetableProviderElement(super.provider);

  @override
  String get classId => (origin as StableTimetableProvider).classId;
}

String _$weekTimetableHash() => r'20712e3f8a6b9d5fe2a947632d1c902eea735df3';

/// Provider for week timetable for a specific class and week.
///
/// Takes a class ID and week start date as parameters.
///
/// Copied from [weekTimetable].
@ProviderFor(weekTimetable)
const weekTimetableProvider = WeekTimetableFamily();

/// Provider for week timetable for a specific class and week.
///
/// Takes a class ID and week start date as parameters.
///
/// Copied from [weekTimetable].
class WeekTimetableFamily extends Family<AsyncValue<Map<int, List<Lesson>>>> {
  /// Provider for week timetable for a specific class and week.
  ///
  /// Takes a class ID and week start date as parameters.
  ///
  /// Copied from [weekTimetable].
  const WeekTimetableFamily();

  /// Provider for week timetable for a specific class and week.
  ///
  /// Takes a class ID and week start date as parameters.
  ///
  /// Copied from [weekTimetable].
  WeekTimetableProvider call(String classId, DateTime weekStartDate) {
    return WeekTimetableProvider(classId, weekStartDate);
  }

  @override
  WeekTimetableProvider getProviderOverride(
    covariant WeekTimetableProvider provider,
  ) {
    return call(provider.classId, provider.weekStartDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weekTimetableProvider';
}

/// Provider for week timetable for a specific class and week.
///
/// Takes a class ID and week start date as parameters.
///
/// Copied from [weekTimetable].
class WeekTimetableProvider
    extends AutoDisposeFutureProvider<Map<int, List<Lesson>>> {
  /// Provider for week timetable for a specific class and week.
  ///
  /// Takes a class ID and week start date as parameters.
  ///
  /// Copied from [weekTimetable].
  WeekTimetableProvider(String classId, DateTime weekStartDate)
    : this._internal(
        (ref) => weekTimetable(ref as WeekTimetableRef, classId, weekStartDate),
        from: weekTimetableProvider,
        name: r'weekTimetableProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$weekTimetableHash,
        dependencies: WeekTimetableFamily._dependencies,
        allTransitiveDependencies:
            WeekTimetableFamily._allTransitiveDependencies,
        classId: classId,
        weekStartDate: weekStartDate,
      );

  WeekTimetableProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.weekStartDate,
  }) : super.internal();

  final String classId;
  final DateTime weekStartDate;

  @override
  Override overrideWith(
    FutureOr<Map<int, List<Lesson>>> Function(WeekTimetableRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeekTimetableProvider._internal(
        (ref) => create(ref as WeekTimetableRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        weekStartDate: weekStartDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, List<Lesson>>> createElement() {
    return _WeekTimetableProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeekTimetableProvider &&
        other.classId == classId &&
        other.weekStartDate == weekStartDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, weekStartDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WeekTimetableRef on AutoDisposeFutureProviderRef<Map<int, List<Lesson>>> {
  /// The parameter `classId` of this provider.
  String get classId;

  /// The parameter `weekStartDate` of this provider.
  DateTime get weekStartDate;
}

class _WeekTimetableProviderElement
    extends AutoDisposeFutureProviderElement<Map<int, List<Lesson>>>
    with WeekTimetableRef {
  _WeekTimetableProviderElement(super.provider);

  @override
  String get classId => (origin as WeekTimetableProvider).classId;
  @override
  DateTime get weekStartDate => (origin as WeekTimetableProvider).weekStartDate;
}

String _$isViewingStableHash() => r'78a40d6c69769af6a2ec5962d5eae866773c2d95';

/// Provider to check if the current view is showing the stable timetable.
///
/// Copied from [isViewingStable].
@ProviderFor(isViewingStable)
final isViewingStableProvider = AutoDisposeProvider<bool>.internal(
  isViewingStable,
  name: r'isViewingStableProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isViewingStableHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsViewingStableRef = AutoDisposeProviderRef<bool>;
String _$lessonIsModifiedHash() => r'7afd3374ef92f8129251ce6746b1f235cf4f9b08';

/// Provider to check if a lesson has been modified from stable.
///
/// Copied from [lessonIsModified].
@ProviderFor(lessonIsModified)
const lessonIsModifiedProvider = LessonIsModifiedFamily();

/// Provider to check if a lesson has been modified from stable.
///
/// Copied from [lessonIsModified].
class LessonIsModifiedFamily extends Family<bool> {
  /// Provider to check if a lesson has been modified from stable.
  ///
  /// Copied from [lessonIsModified].
  const LessonIsModifiedFamily();

  /// Provider to check if a lesson has been modified from stable.
  ///
  /// Copied from [lessonIsModified].
  LessonIsModifiedProvider call(Lesson lesson) {
    return LessonIsModifiedProvider(lesson);
  }

  @override
  LessonIsModifiedProvider getProviderOverride(
    covariant LessonIsModifiedProvider provider,
  ) {
    return call(provider.lesson);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lessonIsModifiedProvider';
}

/// Provider to check if a lesson has been modified from stable.
///
/// Copied from [lessonIsModified].
class LessonIsModifiedProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if a lesson has been modified from stable.
  ///
  /// Copied from [lessonIsModified].
  LessonIsModifiedProvider(Lesson lesson)
    : this._internal(
        (ref) => lessonIsModified(ref as LessonIsModifiedRef, lesson),
        from: lessonIsModifiedProvider,
        name: r'lessonIsModifiedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$lessonIsModifiedHash,
        dependencies: LessonIsModifiedFamily._dependencies,
        allTransitiveDependencies:
            LessonIsModifiedFamily._allTransitiveDependencies,
        lesson: lesson,
      );

  LessonIsModifiedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lesson,
  }) : super.internal();

  final Lesson lesson;

  @override
  Override overrideWith(bool Function(LessonIsModifiedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: LessonIsModifiedProvider._internal(
        (ref) => create(ref as LessonIsModifiedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lesson: lesson,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _LessonIsModifiedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LessonIsModifiedProvider && other.lesson == lesson;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lesson.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LessonIsModifiedRef on AutoDisposeProviderRef<bool> {
  /// The parameter `lesson` of this provider.
  Lesson get lesson;
}

class _LessonIsModifiedProviderElement extends AutoDisposeProviderElement<bool>
    with LessonIsModifiedRef {
  _LessonIsModifiedProviderElement(super.provider);

  @override
  Lesson get lesson => (origin as LessonIsModifiedProvider).lesson;
}

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
