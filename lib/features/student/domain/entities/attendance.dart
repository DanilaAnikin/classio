import 'package:flutter/material.dart';

/// Represents the status of an attendance record.
enum AttendanceStatus {
  /// Student was present for the lesson.
  present,

  /// Student was absent from the lesson.
  absent,

  /// Student was late to the lesson.
  late,

  /// Student left early from the lesson.
  leftEarly,

  /// Student was excused (with valid excuse).
  excused;

  /// Converts a string to an [AttendanceStatus].
  static AttendanceStatus? fromString(String? status) {
    if (status == null) return null;
    return AttendanceStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == status.toLowerCase(),
      orElse: () => AttendanceStatus.present,
    );
  }

  /// Returns a human-readable label for the status.
  String get label {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.leftEarly:
        return 'Left Early';
      case AttendanceStatus.excused:
        return 'Excused';
    }
  }

  /// Returns the color associated with this status.
  Color get color {
    switch (this) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.leftEarly:
        return Colors.amber;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }

  /// Returns the icon associated with this status.
  IconData get icon {
    switch (this) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.late:
        return Icons.schedule;
      case AttendanceStatus.leftEarly:
        return Icons.exit_to_app;
      case AttendanceStatus.excused:
        return Icons.verified;
    }
  }
}

/// Represents the status of an excuse submission.
enum ExcuseStatus {
  /// No excuse has been submitted.
  none,

  /// Excuse is pending review.
  pending,

  /// Excuse has been approved.
  approved,

  /// Excuse has been rejected.
  rejected;

  /// Converts a string to an [ExcuseStatus].
  static ExcuseStatus fromString(String? status) {
    if (status == null) return ExcuseStatus.none;
    return ExcuseStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == status.toLowerCase(),
      orElse: () => ExcuseStatus.none,
    );
  }

  /// Returns a human-readable label for the status.
  String get label {
    switch (this) {
      case ExcuseStatus.none:
        return 'No Excuse';
      case ExcuseStatus.pending:
        return 'Pending';
      case ExcuseStatus.approved:
        return 'Approved';
      case ExcuseStatus.rejected:
        return 'Rejected';
    }
  }

  /// Returns the color associated with this status.
  Color get color {
    switch (this) {
      case ExcuseStatus.none:
        return Colors.grey;
      case ExcuseStatus.pending:
        return Colors.orange;
      case ExcuseStatus.approved:
        return Colors.green;
      case ExcuseStatus.rejected:
        return Colors.red;
    }
  }
}

/// Represents an attendance record for a student.
class AttendanceEntity {
  /// Creates an [AttendanceEntity] instance.
  const AttendanceEntity({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.date,
    required this.status,
    this.subjectId,
    this.subjectName,
    this.lessonStartTime,
    this.lessonEndTime,
    this.note,
    this.excuseNote,
    this.excuseStatus = ExcuseStatus.none,
    this.excuseAttachmentUrl,
    this.recordedBy,
    this.recordedAt,
  });

  /// Unique identifier for the attendance record.
  final String id;

  /// ID of the student this record belongs to.
  final String studentId;

  /// ID of the lesson this attendance is for.
  final String lessonId;

  /// Date of the attendance record.
  final DateTime date;

  /// Attendance status.
  final AttendanceStatus status;

  /// ID of the subject (optional, for display purposes).
  final String? subjectId;

  /// Name of the subject (optional, for display purposes).
  final String? subjectName;

  /// Start time of the lesson.
  final DateTime? lessonStartTime;

  /// End time of the lesson.
  final DateTime? lessonEndTime;

  /// Optional note from the teacher.
  final String? note;

  /// Excuse note submitted by parent.
  final String? excuseNote;

  /// Status of the excuse.
  final ExcuseStatus excuseStatus;

  /// URL to any attached document (e.g., doctor's note).
  final String? excuseAttachmentUrl;

  /// ID of the teacher who recorded this attendance.
  final String? recordedBy;

  /// Timestamp when the attendance was recorded.
  final DateTime? recordedAt;

