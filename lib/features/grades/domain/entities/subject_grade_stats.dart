import 'grade.dart';

/// Represents grade statistics for a specific subject.
///
/// Aggregates all grades for a subject and provides the weighted average
/// along with the subject's visual identification (name and color).
class SubjectGradeStats {
  /// Creates a [SubjectGradeStats] instance.
  const SubjectGradeStats({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.average,
    required this.grades,
  });

  /// Unique identifier for the subject.
  final String subjectId;

  /// Name of the subject (e.g., "Mathematics", "Physics").
  final String subjectName;

  /// Theme color for the subject for visual identification (ARGB int value).
  /// Convert to Flutter Color in UI layer using: Color(subjectColor)
  final int subjectColor;

  /// Weighted average of all grades for this subject.
  ///
  /// Calculated as: sum(score * weight) / sum(weight)
  ///
  /// This gives more importance to grades with higher weights
  /// (e.g., exams count more than homework).
  final double average;

  /// List of all grades for this subject.
  ///
  /// The list is typically sorted by date (newest first or oldest first
  /// depending on the use case).
  final List<Grade> grades;

  /// Returns the number of grades for this subject.
  int get gradeCount => grades.length;

  /// Returns true if this subject has no grades yet.
  bool get hasNoGrades => grades.isEmpty;

  /// Creates a copy of this [SubjectGradeStats] with the given fields replaced
  /// with new values.
  SubjectGradeStats copyWith({
    String? subjectId,
    String? subjectName,
    int? subjectColor,
    double? average,
    List<Grade>? grades,
  }) {
    return SubjectGradeStats(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectColor: subjectColor ?? this.subjectColor,
      average: average ?? this.average,
      grades: grades ?? this.grades,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubjectGradeStats &&
        other.subjectId == subjectId &&
        other.subjectName == subjectName &&
        other.subjectColor == subjectColor &&
        other.average == average &&
        _listEquals(other.grades, grades);
  }

  /// Helper method to compare lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        subjectId,
        subjectName,
        subjectColor,
        average,
        Object.hashAll(grades),
      );

  @override
  String toString() =>
      'SubjectGradeStats(subjectId: $subjectId, subjectName: $subjectName, '
      'average: $average, gradeCount: $gradeCount)';
}
