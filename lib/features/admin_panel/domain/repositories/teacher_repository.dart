import '../entities/entities.dart';

/// Repository interface for teacher-related data operations.
///
/// This interface defines the contract for fetching data
/// specific to teachers in the admin panel.
abstract class TeacherRepository {
  /// Fetches all subjects taught by a specific teacher.
  ///
  /// [teacherId] - The ID of the teacher to fetch subjects for.
  ///
  /// Returns a list of [TeacherSubject] entities, each containing
  /// the subject details and the count of classes it's taught to.
  Future<List<TeacherSubject>> getTeacherSubjects(String teacherId);

  /// Refreshes the cached teacher data.
  Future<void> refreshTeacherData();
}
