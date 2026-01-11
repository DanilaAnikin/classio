import 'package:flutter/foundation.dart';

/// Represents a single grade entry for a specific assessment.
///
/// Contains information about the grade value, weight, date,
/// and optional description for each graded item.
@immutable
class GradeEntry {
  const GradeEntry({
    required this.id,
    required this.value,
    required this.maxValue,
    required this.weight,
    required this.date,
    this.description,
    this.type = GradeType.written,
  });

  /// Unique identifier for the grade entry
  final String id;

  /// The grade value received (e.g., 85 out of 100)
  final double value;

  /// Maximum possible value for this grade
  final double maxValue;

  /// Weight of this grade in the overall subject average
  /// (e.g., 1.0 for normal test, 2.0 for major exam)
  final double weight;

  /// Date when this grade was received
  final DateTime date;

  /// Optional description of the assessment (e.g., "Chapter 5 Test")
  final String? description;

  /// Type of assessment
  final GradeType type;

  /// Calculates the percentage score for this grade
  double get percentage => (value / maxValue) * 100;

  /// Returns a letter grade representation (A-F)
  String get letterGrade {
    final pct = percentage;
    if (pct >= 90) return 'A';
    if (pct >= 80) return 'B';
    if (pct >= 70) return 'C';
    if (pct >= 60) return 'D';
    return 'F';
  }

  @override
  String toString() {
    return 'GradeEntry(id: $id, value: $value/$maxValue, weight: $weight, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GradeEntry &&
        other.id == id &&
        other.value == value &&
        other.maxValue == maxValue &&
        other.weight == weight &&
        other.date == date &&
        other.description == description &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      value,
      maxValue,
      weight,
      date,
      description,
      type,
    );
  }
}

/// Type of grade/assessment
enum GradeType {
  written('Written Test'),
  oral('Oral Exam'),
  homework('Homework'),
  project('Project'),
  quiz('Quiz'),
  midterm('Midterm'),
  final_('Final Exam'),
  participation('Participation');

  const GradeType(this.displayName);
  final String displayName;
}
