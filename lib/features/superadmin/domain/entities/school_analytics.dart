/// Analytics data for a specific school.
///
/// Contains detailed statistics about users, classes, and subjects
/// within a school.
class SchoolAnalytics {
  /// Creates a [SchoolAnalytics] instance.
  const SchoolAnalytics({
    required this.schoolId,
    required this.schoolName,
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalClasses,
    required this.totalSubjects,
    required this.totalParents,
  });

  /// The ID of the school.
  final String schoolId;

  /// The name of the school.
  final String schoolName;

  /// Total number of users in the school.
  final int totalUsers;

  /// Number of students in the school.
  final int totalStudents;

  /// Number of teachers in the school.
  final int totalTeachers;

  /// Number of admins (principal + deputies) in the school.
  final int totalAdmins;

  /// Number of classes in the school.
  final int totalClasses;

  /// Number of subjects in the school.
  final int totalSubjects;

  /// Number of parents linked to students in the school.
  final int totalParents;

  /// Creates a [SchoolAnalytics] from a JSON map.
  factory SchoolAnalytics.fromJson(Map<String, dynamic> json) {
    return SchoolAnalytics(
      schoolId: json['school_id'] as String? ?? '',
      schoolName: json['school_name'] as String? ?? '',
      totalUsers: json['total_users'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
      totalTeachers: json['total_teachers'] as int? ?? 0,
      totalAdmins: json['total_admins'] as int? ?? 0,
      totalClasses: json['total_classes'] as int? ?? 0,
      totalSubjects: json['total_subjects'] as int? ?? 0,
      totalParents: json['total_parents'] as int? ?? 0,
    );
  }

  /// Converts this [SchoolAnalytics] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'school_id': schoolId,
      'school_name': schoolName,
      'total_users': totalUsers,
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_admins': totalAdmins,
      'total_classes': totalClasses,
      'total_subjects': totalSubjects,
      'total_parents': totalParents,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SchoolAnalytics &&
        other.schoolId == schoolId &&
        other.schoolName == schoolName &&
        other.totalUsers == totalUsers &&
        other.totalStudents == totalStudents &&
        other.totalTeachers == totalTeachers &&
        other.totalAdmins == totalAdmins &&
        other.totalClasses == totalClasses &&
        other.totalSubjects == totalSubjects &&
        other.totalParents == totalParents;
  }

  @override
  int get hashCode => Object.hash(
        schoolId,
        schoolName,
        totalUsers,
        totalStudents,
        totalTeachers,
        totalAdmins,
        totalClasses,
        totalSubjects,
        totalParents,
      );

  @override
  String toString() =>
      'SchoolAnalytics(schoolId: $schoolId, schoolName: $schoolName, '
      'users: $totalUsers, students: $totalStudents, teachers: $totalTeachers, '
      'admins: $totalAdmins, classes: $totalClasses, subjects: $totalSubjects, '
      'parents: $totalParents)';
}
