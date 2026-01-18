import '../entities/absence_excuse.dart';

/// Repository interface for managing absence excuses.
///
/// This defines the contract for CRUD operations on absence excuses,
/// including parent submission and teacher review functionality.
abstract class AbsenceExcuseRepository {
  // ============== Parent Operations ==============

  /// Submits a new absence excuse for an attendance record.
  ///
  /// [attendanceId] - The ID of the attendance record being excused.
  /// [studentId] - The ID of the student.
  /// [reason] - The excuse reason text.
  ///
  /// Returns the created [AbsenceExcuse].
  /// Throws an exception if submission fails.
  Future<AbsenceExcuse> submitExcuse({
    required String attendanceId,
    required String studentId,
    required String reason,
  });

  /// Gets all excuses submitted by the current parent for a specific child.
  ///
  /// [childId] - The ID of the child (student).
  ///
  /// Returns a list of [AbsenceExcuse] for the child.
  Future<List<AbsenceExcuse>> getExcusesForChild(String childId);

  /// Gets all excuses submitted by the current parent across all children.
  ///
  /// Returns a list of all [AbsenceExcuse] submitted by the parent.
  Future<List<AbsenceExcuse>> getAllParentExcuses();

  /// Gets pending excuses for a specific child.
  ///
  /// [childId] - The ID of the child (student).
  ///
  /// Returns a list of pending [AbsenceExcuse].
  Future<List<AbsenceExcuse>> getPendingExcusesForChild(String childId);

  /// Checks if an excuse already exists for an attendance record.
  ///
  /// [attendanceId] - The ID of the attendance record.
  ///
  /// Returns the existing [AbsenceExcuse] if one exists, null otherwise.
  Future<AbsenceExcuse?> getExcuseByAttendanceId(String attendanceId);

  // ============== Teacher Operations ==============

  /// Gets all pending excuses for the teacher's classes.
  ///
  /// Returns a list of pending [AbsenceExcuse] for review.
  Future<List<AbsenceExcuse>> getPendingExcusesForTeacher();

  /// Gets all excuses (regardless of status) for the teacher's classes.
  ///
  /// Returns a list of all [AbsenceExcuse] for the teacher's classes.
  Future<List<AbsenceExcuse>> getAllExcusesForTeacher();

  /// Approves an absence excuse.
  ///
  /// [excuseId] - The ID of the excuse to approve.
  ///
  /// Returns the updated [AbsenceExcuse].
  Future<AbsenceExcuse> approveExcuse(String excuseId);

  /// Declines an absence excuse with an optional response message.
  ///
  /// [excuseId] - The ID of the excuse to decline.
  /// [response] - Optional message explaining the decline reason.
  ///
  /// Returns the updated [AbsenceExcuse].
  Future<AbsenceExcuse> declineExcuse(String excuseId, {String? response});

  // ============== Student Operations ==============

  /// Gets all excuses for the current student.
  ///
  /// Returns a list of [AbsenceExcuse] for the student.
  Future<List<AbsenceExcuse>> getStudentExcuses();

  /// Gets a specific excuse by ID.
  ///
  /// [excuseId] - The ID of the excuse.
  ///
  /// Returns the [AbsenceExcuse] if found, null otherwise.
  Future<AbsenceExcuse?> getExcuseById(String excuseId);

  // ============== Utility ==============

  /// Clears any cached data.
  Future<void> refresh();
}
