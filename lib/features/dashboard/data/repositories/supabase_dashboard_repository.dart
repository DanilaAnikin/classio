import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/domain.dart';

/// Exception thrown when dashboard operations fail.
class DashboardException implements Exception {
  const DashboardException(this.message);

  final String message;

  @override
  String toString() => 'DashboardException: $message';
}

/// Supabase implementation of [DashboardRepository].
///
/// Fetches dashboard data from the Supabase database including:
/// - Today's lessons from the `lessons` table filtered by day of week
/// - Upcoming assignments from the `assignments` table
/// - Subject information from the `subjects` table
///
/// Data is filtered by the current user's class enrollment via
/// the `class_students` table.
class SupabaseDashboardRepository implements DashboardRepository {
  /// Creates a [SupabaseDashboardRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseDashboardRepository({SupabaseClient? supabaseClient})
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

  /// Gets the current authenticated user's ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Gets the current user's class ID from the class_students table.
  ///
  /// Returns the class ID if the user is enrolled in a class, null otherwise.
  /// Results are cached to avoid repeated database queries.
  Future<String?> _getCurrentUserClassId() async {
    if (_cachedClassId != null) {
      return _cachedClassId;
    }

    final userId = _currentUserId;
    if (userId == null) {
      return null;
    }

    try {
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
      throw DashboardException('Failed to get user class: ${e.message}');
    }
  }

  /// Generates a deterministic color for a subject based on its ID.
  Color _getSubjectColor(String subjectId) {
    final hash = subjectId.hashCode.abs();
    return _subjectColors[hash % _subjectColors.length];
  }

  /// Converts a weekday number (1=Monday to 7=Sunday) to the database
  /// day_of_week format (0=Sunday to 6=Saturday).
  int _dartWeekdayToDbDayOfWeek(int dartWeekday) {
    return dartWeekday == 7 ? 0 : dartWeekday;
  }

  /// Converts a database lesson row to a [Lesson] entity.
  Lesson _rowToLesson(Map<String, dynamic> row, DateTime date) {
    final subjectData = row['subjects'] as Map<String, dynamic>?;
    final teacherData = subjectData?['teacher'] as Map<String, dynamic>?;

    // Parse start and end times from the database
    final startTimeStr = row['start_time'] as String?;
    final endTimeStr = row['end_time'] as String?;

    DateTime startTime;
    DateTime endTime;

    if (startTimeStr != null && endTimeStr != null) {
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

    final subjectId =
        (subjectData?['id'] ?? row['subject_id'] ?? '') as String;
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

  /// Converts a database assignment row to an [Assignment] entity.
  Assignment _rowToAssignment(
      Map<String, dynamic> row, Map<String, dynamic> subjectData) {
    final teacherData = subjectData['teacher'] as Map<String, dynamic>?;

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

    final subjectId = subjectData['id'] as String;
    final subjectName = (subjectData['name'] ?? 'Unknown Subject') as String;

    final subject = Subject(
      id: subjectId,
      name: subjectName,
      color: _getSubjectColor(subjectId),
      teacherName: teacherName,
    );

    return Assignment(
      id: row['id'] as String,
      subject: subject,
      title: row['title'] as String? ?? 'Untitled Assignment',
      description: row['description'] as String?,
      dueDate: row['due_date'] != null
          ? DateTime.parse(row['due_date'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      isCompleted: false, // Will check submission status separately
    );
  }

  @override
  Future<DashboardData> getDashboardData() async {
    final todayLessons = await getTodayLessons();
    final upcomingAssignments = await getUpcomingAssignments(days: 3);

    // Find current lesson
    Lesson? currentLesson;
    for (final lesson in todayLessons) {
      if (lesson.isInProgress) {
        currentLesson = lesson;
        break;
      }
    }

    // Find next lesson
    Lesson? nextLesson;
    for (final lesson in todayLessons) {
      if (lesson.isUpcoming) {
        nextLesson = lesson;
        break;
      }
    }

    return DashboardData(
      todayLessons: todayLessons,
      upcomingAssignments: upcomingAssignments,
      currentLesson: currentLesson,
      nextLesson: nextLesson,
    );
  }

  @override
  Future<List<Lesson>> getTodayLessons() async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) {
      return [];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dbDayOfWeek = _dartWeekdayToDbDayOfWeek(now.weekday);

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
        lessons.add(_rowToLesson(row, today));
      }

      return lessons;
    } on PostgrestException catch (e) {
      throw DashboardException('Failed to fetch today lessons: ${e.message}');
    }
  }

  @override
  Future<List<Assignment>> getUpcomingAssignments({int days = 2}) async {
    final userId = _currentUserId;
    if (userId == null) {
      return [];
    }

    final classId = await _getCurrentUserClassId();
    if (classId == null) {
      return [];
    }

    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: days));

    try {
      // First, get the subjects for this class to filter assignments
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .eq('class_id', classId);

      final subjectMap = <String, Map<String, dynamic>>{};
      for (final subject in subjectsResponse) {
        subjectMap[subject['id'] as String] = subject;
      }

      if (subjectMap.isEmpty) {
        return [];
      }

      // Get assignments for these subjects
      final assignmentsResponse = await _supabase
          .from('assignments')
          .select('id, subject_id, title, description, due_date, created_at')
          .inFilter('subject_id', subjectMap.keys.toList())
          .gte('due_date', now.toIso8601String())
          .lte('due_date', cutoffDate.toIso8601String())
          .order('due_date', ascending: true);

      // Check which assignments the user has submitted
      final assignmentIds =
          assignmentsResponse.map((a) => a['id'] as String).toList();
      final submissionsResponse = await _supabase
          .from('assignment_submissions')
          .select('assignment_id')
          .eq('student_id', userId)
          .inFilter('assignment_id', assignmentIds);

      final completedAssignmentIds = <String>{};
      for (final submission in submissionsResponse) {
        completedAssignmentIds.add(submission['assignment_id'] as String);
      }

      final assignments = <Assignment>[];
      for (final row in assignmentsResponse) {
        final subjectId = row['subject_id'] as String;
        final subjectData = subjectMap[subjectId];
        if (subjectData != null) {
          var assignment = _rowToAssignment(row, subjectData);
          if (completedAssignmentIds.contains(assignment.id)) {
            assignment = assignment.copyWith(isCompleted: true);
          }
          assignments.add(assignment);
        }
      }

      return assignments;
    } on PostgrestException catch (e) {
      throw DashboardException(
          'Failed to fetch upcoming assignments: ${e.message}');
    }
  }

  @override
  Future<void> refreshDashboard() async {
    // Clear cached data to force a fresh fetch
    _cachedClassId = null;
  }
}
