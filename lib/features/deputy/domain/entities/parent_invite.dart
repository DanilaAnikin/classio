/// Represents a parent invite token linked to a specific student.
///
/// Used for the parent onboarding feature where deputies can generate
/// invite codes for parents to register and link to their children.
class ParentInvite {
  /// Creates a [ParentInvite] instance.
  const ParentInvite({
    required this.id,
    required this.code,
    required this.studentId,
    required this.schoolId,
    required this.timesUsed,
    required this.usageLimit,
    this.studentName,
    this.studentEmail,
    this.className,
    this.createdAt,
    this.usedAt,
    this.expiresAt,
    this.parentId,
    this.parentName,
  });

  /// Unique identifier for the invite.
  final String id;

  /// The invite code string.
  final String code;

  /// ID of the student this invite is for.
  final String studentId;

  /// School ID this invite belongs to.
  final String schoolId;

  /// Number of times this invite has been used.
  final int timesUsed;

  /// Maximum number of times this invite can be used.
  final int usageLimit;

  /// Name of the student (joined data).
  final String? studentName;

  /// Email of the student (joined data).
  final String? studentEmail;

  /// Name of the student's class (joined data).
  final String? className;

  /// Timestamp when the invite was created.
  final DateTime? createdAt;

  /// Timestamp when the invite was used.
  final DateTime? usedAt;

  /// Optional expiration date for the invite.
  final DateTime? expiresAt;

  /// ID of the parent who used this invite (if used).
  final String? parentId;

  /// Name of the parent who used this invite (if used).
  final String? parentName;

  /// Whether this invite has reached its usage limit.
  bool get isUsed => timesUsed >= usageLimit;

  /// Whether this invite is still active (can be used).
  bool get isActive => timesUsed < usageLimit;

  /// Whether this invite can still be used.
  bool get canBeUsed {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// Whether this invite has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Creates a [ParentInvite] from a JSON map.
  factory ParentInvite.fromJson(Map<String, dynamic> json) {
    // Parse student data if joined
    final studentData = json['student'] as Map<String, dynamic>?;
    String? studentName;
    String? studentEmail;
    String? className;

    if (studentData != null) {
      final firstName = studentData['first_name'] as String?;
      final lastName = studentData['last_name'] as String?;
      if (firstName != null || lastName != null) {
        studentName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
      studentEmail = studentData['email'] as String?;

      // Parse class data if joined through student
      final classData = studentData['class'] as Map<String, dynamic>?;
      if (classData != null) {
        className = classData['name'] as String?;
      }
    }

    // Parse parent data if joined
    final parentData = json['parent'] as Map<String, dynamic>?;
    String? parentName;
    if (parentData != null) {
      final firstName = parentData['first_name'] as String?;
      final lastName = parentData['last_name'] as String?;
      if (firstName != null || lastName != null) {
        parentName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    // Parse dates
    DateTime? createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {}
    }

    DateTime? usedAt;
    final usedAtStr = json['used_at'] as String?;
    if (usedAtStr != null) {
      try {
        usedAt = DateTime.parse(usedAtStr);
      } catch (_) {}
    }

    DateTime? expiresAt;
    final expiresAtStr = json['expires_at'] as String?;
    if (expiresAtStr != null) {
      try {
        expiresAt = DateTime.parse(expiresAtStr);
      } catch (_) {}
    }

    return ParentInvite(
      id: json['id'] as String,
      code: json['code'] as String,
      studentId: json['student_id'] as String,
      schoolId: json['school_id'] as String,
      timesUsed: json['times_used'] as int? ?? 0,
      usageLimit: json['usage_limit'] as int? ?? 1,
      studentName: studentName ?? json['student_name'] as String?,
      studentEmail: studentEmail,
      className: className ?? json['class_name'] as String?,
      createdAt: createdAt,
      usedAt: usedAt,
      expiresAt: expiresAt,
      parentId: json['parent_id'] as String?,
      parentName: parentName,
    );
  }

  /// Converts this [ParentInvite] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'student_id': studentId,
      'school_id': schoolId,
      'times_used': timesUsed,
      'usage_limit': usageLimit,
      'created_at': createdAt?.toIso8601String(),
      'used_at': usedAt?.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'parent_id': parentId,
    };
  }

  /// Creates a copy with the given fields replaced.
  ParentInvite copyWith({
    String? id,
    String? code,
    String? studentId,
    String? schoolId,
    int? timesUsed,
    int? usageLimit,
    String? studentName,
    String? studentEmail,
    String? className,
    DateTime? createdAt,
    DateTime? usedAt,
    DateTime? expiresAt,
    String? parentId,
    String? parentName,
  }) {
    return ParentInvite(
      id: id ?? this.id,
      code: code ?? this.code,
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
      timesUsed: timesUsed ?? this.timesUsed,
      usageLimit: usageLimit ?? this.usageLimit,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      className: className ?? this.className,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ParentInvite &&
        other.id == id &&
        other.code == code &&
        other.studentId == studentId &&
        other.timesUsed == timesUsed &&
        other.usageLimit == usageLimit;
  }

  @override
  int get hashCode => Object.hash(id, code, studentId, timesUsed, usageLimit);

  @override
  String toString() =>
      'ParentInvite(id: $id, code: $code, studentId: $studentId, '
      'studentName: $studentName, timesUsed: $timesUsed, usageLimit: $usageLimit, '
      'isActive: $isActive)';
}

/// Represents a student who doesn't have a parent linked yet.
class StudentWithoutParent {
  /// Creates a [StudentWithoutParent] instance.
  const StudentWithoutParent({
    required this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.className,
    this.classId,
    this.avatarUrl,
    this.createdAt,
  });

  /// Student's user ID.
  final String id;

  /// Student's email (may be null if not available from database).
  final String? email;

  /// Student's first name.
  final String? firstName;

  /// Student's last name.
  final String? lastName;

  /// Name of the student's class.
  final String? className;

  /// ID of the student's class.
  final String? classId;

  /// URL to student's avatar.
  final String? avatarUrl;

  /// When the student account was created.
  final DateTime? createdAt;

  /// Returns the student's full name.
  /// Falls back to email if name is not available, or 'Unknown Student' if both are null.
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email ?? 'Unknown Student';
  }

  /// Returns initials for avatar display.
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    }
    return email != null ? email![0].toUpperCase() : '?';
  }

  /// Creates a [StudentWithoutParent] from a JSON map.
  factory StudentWithoutParent.fromJson(Map<String, dynamic> json) {
    // Parse class data if joined
    final classData = json['class'] as Map<String, dynamic>?;
    String? className;
    String? classId;

    if (classData != null) {
      className = classData['name'] as String?;
      classId = classData['id'] as String?;
    }

    // Parse createdAt
    DateTime? createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {}
    }

    // Email may be null if not available - UI should handle this gracefully
    return StudentWithoutParent(
      id: json['id'] as String,
      email: json['email'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      className: className ?? json['class_name'] as String?,
      classId: classId ?? json['class_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentWithoutParent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StudentWithoutParent(id: $id, name: $fullName, class: $className)';
}
