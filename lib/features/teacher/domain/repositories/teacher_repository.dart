import '../../../auth/domain/entities/app_user.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../dashboard/domain/entities/lesson.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../entities/entities.dart';

/// Repository interface for teacher-related operations.
///
/// Provides methods for gradebook management, attendance tracking,
/// assignment handling, and student management.
abstract class TeacherRepository {
  // ========== My Subjects/Classes ==========

  /// Gets all subjects taught by the current teacher.
  Future<List<Subject>> getMySubjects();

  /// Gets all classes the current teacher is assigned to.
  Future<List<ClassInfo>> getMyClasses();

  // ========== Gradebook ==========

  /// Gets all students in a specific class.
  Future<List<AppUser>> getClassStudents(String classId);

  /// Gets all students enrolled in classes that have this subject.
  Future<List<AppUser>> getSubjectStudents(String subjectId);

  /// Gets all grades for a specific subject.
  Future<List<TeacherGradeEntity>> getSubjectGrades(String subjectId);

  /// Gets grades for a specific student in a subject.
  Future<List<TeacherGradeEntity>> getStudentGrades(
    String studentId,
    String subjectId,
  );

  /// Adds a new grade for a student.
  Future<TeacherGradeEntity> addGrade({
    required String studentId,
    required String subjectId,
    required double score,
    double weight = 1.0,
    String? gradeType,
    String? comment,
    String? assignmentId,
  });

  /// Updates an existing grade.
  Future<void> updateGrade(TeacherGradeEntity grade);

  /// Deletes a grade.
  Future<void> deleteGrade(String gradeId);

  // ========== Assignments ==========

  /// Gets all assignments for a specific subject.
  Future<List<AssignmentEntity>> getSubjectAssignments(String subjectId);

  /// Gets all assignments created by the teacher.
  Future<List<AssignmentEntity>> getMyAssignments();

  /// Creates a new assignment.
  Future<AssignmentEntity> createAssignment({
    required String subjectId,
    required String title,
    String? description,
    DateTime? dueDate,
    int maxScore = 100,
  });

  /// Updates an existing assignment.
  Future<void> updateAssignment(AssignmentEntity assignment);

  /// Deletes an assignment.
  Future<void> deleteAssignment(String assignmentId);

  /// Gets all submissions for an assignment.
  Future<List<SubmissionEntity>> getAssignmentSubmissions(String assignmentId);

  /// Grades a submission.
  Future<void> gradeSubmission(
    String submissionId,
    double grade,
    String? comment,
  );

  // ========== Attendance ==========

  /// Gets today's lessons for the current teacher.
  Future<List<Lesson>> getTodaysLessons(DateTime date);

  /// Gets lessons for a specific date range.
  Future<List<Lesson>> getLessonsForDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets attendance records for a specific lesson and date.
  Future<List<AttendanceEntity>> getLessonAttendance(
    String lessonId,
    DateTime date,
  );

  /// Marks attendance for a single student.
  Future<void> markAttendance({
    required String studentId,
    required String lessonId,
    required DateTime date,
    required AttendanceStatus status,
  });

  /// Marks attendance for multiple students at once.
  Future<void> bulkMarkAttendance(List<AttendanceRecord> records);

  /// Gets students in a class for attendance marking.
  Future<List<AppUser>> getStudentsForLesson(String lessonId);

  // ========== Excuse Management ==========

  /// Gets all pending excuse requests for the teacher's classes.
  Future<List<AttendanceEntity>> getPendingExcuses();

  /// Reviews an excuse request (approve/reject).
  Future<void> reviewExcuse(String attendanceId, ExcuseStatus status);

  // ========== Stats ==========

  /// Gets teacher dashboard statistics.
  Future<TeacherStats> getTeacherStats();

  /// Gets attendance statistics for a class.
  Future<Map<String, double>> getClassAttendanceStats(String classId);

  /// Gets grade statistics for a subject.
  Future<Map<String, double>> getSubjectGradeStats(String subjectId);
}
