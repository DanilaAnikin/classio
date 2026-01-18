/// Statistics for the deputy dashboard.
///
/// Contains summary information about lessons, students without parents,
/// and pending parent invites for a school.
class DeputyStats {
  /// Creates a [DeputyStats] instance.
  const DeputyStats({
    required this.totalLessons,
    required this.totalClasses,
    required this.studentsWithoutParents,
    required this.pendingParentInvites,
    required this.totalSubjects,
    required this.totalTeachers,
  });

  /// Total number of lessons scheduled across all classes.
  final int totalLessons;

  /// Total number of classes in the school.
  final int totalClasses;

  /// Number of students who don't have a parent account linked.
  final int studentsWithoutParents;

  /// Number of parent invite codes that are still pending/unused.
  final int pendingParentInvites;

  /// Total number of subjects in the school.
  final int totalSubjects;

  /// Total number of teachers in the school.
  final int totalTeachers;

  /// Creates a [DeputyStats] from a JSON map.
  factory DeputyStats.fromJson(Map<String, dynamic> json) {
    return DeputyStats(
      totalLessons: json['total_lessons'] as int? ?? 0,
      totalClasses: json['total_classes'] as int? ?? 0,
      studentsWithoutParents: json['students_without_parents'] as int? ?? 0,
      pendingParentInvites: json['pending_parent_invites'] as int? ?? 0,
      totalSubjects: json['total_subjects'] as int? ?? 0,
      totalTeachers: json['total_teachers'] as int? ?? 0,
    );
  }

  /// Converts this [DeputyStats] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'total_lessons': totalLessons,
      'total_classes': totalClasses,
      'students_without_parents': studentsWithoutParents,
      'pending_parent_invites': pendingParentInvites,
      'total_subjects': totalSubjects,
      'total_teachers': totalTeachers,
    };
  }

  /// Creates a copy with the given fields replaced.
  DeputyStats copyWith({
    int? totalLessons,
    int? totalClasses,
    int? studentsWithoutParents,
    int? pendingParentInvites,
    int? totalSubjects,
    int? totalTeachers,
  }) {
    return DeputyStats(
      totalLessons: totalLessons ?? this.totalLessons,
      totalClasses: totalClasses ?? this.totalClasses,
      studentsWithoutParents: studentsWithoutParents ?? this.studentsWithoutParents,
      pendingParentInvites: pendingParentInvites ?? this.pendingParentInvites,
      totalSubjects: totalSubjects ?? this.totalSubjects,
      totalTeachers: totalTeachers ?? this.totalTeachers,
    );
  }

  /// Creates an empty/initial stats object.
  factory DeputyStats.empty() {
    return const DeputyStats(
      totalLessons: 0,
      totalClasses: 0,
      studentsWithoutParents: 0,
      pendingParentInvites: 0,
      totalSubjects: 0,
      totalTeachers: 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeputyStats &&
        other.totalLessons == totalLessons &&
        other.totalClasses == totalClasses &&
        other.studentsWithoutParents == studentsWithoutParents &&
        other.pendingParentInvites == pendingParentInvites &&
        other.totalSubjects == totalSubjects &&
        other.totalTeachers == totalTeachers;
  }

  @override
  int get hashCode => Object.hash(
        totalLessons,
        totalClasses,
        studentsWithoutParents,
        pendingParentInvites,
        totalSubjects,
        totalTeachers,
      );

  @override
  String toString() =>
      'DeputyStats(totalLessons: $totalLessons, totalClasses: $totalClasses, '
      'studentsWithoutParents: $studentsWithoutParents, pendingParentInvites: $pendingParentInvites)';
}
