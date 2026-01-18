import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../../../student/domain/entities/entities.dart';

/// Abstract repository for parent-related data operations.
///
/// Provides methods for fetching child data, viewing attendance,
/// grades, schedules, and submitting excuses.
abstract class ParentRepository {
  // ============== Children ==============

  /// Gets all children associated with the current parent.
  Future<List<AppUser>> getMyChildren();

  // ============== Child Attendance ==============

  /// Gets attendance records for a specific child.
  ///
  /// Optionally filter by [startDate] and [endDate].
  Future<List<AttendanceEntity>> getChildAttendance(
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets attendance statistics for a specific child.
  ///
  /// If [month] is provided, returns stats for that month (format: 'YYYY-MM').
  Future<AttendanceStats> getChildAttendanceStats(String childId, String? month);

  /// Gets attendance calendar data for a specific child and month.
  Future<Map<DateTime, DailyAttendanceStatus>> getChildAttendanceCalendar(
    String childId,
    int month,
    int year,
  );

  /// Gets recent attendance issues for a specific child.
  Future<List<AttendanceEntity>> getChildAttendanceIssues(
    String childId, {
    int limit = 10,
  });

  // ============== Child Grades ==============

  /// Gets all grades for a specific child.
  Future<List<SubjectGradeStats>> getChildGrades(String childId);

  /// Gets subject averages for a specific child.
  Future<Map<String, double>> getChildSubjectAverages(String childId);

  // ============== Child Schedule ==============

  /// Gets today's lessons for a specific child.
  Future<List<Lesson>> getChildTodaysLessons(String childId);

  /// Gets the weekly schedule for a specific child.
  Future<Map<int, List<Lesson>>> getChildWeeklySchedule(String childId);

  /// Gets the weekly schedule for a specific child for a specific week.
  ///
  /// [weekStart] should be the Monday of the desired week.
  Future<Map<int, List<Lesson>>> getChildWeeklyScheduleForWeek(
    String childId,
    DateTime weekStart,
  );

  // ============== Child Assignments ==============

  /// Gets upcoming assignments for a specific child.
  Future<List<Assignment>> getChildAssignments(String childId, {int days = 7});

  // ============== Excuse Submission ==============

  /// Submits an excuse for a specific attendance record.
  ///
  /// [attendanceId] is the ID of the attendance record to excuse.
  /// [excuseNote] is the reason for the absence/lateness.
  /// [attachmentUrl] is an optional URL to supporting documentation.
  Future<void> submitExcuse(
    String attendanceId,
    String excuseNote, {
    String? attachmentUrl,
  });

  /// Gets all pending excuses for a specific child.
  Future<List<AttendanceEntity>> getPendingExcuses(String childId);

  /// Gets all excuses (pending, approved, rejected) for a specific child.
  Future<List<AttendanceEntity>> getAllExcuses(String childId);

  // ============== Utility ==============

  /// Refreshes cached data.
  Future<void> refresh();
}
