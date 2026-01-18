import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/subject_colors.dart';
import '../../../dashboard/domain/entities/lesson.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/repositories/schedule_repository.dart';

/// Safely parses a time string (HH:MM or HH:MM:SS) into a DateTime.
/// Returns null if parsing fails.
DateTime? _parseTimeString(String? timeStr, DateTime date) {
  if (timeStr == null || timeStr.isEmpty) return null;

  try {
    final parts = timeStr.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return DateTime(date.year, date.month, date.day, hour, minute);
  } catch (e) {
    debugPrint('Failed to parse time string "$timeStr": $e');
    return null;
  }
}

/// Safely parses a date string (YYYY-MM-DD) into a DateTime.
/// Returns null if parsing fails.
DateTime? _parseDateString(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;

  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    debugPrint('Failed to parse date string "$dateStr": $e');
    return null;
  }
}

/// Exception thrown when schedule operations fail.
class ScheduleException implements Exception {
  const ScheduleException(this.message);

  final String message;

  @override
  String toString() => 'ScheduleException: $message';
}

/// Supabase implementation of [ScheduleRepository].
///
/// Fetches schedule data from Supabase database, querying the lessons table
/// and joining with subjects to get subject names. Filters lessons by the
/// current user's class enrollment.
///
/// Supports stable timetable functionality where lessons can be either:
/// - Stable: baseline lessons that repeat every week
/// - Week-specific: copies of stable lessons for a specific week that can be modified
class SupabaseScheduleRepository implements ScheduleRepository {
  /// Creates a [SupabaseScheduleRepository] instance.
  SupabaseScheduleRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Cache for the current user's class ID to avoid repeated queries.
  String? _cachedClassId;

  /// Standard select query for lessons with all necessary joins.
  /// Note: lessons table does NOT have class_id - use subjects.class_id instead.
  static const String _lessonSelectQuery = '''
    id,
    subject_id,
    day_of_week,
    start_time,
    end_time,
    room,
    is_stable,
    stable_lesson_id,
    modified_from_stable,
    week_start_date,
    subjects (
      id,
      name,
      class_id,
      teacher:profiles!subjects_teacher_id_fkey (
        first_name,
        last_name
      )
    )
  ''';

  /// Gets the current user's class ID from the class_students table.
  ///
  /// Returns the class ID if the user is enrolled in a class, null otherwise.
  /// Results are cached to avoid repeated database queries.
  Future<String?> _getCurrentUserClassId() async {
    // Return cached value if available
    if (_cachedClassId != null) {
      return _cachedClassId;
    }

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      // Query class_students to find the user's class enrollment
      final response = await _supabase
          .from('class_students')
          .select('class_id')
          .eq('student_id', userId)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _cachedClassId = response['class_id'] as String?;
        return _cachedClassId;
      }

