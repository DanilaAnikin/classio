import '../entities/subject_detail.dart';

/// Abstract repository interface for subject detail data.
///
/// Defines the contract for fetching detailed information about a subject.
abstract class SubjectDetailRepository {
  /// Fetches detailed information for a specific subject.
  ///
  /// Returns a [SubjectDetail] containing all information about the subject
  /// including posts, materials, and assignments.
  ///
  /// Throws an exception if the subject is not found or if there's an error
  /// fetching the data.
  Future<SubjectDetail> getSubjectDetail(String subjectId);
}
