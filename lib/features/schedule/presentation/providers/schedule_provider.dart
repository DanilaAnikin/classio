import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dashboard/domain/entities/lesson.dart';
import '../../data/repositories/supabase_schedule_repository.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../widgets/week_selector.dart';

part 'schedule_provider.g.dart';

/// Provider for the selected weekday in the schedule view.
///
/// Uses weekday numbering where 1=Monday and 7=Sunday.
/// Defaults to the current weekday.
@riverpod
class SelectedDay extends _$SelectedDay {
  @override
  int build() {
    // Default to current weekday (1=Monday, 7=Sunday)
    return DateTime.now().weekday;
  }

  /// Sets the selected day to the specified weekday number.
  void selectDay(int weekday) {
    if (weekday >= 1 && weekday <= 7) {
      state = weekday;
    }
  }
}

/// Provider for the schedule repository.
///
/// Can be overridden in tests to provide a mock implementation.
@riverpod
ScheduleRepository scheduleRepository(Ref ref) {
  return SupabaseScheduleRepository();
}

/// Helper function to get the Monday of the week containing a date.
DateTime _getMondayOfWeek(DateTime date) {
  return DateTime(date.year, date.month, date.day - (date.weekday - 1));
}

/// Provider that fetches lessons for the entire week.
///
/// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
/// and values are lists of lessons for that day.
/// Reacts to the selected week view from the week selector.
@riverpod
Future<Map<int, List<Lesson>>> weekLessons(Ref ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  final weekView = ref.watch(selectedWeekViewProvider);
  final weekStartDate = ref.watch(selectedWeekStartDateProvider);

  if (weekView == WeekViewType.stable) {
    // For stable view, get the stable timetable
    // We need a class ID - for now, use the repository's default behavior
    return repository.getWeekLessons(_getMondayOfWeek(DateTime.now()));
  }

  if (weekStartDate != null) {
    return repository.getWeekLessons(weekStartDate);
  }

  // Fallback to current week
  final now = DateTime.now();
  final monday = _getMondayOfWeek(now);
  return repository.getWeekLessons(monday);
}

/// Provider that returns lessons for the currently selected day.
///
/// Filters the week lessons based on the selected day provider.
@riverpod
List<Lesson> selectedDayLessons(Ref ref) {
  final selectedDay = ref.watch(selectedDayProvider);
  final weekLessonsAsync = ref.watch(weekLessonsProvider);

  return weekLessonsAsync.when(
    data: (weekLessons) => weekLessons[selectedDay] ?? [],
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider that returns the loading state of the week lessons.
@riverpod
bool isScheduleLoading(Ref ref) {
  return ref.watch(weekLessonsProvider).isLoading;
}

/// Provider that returns any error from loading the schedule.
@riverpod
String? scheduleError(Ref ref) {
  final weekLessons = ref.watch(weekLessonsProvider);
  return weekLessons.whenOrNull(
    error: (error, _) => error.toString(),
  );
}

/// Provider for the stable timetable for a specific class.
///
/// Takes a class ID as a parameter and returns the stable lessons.
@riverpod
Future<Map<int, List<Lesson>>> stableTimetable(
  Ref ref,
  String classId,
) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getStableTimetable(classId);
}

/// Provider for week timetable for a specific class and week.
///
/// Takes a class ID and week start date as parameters.
@riverpod
Future<Map<int, List<Lesson>>> weekTimetable(
  Ref ref,
  String classId,
  DateTime weekStartDate,
) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getWeekTimetable(classId, weekStartDate);
}

/// Provider to check if the current view is showing the stable timetable.
@riverpod
bool isViewingStable(Ref ref) {
  final weekView = ref.watch(selectedWeekViewProvider);
  return weekView == WeekViewType.stable;
}

/// Provider to check if a lesson has been modified from stable.
@riverpod
bool lessonIsModified(Ref ref, Lesson lesson) {
  return lesson.modifiedFromStable;
}
