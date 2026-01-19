import '../../../../core/utils/dto_base.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/message_entity.dart';

/// Data Transfer Object for MessageEntity.
///
/// Handles safe parsing of message data from Supabase responses,
/// including nested sender and recipient profile data.
///
/// Required fields:
/// - id: Unique identifier
/// - senderId: ID of the user who sent the message
/// - content: Message text
/// - type: direct, group, or announcement
/// - isRead: Whether the message has been read
/// - createdAt: Timestamp when the message was created
///
/// Optional fields (based on message type):
/// - recipientId: For direct messages
/// - groupId: For group messages
/// - senderName, senderAvatarUrl: From joined sender profile
/// - recipientName: From joined recipient profile
class MessageDTO extends BaseDTO<MessageEntity> {
  /// Creates a [MessageDTO] instance.
  MessageDTO({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
    this.recipientId,
    this.recipientName,
    this.groupId,
    this.currentUserId,
  });

  /// Unique identifier for the message.
  final String? id;

  /// ID of the user who sent the message.
  final String? senderId;

  /// Name of the sender (from joined profile).
  final String? senderName;

  /// Avatar URL of the sender (from joined profile).
  final String? senderAvatarUrl;

  /// ID of the recipient for direct messages.
  final String? recipientId;

  /// Name of the recipient (from joined profile).
  final String? recipientName;

  /// ID of the message group for group messages.
  final String? groupId;

  /// Content/text of the message.
  final String? content;

  /// Type of the message.
  final MessageType? type;

  /// Whether the message has been read.
  final bool isRead;

  /// Timestamp when the message was created.
  final DateTime? createdAt;

  /// Current user's ID (for determining if message is from self).
  final String? currentUserId;

  /// Creates a [MessageDTO] from a Supabase response.
  ///
  /// Handles nested profile data for sender and recipient, including
  /// special handling for superadmin display names.
  ///
  /// [json] - The message data from the database.
  /// [currentUserId] - The current user's ID for isFromMe calculation.
  factory MessageDTO.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Parse sender profile with superadmin name transformation
    final senderProfile = JsonParser.parseMap(json['sender'], fieldName: 'sender');
    String? senderName;
    String? senderAvatarUrl;

    if (senderProfile != null) {
      final firstName = JsonParser.parseStringNullable(
        senderProfile['first_name'],
        fieldName: 'sender.first_name',
      );
      final lastName = JsonParser.parseStringNullable(
        senderProfile['last_name'],
        fieldName: 'sender.last_name',
      );
      final role = JsonParser.parseStringNullable(
        senderProfile['role'],
        fieldName: 'sender.role',
      );
      senderAvatarUrl = JsonParser.parseStringNullable(
        senderProfile['avatar_url'],
        fieldName: 'sender.avatar_url',
      );

      // Transform superadmin display name to "Admin " + first_name
      if (role == 'superadmin' && firstName != null) {
        senderName = 'Admin $firstName';
      } else {
        senderName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        if (senderName.isEmpty) senderName = null;
      }
    }

    // Parse recipient profile with superadmin name transformation
    final recipientProfile = JsonParser.parseMap(json['recipient'], fieldName: 'recipient');
    String? recipientName;

    if (recipientProfile != null) {
      final firstName = JsonParser.parseStringNullable(
        recipientProfile['first_name'],
        fieldName: 'recipient.first_name',
      );
      final lastName = JsonParser.parseStringNullable(
        recipientProfile['last_name'],
        fieldName: 'recipient.last_name',
      );
      final role = JsonParser.parseStringNullable(
        recipientProfile['role'],
        fieldName: 'recipient.role',
      );

      // Transform superadmin display name
      if (role == 'superadmin' && firstName != null) {
        recipientName = 'Admin $firstName';
      } else {
        recipientName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
        if (recipientName.isEmpty) recipientName = null;
      }
    }

    // Parse message type
    final typeStr = JsonParser.parseStringNullable(
      json['message_type'],
      fieldName: 'message_type',
    );
    final type = JsonParser.parseEnum<MessageType>(
      typeStr,
      MessageType.values,
      fieldName: 'message_type',
      defaultValue: MessageType.direct,
    );

