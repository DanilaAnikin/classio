import '../../../dashboard/domain/entities/subject.dart';

/// Repository interface for teacher-specific data operations.
///
/// Defines the contract for fetching teacher-related data such as
/// subjects assigned to a teacher.
abstract class TeacherRepository {
  /// Fetches all subjects assigned to a specific teacher.
  ///
  /// The [teacherId] parameter identifies the teacher.
  ///
  /// Returns a list of [Subject] objects assigned to the teacher.
  Future<List<Subject>> getMySubjects(String teacherId);
}
