import 'package:flutter/foundation.dart';

/// Represents a grade entry from the teacher's perspective.
///
/// Includes student information and additional metadata for gradebook display.
@immutable
class TeacherGradeEntity {
  const TeacherGradeEntity({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.score,
    this.weight = 1.0,
    this.gradeType,
    this.comment,
    this.assignmentId,
    this.assignmentTitle,
    this.studentName,
    this.studentAvatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the grade.
  final String id;

  /// ID of the student receiving the grade.
  final String studentId;

  /// ID of the subject.
  final String subjectId;

  /// Score value (0-100).
  final double score;

  /// Weight of this grade (1-10).
  final double weight;

  /// Type of grade (e.g., "Test", "Quiz", "Homework").
  final String? gradeType;

  /// Teacher's comment on the grade.
  final String? comment;

  /// Optional assignment ID if grade is for an assignment.
  final String? assignmentId;

  /// Title of the assignment (if applicable).
  final String? assignmentTitle;

  /// Name of the student.
  final String? studentName;

  /// Avatar URL of the student.
  final String? studentAvatarUrl;

  /// Timestamp when the grade was created.
  final DateTime? createdAt;

  /// Timestamp when the grade was last updated.
  final DateTime? updatedAt;

  /// Returns the letter grade for this score.
  String get letterGrade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  /// Creates a [TeacherGradeEntity] from a JSON map.
  factory TeacherGradeEntity.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final studentId = json['student_id'] as String?;
    final subjectId = json['subject_id'] as String?;
    final score = json['score'] as num?;

    if (id == null || studentId == null || subjectId == null || score == null) {
      throw ArgumentError(
        'Invalid JSON: missing required fields (id, student_id, subject_id, score)',
      );
    }

    // Parse student info if joined
    String? studentName;
    String? studentAvatarUrl;
    final studentData = json['student'] as Map<String, dynamic>?;
    if (studentData != null) {
      final firstName = studentData['first_name'] as String?;
      final lastName = studentData['last_name'] as String?;
      if (firstName != null || lastName != null) {
        studentName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
      studentAvatarUrl = studentData['avatar_url'] as String?;
    }

    // Parse assignment info if joined
    String? assignmentTitle;
    final assignmentData = json['assignments'] as Map<String, dynamic>?;
    if (assignmentData != null) {
      assignmentTitle = assignmentData['title'] as String?;
    }

    return TeacherGradeEntity(
      id: id,
      studentId: studentId,
      subjectId: subjectId,
      score: score.toDouble(),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      gradeType: json['grade_type'] as String?,
      comment: json['comment'] as String?,
      assignmentId: json['assignment_id'] as String?,
      assignmentTitle: assignmentTitle ?? json['assignment_title'] as String?,
      studentName: studentName ?? json['student_name'] as String?,
      studentAvatarUrl: studentAvatarUrl ?? json['student_avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [TeacherGradeEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'subject_id': subjectId,
      'score': score,
      'weight': weight,
      'grade_type': gradeType,
      'comment': comment,
      'assignment_id': assignmentId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [TeacherGradeEntity] with the given fields replaced.
  TeacherGradeEntity copyWith({
    String? id,
    String? studentId,
    String? subjectId,
    double? score,
    double? weight,
    String? gradeType,
    String? comment,
    String? assignmentId,
    String? assignmentTitle,
    String? studentName,
    String? studentAvatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherGradeEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      score: score ?? this.score,
      weight: weight ?? this.weight,
      gradeType: gradeType ?? this.gradeType,
      comment: comment ?? this.comment,
      assignmentId: assignmentId ?? this.assignmentId,
      assignmentTitle: assignmentTitle ?? this.assignmentTitle,
      studentName: studentName ?? this.studentName,
      studentAvatarUrl: studentAvatarUrl ?? this.studentAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeacherGradeEntity &&
        other.id == id &&
        other.studentId == studentId &&
        other.subjectId == subjectId &&
        other.score == score;
  }

  @override
  int get hashCode => Object.hash(id, studentId, subjectId, score);

  @override
  String toString() =>
      'TeacherGradeEntity(id: $id, studentId: $studentId, score: $score)';
}
