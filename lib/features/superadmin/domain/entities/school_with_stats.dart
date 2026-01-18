import 'subscription_status.dart';

/// A school entity with associated statistics.
///
/// Used by the superadmin panel to display schools with their
/// user counts, class counts, and subscription information.
class SchoolWithStats {
  /// Creates a [SchoolWithStats] instance.
  const SchoolWithStats({
    required this.id,
    required this.name,
    required this.subscriptionStatus,
    required this.totalUsers,
    required this.totalClasses,
    required this.totalStudents,
    required this.totalTeachers,
    this.createdAt,
    this.subscriptionExpiresAt,
  });

  /// Unique identifier for the school.
  final String id;

  /// Name of the school.
  final String name;

  /// Current subscription status of the school.
  final SubscriptionStatus subscriptionStatus;

  /// Total number of users in the school.
  final int totalUsers;

  /// Total number of classes in the school.
  final int totalClasses;

  /// Total number of students in the school.
  final int totalStudents;

  /// Total number of teachers in the school.
  final int totalTeachers;

  /// Timestamp when the school was created.
  final DateTime? createdAt;

  /// When the subscription expires (null if no expiration).
  final DateTime? subscriptionExpiresAt;

  /// Creates a [SchoolWithStats] from a JSON map.
  ///
  /// Throws an [ArgumentError] if the JSON is invalid or missing required fields.
  factory SchoolWithStats.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;

    if (id == null || name == null) {
      throw ArgumentError('Invalid JSON: missing required fields (id, name)');
    }

    // Parse subscription status
    final statusString = json['subscription_status'] as String?;
    final subscriptionStatus =
        SubscriptionStatus.fromString(statusString) ?? SubscriptionStatus.trial;

    // Parse counts with defaults
    final totalUsers = json['total_users'] as int? ?? 0;
    final totalClasses = json['total_classes'] as int? ?? 0;
    final totalStudents = json['total_students'] as int? ?? 0;
    final totalTeachers = json['total_teachers'] as int? ?? 0;

    // Parse createdAt from string if present
    DateTime? createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAt = null;
      }
    }

    // Parse subscription expiration
    DateTime? subscriptionExpiresAt;
    final expiresAtStr = json['subscription_expires_at'] as String?;
    if (expiresAtStr != null) {
      try {
        subscriptionExpiresAt = DateTime.parse(expiresAtStr);
      } catch (_) {
        subscriptionExpiresAt = null;
      }
    }

    return SchoolWithStats(
      id: id,
      name: name,
      subscriptionStatus: subscriptionStatus,
      totalUsers: totalUsers,
      totalClasses: totalClasses,
      totalStudents: totalStudents,
      totalTeachers: totalTeachers,
      createdAt: createdAt,
      subscriptionExpiresAt: subscriptionExpiresAt,
    );
  }

  /// Converts this [SchoolWithStats] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subscription_status': subscriptionStatus.toJson(),
      'total_users': totalUsers,
      'total_classes': totalClasses,
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'created_at': createdAt?.toIso8601String(),
      'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [SchoolWithStats] with the given fields replaced
  /// with new values.
  SchoolWithStats copyWith({
    String? id,
    String? name,
    SubscriptionStatus? subscriptionStatus,
    int? totalUsers,
    int? totalClasses,
    int? totalStudents,
    int? totalTeachers,
    DateTime? createdAt,
    DateTime? subscriptionExpiresAt,
  }) {
    return SchoolWithStats(
      id: id ?? this.id,
      name: name ?? this.name,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      totalUsers: totalUsers ?? this.totalUsers,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      createdAt: createdAt ?? this.createdAt,
      subscriptionExpiresAt:
          subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SchoolWithStats &&
        other.id == id &&
        other.name == name &&
        other.subscriptionStatus == subscriptionStatus &&
        other.totalUsers == totalUsers &&
        other.totalClasses == totalClasses &&
        other.totalStudents == totalStudents &&
        other.totalTeachers == totalTeachers &&
        other.createdAt == createdAt &&
        other.subscriptionExpiresAt == subscriptionExpiresAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        subscriptionStatus,
        totalUsers,
        totalClasses,
        totalStudents,
        totalTeachers,
        createdAt,
        subscriptionExpiresAt,
      );

  @override
  String toString() =>
      'SchoolWithStats(id: $id, name: $name, status: ${subscriptionStatus.name}, '
      'users: $totalUsers, classes: $totalClasses, students: $totalStudents, '
      'teachers: $totalTeachers)';
}
