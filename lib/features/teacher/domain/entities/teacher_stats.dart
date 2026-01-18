import 'package:flutter/foundation.dart';

/// Statistics for a teacher's dashboard overview.
@immutable
class TeacherStats {
  const TeacherStats({
    this.totalStudents = 0,
    this.totalLessons = 0,
    this.totalSubjects = 0,
    this.pendingExcuses = 0,
    this.gradesToReview = 0,
    this.averageAttendance = 0.0,
    this.todaysLessons = 0,
    this.assignmentsDue = 0,
  });

  /// Total number of students across all classes taught.
  final int totalStudents;

  /// Total number of lessons per week.
  final int totalLessons;

  /// Total number of subjects taught.
  final int totalSubjects;

  /// Number of pending excuse requests to review.
  final int pendingExcuses;

  /// Number of submissions waiting to be graded.
  final int gradesToReview;

  /// Average attendance rate across all classes (0-100).
  final double averageAttendance;

  /// Number of lessons scheduled for today.
  final int todaysLessons;

  /// Number of assignments due this week.
  final int assignmentsDue;

  /// Creates a [TeacherStats] from a JSON map.
  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    return TeacherStats(
      totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
      totalLessons: (json['total_lessons'] as num?)?.toInt() ?? 0,
      totalSubjects: (json['total_subjects'] as num?)?.toInt() ?? 0,
      pendingExcuses: (json['pending_excuses'] as num?)?.toInt() ?? 0,
      gradesToReview: (json['grades_to_review'] as num?)?.toInt() ?? 0,
      averageAttendance: (json['average_attendance'] as num?)?.toDouble() ?? 0.0,
      todaysLessons: (json['todays_lessons'] as num?)?.toInt() ?? 0,
      assignmentsDue: (json['assignments_due'] as num?)?.toInt() ?? 0,
    );
  }

  /// Creates a copy of this [TeacherStats] with the given fields replaced.
  TeacherStats copyWith({
    int? totalStudents,
    int? totalLessons,
    int? totalSubjects,
    int? pendingExcuses,
    int? gradesToReview,
    double? averageAttendance,
    int? todaysLessons,
    int? assignmentsDue,
  }) {
    return TeacherStats(
      totalStudents: totalStudents ?? this.totalStudents,
      totalLessons: totalLessons ?? this.totalLessons,
      totalSubjects: totalSubjects ?? this.totalSubjects,
      pendingExcuses: pendingExcuses ?? this.pendingExcuses,
      gradesToReview: gradesToReview ?? this.gradesToReview,
      averageAttendance: averageAttendance ?? this.averageAttendance,
      todaysLessons: todaysLessons ?? this.todaysLessons,
      assignmentsDue: assignmentsDue ?? this.assignmentsDue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeacherStats &&
        other.totalStudents == totalStudents &&
        other.totalLessons == totalLessons &&
        other.totalSubjects == totalSubjects &&
        other.pendingExcuses == pendingExcuses &&
        other.gradesToReview == gradesToReview &&
        other.averageAttendance == averageAttendance &&
        other.todaysLessons == todaysLessons &&
        other.assignmentsDue == assignmentsDue;
  }

  @override
  int get hashCode => Object.hash(
        totalStudents,
        totalLessons,
        totalSubjects,
        pendingExcuses,
        gradesToReview,
        averageAttendance,
        todaysLessons,
        assignmentsDue,
      );

  @override
  String toString() =>
      'TeacherStats(totalStudents: $totalStudents, totalLessons: $totalLessons, '
      'pendingExcuses: $pendingExcuses, gradesToReview: $gradesToReview)';
}