      return null;
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to get user class: ${e.message}');
    }
  }

  /// Clears the cached class ID.
  ///
  /// Call this method when the user's class enrollment changes.
  void clearCache() {
    _cachedClassId = null;
  }

  /// Gets subject IDs for a given class.
  ///
  /// Since lessons link to classes through subjects (lessons -> subjects -> class),
  /// we need to first get the subject IDs for a class before querying lessons.
  Future<List<String>> _getSubjectIdsForClass(String classId) async {
    try {
      final response = await _supabase
          .from('subjects')
          .select('id')
          .eq('class_id', classId);

      return (response as List).map((r) => r['id'] as String).toList();
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to get subjects for class: ${e.message}');
    }
  }

  /// Converts a database row to a [Lesson] entity.
  ///
  /// The [row] should contain lesson data joined with subject data.
  /// The [date] is the actual date for this lesson occurrence.
  /// If [stableLesson] is provided, it will be attached to the lesson for comparison.
  Lesson _rowToLesson(
    Map<String, dynamic> row,
    DateTime date, {
    Lesson? stableLesson,
  }) {
    final subjectData = row['subjects'] as Map<String, dynamic>?;
    final teacherData = subjectData?['teacher'] as Map<String, dynamic>?;

    // Parse start and end times from the database using safe parsing
    final startTimeStr = row['start_time'] as String?;
    final endTimeStr = row['end_time'] as String?;

    // Default times if parsing fails
    final defaultStart = DateTime(date.year, date.month, date.day, 8, 0);
    final defaultEnd = DateTime(date.year, date.month, date.day, 8, 45);

    final startTime = _parseTimeString(startTimeStr, date) ?? defaultStart;
    final endTime = _parseTimeString(endTimeStr, date) ?? defaultEnd;

    // Build teacher name from profile data
    String? teacherName;
    if (teacherData != null) {
      final firstName = teacherData['first_name'] as String?;
      final lastName = teacherData['last_name'] as String?;
      if (firstName != null || lastName != null) {
        teacherName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    final subjectId = (subjectData?['id'] ?? row['subject_id'] ?? '') as String;
    final subjectName = (subjectData?['name'] ?? 'Unknown Subject') as String;

    final subject = Subject(
      id: subjectId,
      name: subjectName,
      color: SubjectColors.getColorForId(subjectId),
      teacherName: teacherName,
    );

    // Parse stable timetable fields
    final isStable = (row['is_stable'] as bool?) ?? false;
    final stableLessonId = row['stable_lesson_id'] as String?;
    final modifiedFromStable = (row['modified_from_stable'] as bool?) ?? false;
    final weekStartDateStr = row['week_start_date'] as String?;
    final weekStartDate = _parseDateString(weekStartDateStr);

    return Lesson(
      id: row['id'] as String,
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      room: (row['room'] as String?) ?? '',
      status: LessonStatus.normal,
      isStable: isStable,
      stableLessonId: stableLessonId,
      modifiedFromStable: modifiedFromStable,
      weekStartDate: weekStartDate,
      stableLesson: stableLesson,
    );
  }

  /// Converts a weekday number (1=Monday to 7=Sunday) to the database
  /// day_of_week format (0=Sunday to 6=Saturday).
  int _dartWeekdayToDbDayOfWeek(int dartWeekday) {
    // Dart: 1=Monday, 2=Tuesday, ..., 7=Sunday
    // Database: 0=Sunday, 1=Monday, ..., 6=Saturday
    return dartWeekday == 7 ? 0 : dartWeekday;
  }

  /// Converts a database day_of_week (0=Sunday to 6=Saturday) to
  /// Dart weekday format (1=Monday to 7=Sunday).
  int _dbDayOfWeekToDartWeekday(int dbDayOfWeek) {
    // Database: 0=Sunday, 1=Monday, ..., 6=Saturday
    // Dart: 1=Monday, 2=Tuesday, ..., 7=Sunday
    return dbDayOfWeek == 0 ? 7 : dbDayOfWeek;
  }

  /// Formats a DateTime to a date string suitable for the database (YYYY-MM-DD).
  String _formatDateForDb(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Returns the Monday of the week containing the given date.
  DateTime _getMondayOfWeek(DateTime date) {
    // weekday: 1=Monday, 7=Sunday
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  @override
  Future<List<Lesson>> getLessonsForDay(DateTime date) async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) {
      return [];
    }

    final dbDayOfWeek = _dartWeekdayToDbDayOfWeek(date.weekday);
    final weekStartDate = _getMondayOfWeek(date);

    try {
      // Get subject IDs for this class (lessons link to classes through subjects)
      final subjectIds = await _getSubjectIdsForClass(classId);
      if (subjectIds.isEmpty) {
        return [];
      }

      // First try to get week-specific lessons
      final weekDateStr = _formatDateForDb(weekStartDate);
      var response = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .inFilter('subject_id', subjectIds)
          .eq('day_of_week', dbDayOfWeek)
          .eq('week_start_date', weekDateStr)
          .order('start_time', ascending: true);

      // If no week-specific lessons, fall back to stable lessons
      if ((response as List).isEmpty) {
        response = await _supabase
            .from('lessons')
            .select(_lessonSelectQuery)
            .inFilter('subject_id', subjectIds)
            .eq('day_of_week', dbDayOfWeek)
            .eq('is_stable', true)
            .order('start_time', ascending: true);
      }

      // Build a map of stable lessons for comparison
      final stableLessonsMap = <String, Lesson>{};
      for (final row in response) {
        if (row['stable_lesson_id'] != null) {
          final stableLessonResponse = await _supabase
              .from('lessons')
              .select(_lessonSelectQuery)
              .eq('id', row['stable_lesson_id'])
              .maybeSingle();
          if (stableLessonResponse != null) {
            final stableLesson = _rowToLesson(stableLessonResponse, date);
            stableLessonsMap[stableLesson.id] = stableLesson;
          }
        }
      }

      final lessons = <Lesson>[];
      for (final row in response) {
        final stableLessonId = row['stable_lesson_id'] as String?;
        final stableLesson = stableLessonId != null
            ? stableLessonsMap[stableLessonId]
            : null;
        lessons.add(_rowToLesson(row, date, stableLesson: stableLesson));
      }

      return lessons;
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to fetch lessons: ${e.message}');
    }
  }

  @override
  Future<Map<int, List<Lesson>>> getWeekLessons(DateTime weekStart) async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) {
      return {for (int i = 1; i <= 7; i++) i: <Lesson>[]};
    }

    return getWeekTimetable(classId, weekStart);
  }

  @override
  Future<Map<int, List<Lesson>>> getStableTimetable(String classId) async {
    try {
      // Get subject IDs for this class (lessons link to classes through subjects)
      final subjectIds = await _getSubjectIdsForClass(classId);
      if (subjectIds.isEmpty) {
        return {for (int i = 1; i <= 7; i++) i: <Lesson>[]};
      }

      final response = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .inFilter('subject_id', subjectIds)
          .eq('is_stable', true)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      // Initialize the result map with empty lists for all weekdays
      final weekLessons = <int, List<Lesson>>{
        for (int i = 1; i <= 7; i++) i: <Lesson>[],
      };

      // Use today as the base date for stable lessons
      final today = DateTime.now();
      final mondayOfWeek = _getMondayOfWeek(today);

      for (final row in response as List) {
        final dbDayOfWeek = row['day_of_week'] as int;
        final dartWeekday = _dbDayOfWeekToDartWeekday(dbDayOfWeek);

        // Calculate the actual date for this lesson in the current week
        final lessonDate = mondayOfWeek.add(Duration(days: dartWeekday - 1));

        final lesson = _rowToLesson(row, lessonDate);
        weekLessons[dartWeekday]!.add(lesson);
      }

      return weekLessons;
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to fetch stable timetable: ${e.message}');
    }
  }

  @override
  Future<Map<int, List<Lesson>>> getWeekTimetable(
    String classId,
    DateTime weekStartDate,
  ) async {
    final mondayOfWeek = _getMondayOfWeek(weekStartDate);
    final weekDateStr = _formatDateForDb(mondayOfWeek);

    try {
      // Get subject IDs for this class (lessons link to classes through subjects)
      final subjectIds = await _getSubjectIdsForClass(classId);
      if (subjectIds.isEmpty) {
        return {for (int i = 1; i <= 7; i++) i: <Lesson>[]};
      }

      // First try to get week-specific lessons
      var response = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .inFilter('subject_id', subjectIds)
          .eq('week_start_date', weekDateStr)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      // If no week-specific lessons exist, fall back to stable timetable
      if ((response as List).isEmpty) {
        response = await _supabase
            .from('lessons')
            .select(_lessonSelectQuery)
            .inFilter('subject_id', subjectIds)
            .eq('is_stable', true)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);
      }

      // Initialize the result map with empty lists for all weekdays
      final weekLessons = <int, List<Lesson>>{
        for (int i = 1; i <= 7; i++) i: <Lesson>[],
      };

      // Build a map of stable lessons for comparison (if we have week-specific lessons)
      final stableLessonsMap = <String, Lesson>{};
      for (final row in response) {
        final stableLessonId = row['stable_lesson_id'] as String?;
        if (stableLessonId != null && !stableLessonsMap.containsKey(stableLessonId)) {
          final stableLessonResponse = await _supabase
              .from('lessons')
              .select(_lessonSelectQuery)
              .eq('id', stableLessonId)
              .maybeSingle();
          if (stableLessonResponse != null) {
            final dbDayOfWeek = stableLessonResponse['day_of_week'] as int;
            final dartWeekday = _dbDayOfWeekToDartWeekday(dbDayOfWeek);
            final lessonDate = mondayOfWeek.add(Duration(days: dartWeekday - 1));
            final stableLesson = _rowToLesson(stableLessonResponse, lessonDate);
            stableLessonsMap[stableLesson.id] = stableLesson;
          }
        }
      }

      for (final row in response) {
        final dbDayOfWeek = row['day_of_week'] as int;
        final dartWeekday = _dbDayOfWeekToDartWeekday(dbDayOfWeek);

        // Calculate the actual date for this lesson in the requested week
        final lessonDate = mondayOfWeek.add(Duration(days: dartWeekday - 1));

        final stableLessonId = row['stable_lesson_id'] as String?;
        final stableLesson = stableLessonId != null
            ? stableLessonsMap[stableLessonId]
            : null;

        final lesson = _rowToLesson(row, lessonDate, stableLesson: stableLesson);
        weekLessons[dartWeekday]!.add(lesson);
      }

      return weekLessons;
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to fetch week timetable: ${e.message}');
    }
  }

  @override
  Future<Map<int, List<Lesson>>> createWeekFromStable(
    String classId,
    DateTime weekStartDate,
  ) async {
    final mondayOfWeek = _getMondayOfWeek(weekStartDate);
    final weekDateStr = _formatDateForDb(mondayOfWeek);

    try {
      // Get subject IDs for this class (lessons link to classes through subjects)
      final subjectIds = await _getSubjectIdsForClass(classId);
      if (subjectIds.isEmpty) {
        return {for (int i = 1; i <= 7; i++) i: <Lesson>[]};
      }

      // Check if week-specific lessons already exist
      final existingResponse = await _supabase
          .from('lessons')
          .select('id')
          .inFilter('subject_id', subjectIds)
          .eq('week_start_date', weekDateStr)
          .limit(1);

      if ((existingResponse as List).isNotEmpty) {
        // Week already exists, just return it
        return getWeekTimetable(classId, weekStartDate);
      }

      // Get stable lessons to copy
      final stableResponse = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .inFilter('subject_id', subjectIds)
          .eq('is_stable', true)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);

      if ((stableResponse as List).isEmpty) {
        return {for (int i = 1; i <= 7; i++) i: <Lesson>[]};
      }

      // Copy stable lessons to week-specific lessons
      // Note: lessons table does NOT have class_id - it links to classes through subjects
      for (final stableRow in stableResponse) {
        await _supabase.from('lessons').insert({
          'subject_id': stableRow['subject_id'],
          'day_of_week': stableRow['day_of_week'],
          'start_time': stableRow['start_time'],
          'end_time': stableRow['end_time'],
          'room': stableRow['room'],
          'is_stable': false,
          'stable_lesson_id': stableRow['id'],
          'modified_from_stable': false,
          'week_start_date': weekDateStr,
        });
      }

      // Return the newly created week timetable
      return getWeekTimetable(classId, weekStartDate);
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to create week from stable: ${e.message}');
    }
  }

  @override
  Future<Lesson> updateWeekLesson({
    required String lessonId,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) async {
    try {
      // Get the current lesson to check if it's stable
      final currentResponse = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .eq('id', lessonId)
          .single();

      final isStable = (currentResponse['is_stable'] as bool?) ?? false;
      if (isStable) {
        throw const ScheduleException(
          'Cannot modify stable lessons directly. Create a week-specific copy first.',
        );
      }

      // Build update data
      final updateData = <String, dynamic>{};
      if (subjectId != null) updateData['subject_id'] = subjectId;
      if (dayOfWeek != null) {
        updateData['day_of_week'] = _dartWeekdayToDbDayOfWeek(dayOfWeek);
      }
      if (startTime != null) updateData['start_time'] = startTime;
      if (endTime != null) updateData['end_time'] = endTime;
      if (room != null) updateData['room'] = room;

      // Update the lesson
      final response = await _supabase
          .from('lessons')
          .update(updateData)
          .eq('id', lessonId)
          .select(_lessonSelectQuery)
          .single();

      // Check if lesson is now different from stable
      final stableLessonId = response['stable_lesson_id'] as String?;
      bool modifiedFromStable = false;

      if (stableLessonId != null) {
        final stableLessonResponse = await _supabase
            .from('lessons')
            .select(_lessonSelectQuery)
            .eq('id', stableLessonId)
            .maybeSingle();

        if (stableLessonResponse != null) {
          modifiedFromStable = (
            response['subject_id'] != stableLessonResponse['subject_id'] ||
            response['day_of_week'] != stableLessonResponse['day_of_week'] ||
            response['start_time'] != stableLessonResponse['start_time'] ||
            response['end_time'] != stableLessonResponse['end_time'] ||
            (response['room'] ?? '') != (stableLessonResponse['room'] ?? '')
          );
        }

        // Update the modified_from_stable flag
        await _supabase
            .from('lessons')
            .update({'modified_from_stable': modifiedFromStable})
            .eq('id', lessonId);
      }

      // Fetch the final updated lesson
      final finalResponse = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .eq('id', lessonId)
          .single();

      // Get stable lesson for comparison
      Lesson? stableLesson;
      if (stableLessonId != null) {
        stableLesson = await getStableLessonFor(lessonId);
      }

      final today = DateTime.now();
      final mondayOfWeek = _getMondayOfWeek(today);
      final dbDayOfWeek = finalResponse['day_of_week'] as int;
      final dartWeekday = _dbDayOfWeekToDartWeekday(dbDayOfWeek);
      final lessonDate = mondayOfWeek.add(Duration(days: dartWeekday - 1));

      return _rowToLesson(finalResponse, lessonDate, stableLesson: stableLesson);
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to update lesson: ${e.message}');
    }
  }

  @override
  Future<Lesson?> getStableLessonFor(String lessonId) async {
    try {
      // Get the lesson
      final response = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .eq('id', lessonId)
          .maybeSingle();

      if (response == null) return null;

      final stableLessonId = response['stable_lesson_id'] as String?;
      if (stableLessonId == null) return null;

      // Get the stable lesson
      final stableLessonResponse = await _supabase
          .from('lessons')
          .select(_lessonSelectQuery)
          .eq('id', stableLessonId)
          .maybeSingle();

      if (stableLessonResponse == null) return null;

      final today = DateTime.now();
      final mondayOfWeek = _getMondayOfWeek(today);
      final dbDayOfWeek = stableLessonResponse['day_of_week'] as int;
      final dartWeekday = _dbDayOfWeekToDartWeekday(dbDayOfWeek);
      final lessonDate = mondayOfWeek.add(Duration(days: dartWeekday - 1));

      return _rowToLesson(stableLessonResponse, lessonDate);
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to get stable lesson: ${e.message}');
    }
  }
}
