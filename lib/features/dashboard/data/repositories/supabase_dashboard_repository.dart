import 'package:classio/core/utils/subject_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../domain/domain.dart';
import '../dtos/lesson_dto.dart';

/// Exception thrown when dashboard operations fail.
class DashboardException extends RepositoryException {
  const DashboardException(super.message, {super.code, super.originalError});

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

  /// Converts a weekday number (1=Monday to 7=Sunday) to the database
  /// day_of_week format (0=Sunday to 6=Saturday).
  int _dartWeekdayToDbDayOfWeek(int dartWeekday) {
    return dartWeekday == 7 ? 0 : dartWeekday;
  }

  /// Converts a database lesson row to a [Lesson] entity using DTO.
  ///
  /// Uses [LessonDTO] for type-safe parsing with validation.
  /// Falls back to default times if parsing fails.
  Lesson _rowToLesson(Map<String, dynamic> row, DateTime date) {
    final dto = LessonDTO.fromJson(row, date: date);

    // Use fallback conversion which handles missing times gracefully
    if (!dto.isValid) {
      debugPrint('Warning: Invalid lesson data received:');
      for (final error in dto.validationErrors) {
        debugPrint('  - $error');
      }
      debugPrint('  Raw data: $row');

      // Still try to create a lesson with fallbacks for dashboard display
      try {
        final defaultStart = DateTime(date.year, date.month, date.day, 8, 0);
        final defaultEnd = DateTime(date.year, date.month, date.day, 8, 45);
        return dto.toEntityWithFallback(
          fallbackStartTime: defaultStart,
          fallbackEndTime: defaultEnd,
        );
      } catch (e) {
        // If even fallback fails (e.g., missing subject), create a minimal lesson
        debugPrint('Warning: Could not create lesson even with fallbacks: $e');
        rethrow;
      }
    }

    return dto.toEntity();
  }

  /// Converts a list of database rows to [Lesson] entities, filtering invalid ones.
  List<Lesson> _rowsToLessons(List<Map<String, dynamic>> rows, DateTime date) {
    final lessons = <Lesson>[];
    var invalidCount = 0;

    for (final row in rows) {
      try {
        lessons.add(_rowToLesson(row, date));
      } catch (e) {
        invalidCount++;
        debugPrint('Warning: Skipping invalid lesson: $e');
      }
    }

    if (invalidCount > 0) {
      debugPrint(
        'Warning: $invalidCount invalid lesson(s) were skipped during parsing',
      );
    }

    return lessons;
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
      color: SubjectColors.getColorForId(subjectId),
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
      // First get subject IDs for this class, then query lessons
      // (lessons don't have class_id - they link through subjects)
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('class_id', classId);

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      if (subjectIds.isEmpty) {
        return [];
      }

      final response = await _supabase
          .from('lessons')
          .select('''
            id,
            subject_id,
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
          .inFilter('subject_id', subjectIds)
          .eq('day_of_week', dbDayOfWeek)
          .order('start_time', ascending: true);

      // Use DTO-based conversion with validation logging
      return _rowsToLessons(List<Map<String, dynamic>>.from(response), today);
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
