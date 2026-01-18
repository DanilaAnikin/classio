import '../../../dashboard/domain/entities/lesson.dart';

/// Repository interface for schedule data operations.
///
/// Defines the contract for fetching schedule-related data such as
/// lessons for a specific day or an entire week.
///
/// Supports stable timetable functionality with week-specific modifications.
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

  /// Fetches the stable (baseline) timetable for a class.
  ///
  /// The [classId] parameter specifies which class to fetch the timetable for.
  /// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
  /// and values are lists of stable [Lesson] objects for that day.
  Future<Map<int, List<Lesson>>> getStableTimetable(String classId);

  /// Fetches lessons for a specific week for a class.
  ///
  /// The [classId] parameter specifies which class to fetch lessons for.
  /// The [weekStartDate] should be the Monday of the desired week.
  /// If no week-specific lessons exist, returns the stable timetable.
  /// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
  /// and values are lists of [Lesson] objects for that day.
  Future<Map<int, List<Lesson>>> getWeekTimetable(
    String classId,
    DateTime weekStartDate,
  );

  /// Creates week-specific lessons from the stable timetable.
  ///
  /// The [classId] parameter specifies which class to create lessons for.
  /// The [weekStartDate] should be the Monday of the desired week.
  /// Copies all stable lessons to create week-specific copies that can be modified.
  /// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday)
  /// and values are lists of the newly created [Lesson] objects.
  Future<Map<int, List<Lesson>>> createWeekFromStable(
    String classId,
    DateTime weekStartDate,
  );

  /// Updates a week-specific lesson and marks it as modified if different from stable.
  ///
  /// The [lessonId] is the ID of the lesson to update.
  /// Only non-stable lessons can be updated using this method.
  /// After update, the lesson's [modifiedFromStable] flag will be set appropriately.
  Future<Lesson> updateWeekLesson({
    required String lessonId,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  });

  /// Gets the stable lesson associated with a week-specific lesson.
  ///
  /// Returns null if the lesson has no associated stable lesson.
  Future<Lesson?> getStableLessonFor(String lessonId);
}
