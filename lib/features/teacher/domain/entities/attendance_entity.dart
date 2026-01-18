import 'package:flutter/foundation.dart';

/// Attendance status for a student in a lesson.
enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  late('Late'),
  excused('Excused');

  const AttendanceStatus(this.displayName);
  final String displayName;

  /// Converts a string to an [AttendanceStatus].
  static AttendanceStatus? fromString(String? value) {
    if (value == null) return null;
    try {
      return AttendanceStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Status of an excuse submitted for an absence.
enum ExcuseStatus {
  pending('Pending Review'),
  approved('Approved'),
  rejected('Rejected');

  const ExcuseStatus(this.displayName);
  final String displayName;

  /// Converts a string to an [ExcuseStatus].
  static ExcuseStatus? fromString(String? value) {
    if (value == null) return null;
    try {
      return ExcuseStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == value.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Represents an attendance record for a student in a specific lesson.
///
/// Contains information about the student's attendance status, any excuse
/// notes, and metadata about when and by whom the record was created.
@immutable
class AttendanceEntity {
  /// Creates an [AttendanceEntity] instance.
  const AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.date,
    required this.status,
    this.studentName,
    this.studentAvatarUrl,
    this.excuseNote,
    this.excuseStatus,
    this.markedBy,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for the attendance record.
  final String id;

  /// ID of the student.
  final String studentId;

  /// Name of the student (joined from profiles).
  final String? studentName;

  /// Avatar URL of the student (joined from profiles).
  final String? studentAvatarUrl;

  /// ID of the lesson.
  final String lessonId;

  /// Date of the attendance record.
  final DateTime date;

  /// Attendance status.
  final AttendanceStatus status;

  /// Excuse note provided by parent/student.
  final String? excuseNote;

  /// Status of the excuse (if an excuse was provided).
  final ExcuseStatus? excuseStatus;

  /// ID of the user who marked the attendance.
  final String? markedBy;

  /// Timestamp when the record was created.
  final DateTime? createdAt;

  /// Timestamp when the record was last updated.
  final DateTime? updatedAt;

  /// Whether this attendance record has a pending excuse.
  bool get hasPendingExcuse =>
      excuseNote != null && excuseStatus == ExcuseStatus.pending;

  /// Whether this attendance record has an approved excuse.
  bool get hasApprovedExcuse => excuseStatus == ExcuseStatus.approved;

  /// Creates an [AttendanceEntity] from a JSON map.
  factory AttendanceEntity.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final studentId = json['student_id'] as String?;
    final lessonId = json['lesson_id'] as String?;
    final dateStr = json['date'] as String?;

    if (id == null || studentId == null || lessonId == null || dateStr == null) {
      throw ArgumentError(
        'Invalid JSON: missing required fields (id, student_id, lesson_id, date)',
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

    return AttendanceEntity(
      id: id,
      studentId: studentId,
      studentName: studentName ?? json['student_name'] as String?,
      studentAvatarUrl: studentAvatarUrl ?? json['student_avatar_url'] as String?,
      lessonId: lessonId,
      date: DateTime.parse(dateStr),
      status: AttendanceStatus.fromString(json['status'] as String?) ??
          AttendanceStatus.absent,
      excuseNote: json['excuse_note'] as String?,
      excuseStatus: ExcuseStatus.fromString(json['excuse_status'] as String?),
      markedBy: json['marked_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [AttendanceEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'lesson_id': lessonId,
      'date': date.toIso8601String().split('T').first,
      'status': status.name,
      'excuse_note': excuseNote,
      'excuse_status': excuseStatus?.name,
      'marked_by': markedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [AttendanceEntity] with the given fields replaced.
  AttendanceEntity copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentAvatarUrl,
    String? lessonId,
    DateTime? date,
    AttendanceStatus? status,
    String? excuseNote,
    ExcuseStatus? excuseStatus,
    String? markedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentAvatarUrl: studentAvatarUrl ?? this.studentAvatarUrl,
      lessonId: lessonId ?? this.lessonId,
      date: date ?? this.date,
      status: status ?? this.status,
      excuseNote: excuseNote ?? this.excuseNote,
      excuseStatus: excuseStatus ?? this.excuseStatus,
      markedBy: markedBy ?? this.markedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AttendanceEntity &&
        other.id == id &&
        other.studentId == studentId &&
        other.lessonId == lessonId &&
        other.date == date &&
        other.status == status &&
        other.excuseNote == excuseNote &&
        other.excuseStatus == excuseStatus;
  }

  @override
  int get hashCode => Object.hash(
        id,
        studentId,
        lessonId,
        date,
        status,
        excuseNote,
        excuseStatus,
      );

  @override
  String toString() =>
      'AttendanceEntity(id: $id, studentId: $studentId, lessonId: $lessonId, '
      'date: $date, status: ${status.name})';
}

/// A record for bulk attendance operations.
@immutable
class AttendanceRecord {
  const AttendanceRecord({
    required this.studentId,
    required this.lessonId,
    required this.date,
    required this.status,
  });

  final String studentId;
  final String lessonId;
  final DateTime date;
  final AttendanceStatus status;

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'lesson_id': lessonId,
      'date': date.toIso8601String().split('T').first,
      'status': status.name,
    };
  }
}
