import '../entities/entities.dart';

/// Repository interface for grades data operations.
///
/// Defines the contract for fetching grade-related data such as
/// individual subject grades and overall grade statistics.
abstract class GradesRepository {
  /// Fetches grade statistics for all subjects.
  ///
  /// Returns a list of [SubjectGradeStats] objects containing:
  /// - Subject information (name, color)
  /// - All grades for each subject
  /// - Weighted average for each subject
  ///
  /// The list is typically sorted by subject name or by average grade.
  Future<List<SubjectGradeStats>> getAllSubjectStats();

  /// Fetches grade statistics for a specific subject.
  ///
  /// The [subjectId] parameter identifies which subject's grades to fetch.
  ///
  /// Returns a [SubjectGradeStats] object for the specified subject,
  /// or null if the subject is not found or has no grades.
  Future<SubjectGradeStats?> getSubjectStats(String subjectId);
}
