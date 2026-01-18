/// Message type enumeration.
///
/// Defines the different types of messages in the chat system.
enum MessageType {
  /// Direct message between two users.
  direct,

  /// Group message sent to a message group.
  group,

  /// School-wide announcement (typically from principal/admin).
  announcement;

  /// Converts a string to a [MessageType].
  ///
  /// Returns [MessageType.direct] if the string doesn't match any type.
  static MessageType fromString(String? type) {
    if (type == null) return MessageType.direct;
    try {
      return MessageType.values.firstWhere(
        (t) => t.name.toLowerCase() == type.toLowerCase(),
      );
    } catch (_) {
      return MessageType.direct;
    }
  }

  /// Converts the type to a string.
  String toJson() => name;
}

/// Represents a message in the chat system.
///
/// A message can be a direct message between two users, a group message,
/// or a school-wide announcement. Messages are immutable entities that
/// contain sender information, content, and metadata.
class MessageEntity {
  /// Creates a [MessageEntity] instance.
  const MessageEntity({
    required this.id,
    required this.senderId,
    this.senderName,
    this.senderAvatarUrl,
    this.recipientId,
    this.recipientName,
    this.groupId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.currentUserId,
  });

  /// Unique identifier for the message.
  final String id;

  /// ID of the user who sent the message.
  final String senderId;

  /// Name of the sender (joined from profiles).
  final String? senderName;

  /// Avatar URL of the sender (joined from profiles).
  final String? senderAvatarUrl;

  /// ID of the recipient for direct messages (null for group messages).
  final String? recipientId;

  /// Name of the recipient (joined from profiles).
  final String? recipientName;

  /// ID of the message group for group messages (null for direct messages).
  final String? groupId;

  /// Content/text of the message.
  final String content;

  /// Type of the message (direct, group, announcement).
  final MessageType type;

  /// Whether the message has been read by the recipient.
  final bool isRead;

  /// Timestamp when the message was created.
  final DateTime createdAt;

  /// Current user's ID (used for determining if message is from self).
  final String? currentUserId;

  /// Returns true if this message was sent by the current user.
  bool get isFromMe => currentUserId != null && senderId == currentUserId;

  /// Returns true if this is a direct message.
  bool get isDirect => type == MessageType.direct;

  /// Returns true if this is a group message.
  bool get isGroup => type == MessageType.group;

  /// Returns true if this is an announcement.
  bool get isAnnouncement => type == MessageType.announcement;

  /// Creates a [MessageEntity] from a JSON map.
  factory MessageEntity.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Parse created_at from string if present
    DateTime createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      createdAt = DateTime.parse(createdAtStr);
    } else {
      createdAt = DateTime.now();
    }

    // Handle sender profile data (from join)
    String? senderName;
    String? senderAvatarUrl;
    final senderProfile = json['sender'] as Map<String, dynamic>?;
    if (senderProfile != null) {
      final firstName = senderProfile['first_name'] as String?;
      final lastName = senderProfile['last_name'] as String?;
      final role = senderProfile['role'] as String?;
      senderAvatarUrl = senderProfile['avatar_url'] as String?;

      // Transform superadmin display name to "Admin " + first_name
      if (role == 'superadmin' && firstName != null) {
        senderName = 'Admin $firstName';
      } else if (firstName != null || lastName != null) {
        senderName = [firstName, lastName].where((s) => s != null).join(' ').trim();
      }
    }

    // Handle recipient profile data (from join)
    String? recipientName;
    final recipientProfile = json['recipient'] as Map<String, dynamic>?;
    if (recipientProfile != null) {
      final firstName = recipientProfile['first_name'] as String?;
      final lastName = recipientProfile['last_name'] as String?;
      final role = recipientProfile['role'] as String?;

      // Transform superadmin display name to "Admin " + first_name
      if (role == 'superadmin' && firstName != null) {
        recipientName = 'Admin $firstName';
      } else if (firstName != null || lastName != null) {
        recipientName = [firstName, lastName].where((s) => s != null).join(' ').trim();
      }
    }

    return MessageEntity(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      recipientId: json['recipient_id'] as String?,
      recipientName: recipientName,
      groupId: json['group_id'] as String?,
      content: json['content'] as String,
      type: MessageType.fromString(json['message_type'] as String?),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: createdAt,
      currentUserId: currentUserId,
    );
  }

  /// Converts this [MessageEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'group_id': groupId,
      'content': content,
      'message_type': type.toJson(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [MessageEntity] with the given fields replaced.
  MessageEntity copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? recipientId,
    String? recipientName,
    String? groupId,
    String? content,
    MessageType? type,
    bool? isRead,
    DateTime? createdAt,
    String? currentUserId,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MessageEntity &&
        other.id == id &&
        other.senderId == senderId &&
        other.recipientId == recipientId &&
        other.groupId == groupId &&
        other.content == content &&
        other.type == type &&
        other.isRead == isRead &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        senderId,
        recipientId,
        groupId,
        content,
        type,
        isRead,
        createdAt,
      );

  @override
  String toString() => 'MessageEntity(id: $id, senderId: $senderId, '
      'type: ${type.name}, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content})';
}