    // Parse created_at with fallback to current time
    final createdAt = JsonParser.parseDateTime(
          json['created_at'],
          fieldName: 'created_at',
        ) ??
        DateTime.now();

    return MessageDTO(
      id: JsonParser.parseStringNullable(json['id'], fieldName: 'id'),
      senderId: JsonParser.parseStringNullable(
        json['sender_id'],
        fieldName: 'sender_id',
      ),
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      recipientId: JsonParser.parseStringNullable(
        json['recipient_id'],
        fieldName: 'recipient_id',
      ),
      recipientName: recipientName,
      groupId: JsonParser.parseStringNullable(
        json['group_id'],
        fieldName: 'group_id',
      ),
      content: JsonParser.parseStringNullable(json['content'], fieldName: 'content'),
      type: type,
      isRead: JsonParser.parseBool(json['is_read'], fieldName: 'is_read'),
      createdAt: createdAt,
      currentUserId: currentUserId,
    );
  }

  @override
  bool get isValid {
    // Required fields
    if (id == null || id!.isEmpty) return false;
    if (senderId == null || senderId!.isEmpty) return false;
    if (content == null) return false; // Empty content is allowed
    if (type == null) return false;
    if (createdAt == null) return false;

    // Type-specific validation
    if (type == MessageType.direct && (recipientId == null || recipientId!.isEmpty)) {
      return false;
    }
    if (type == MessageType.group && (groupId == null || groupId!.isEmpty)) {
      return false;
    }

    return true;
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (id == null || id!.isEmpty) {
      errors.add('id is required');
    }

    if (senderId == null || senderId!.isEmpty) {
      errors.add('sender_id is required');
    }

    if (content == null) {
      errors.add('content is required');
    }

    if (type == null) {
      errors.add('message_type is required');
    }

    if (createdAt == null) {
      errors.add('created_at is required');
    }

    // Type-specific validation
    if (type == MessageType.direct && (recipientId == null || recipientId!.isEmpty)) {
      errors.add('recipient_id is required for direct messages');
    }

    if (type == MessageType.group && (groupId == null || groupId!.isEmpty)) {
      errors.add('group_id is required for group messages');
    }

    return errors;
  }

  @override
  MessageEntity toEntity() {
    if (!isValid) {
      throw StateError(
        'Cannot convert invalid MessageDTO to MessageEntity. '
        'Errors: ${validationErrors.join(', ')}',
      );
    }

    return MessageEntity(
      id: id!,
      senderId: senderId!,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      recipientId: recipientId,
      recipientName: recipientName,
      groupId: groupId,
      content: content!,
      type: type!,
      isRead: isRead,
      createdAt: createdAt!,
      currentUserId: currentUserId,
    );
  }

  /// Converts back to JSON for sending messages.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      'group_id': groupId,
      'content': content,
      'message_type': type?.name,
      'is_read': isRead,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'MessageDTO(id: $id, senderId: $senderId, type: ${type?.name}, '
      'content: ${content != null && content!.length > 20 ? '${content!.substring(0, 20)}...' : content}, '
      'isValid: $isValid)';
}

/// Extension for parsing lists of messages from API responses.
extension MessageDTOListParser on List<Map<String, dynamic>> {
  /// Parses a list of JSON maps to MessageDTOs.
  ///
  /// [currentUserId] is used to populate the currentUserId field for isFromMe calculation.
  List<MessageDTO> toMessageDTOs({String? currentUserId}) {
    return map((json) => MessageDTO.fromJson(json, currentUserId: currentUserId)).toList();
  }

  /// Parses and converts to MessageEntity list, filtering invalid entries.
  List<MessageEntity> toMessages({String? currentUserId, bool logErrors = true}) {
    final dtos = toMessageDTOs(currentUserId: currentUserId);
    final messages = <MessageEntity>[];
    for (final dto in dtos) {
      final entity = dto.toEntityOrNull(logErrors: logErrors, context: 'Message');
      if (entity != null) {
        messages.add(entity);
      }
    }
    return messages;
  }
}
