/// Represents a member of a message group.
///
/// Contains information about a user's membership in a message group,
/// including their profile information.
class GroupMemberEntity {
  /// Creates a [GroupMemberEntity] instance.
  const GroupMemberEntity({
    required this.id,
    required this.userId,
    this.userName,
    this.userRole,
    this.avatarUrl,
  });

  /// Unique identifier for the membership (composite of group_id and user_id).
  final String id;

  /// ID of the user who is a member.
  final String userId;

  /// Name of the user (joined from profiles).
  final String? userName;

  /// Role of the user (teacher, student, parent, etc.).
  final String? userRole;

  /// Avatar URL of the user.
  final String? avatarUrl;

  /// Creates a [GroupMemberEntity] from a JSON map.
  factory GroupMemberEntity.fromJson(Map<String, dynamic> json) {
    // Handle user profile data (from join)
    String? userName;
    String? userRole;
    String? avatarUrl;
    final userProfile = json['user'] as Map<String, dynamic>?;
    if (userProfile != null) {
      final firstName = userProfile['first_name'] as String?;
      final lastName = userProfile['last_name'] as String?;
      userRole = userProfile['role'] as String?;
      avatarUrl = userProfile['avatar_url'] as String?;

      // Transform superadmin display name to "Admin " + first_name
      if (userRole == 'superadmin' && firstName != null) {
        userName = 'Admin $firstName';
      } else if (firstName != null || lastName != null) {
        userName = [firstName, lastName].where((s) => s != null).join(' ').trim();
      }
    }

    return GroupMemberEntity(
      id: json['id'] as String? ?? '${json['group_id']}_${json['user_id']}',
      userId: json['user_id'] as String,
      userName: userName,
      userRole: userRole,
      avatarUrl: avatarUrl,
    );
  }

  /// Converts this [GroupMemberEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_role': userRole,
      'avatar_url': avatarUrl,
    };
  }

  /// Creates a copy of this [GroupMemberEntity] with the given fields replaced.
  GroupMemberEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? avatarUrl,
  }) {
    return GroupMemberEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GroupMemberEntity &&
        other.id == id &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(id, userId);

  @override
  String toString() => 'GroupMemberEntity(id: $id, userId: $userId, '
      'userName: $userName, userRole: $userRole)';
}

/// Represents a message group in the chat system.
///
/// A message group is a chat room that can have multiple members.
/// Groups can be of different types (class, staff, custom) and
/// contain multiple messages.
class MessageGroupEntity {
  /// Creates a [MessageGroupEntity] instance.
  const MessageGroupEntity({
    required this.id,
    this.schoolId,
    required this.name,
    required this.type,
    required this.createdBy,
    required this.createdAt,
    this.members = const [],
  });

  /// Unique identifier for the group.
  final String id;

  /// ID of the school this group belongs to.
  /// Can be null for superadmin cross-school groups.
  final String? schoolId;

  /// Name of the group.
  final String name;

  /// Type of group (class, staff, custom).
  final String type;

  /// ID of the user who created the group.
  final String createdBy;

  /// Timestamp when the group was created.
  final DateTime createdAt;

  /// List of group members.
  final List<GroupMemberEntity> members;

  /// Returns the number of members in the group.
  int get memberCount => members.length;

  /// Returns true if the given user is a member of this group.
  bool isMember(String userId) {
    return members.any((m) => m.userId == userId);
  }

  /// Returns true if the given user is the creator of this group.
  bool isCreator(String userId) => createdBy == userId;

  /// Creates a [MessageGroupEntity] from a JSON map.
  factory MessageGroupEntity.fromJson(Map<String, dynamic> json) {
    // Parse created_at
    DateTime createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      createdAt = DateTime.parse(createdAtStr);
    } else {
      createdAt = DateTime.now();
    }

    // Parse members
    List<GroupMemberEntity> members = [];
    if (json['members'] != null) {
      members = (json['members'] as List)
          .map((m) => GroupMemberEntity.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return MessageGroupEntity(
      id: json['id'] as String,
      schoolId: json['school_id'] as String?, // Can be null for superadmin cross-school groups
      name: json['name'] as String,
      type: json['type'] as String? ?? 'custom',
      createdBy: json['created_by'] as String,
      createdAt: createdAt,
      members: members,
    );
  }

  /// Converts this [MessageGroupEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'type': type,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'members': members.map((m) => m.toJson()).toList(),
    };
  }

  /// Creates a copy of this [MessageGroupEntity] with the given fields replaced.
  MessageGroupEntity copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? type,
    String? createdBy,
    DateTime? createdAt,
    List<GroupMemberEntity>? members,
  }) {
    return MessageGroupEntity(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageGroupEntity &&
        other.id == id &&
        other.name == name &&
        other.schoolId == schoolId;
  }

  @override
  int get hashCode => Object.hash(id, name, schoolId);

  @override
  String toString() => 'MessageGroupEntity(id: $id, name: $name, '
      'type: $type, memberCount: $memberCount)';
}
