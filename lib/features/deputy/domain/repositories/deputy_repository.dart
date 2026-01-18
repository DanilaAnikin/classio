import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../entities/entities.dart';

/// Repository interface for deputy panel data operations.
///
/// Defines the contract for schedule management and parent onboarding
/// operations used by school admins/deputies.
abstract class DeputyRepository {
  // ============== Schedule Management ==============

  /// Fetches all lessons for a specific class.
  ///
  /// Returns lessons for all days of the week.
  /// If [weekStartDate] is null, returns stable timetable lessons.
  /// If [weekStartDate] is provided, returns week-specific lessons (or stable as fallback).
  Future<List<ScheduleLesson>> getClassSchedule(String classId, {DateTime? weekStartDate});

  /// Fetches only the stable timetable lessons for a class.
  ///
  /// Returns the base recurring schedule without week-specific overrides.
  Future<List<ScheduleLesson>> getStableSchedule(String classId);

  /// Creates a new lesson in the schedule.
  ///
  /// Returns the created lesson with its generated ID.
  /// If [isStable] is true, creates a stable (recurring) lesson.
  /// If [weekStartDate] is provided, creates a week-specific lesson.
  Future<ScheduleLesson> createLesson({
    required String classId,
    required String subjectId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    bool isStable = true,
    DateTime? weekStartDate,
  });

  /// Updates an existing lesson.
  ///
  /// Returns the updated lesson.
  Future<ScheduleLesson> updateLesson({
    required String lessonId,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  });

  /// Deletes a lesson from the schedule.
  ///
  /// Returns true if deletion was successful.
  Future<bool> deleteLesson(String lessonId);

  /// Fetches all subjects for a specific class.
  ///
  /// Used for the subject dropdown in the lesson form.
  Future<List<Subject>> getClassSubjects(String classId);

  /// Fetches all classes for a school.
  ///
  /// Used for the class selector dropdown.
  Future<List<ClassInfo>> getSchoolClasses(String schoolId);

  // ============== Parent Onboarding ==============

  /// Fetches all students in the school who don't have a parent linked.
  Future<List<StudentWithoutParent>> getStudentsWithoutParents(String schoolId);

  /// Generates a parent invite token for a specific student.
  ///
  /// Returns the generated invite with the code.
  Future<ParentInvite> generateParentInviteForStudent({
    required String studentId,
    required String schoolId,
    DateTime? expiresAt,
  });

  /// Fetches all pending (unused) parent invites for a school.
  Future<List<ParentInvite>> getPendingParentInvites(String schoolId);

  /// Fetches all parent invites (including used) for a school.
  Future<List<ParentInvite>> getAllParentInvites(String schoolId);

  /// Revokes/deletes a parent invite.
  Future<bool> revokeParentInvite(String inviteId);

  // ============== Stats ==============

  /// Fetches deputy dashboard statistics for a school.
  Future<DeputyStats> getDeputyStats(String schoolId);

  // ============== Subjects Management ==============

  /// Fetches all subjects for a school.
  ///
  /// Includes subjects from all classes.
  Future<List<Subject>> getSchoolSubjects(String schoolId);

  // ============== Class Management ==============

  /// Adds a student to a class.
  ///
  /// Returns true if the operation was successful.
  Future<bool> addStudentToClass(String classId, String studentId);

  /// Removes a student from a class.
  ///
  /// Returns true if the operation was successful.
  Future<bool> removeStudentFromClass(String classId, String studentId);

  /// Fetches all students in a specific class.
  Future<List<AppUser>> getClassStudents(String classId);

  /// Fetches all students in a school who are not assigned to any class.
  Future<List<AppUser>> getStudentsWithoutClass(String schoolId);

  // ============== Subject CRUD ==============

  /// Creates a new subject in the school.
  ///
  /// Returns the created subject with its generated ID.
  Future<Subject> createSubject({
    required String schoolId,
    required String name,
    String? description,
    String? teacherId,
  });

  /// Deletes a subject.
  ///
  /// Returns true if deletion was successful.
  Future<bool> deleteSubject(String subjectId);

  /// Updates an existing subject.
  ///
  /// Returns the updated subject.
  Future<Subject> updateSubject({
    required String subjectId,
    String? name,
    String? description,
    String? teacherId,
  });

  /// Assigns a subject to a class.
  ///
  /// Returns true if the operation was successful.
  Future<bool> assignSubjectToClass(String subjectId, String classId);

  /// Removes a subject from a class.
  ///
  /// Returns true if the operation was successful.
  Future<bool> removeSubjectFromClass(String subjectId, String classId);

  /// Fetches all teachers in a school.
  ///
  /// Used for assigning teachers to subjects.
  Future<List<AppUser>> getSchoolTeachers(String schoolId);
}
