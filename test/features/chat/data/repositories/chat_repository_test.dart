import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/chat/domain/entities/message_group_entity.dart';
import 'package:classio/features/chat/domain/entities/conversation_entity.dart';
import 'package:classio/features/chat/domain/entities/message_entity.dart';

void main() {
  group('MessageGroupEntity', () {
    test('creates from JSON correctly with all fields', () {
      final json = {
        'id': 'group-1',
        'school_id': 'school-1',
        'name': 'Test Group',
        'type': 'custom',
        'created_by': 'user-1',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageGroupEntity.fromJson(json);

      expect(entity.id, 'group-1');
      expect(entity.schoolId, 'school-1');
      expect(entity.name, 'Test Group');
      expect(entity.type, 'custom');
      expect(entity.createdBy, 'user-1');
      expect(entity.createdAt, DateTime.utc(2026, 1, 13, 10, 0, 0));
      expect(entity.members, isEmpty);
    });

    test('defaults type to custom when null', () {
      final json = {
        'id': 'group-1',
        'school_id': 'school-1',
        'name': 'Test Group',
        'type': null,
        'created_by': 'user-1',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageGroupEntity.fromJson(json);

      expect(entity.type, 'custom');
    });

    test('handles members list mapping correctly', () {
      final json = {
        'id': 'group-1',
        'school_id': 'school-1',
        'name': 'Test Group',
        'type': 'class',
        'created_by': 'user-1',
        'created_at': '2026-01-13T10:00:00Z',
        'members': [
          {
            'id': 'member-1',
            'user_id': 'user-2',
            'user': {
              'first_name': 'John',
              'last_name': 'Doe',
              'role': 'teacher',
              'avatar_url': 'https://example.com/avatar1.jpg',
            },
          },
          {
            'id': 'member-2',
            'user_id': 'user-3',
            'user': {
              'first_name': 'Jane',
              'last_name': 'Smith',
              'role': 'student',
              'avatar_url': null,
            },
          },
        ],
      };

      final entity = MessageGroupEntity.fromJson(json);

      expect(entity.members.length, 2);
      expect(entity.memberCount, 2);

      final member1 = entity.members[0];
      expect(member1.id, 'member-1');
      expect(member1.userId, 'user-2');
      expect(member1.userName, 'John Doe');
      expect(member1.userRole, 'teacher');
      expect(member1.avatarUrl, 'https://example.com/avatar1.jpg');

      final member2 = entity.members[1];
      expect(member2.id, 'member-2');
      expect(member2.userId, 'user-3');
      expect(member2.userName, 'Jane Smith');
      expect(member2.userRole, 'student');
      expect(member2.avatarUrl, isNull);
    });

    test('isMember correctly identifies group members', () {
      final json = {
        'id': 'group-1',
        'school_id': 'school-1',
        'name': 'Test Group',
        'type': 'custom',
        'created_by': 'user-1',
        'created_at': '2026-01-13T10:00:00Z',
        'members': [
          {'id': 'member-1', 'user_id': 'user-2'},
          {'id': 'member-2', 'user_id': 'user-3'},
        ],
      };

      final entity = MessageGroupEntity.fromJson(json);

      expect(entity.isMember('user-2'), isTrue);
      expect(entity.isMember('user-3'), isTrue);
      expect(entity.isMember('user-4'), isFalse);
    });

    test('isCreator correctly identifies group creator', () {
      final json = {
        'id': 'group-1',
        'school_id': 'school-1',
        'name': 'Test Group',
        'type': 'custom',
        'created_by': 'user-1',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageGroupEntity.fromJson(json);

      expect(entity.isCreator('user-1'), isTrue);
      expect(entity.isCreator('user-2'), isFalse);
    });

    test('toJson produces valid JSON that can be parsed back', () {
      final original = MessageGroupEntity(
        id: 'group-1',
        schoolId: 'school-1',
        name: 'Test Group',
        type: 'staff',
        createdBy: 'user-1',
        createdAt: DateTime.utc(2026, 1, 13, 10, 0, 0),
        members: const [],
      );

      final json = original.toJson();
      final parsed = MessageGroupEntity.fromJson(json);

      expect(parsed.id, original.id);
      expect(parsed.schoolId, original.schoolId);
      expect(parsed.name, original.name);
      expect(parsed.type, original.type);
      expect(parsed.createdBy, original.createdBy);
      expect(parsed.createdAt, original.createdAt);
    });

    test('handles missing created_at with DateTime.now()', () {
      final json = {
        'id': 'group-1',
        'school_id': 'school-1',
        'name': 'Test Group',
        'type': 'custom',
        'created_by': 'user-1',
      };

      final beforeTest = DateTime.now();
      final entity = MessageGroupEntity.fromJson(json);
      final afterTest = DateTime.now();

      expect(
        entity.createdAt.isAfter(beforeTest.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        entity.createdAt.isBefore(afterTest.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });

  group('GroupMemberEntity', () {
    test('creates from JSON with nested user profile', () {
      final json = {
        'id': 'member-1',
        'user_id': 'user-123',
        'user': {
          'first_name': 'John',
          'last_name': 'Doe',
          'role': 'teacher',
          'avatar_url': 'https://example.com/avatar.jpg',
        },
      };

      final entity = GroupMemberEntity.fromJson(json);

      expect(entity.id, 'member-1');
      expect(entity.userId, 'user-123');
      expect(entity.userName, 'John Doe');
      expect(entity.userRole, 'teacher');
      expect(entity.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('handles null user profile gracefully', () {
      final json = {
        'id': 'member-1',
        'user_id': 'user-123',
        'user': null,
      };

      final entity = GroupMemberEntity.fromJson(json);

      expect(entity.id, 'member-1');
      expect(entity.userId, 'user-123');
      expect(entity.userName, isNull);
      expect(entity.userRole, isNull);
      expect(entity.avatarUrl, isNull);
    });

    test('generates composite id when id is missing', () {
      final json = {
        'group_id': 'group-1',
        'user_id': 'user-123',
      };

      final entity = GroupMemberEntity.fromJson(json);

      expect(entity.id, 'group-1_user-123');
      expect(entity.userId, 'user-123');
    });

    test('handles first name only in user profile', () {
      final json = {
        'id': 'member-1',
        'user_id': 'user-123',
        'user': {
          'first_name': 'John',
          'last_name': null,
        },
      };

      final entity = GroupMemberEntity.fromJson(json);

      expect(entity.userName, 'John');
    });

    test('handles last name only in user profile', () {
      final json = {
        'id': 'member-1',
        'user_id': 'user-123',
        'user': {
          'first_name': null,
          'last_name': 'Doe',
        },
      };

      final entity = GroupMemberEntity.fromJson(json);

      expect(entity.userName, 'Doe');
    });

    test('equality is based on id and userId', () {
      final member1 = GroupMemberEntity(
        id: 'member-1',
        userId: 'user-123',
        userName: 'John Doe',
        userRole: 'teacher',
      );

      final member2 = GroupMemberEntity(
        id: 'member-1',
        userId: 'user-123',
        userName: 'Different Name',
        userRole: 'student',
      );

      final member3 = GroupMemberEntity(
        id: 'member-2',
        userId: 'user-456',
        userName: 'John Doe',
        userRole: 'teacher',
      );

      expect(member1, equals(member2));
      expect(member1, isNot(equals(member3)));
    });
  });

  group('ConversationEntity', () {
    test('creates from JSON correctly', () {
      final json = {
        'id': 'conv-1',
        'name': 'Test Conversation',
        'avatar_url': 'https://example.com/avatar.jpg',
        'is_group': true,
        'unread_count': 5,
        'participant_ids': ['user-1', 'user-2', 'user-3'],
        'group_type': 'class',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.id, 'conv-1');
      expect(entity.name, 'Test Conversation');
      expect(entity.avatarUrl, 'https://example.com/avatar.jpg');
      expect(entity.isGroup, isTrue);
      expect(entity.isDirect, isFalse);
      expect(entity.unreadCount, 5);
      expect(entity.hasUnread, isTrue);
      expect(entity.participantIds, ['user-1', 'user-2', 'user-3']);
      expect(entity.groupType, 'class');
      expect(entity.createdAt, DateTime.utc(2026, 1, 13, 10, 0, 0));
    });

    test('handles direct conversation (non-group)', () {
      final json = {
        'id': 'user-2',
        'name': 'Jane Smith',
        'is_group': false,
        'unread_count': 0,
        'participant_ids': ['user-1', 'user-2'],
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.isGroup, isFalse);
      expect(entity.isDirect, isTrue);
      expect(entity.groupType, isNull);
      expect(entity.hasUnread, isFalse);
    });

    test('handles nested last_message correctly', () {
      final json = {
        'id': 'conv-1',
        'name': 'Test Conversation',
        'is_group': false,
        'unread_count': 1,
        'participant_ids': ['user-1', 'user-2'],
        'last_message': {
          'id': 'msg-1',
          'sender_id': 'user-2',
          'content': 'Hello there!',
          'message_type': 'direct',
          'is_read': false,
          'created_at': '2026-01-13T12:30:00Z',
        },
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.lastMessage, isNotNull);
      expect(entity.lastMessage!.id, 'msg-1');
      expect(entity.lastMessage!.content, 'Hello there!');
      expect(entity.lastMessagePreview, 'Hello there!');
      expect(entity.lastActivityTime, entity.lastMessage!.createdAt);
    });

    test('lastMessagePreview truncates long messages', () {
      final json = {
        'id': 'conv-1',
        'name': 'Test Conversation',
        'is_group': false,
        'unread_count': 0,
        'participant_ids': [],
        'last_message': {
          'id': 'msg-1',
          'sender_id': 'user-2',
          'content':
              'This is a very long message that should be truncated because it exceeds the maximum preview length',
          'message_type': 'direct',
          'is_read': true,
          'created_at': '2026-01-13T12:30:00Z',
        },
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.lastMessagePreview.length, 53); // 50 chars + '...'
      expect(entity.lastMessagePreview.endsWith('...'), isTrue);
    });

    test('defaults is_group to false when null', () {
      final json = {
        'id': 'conv-1',
        'name': 'Test Conversation',
        'unread_count': 0,
        'participant_ids': [],
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.isGroup, isFalse);
    });

    test('defaults unread_count to 0 when null', () {
      final json = {
        'id': 'conv-1',
        'name': 'Test Conversation',
        'participant_ids': [],
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.unreadCount, 0);
      expect(entity.hasUnread, isFalse);
    });

    test('lastActivityTime returns createdAt when no lastMessage', () {
      final json = {
        'id': 'conv-1',
        'name': 'Test Conversation',
        'is_group': false,
        'unread_count': 0,
        'participant_ids': [],
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = ConversationEntity.fromJson(json);

      expect(entity.lastActivityTime, entity.createdAt);
    });
  });

  group('MessageEntity', () {
    test('creates from JSON correctly', () {
      final json = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'recipient_id': 'user-2',
        'content': 'Hello!',
        'message_type': 'direct',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageEntity.fromJson(json);

      expect(entity.id, 'msg-1');
      expect(entity.senderId, 'user-1');
      expect(entity.recipientId, 'user-2');
      expect(entity.content, 'Hello!');
      expect(entity.type, MessageType.direct);
      expect(entity.isRead, isFalse);
      expect(entity.isDirect, isTrue);
      expect(entity.isGroup, isFalse);
      expect(entity.isAnnouncement, isFalse);
    });

    test('parses sender profile from nested JSON', () {
      final json = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'content': 'Hello!',
        'message_type': 'group',
        'is_read': true,
        'created_at': '2026-01-13T10:00:00Z',
        'sender': {
          'first_name': 'John',
          'last_name': 'Doe',
          'avatar_url': 'https://example.com/avatar.jpg',
        },
      };

      final entity = MessageEntity.fromJson(json);

      expect(entity.senderName, 'John Doe');
      expect(entity.senderAvatarUrl, 'https://example.com/avatar.jpg');
    });

    test('parses recipient profile from nested JSON', () {
      final json = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'recipient_id': 'user-2',
        'content': 'Hello!',
        'message_type': 'direct',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
        'recipient': {
          'first_name': 'Jane',
          'last_name': 'Smith',
        },
      };

      final entity = MessageEntity.fromJson(json);

      expect(entity.recipientName, 'Jane Smith');
    });

    test('isFromMe correctly identifies own messages', () {
      final json = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'content': 'Hello!',
        'message_type': 'direct',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageEntity.fromJson(json, currentUserId: 'user-1');

      expect(entity.isFromMe, isTrue);

      final entity2 = MessageEntity.fromJson(json, currentUserId: 'user-2');

      expect(entity2.isFromMe, isFalse);
    });

    test('handles different message types', () {
      final directJson = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'content': 'Direct message',
        'message_type': 'direct',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final groupJson = {
        'id': 'msg-2',
        'sender_id': 'user-1',
        'group_id': 'group-1',
        'content': 'Group message',
        'message_type': 'group',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final announcementJson = {
        'id': 'msg-3',
        'sender_id': 'user-1',
        'content': 'Announcement',
        'message_type': 'announcement',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final direct = MessageEntity.fromJson(directJson);
      final group = MessageEntity.fromJson(groupJson);
      final announcement = MessageEntity.fromJson(announcementJson);

      expect(direct.isDirect, isTrue);
      expect(direct.isGroup, isFalse);
      expect(direct.isAnnouncement, isFalse);

      expect(group.isDirect, isFalse);
      expect(group.isGroup, isTrue);
      expect(group.isAnnouncement, isFalse);

      expect(announcement.isDirect, isFalse);
      expect(announcement.isGroup, isFalse);
      expect(announcement.isAnnouncement, isTrue);
    });

    test('defaults message_type to direct when invalid', () {
      final json = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'content': 'Hello!',
        'message_type': 'invalid_type',
        'is_read': false,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageEntity.fromJson(json);

      expect(entity.type, MessageType.direct);
    });

    test('defaults is_read to false when null', () {
      final json = {
        'id': 'msg-1',
        'sender_id': 'user-1',
        'content': 'Hello!',
        'message_type': 'direct',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final entity = MessageEntity.fromJson(json);

      expect(entity.isRead, isFalse);
    });
  });

  group('MessageType', () {
    test('fromString parses valid types', () {
      expect(MessageType.fromString('direct'), MessageType.direct);
      expect(MessageType.fromString('group'), MessageType.group);
      expect(MessageType.fromString('announcement'), MessageType.announcement);
    });

    test('fromString is case insensitive', () {
      expect(MessageType.fromString('DIRECT'), MessageType.direct);
      expect(MessageType.fromString('Group'), MessageType.group);
      expect(MessageType.fromString('ANNOUNCEMENT'), MessageType.announcement);
    });

    test('fromString defaults to direct for null', () {
      expect(MessageType.fromString(null), MessageType.direct);
    });

    test('fromString defaults to direct for invalid string', () {
      expect(MessageType.fromString('invalid'), MessageType.direct);
      expect(MessageType.fromString(''), MessageType.direct);
    });

    test('toJson returns correct string', () {
      expect(MessageType.direct.toJson(), 'direct');
      expect(MessageType.group.toJson(), 'group');
      expect(MessageType.announcement.toJson(), 'announcement');
    });
  });
}
