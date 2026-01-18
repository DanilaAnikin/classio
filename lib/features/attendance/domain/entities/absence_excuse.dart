import 'package:flutter/foundation.dart';

/// Represents the status of an absence excuse.
enum AbsenceExcuseStatus {
  /// Excuse is awaiting review.
  pending,

  /// Excuse has been approved by teacher.
  approved,

  /// Excuse has been declined by teacher.
  declined;

  /// Converts a string to an [AbsenceExcuseStatus].
  static AbsenceExcuseStatus fromString(String? status) {
    if (status == null) return AbsenceExcuseStatus.pending;
    return AbsenceExcuseStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == status.toLowerCase(),
      orElse: () => AbsenceExcuseStatus.pending,
    );
  }

  /// Returns a human-readable label for the status.
  String get label {
    switch (this) {
      case AbsenceExcuseStatus.pending:
        return 'Pending';
      case AbsenceExcuseStatus.approved:
        return 'Approved';
      case AbsenceExcuseStatus.declined:
        return 'Declined';
    }
  }
}

/// Entity representing an absence excuse submitted by a parent.
///
/// This links to an attendance record and contains the reason for absence
/// along with the review status and any teacher response.
@immutable
class AbsenceExcuse {
  /// Creates an [AbsenceExcuse] instance.
  const AbsenceExcuse({
    required this.id,
    required this.attendanceId,
    required this.studentId,
    required this.parentId,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.teacherResponse,
    this.teacherId,
    this.studentName,
    this.parentName,
    this.teacherName,
    this.subjectName,
    this.attendanceDate,
    this.lessonStartTime,
    this.lessonEndTime,
  });

