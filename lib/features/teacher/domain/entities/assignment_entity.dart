import 'package:flutter/foundation.dart';

/// Represents an assignment created by a teacher for a subject.
@immutable
class AssignmentEntity {
  /// Creates an [AssignmentEntity] instance.
  const AssignmentEntity({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.dueDate,
    this.maxScore = 100,
    this.createdBy,
    this.createdAt,
    this.subjectName,
    this.submissionCount = 0,
    this.gradedCount = 0,
  });

  /// Unique identifier for the assignment.
  final String id;

  /// ID of the subject this assignment belongs to.
  final String subjectId;

  /// Title of the assignment.
  final String title;

  /// Detailed description of the assignment.
  final String? description;

  /// Due date for the assignment.
  final DateTime? dueDate;

  /// Maximum score possible for this assignment.
  final int maxScore;

  /// ID of the teacher who created the assignment.
  final String? createdBy;

  /// Timestamp when the assignment was created.
  final DateTime? createdAt;

  /// Name of the subject (joined from subjects table).
  final String? subjectName;

  /// Number of submissions received.
  final int submissionCount;

  /// Number of submissions that have been graded.
  final int gradedCount;

  /// Whether the assignment is past due.
  bool get isPastDue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Whether all submissions have been graded.
  bool get isFullyGraded => submissionCount > 0 && gradedCount >= submissionCount;

  /// Number of pending submissions to grade.
  int get pendingSubmissions => submissionCount - gradedCount;

  /// Creates an [AssignmentEntity] from a JSON map.
  factory AssignmentEntity.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final subjectId = json['subject_id'] as String?;
    final title = json['title'] as String?;

    if (id == null || subjectId == null || title == null) {
      throw ArgumentError(
        'Invalid JSON: missing required fields (id, subject_id, title)',
      );
    }

    // Parse subject name if joined
    String? subjectName;
    final subjectData = json['subjects'] as Map<String, dynamic>?;
    if (subjectData != null) {
      subjectName = subjectData['name'] as String?;
    }

    return AssignmentEntity(
      id: id,
      subjectId: subjectId,
      title: title,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'] as String)
          : null,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 100,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      subjectName: subjectName ?? json['subject_name'] as String?,
      submissionCount: (json['submission_count'] as num?)?.toInt() ?? 0,
      gradedCount: (json['graded_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Converts this [AssignmentEntity] to a JSON map for creation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'max_score': maxScore,
      'created_by': createdBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [AssignmentEntity] with the given fields replaced.
  AssignmentEntity copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? maxScore,
    String? createdBy,
    DateTime? createdAt,
    String? subjectName,
    int? submissionCount,
    int? gradedCount,
  }) {
    return AssignmentEntity(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      maxScore: maxScore ?? this.maxScore,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      subjectName: subjectName ?? this.subjectName,
      submissionCount: submissionCount ?? this.submissionCount,
      gradedCount: gradedCount ?? this.gradedCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AssignmentEntity &&
        other.id == id &&
        other.subjectId == subjectId &&
        other.title == title &&
        other.maxScore == maxScore;
  }

  @override
  int get hashCode => Object.hash(id, subjectId, title, maxScore);

  @override
  String toString() =>
      'AssignmentEntity(id: $id, subjectId: $subjectId, title: $title, '
      'dueDate: $dueDate, maxScore: $maxScore)';
}

/// Represents a submission for an assignment.
@immutable
class SubmissionEntity {
  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    this.studentAvatarUrl,
    this.content,
    this.fileUrl,
    this.grade,
    this.comment,
    this.submittedAt,
    this.gradedAt,
    this.gradedBy,
  });

  /// Unique identifier for the submission.
  final String id;

  /// ID of the assignment this submission is for.
  final String assignmentId;

  /// ID of the student who submitted.
  final String studentId;

  /// Name of the student (joined from profiles).
  final String? studentName;

  /// Avatar URL of the student.
  final String? studentAvatarUrl;

  /// Text content of the submission.
  final String? content;

  /// URL to attached file.
  final String? fileUrl;

  /// Grade given for the submission.
  final double? grade;

  /// Teacher's comment on the submission.
  final String? comment;

  /// Timestamp when submitted.
  final DateTime? submittedAt;

  /// Timestamp when graded.
  final DateTime? gradedAt;

  /// ID of teacher who graded.
  final String? gradedBy;

  /// Whether this submission has been graded.
  bool get isGraded => grade != null;

  /// Creates a [SubmissionEntity] from a JSON map.
  factory SubmissionEntity.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final assignmentId = json['assignment_id'] as String?;
    final studentId = json['student_id'] as String?;

    if (id == null || assignmentId == null || studentId == null) {
      throw ArgumentError(
        'Invalid JSON: missing required fields (id, assignment_id, student_id)',
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

    return SubmissionEntity(
      id: id,
      assignmentId: assignmentId,
      studentId: studentId,
      studentName: studentName ?? json['student_name'] as String?,
      studentAvatarUrl: studentAvatarUrl ?? json['student_avatar_url'] as String?,
      content: json['content'] as String?,
      fileUrl: json['file_url'] as String?,
      grade: (json['grade'] as num?)?.toDouble(),
      comment: json['comment'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'] as String)
          : null,
      gradedAt: json['graded_at'] != null
          ? DateTime.tryParse(json['graded_at'] as String)
          : null,
      gradedBy: json['graded_by'] as String?,
    );
  }

  /// Creates a copy of this [SubmissionEntity] with the given fields replaced.
  SubmissionEntity copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? studentName,
    String? studentAvatarUrl,
    String? content,
    String? fileUrl,
    double? grade,
    String? comment,
    DateTime? submittedAt,
    DateTime? gradedAt,
    String? gradedBy,
  }) {
    return SubmissionEntity(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentAvatarUrl: studentAvatarUrl ?? this.studentAvatarUrl,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      grade: grade ?? this.grade,
      comment: comment ?? this.comment,
      submittedAt: submittedAt ?? this.submittedAt,
      gradedAt: gradedAt ?? this.gradedAt,
      gradedBy: gradedBy ?? this.gradedBy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubmissionEntity &&
        other.id == id &&
        other.assignmentId == assignmentId &&
        other.studentId == studentId;
  }

  @override
  int get hashCode => Object.hash(id, assignmentId, studentId);
}
