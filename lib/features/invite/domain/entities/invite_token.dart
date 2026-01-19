import 'package:classio/features/auth/domain/entities/app_user.dart';

/// Invite token entity.
///
/// Represents an invitation token that can be used to invite new users
/// with specific roles and school associations. Tokens have a usage limit
/// and track how many times they've been used.
class InviteToken {
  /// Creates an [InviteToken] instance.
  const InviteToken({
    required this.token,
    required this.role,
    this.schoolId,
    this.createdByUserId,
    required this.timesUsed,
    required this.usageLimit,
    required this.createdAt,
    this.specificClassId,
    this.expiresAt,
  });

  /// The actual token string (unique identifier).
  final String token;

  /// Role that will be assigned to users who register with this token.
  final UserRole role;

  /// School ID that users will be associated with.
  /// Can be null for SuperAdmin tokens which are not tied to a specific school.
  final String? schoolId;

  /// User ID of the person who created this token.
  /// Can be null for bootstrap tokens that are not created by a user.
  final String? createdByUserId;

  /// Optional class ID for student assignments (required when teacher invites student).
  final String? specificClassId;

  /// Number of times this token has been used.
  final int timesUsed;

  /// Maximum number of times this token can be used.
  final int usageLimit;

  /// Optional expiration date for the token.
  final DateTime? expiresAt;

  /// Timestamp when the token was created.
  final DateTime createdAt;

  /// Whether this token has reached its usage limit.
  bool get isUsed => timesUsed >= usageLimit;

  /// Whether this token is still active (can be used).
  bool get isActive => timesUsed < usageLimit;

  /// Whether this token is still valid (not fully used and not expired).
  bool get isValid {
    final expiry = expiresAt;
    return isActive && (expiry == null || expiry.isAfter(DateTime.now()));
  }

  /// Whether this token has expired.
  bool get isExpired {
    final expiry = expiresAt;
    return expiry != null && DateTime.now().isAfter(expiry);
  }

  /// Creates an [InviteToken] from a JSON map.
  ///
  /// Throws an [ArgumentError] if the JSON is invalid or missing required fields.
  factory InviteToken.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    final roleString = json['role'] as String?;
    final role = UserRole.fromString(roleString);
    final schoolId = json['school_id'] as String?; // Can be null for SuperAdmin
    final createdByUserId = json['created_by_user_id'] as String?;
    final timesUsed = json['times_used'] as int?;
    final usageLimit = json['usage_limit'] as int?;
    final createdAtStr = json['created_at'] as String?;

    // schoolId and createdByUserId are optional
    // - schoolId is null for SuperAdmin tokens
    // - createdByUserId is null for bootstrap tokens
    if (token == null ||
        role == null ||
        timesUsed == null ||
        usageLimit == null ||
        createdAtStr == null) {
      throw ArgumentError('Invalid JSON: missing required fields');
    }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(createdAtStr);
    } catch (_) {
      throw ArgumentError('Invalid JSON: invalid created_at format');
    }

    // Parse expiresAt from string if present
    DateTime? expiresAt;
    final expiresAtStr = json['expires_at'] as String?;
    if (expiresAtStr != null) {
      try {
        expiresAt = DateTime.parse(expiresAtStr);
      } catch (_) {
        expiresAt = null;
      }
    }

    return InviteToken(
      token: token,
      role: role,
      schoolId: schoolId,
      createdByUserId: createdByUserId,
      specificClassId: json['specific_class_id'] as String?,
      timesUsed: timesUsed,
      usageLimit: usageLimit,
      expiresAt: expiresAt,
      createdAt: createdAt,
    );
  }

  /// Converts this [InviteToken] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role.toJson(),
      'school_id': schoolId,
      'created_by_user_id': createdByUserId,
      'specific_class_id': specificClassId,
      'times_used': timesUsed,
      'usage_limit': usageLimit,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [InviteToken] with the given fields replaced
  /// with new values.
  InviteToken copyWith({
    String? token,
    UserRole? role,
    String? schoolId,
    String? createdByUserId,
    String? specificClassId,
    int? timesUsed,
    int? usageLimit,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return InviteToken(
      token: token ?? this.token,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      specificClassId: specificClassId ?? this.specificClassId,
      timesUsed: timesUsed ?? this.timesUsed,
      usageLimit: usageLimit ?? this.usageLimit,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InviteToken &&
        other.token == token &&
        other.role == role &&
        other.schoolId == schoolId &&
        other.createdByUserId == createdByUserId &&
        other.specificClassId == specificClassId &&
        other.timesUsed == timesUsed &&
        other.usageLimit == usageLimit &&
        other.expiresAt == expiresAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        token,
        role,
        schoolId,
        createdByUserId,
        specificClassId,
        timesUsed,
        usageLimit,
        expiresAt,
        createdAt,
      );

  @override
  String toString() => 'InviteToken(token: $token, role: ${role.name}, '
      'schoolId: $schoolId, createdByUserId: $createdByUserId, '
      'specificClassId: $specificClassId, timesUsed: $timesUsed, '
      'usageLimit: $usageLimit, isActive: $isActive, isValid: $isValid)';
}
