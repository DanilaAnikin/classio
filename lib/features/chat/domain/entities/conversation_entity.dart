import 'message_entity.dart';

/// Role hierarchy for determining communication permissions.
/// Lower numbers indicate higher authority in the hierarchy.
const roleHierarchy = {
  'superadmin': 0,
  'bigadmin': 1,
  'admin': 2,
  'teacher': 3,
  'parent': 4,
  'student': 5,
};

/// Returns the hierarchy level for a role string.
/// Returns a high number (999) for unknown roles.
int getRoleHierarchyLevel(String? role) {
  if (role == null) return 999;
  return roleHierarchy[role.toLowerCase()] ?? 999;
}

/// Checks if [initiatorRole] can initiate a conversation with [targetRole].
/// Higher hierarchy (lower number) can always message lower hierarchy.
/// Same level can message each other.
/// Lower hierarchy cannot initiate with higher hierarchy.
bool canInitiateConversation(String? initiatorRole, String? targetRole) {
  final initiatorLevel = getRoleHierarchyLevel(initiatorRole);
  final targetLevel = getRoleHierarchyLevel(targetRole);
  return initiatorLevel <= targetLevel;
}

/// Represents a conversation in the chat system.
///
/// A conversation can be either a direct conversation between two users
/// or a group conversation. It contains metadata about the conversation
/// including the last message, unread count, and participants.
class ConversationEntity {
  /// Creates a [ConversationEntity] instance.
  const ConversationEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.isGroup,
    this.lastMessage,
    required this.unreadCount,
    required this.participantIds,
    this.groupType,
    this.createdAt,
    this.participantRole,
  });

  /// Unique identifier for the conversation.
  ///
  /// For direct conversations, this is the other user's ID.
  /// For group conversations, this is the group ID.
  final String id;

  /// Display name of the conversation.
  ///
  /// For direct conversations, this is the other user's name.
  /// For group conversations, this is the group name.
  final String name;

  /// Avatar URL for the conversation.
  ///
  /// For direct conversations, this is the other user's avatar.
  /// For group conversations, this can be a group icon or null.
  final String? avatarUrl;

  /// Whether this is a group conversation.
  final bool isGroup;

  /// The most recent message in the conversation (if any).
  final MessageEntity? lastMessage;

  /// Number of unread messages in the conversation.
  final int unreadCount;

  /// List of participant user IDs in the conversation.
  final List<String> participantIds;

  /// Type of group (class, staff, custom) - only for group conversations.
  final String? groupType;

  /// Timestamp when the conversation was created.
  final DateTime? createdAt;

  /// Role of the other participant (for direct conversations).
  /// Used to determine if the current user can initiate conversation based on role hierarchy.
  final String? participantRole;

  /// Returns true if this is a direct (non-group) conversation.
  bool get isDirect => !isGroup;

  /// Returns true if there are unread messages.
  bool get hasUnread => unreadCount > 0;

  /// Returns the time of the last message or conversation creation time.
  DateTime? get lastActivityTime => lastMessage?.createdAt ?? createdAt;

  /// Returns a preview of the last message content.
  String get lastMessagePreview {
    if (lastMessage == null) return '';
    final content = lastMessage!.content;
    if (content.length > 50) {
      return '${content.substring(0, 50)}...';
    }
    return content;
  }

  /// Checks if a user with the given role can initiate a conversation
  /// with the participant of this direct conversation.
  /// Returns true for group conversations (role hierarchy doesn't apply).
  bool canUserInitiate(String? userRole) {
    if (isGroup) return true;
    return canInitiateConversation(userRole, participantRole);
  }

  /// Creates a [ConversationEntity] from a JSON map.
  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    // Parse last message if present
    MessageEntity? lastMessage;
    if (json['last_message'] != null) {
      lastMessage = MessageEntity.fromJson(
        json['last_message'] as Map<String, dynamic>,
      );
    }

    // Parse participant IDs
    List<String> participantIds = [];
    if (json['participant_ids'] != null) {
      participantIds = List<String>.from(json['participant_ids'] as List);
    }

    // Parse created_at
    DateTime? createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    }

    return ConversationEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      lastMessage: lastMessage,
      unreadCount: json['unread_count'] as int? ?? 0,
      participantIds: participantIds,
      groupType: json['group_type'] as String?,
      createdAt: createdAt,
      participantRole: json['participant_role'] as String?,
    );
  }

  /// Converts this [ConversationEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'is_group': isGroup,
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'participant_ids': participantIds,
      'group_type': groupType,
      'created_at': createdAt?.toIso8601String(),
      'participant_role': participantRole,
    };
  }

  /// Creates a copy of this [ConversationEntity] with the given fields replaced.
  ConversationEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    bool? isGroup,
    MessageEntity? lastMessage,
    int? unreadCount,
    List<String>? participantIds,
    String? groupType,
    DateTime? createdAt,
    String? participantRole,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGroup: isGroup ?? this.isGroup,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      participantIds: participantIds ?? this.participantIds,
      groupType: groupType ?? this.groupType,
      createdAt: createdAt ?? this.createdAt,
      participantRole: participantRole ?? this.participantRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ConversationEntity &&
        other.id == id &&
        other.name == name &&
        other.isGroup == isGroup &&
        other.unreadCount == unreadCount;
  }

  @override
  int get hashCode => Object.hash(id, name, isGroup, unreadCount);

  @override
  String toString() => 'ConversationEntity(id: $id, name: $name, '
      'isGroup: $isGroup, unreadCount: $unreadCount)';
}
