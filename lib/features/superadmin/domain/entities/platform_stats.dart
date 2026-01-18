/// Platform-wide statistics for the superadmin dashboard.
///
/// Provides aggregate metrics across all schools in the Classio platform.
class PlatformStats {
  /// Creates a [PlatformStats] instance.
  const PlatformStats({
    required this.totalSchools,
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.trialSubscriptions,
    required this.expiredSubscriptions,
    required this.suspendedSchools,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
  });

  /// Total number of schools on the platform.
  final int totalSchools;

  /// Total number of users across all schools.
  final int totalUsers;

  /// Number of schools with active subscriptions.
  final int activeSubscriptions;

  /// Number of schools in trial period.
  final int trialSubscriptions;

  /// Number of schools with expired subscriptions.
  final int expiredSubscriptions;

  /// Number of suspended schools.
  final int suspendedSchools;

  /// Total number of students across all schools.
  final int totalStudents;

  /// Total number of teachers across all schools.
  final int totalTeachers;

  /// Total number of classes across all schools.
  final int totalClasses;

  /// Creates an empty [PlatformStats] instance with all zeros.
  factory PlatformStats.empty() {
    return const PlatformStats(
      totalSchools: 0,
      totalUsers: 0,
      activeSubscriptions: 0,
      trialSubscriptions: 0,
      expiredSubscriptions: 0,
      suspendedSchools: 0,
      totalStudents: 0,
      totalTeachers: 0,
      totalClasses: 0,
    );
  }

  /// Creates a [PlatformStats] from a JSON map.
  factory PlatformStats.fromJson(Map<String, dynamic> json) {
    return PlatformStats(
      totalSchools: json['total_schools'] as int? ?? 0,
      totalUsers: json['total_users'] as int? ?? 0,
      activeSubscriptions: json['active_subscriptions'] as int? ?? 0,
      trialSubscriptions: json['trial_subscriptions'] as int? ?? 0,
      expiredSubscriptions: json['expired_subscriptions'] as int? ?? 0,
      suspendedSchools: json['suspended_schools'] as int? ?? 0,
      totalStudents: json['total_students'] as int? ?? 0,
      totalTeachers: json['total_teachers'] as int? ?? 0,
      totalClasses: json['total_classes'] as int? ?? 0,
    );
  }

  /// Converts this [PlatformStats] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'total_schools': totalSchools,
      'total_users': totalUsers,
      'active_subscriptions': activeSubscriptions,
      'trial_subscriptions': trialSubscriptions,
      'expired_subscriptions': expiredSubscriptions,
      'suspended_schools': suspendedSchools,
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_classes': totalClasses,
    };
  }

  /// Creates a copy of this [PlatformStats] with the given fields replaced
  /// with new values.
  PlatformStats copyWith({
    int? totalSchools,
    int? totalUsers,
    int? activeSubscriptions,
    int? trialSubscriptions,
    int? expiredSubscriptions,
    int? suspendedSchools,
    int? totalStudents,
    int? totalTeachers,
    int? totalClasses,
  }) {
    return PlatformStats(
      totalSchools: totalSchools ?? this.totalSchools,
      totalUsers: totalUsers ?? this.totalUsers,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      trialSubscriptions: trialSubscriptions ?? this.trialSubscriptions,
      expiredSubscriptions: expiredSubscriptions ?? this.expiredSubscriptions,
      suspendedSchools: suspendedSchools ?? this.suspendedSchools,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalClasses: totalClasses ?? this.totalClasses,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlatformStats &&
        other.totalSchools == totalSchools &&
        other.totalUsers == totalUsers &&
        other.activeSubscriptions == activeSubscriptions &&
        other.trialSubscriptions == trialSubscriptions &&
        other.expiredSubscriptions == expiredSubscriptions &&
        other.suspendedSchools == suspendedSchools &&
        other.totalStudents == totalStudents &&
        other.totalTeachers == totalTeachers &&
        other.totalClasses == totalClasses;
  }

  @override
  int get hashCode => Object.hash(
        totalSchools,
        totalUsers,
        activeSubscriptions,
        trialSubscriptions,
        expiredSubscriptions,
        suspendedSchools,
        totalStudents,
        totalTeachers,
        totalClasses,
      );

  @override
  String toString() => 'PlatformStats(schools: $totalSchools, users: $totalUsers, '
      'active: $activeSubscriptions, trial: $trialSubscriptions, '
      'expired: $expiredSubscriptions, suspended: $suspendedSchools)';
}
