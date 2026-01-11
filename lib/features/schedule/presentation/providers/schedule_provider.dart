import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dashboard/domain/entities/lesson.dart';
import '../../data/repositories/supabase_schedule_repository.dart';
import '../../domain/repositories/schedule_repository.dart';

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

/// Provider that fetches lessons for the entire week.
///
/// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
/// and values are lists of lessons for that day.
@riverpod
Future<Map<int, List<Lesson>>> weekLessons(Ref ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);

  // Get the Monday of the current week
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final weekStart = DateTime(monday.year, monday.month, monday.day);

  return repository.getWeekLessons(weekStart);
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
