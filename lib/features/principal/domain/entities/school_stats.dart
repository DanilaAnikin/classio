/// School statistics entity.
///
/// Represents aggregated statistics about a school for the principal dashboard.
class SchoolStats {
  /// Creates a [SchoolStats] instance.
  const SchoolStats({
    required this.totalStaff,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalClasses,
    required this.totalStudents,
    required this.totalParents,
    this.activeInviteCodes = 0,
  });

  /// Total number of staff members (teachers + admins).
  final int totalStaff;

  /// Total number of teachers.
  final int totalTeachers;

  /// Total number of administrators (admin + bigadmin).
  final int totalAdmins;

  /// Total number of classes.
  final int totalClasses;

  /// Total number of students.
  final int totalStudents;

  /// Total number of parents.
  final int totalParents;

  /// Number of active (unused) invite codes.
  final int activeInviteCodes;

  /// Creates a [SchoolStats] with all zeros.
  factory SchoolStats.empty() {
    return const SchoolStats(
      totalStaff: 0,
      totalTeachers: 0,
      totalAdmins: 0,
      totalClasses: 0,
      totalStudents: 0,
      totalParents: 0,
      activeInviteCodes: 0,
    );
  }

  /// Creates a copy of this [SchoolStats] with the given fields replaced.
  SchoolStats copyWith({
    int? totalStaff,
    int? totalTeachers,
    int? totalAdmins,
    int? totalClasses,
    int? totalStudents,
    int? totalParents,
    int? activeInviteCodes,
  }) {
    return SchoolStats(
      totalStaff: totalStaff ?? this.totalStaff,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalAdmins: totalAdmins ?? this.totalAdmins,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      totalParents: totalParents ?? this.totalParents,
      activeInviteCodes: activeInviteCodes ?? this.activeInviteCodes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SchoolStats &&
        other.totalStaff == totalStaff &&
        other.totalTeachers == totalTeachers &&
        other.totalAdmins == totalAdmins &&
        other.totalClasses == totalClasses &&
        other.totalStudents == totalStudents &&
        other.totalParents == totalParents &&
        other.activeInviteCodes == activeInviteCodes;
  }

  @override
  int get hashCode => Object.hash(
        totalStaff,
        totalTeachers,
        totalAdmins,
        totalClasses,
        totalStudents,
        totalParents,
        activeInviteCodes,
      );

  @override
  String toString() => 'SchoolStats('
      'totalStaff: $totalStaff, '
      'totalTeachers: $totalTeachers, '
      'totalAdmins: $totalAdmins, '
      'totalClasses: $totalClasses, '
      'totalStudents: $totalStudents, '
      'totalParents: $totalParents, '
      'activeInviteCodes: $activeInviteCodes)';
}
