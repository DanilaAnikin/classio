import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../dashboard/domain/entities/lesson.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/repositories/schedule_repository.dart';

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
class SupabaseScheduleRepository implements ScheduleRepository {
  /// Creates a [SupabaseScheduleRepository] instance.
  SupabaseScheduleRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Cache for the current user's class ID to avoid repeated queries.
  String? _cachedClassId;

  /// Predefined colors for subjects based on hash of subject ID.
  static const List<Color> _subjectColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lime,
    Colors.deepPurple,
    Colors.brown,
  ];

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

  /// Generates a deterministic color for a subject based on its ID.
  Color _getSubjectColor(String subjectId) {
    final hash = subjectId.hashCode.abs();
    return _subjectColors[hash % _subjectColors.length];
  }

  /// Converts a database row to a [Lesson] entity.
  ///
  /// The [row] should contain lesson data joined with subject data.
  /// The [date] is the actual date for this lesson occurrence.
  Lesson _rowToLesson(Map<String, dynamic> row, DateTime date) {
    final subjectData = row['subjects'] as Map<String, dynamic>?;
    final teacherData = subjectData?['teacher'] as Map<String, dynamic>?;

    // Parse start and end times from the database
    final startTimeStr = row['start_time'] as String?;
    final endTimeStr = row['end_time'] as String?;

    DateTime startTime;
    DateTime endTime;

    if (startTimeStr != null && endTimeStr != null) {
      // Parse time strings (format: "HH:MM:SS" or "HH:MM")
      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');

      startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );

      endTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
    } else {
      // Default times if not specified
      startTime = DateTime(date.year, date.month, date.day, 8, 0);
      endTime = DateTime(date.year, date.month, date.day, 8, 45);
    }

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
      color: _getSubjectColor(subjectId),
      teacherName: teacherName,
    );

    return Lesson(
      id: row['id'] as String,
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      room: (row['room'] as String?) ?? '',
      status: LessonStatus.normal,
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

  @override
  Future<List<Lesson>> getLessonsForDay(DateTime date) async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) {
      return [];
    }

    final dbDayOfWeek = _dartWeekdayToDbDayOfWeek(date.weekday);

    try {
      final response = await _supabase
          .from('lessons')
          .select('''
            id,
            subject_id,
            class_id,
            day_of_week,
            start_time,
            end_time,
            room,
            subjects (
              id,
              name,
              teacher:profiles!subjects_teacher_id_fkey (
                first_name,
                last_name
              )
            )
          ''')
          .eq('class_id', classId)
          .eq('day_of_week', dbDayOfWeek)
          .order('start_time', ascending: true);

      final lessons = <Lesson>[];
      for (final row in response) {
        lessons.add(_rowToLesson(row, date));
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

    try {
      final response = await _supabase
          .from('lessons')
          .select('''
            id,
            subject_id,
            class_id,
            day_of_week,
            start_time,
            end_time,
            room,
            subjects (
              id,
              name,
              teacher:profiles!subjects_teacher_id_fkey (
                first_name,
                last_name
              )
            )
          ''')
          .eq('class_id', classId)
          .order('start_time', ascending: true);

      // Initialize the result map with empty lists for all weekdays
      final weekLessons = <int, List<Lesson>>{
        for (int i = 1; i <= 7; i++) i: <Lesson>[],
      };

      for (final row in response) {
        final dbDayOfWeek = row['day_of_week'] as int;
        final dartWeekday = _dbDayOfWeekToDartWeekday(dbDayOfWeek);

        // Calculate the actual date for this lesson in the requested week
        final lessonDate = weekStart.add(Duration(days: dartWeekday - 1));

        final lesson = _rowToLesson(row, lessonDate);
        weekLessons[dartWeekday]!.add(lesson);
      }

      return weekLessons;
    } on PostgrestException catch (e) {
      throw ScheduleException('Failed to fetch week lessons: ${e.message}');
    }
  }
}
