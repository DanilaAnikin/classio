/// Represents a grade/mark for a specific subject.
///
/// Contains information about the grade value, weight, description, and date.
/// Grades are weighted to calculate accurate subject averages.
class Grade {
  /// Creates a [Grade] instance.
  const Grade({
    required this.id,
    required this.subjectId,
    required this.score,
    required this.weight,
    required this.description,
    required this.date,
  });

  /// Creates a [Grade] instance from a JSON map.
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      score: (json['score'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Unique identifier for the grade.
  final String id;

  /// ID of the subject this grade belongs to.
  final String subjectId;

  /// The actual grade value (e.g., 1.0, 2.5, etc.).
  ///
  /// In many grading systems, lower numbers indicate better performance
  /// (e.g., 1 = A, 2 = B, etc.), but this can vary by region.
  final double score;

  /// Weight of the grade between 0.5 and 1.0.
  ///
  /// Used for calculating weighted averages. For example:
  /// - 1.0 = Full weight (major test)
  /// - 0.75 = Moderate weight (quiz)
  /// - 0.5 = Low weight (homework)
  final double weight;

  /// Description of what this grade is for.
  ///
  /// Examples: "Linear Algebra Test", "Homework Assignment 3", "Final Exam"
  final String description;

  /// Date when the grade was received.
  final DateTime date;

  /// Creates a copy of this [Grade] with the given fields replaced
  /// with new values.
  Grade copyWith({
    String? id,
    String? subjectId,
    double? score,
    double? weight,
    String? description,
    DateTime? date,
  }) {
    return Grade(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      score: score ?? this.score,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  /// Converts this [Grade] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'score': score,
      'weight': weight,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Grade &&
        other.id == id &&
        other.subjectId == subjectId &&
        other.score == score &&
        other.weight == weight &&
        other.description == description &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(
        id,
        subjectId,
        score,
        weight,
        description,
        date,
      );

  @override
  String toString() =>
      'Grade(id: $id, subjectId: $subjectId, score: $score, '
      'weight: $weight, description: $description, date: $date)';
}
