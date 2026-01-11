import '../../../dashboard/domain/entities/lesson.dart';

/// Repository interface for schedule data operations.
///
/// Defines the contract for fetching schedule-related data such as
/// lessons for a specific day or an entire week.
abstract class ScheduleRepository {
  /// Fetches all lessons scheduled for a specific day.
  ///
  /// The [date] parameter specifies which day to fetch lessons for.
  /// Returns a list of [Lesson] objects sorted by start time.
  Future<List<Lesson>> getLessonsForDay(DateTime date);

  /// Fetches lessons for an entire week starting from [weekStart].
  ///
  /// The [weekStart] should be the Monday of the desired week.
  /// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
  /// and values are lists of [Lesson] objects for that day.
  Future<Map<int, List<Lesson>>> getWeekLessons(DateTime weekStart);
}
