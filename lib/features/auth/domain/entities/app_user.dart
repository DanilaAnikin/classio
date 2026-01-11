/// User role enumeration.
///
/// Defines the different roles a user can have in the Classio application.
enum UserRole {
  /// Super Admin role - has full system access across all schools.
  superadmin,

  /// Big Admin role - has elevated privileges across multiple schools.
  bigadmin,

  /// Admin role - has full access to all features within a school.
  admin,

  /// Teacher role - has access to teacher-specific features.
  teacher,

  /// Student role - has access to student-specific features.
  student,

  /// Parent role - has access to parent-specific features.
  parent;

  /// Converts a string to a [UserRole].
  ///
  /// Returns null if the string doesn't match any role.
  static UserRole? fromString(String? role) {
    if (role == null) return null;
    try {
      return UserRole.values.firstWhere(
        (r) => r.name.toLowerCase() == role.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Converts the role to a string.
  String toJson() => name;
}

/// Application user entity.
///
/// Represents a user in the Classio application with their
/// basic information and role.
class AppUser {
  /// Creates an [AppUser] instance.
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.firstName,
    this.lastName,
    this.schoolId,
    this.avatarUrl,
    this.createdAt,
  });

  /// Unique identifier for the user.
  final String id;

  /// User's email address.
  final String email;

  /// User's role in the application.
  final UserRole role;

  /// User's first name.
  final String? firstName;

  /// User's last name.
  final String? lastName;

  /// School ID the user belongs to (null for superadmin).
  final String? schoolId;

  /// URL to user's avatar image.
  final String? avatarUrl;

  /// Timestamp when the user was created.
  final DateTime? createdAt;

  /// Creates an [AppUser] from a JSON map.
  ///
  /// Returns null if the JSON is invalid or missing required fields.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final email = json['email'] as String?;
    final roleString = json['role'] as String?;
    final role = UserRole.fromString(roleString);

    if (id == null || email == null || role == null) {
      throw ArgumentError('Invalid JSON: missing required fields');
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

    return AppUser(
      id: id,
      email: email,
      role: role,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      schoolId: json['school_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: createdAt,
    );
  }

  /// Converts this [AppUser] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.toJson(),
      'first_name': firstName,
      'last_name': lastName,
      'school_id': schoolId,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [AppUser] with the given fields replaced
  /// with new values.
  AppUser copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? firstName,
    String? lastName,
    String? schoolId,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      schoolId: schoolId ?? this.schoolId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.role == role &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.schoolId == schoolId &&
        other.avatarUrl == avatarUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        role,
        firstName,
        lastName,
        schoolId,
        avatarUrl,
        createdAt,
      );

  @override
  String toString() => 'AppUser(id: $id, email: $email, role: ${role.name}, '
      'firstName: $firstName, lastName: $lastName, schoolId: $schoolId)';

  // RBAC Helper Methods

  /// Returns the user's full name.
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email;
  }

  /// Checks if the user is a superadmin.
  bool get isSuperAdmin => role == UserRole.superadmin;

  /// Checks if the user is a bigadmin.
  bool get isBigAdmin => role == UserRole.bigadmin;

  /// Checks if the user is an admin (school admin).
  bool get isAdmin => role == UserRole.admin;

  /// Checks if the user is a teacher.
  bool get isTeacher => role == UserRole.teacher;

  /// Checks if the user is a student.
  bool get isStudent => role == UserRole.student;

  /// Checks if the user is a parent.
  bool get isParent => role == UserRole.parent;

  /// Checks if the user has admin privileges (superadmin, bigadmin, or admin).
  bool get hasAdminPrivileges => isSuperAdmin || isBigAdmin || isAdmin;

  /// Checks if the user can manage users within their school.
  bool get canManageUsers => isSuperAdmin || isBigAdmin || isAdmin;

  /// Checks if the user can manage classes within their school.
  bool get canManageClasses => isSuperAdmin || isBigAdmin || isAdmin || isTeacher;

  /// Checks if the user can manage school staff (bigadmin and superadmin only).
  bool get canManageSchoolStaff => isSuperAdmin || isBigAdmin;

  /// Checks if the user can access all schools (superadmin only).
  bool get canAccessAllSchools => isSuperAdmin;

  /// Checks if the user belongs to a specific school.
  bool belongsToSchool(String? checkSchoolId) {
    if (checkSchoolId == null) return false;
    if (isSuperAdmin) return true; // Superadmin can access all schools
    return schoolId == checkSchoolId;
  }

  /// Checks if the user has a specific role or higher privileges.
  bool hasRoleOrHigher(UserRole checkRole) {
    // Define role hierarchy: superadmin > bigadmin > admin > teacher > student/parent
    const roleHierarchy = {
      UserRole.superadmin: 5,
      UserRole.bigadmin: 4,
      UserRole.admin: 3,
      UserRole.teacher: 2,
      UserRole.student: 1,
      UserRole.parent: 1,
    };

    return (roleHierarchy[role] ?? 0) >= (roleHierarchy[checkRole] ?? 0);
  }
}
