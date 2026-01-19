import '../../../auth/domain/entities/app_user.dart';

/// Invite code entity for admin panel operations.
///
/// Re-exports and extends the auth invite code entity for admin-specific
/// operations like generating and managing invite codes.
///
/// Represents an invitation code that can be used to register new users
/// with specific roles and school associations.
class InviteCode {
  /// Creates an [InviteCode] instance.
  const InviteCode({
    required this.id,
    required this.code,
    required this.role,
    required this.schoolId,
    required this.usageLimit,
    required this.timesUsed,
    required this.isActive,
    this.classId,
    this.expiresAt,
    this.createdAt,
  });

  /// Unique identifier for the invite code.
  final String id;

  /// The actual invite code string.
  final String code;

  /// Role that will be assigned to users who register with this code.
  final UserRole role;

  /// School ID that users will be associated with.
  final String schoolId;

  /// Optional class ID for student/teacher assignments.
  final String? classId;

  /// Maximum number of times this code can be used.
  final int usageLimit;

  /// Number of times this code has been used.
  final int timesUsed;

  /// Whether this code is currently active.
  final bool isActive;

  /// Optional expiration date for the code.
  final DateTime? expiresAt;

  /// Timestamp when the invite code was created.
  final DateTime? createdAt;

  /// Whether this code can still be used.
  bool get canBeUsed {
    if (!isActive) return false;
    if (timesUsed >= usageLimit) return false;
    final expiry = expiresAt;
    if (expiry != null && DateTime.now().isAfter(expiry)) return false;
    return true;
  }

  /// Number of remaining uses for this code.
  int get remainingUses => usageLimit - timesUsed;

  /// Creates an [InviteCode] from a JSON map.
  ///
  /// Throws an [ArgumentError] if the JSON is invalid or missing required fields.
  factory InviteCode.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final code = json['code'] as String?;
    final roleString = json['role'] as String?;
    final role = UserRole.fromString(roleString);
    final schoolId = json['school_id'] as String?;
    final usageLimit = json['usage_limit'] as int?;
    final timesUsed = json['times_used'] as int?;
    final isActive = json['is_active'] as bool?;

    if (id == null ||
        code == null ||
        role == null ||
        schoolId == null ||
        usageLimit == null ||
        timesUsed == null ||
        isActive == null) {
      throw ArgumentError('Invalid JSON: missing required fields');
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

    return InviteCode(
      id: id,
      code: code,
      role: role,
      schoolId: schoolId,
      classId: json['class_id'] as String?,
      usageLimit: usageLimit,
      timesUsed: timesUsed,
      isActive: isActive,
      expiresAt: expiresAt,
      createdAt: createdAt,
    );
  }

  /// Converts this [InviteCode] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'role': role.toJson(),
      'school_id': schoolId,
      'class_id': classId,
      'usage_limit': usageLimit,
      'times_used': timesUsed,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [InviteCode] with the given fields replaced
  /// with new values.
  InviteCode copyWith({
    String? id,
    String? code,
    UserRole? role,
    String? schoolId,
    String? classId,
    int? usageLimit,
    int? timesUsed,
    bool? isActive,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return InviteCode(
      id: id ?? this.id,
      code: code ?? this.code,
      role: role ?? this.role,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      usageLimit: usageLimit ?? this.usageLimit,
      timesUsed: timesUsed ?? this.timesUsed,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InviteCode &&
        other.id == id &&
        other.code == code &&
        other.role == role &&
        other.schoolId == schoolId &&
        other.classId == classId &&
        other.usageLimit == usageLimit &&
        other.timesUsed == timesUsed &&
        other.isActive == isActive &&
        other.expiresAt == expiresAt &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        code,
        role,
        schoolId,
        classId,
        usageLimit,
        timesUsed,
        isActive,
        expiresAt,
        createdAt,
      );

  @override
  String toString() => 'InviteCode(id: $id, code: $code, role: ${role.name}, '
      'schoolId: $schoolId, usageLimit: $usageLimit, timesUsed: $timesUsed, '
      'isActive: $isActive, canBeUsed: $canBeUsed)';
}
