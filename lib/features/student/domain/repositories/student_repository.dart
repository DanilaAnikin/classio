import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../entities/entities.dart';

/// Abstract repository for student-related data operations.
///
/// Provides methods for fetching attendance, grades, schedule, and assignments
/// for the currently authenticated student.
abstract class StudentRepository {
  // ============== Attendance ==============

  /// Gets attendance records for the current student.
  ///
  /// Optionally filter by [startDate] and [endDate].
  Future<List<AttendanceEntity>> getMyAttendance({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets attendance statistics for the current student.
  ///
  /// If [month] is provided, returns stats for that month (format: 'YYYY-MM').
  /// Otherwise returns stats for the current month.
  Future<AttendanceStats> getMyAttendanceStats(String? month);

  /// Gets attendance calendar data for a specific month.
  ///
  /// Returns a map where keys are dates and values are [DailyAttendanceStatus].
  Future<Map<DateTime, DailyAttendanceStatus>> getAttendanceCalendar(
    int month,
    int year,
  );

  /// Gets recent attendance issues (absences, lates) that may need excuses.
  Future<List<AttendanceEntity>> getRecentAttendanceIssues({int limit = 10});

  // ============== Grades ==============

  /// Gets all grades for the current student.
  Future<List<SubjectGradeStats>> getMyGrades();

  /// Gets subject averages for the current student.
  ///
  /// Returns a map where keys are subject IDs and values are averages.
  Future<Map<String, double>> getSubjectAverages();

  /// Gets recent grades for the current student.
  Future<List<Grade>> getRecentGrades({int limit = 5});

  // ============== Schedule ==============

  /// Gets today's lessons for the current student.
  Future<List<Lesson>> getTodaysLessons();

  /// Gets the weekly schedule for the current student.
  ///
  /// Returns a map where keys are weekday numbers (1=Monday to 7=Sunday).
  Future<Map<int, List<Lesson>>> getWeeklySchedule();

  // ============== Assignments ==============

  /// Gets upcoming assignments for the current student.
  Future<List<Assignment>> getUpcomingAssignments({int days = 7});

  /// Gets all assignments for the current student.
  Future<List<Assignment>> getMyAssignments();

  /// Submits an assignment.
  Future<void> submitAssignment(
    String assignmentId, {
    String? content,
    String? fileUrl,
  });

  /// Gets the current student's submissions.
  Future<List<AssignmentSubmission>> getMySubmissions();

  // ============== Utility ==============

  /// Refreshes cached data.
  Future<void> refresh();
}

/// Represents an assignment submission.
class AssignmentSubmission {
  const AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.submittedAt,
    this.content,
    this.fileUrl,
    this.grade,
    this.feedback,
  });

  final String id;
  final String assignmentId;
  final String studentId;
  final DateTime submittedAt;
  final String? content;
  final String? fileUrl;
  final double? grade;
  final String? feedback;

  @override
  String toString() =>
      'AssignmentSubmission(id: $id, assignmentId: $assignmentId, submittedAt: $submittedAt)';
}