  /// Returns true if an excuse can be submitted for this record.
  bool get canSubmitExcuse {
    return (status == AttendanceStatus.absent || status == AttendanceStatus.late) &&
        excuseStatus != ExcuseStatus.approved;
  }

  /// Returns true if this is a negative attendance (absent or late).
  bool get isNegative {
    return status == AttendanceStatus.absent || status == AttendanceStatus.late;
  }

  /// Creates a copy of this entity with the given fields replaced.
  AttendanceEntity copyWith({
    String? id,
    String? studentId,
    String? lessonId,
    DateTime? date,
    AttendanceStatus? status,
    String? subjectId,
    String? subjectName,
    DateTime? lessonStartTime,
    DateTime? lessonEndTime,
    String? note,
    String? excuseNote,
    ExcuseStatus? excuseStatus,
    String? excuseAttachmentUrl,
    String? recordedBy,
    DateTime? recordedAt,
  }) {
    return AttendanceEntity(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      date: date ?? this.date,
      status: status ?? this.status,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      lessonStartTime: lessonStartTime ?? this.lessonStartTime,
      lessonEndTime: lessonEndTime ?? this.lessonEndTime,
      note: note ?? this.note,
      excuseNote: excuseNote ?? this.excuseNote,
      excuseStatus: excuseStatus ?? this.excuseStatus,
      excuseAttachmentUrl: excuseAttachmentUrl ?? this.excuseAttachmentUrl,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'AttendanceEntity(id: $id, studentId: $studentId, date: $date, status: $status)';
}

/// Statistics about a student's attendance.
class AttendanceStats {
  /// Creates an [AttendanceStats] instance.
  const AttendanceStats({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.excusedDays,
  });

  /// Creates empty stats.
  const AttendanceStats.empty()
      : totalDays = 0,
        presentDays = 0,
        absentDays = 0,
        lateDays = 0,
        excusedDays = 0;

  /// Total number of school days in the period.
  final int totalDays;

  /// Number of days the student was present.
  final int presentDays;

  /// Number of days the student was absent.
  final int absentDays;

  /// Number of days the student was late.
  final int lateDays;

  /// Number of days with excused absences.
  final int excusedDays;

  /// Calculates the attendance percentage.
  double get attendancePercentage {
    if (totalDays == 0) return 100.0;
    return (presentDays + excusedDays) / totalDays * 100;
  }

  /// Returns a color based on the attendance percentage.
  Color get percentageColor {
    if (attendancePercentage >= 95) return Colors.green;
    if (attendancePercentage >= 90) return Colors.lightGreen;
    if (attendancePercentage >= 80) return Colors.orange;
    if (attendancePercentage >= 70) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  String toString() =>
      'AttendanceStats(total: $totalDays, present: $presentDays, absent: $absentDays, late: $lateDays)';
}

/// Represents the daily attendance status for calendar display.
enum DailyAttendanceStatus {
  /// All lessons attended.
  allPresent,

  /// Some lessons were missed.
  partialAbsent,

  /// All lessons were missed.
  allAbsent,

  /// Late to some lessons.
  wasLate,

  /// No data for this day.
  noData;

  /// Returns the color for this status.
  Color get color {
    switch (this) {
      case DailyAttendanceStatus.allPresent:
        return Colors.green;
      case DailyAttendanceStatus.partialAbsent:
        return Colors.orange;
      case DailyAttendanceStatus.allAbsent:
        return Colors.red;
      case DailyAttendanceStatus.wasLate:
        return Colors.amber;
      case DailyAttendanceStatus.noData:
        return Colors.grey.shade300;
    }
  }

  /// Returns a human-readable label for the status.
  String get label {
    switch (this) {
      case DailyAttendanceStatus.allPresent:
        return 'Present';
      case DailyAttendanceStatus.partialAbsent:
        return 'Partial Absence';
      case DailyAttendanceStatus.allAbsent:
        return 'Absent';
      case DailyAttendanceStatus.wasLate:
        return 'Late';
      case DailyAttendanceStatus.noData:
        return 'No Data';
    }
  }
}