  /// Creates an [AbsenceExcuse] from a JSON map.
  factory AbsenceExcuse.fromJson(Map<String, dynamic> json) {
    // Extract student info if available
    final studentProfile = json['student'] as Map<String, dynamic>?;
    String? studentName;
    if (studentProfile != null) {
      final firstName = studentProfile['first_name'] as String?;
      final lastName = studentProfile['last_name'] as String?;
      if (firstName != null || lastName != null) {
        studentName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    // Extract parent info if available
    final parentProfile = json['parent'] as Map<String, dynamic>?;
    String? parentName;
    if (parentProfile != null) {
      final firstName = parentProfile['first_name'] as String?;
      final lastName = parentProfile['last_name'] as String?;
      if (firstName != null || lastName != null) {
        parentName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    // Extract teacher info if available
    final teacherProfile = json['teacher'] as Map<String, dynamic>?;
    String? teacherName;
    if (teacherProfile != null) {
      final firstName = teacherProfile['first_name'] as String?;
      final lastName = teacherProfile['last_name'] as String?;
      if (firstName != null || lastName != null) {
        teacherName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    // Extract attendance info if available
    final attendance = json['attendance'] as Map<String, dynamic>?;
    DateTime? attendanceDate;
    String? subjectName;
    DateTime? lessonStartTime;
    DateTime? lessonEndTime;

    if (attendance != null) {
      final dateStr = attendance['date'] as String?;
      if (dateStr != null) {
        attendanceDate = DateTime.tryParse(dateStr);
      }

      final lessons = attendance['lessons'] as Map<String, dynamic>?;
      if (lessons != null) {
        final subjects = lessons['subjects'] as Map<String, dynamic>?;
        subjectName = subjects?['name'] as String?;

        final startTimeStr = lessons['start_time'] as String?;
        final endTimeStr = lessons['end_time'] as String?;

        if (startTimeStr != null && attendanceDate != null) {
          final parts = startTimeStr.split(':');
          if (parts.length >= 2) {
            lessonStartTime = DateTime(
              attendanceDate.year,
              attendanceDate.month,
              attendanceDate.day,
              int.tryParse(parts[0]) ?? 0,
              int.tryParse(parts[1]) ?? 0,
            );
          }
        }
        if (endTimeStr != null && attendanceDate != null) {
          final parts = endTimeStr.split(':');
          if (parts.length >= 2) {
            lessonEndTime = DateTime(
              attendanceDate.year,
              attendanceDate.month,
              attendanceDate.day,
              int.tryParse(parts[0]) ?? 0,
              int.tryParse(parts[1]) ?? 0,
            );
          }
        }
      }
    }

    return AbsenceExcuse(
      id: json['id'] as String,
      attendanceId: json['attendance_id'] as String,
      studentId: json['student_id'] as String,
      parentId: json['parent_id'] as String,
      reason: json['reason'] as String,
      status: AbsenceExcuseStatus.fromString(json['status'] as String?),
      teacherResponse: json['teacher_response'] as String?,
      teacherId: json['teacher_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      studentName: studentName,
      parentName: parentName,
      teacherName: teacherName,
      subjectName: subjectName,
      attendanceDate: attendanceDate,
      lessonStartTime: lessonStartTime,
      lessonEndTime: lessonEndTime,
    );
  }

  /// Unique identifier for the excuse.
  final String id;

  /// ID of the attendance record being excused.
  final String attendanceId;

  /// ID of the student for whom the excuse is submitted.
  final String studentId;

  /// ID of the parent who submitted the excuse.
  final String parentId;

  /// The excuse reason text.
  final String reason;

  /// Current status of the excuse.
  final AbsenceExcuseStatus status;

  /// Optional response message from teacher (usually when declining).
  final String? teacherResponse;

  /// ID of the teacher who reviewed the excuse.
  final String? teacherId;

  /// Timestamp when the excuse was created.
  final DateTime createdAt;

  /// Timestamp when the excuse was last updated.
  final DateTime updatedAt;

  /// Name of the student (for display purposes).
  final String? studentName;

  /// Name of the parent who submitted (for display purposes).
  final String? parentName;

  /// Name of the teacher who reviewed (for display purposes).
  final String? teacherName;

  /// Name of the subject for the lesson (for display purposes).
  final String? subjectName;

  /// Date of the attendance record.
  final DateTime? attendanceDate;

  /// Start time of the lesson.
  final DateTime? lessonStartTime;

  /// End time of the lesson.
  final DateTime? lessonEndTime;

  /// Returns true if the excuse is pending review.
  bool get isPending => status == AbsenceExcuseStatus.pending;

  /// Returns true if the excuse has been approved.
  bool get isApproved => status == AbsenceExcuseStatus.approved;

  /// Returns true if the excuse has been declined.
  bool get isDeclined => status == AbsenceExcuseStatus.declined;

  /// Converts the entity to a JSON map for database insertion.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'student_id': studentId,
      'parent_id': parentId,
      'reason': reason,
      'status': status.name,
      'teacher_response': teacherResponse,
      'teacher_id': teacherId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this entity with the given fields replaced.
  AbsenceExcuse copyWith({
    String? id,
    String? attendanceId,
    String? studentId,
    String? parentId,
    String? reason,
    AbsenceExcuseStatus? status,
    String? teacherResponse,
    String? teacherId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? studentName,
    String? parentName,
    String? teacherName,
    String? subjectName,
    DateTime? attendanceDate,
    DateTime? lessonStartTime,
    DateTime? lessonEndTime,
  }) {
    return AbsenceExcuse(
      id: id ?? this.id,
      attendanceId: attendanceId ?? this.attendanceId,
      studentId: studentId ?? this.studentId,
      parentId: parentId ?? this.parentId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      teacherResponse: teacherResponse ?? this.teacherResponse,
      teacherId: teacherId ?? this.teacherId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      studentName: studentName ?? this.studentName,
      parentName: parentName ?? this.parentName,
      teacherName: teacherName ?? this.teacherName,
      subjectName: subjectName ?? this.subjectName,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      lessonStartTime: lessonStartTime ?? this.lessonStartTime,
      lessonEndTime: lessonEndTime ?? this.lessonEndTime,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AbsenceExcuse && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AbsenceExcuse(id: $id, studentId: $studentId, status: $status)';
}
