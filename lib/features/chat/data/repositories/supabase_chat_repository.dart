import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/chat_repository.dart';

/// Exception thrown when chat operations fail.
class ChatException implements Exception {
  const ChatException(this.message);

  final String message;

  @override
  String toString() => 'ChatException: $message';
}

/// Supabase implementation of [ChatRepository].
///
/// Handles all chat operations including messages, conversations,
/// groups, and real-time subscriptions using Supabase.
class SupabaseChatRepository implements ChatRepository {
  /// Creates a [SupabaseChatRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseChatRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // Role hierarchy: lower number = higher authority
  static const Map<String, int> _roleHierarchy = {
    'superadmin': 0,
    'bigadmin': 1, // Principal
    'admin': 2,
    'teacher': 3,
    'parent': 4,
    'student': 5,
  };

  /// Check if user can initiate conversation with target
  static bool canInitiateConversation(String? initiatorRole, String? targetRole) {
    if (initiatorRole == null || targetRole == null) return false;
    final initiatorLevel = _roleHierarchy[initiatorRole] ?? 999;
    final targetLevel = _roleHierarchy[targetRole] ?? 999;
    // Higher or equal authority can initiate (lower number = higher)
    return initiatorLevel <= targetLevel;
  }

  /// Transform superadmin display name to "Admin " + first_name
  String _transformSuperadminName(String? firstName, String? lastName, String? role) {
    if (role == 'superadmin' && firstName != null) {
      return 'Admin $firstName';
    }
    return [firstName, lastName].whereType<String>().join(' ');
  }

  /// Stream controller for message updates
  StreamController<MessageEntity>? _messageStreamController;

  /// Stream controller for conversation updates
  StreamController<List<ConversationEntity>>? _conversationStreamController;

  /// Stream controller for unread count updates
  StreamController<int>? _unreadCountStreamController;

  /// Realtime channel for messages
  RealtimeChannel? _messageChannel;

  /// Gets the current authenticated user's ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Throws if user is not authenticated.
  void _requireAuth() {
    if (_currentUserId == null) {
      throw const ChatException('User not authenticated');
    }
  }

  @override
  Future<List<ConversationEntity>> getConversations() async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      final List<ConversationEntity> conversations = [];

      // Get direct conversations
      final directConversations = await _getDirectConversations(userId);
      conversations.addAll(directConversations);

      // Get group conversations
      final groupConversations = await _getGroupConversations(userId);
      conversations.addAll(groupConversations);

      // Sort by last activity time (most recent first)
      conversations.sort((a, b) {
        final aTime = a.lastActivityTime;
        final bTime = b.lastActivityTime;
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;
        return bTime.compareTo(aTime);
      });

      return conversations;
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch conversations: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch conversations: $e');
    }
  }

  /// Gets direct conversations for the user.
  Future<List<ConversationEntity>> _getDirectConversations(String userId) async {
    // SECURITY FIX: Get messages sent BY the user
    final sentMessages = await _supabase
        .from('messages')
        .select('''
          id,
          sender_id,
          recipient_id,
          content,
          message_type,
          is_read,
          created_at,
          sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role),
          recipient:profiles!messages_recipient_id_fkey(id, first_name, last_name, avatar_url, role)
        ''')
        .eq('message_type', 'direct')
        .eq('sender_id', userId)
        .order('created_at', ascending: false);

    // SECURITY FIX: Get messages received BY the user
    final receivedMessages = await _supabase
        .from('messages')
        .select('''
          id,
          sender_id,
          recipient_id,
          content,
          message_type,
          is_read,
          created_at,
          sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role),
          recipient:profiles!messages_recipient_id_fkey(id, first_name, last_name, avatar_url, role)
        ''')
        .eq('message_type', 'direct')
        .eq('recipient_id', userId)
        .order('created_at', ascending: false);

    // Combine and deduplicate messages
    final Map<String, Map<String, dynamic>> messageMap = {};
    for (final msg in sentMessages) {
      messageMap[msg['id'] as String] = msg;
    }
    for (final msg in receivedMessages) {
      messageMap[msg['id'] as String] = msg;
    }

    // Sort by created_at descending
    final messages = messageMap.values.toList()
      ..sort((a, b) {
        final aTime = DateTime.parse(a['created_at'] as String);
        final bTime = DateTime.parse(b['created_at'] as String);
        return bTime.compareTo(aTime);
      });

    // Group by the other participant
    final Map<String, List<Map<String, dynamic>>> conversationMessages = {};
    final Map<String, Map<String, dynamic>> participantInfo = {};

    for (final msg in messages) {
      final senderId = msg['sender_id'] as String;
      final recipientId = msg['recipient_id'] as String?;

      if (recipientId == null) continue;

      final otherId = senderId == userId ? recipientId : senderId;

      conversationMessages.putIfAbsent(otherId, () => []);
      conversationMessages[otherId]!.add(msg);

      // Store participant info
      if (!participantInfo.containsKey(otherId)) {
        final otherProfile = senderId == userId
            ? msg['recipient'] as Map<String, dynamic>?
            : msg['sender'] as Map<String, dynamic>?;
        if (otherProfile != null) {
          participantInfo[otherId] = otherProfile;
        }
      }
    }

    // Build conversation entities
    final List<ConversationEntity> conversations = [];
    for (final entry in conversationMessages.entries) {
      final otherId = entry.key;
      final msgs = entry.value;
      final profile = participantInfo[otherId];

      // Calculate unread count
      final unreadCount = msgs.where((m) =>
        m['sender_id'] != userId &&
        !(m['is_read'] as bool? ?? false)
      ).length;

      // Get last message
      final lastMsgData = msgs.first;
      final lastMessage = MessageEntity.fromJson(lastMsgData, currentUserId: userId);

      // Build name from profile (with superadmin transformation)
      String name = 'Unknown User';
      String? avatarUrl;
      if (profile != null) {
        final firstName = profile['first_name'] as String?;
        final lastName = profile['last_name'] as String?;
        final role = profile['role'] as String?;
        final transformedName = _transformSuperadminName(firstName, lastName, role);
        if (transformedName.isNotEmpty) {
          name = transformedName;
        }
        avatarUrl = profile['avatar_url'] as String?;
      }

      conversations.add(ConversationEntity(
        id: otherId,
        name: name,
        avatarUrl: avatarUrl,
        isGroup: false,
        lastMessage: lastMessage,
        unreadCount: unreadCount,
        participantIds: [userId, otherId],
      ));
    }

    return conversations;
  }

  /// Gets group conversations for the user.
  Future<List<ConversationEntity>> _getGroupConversations(String userId) async {
    // Get groups the user is a member of
    final memberships = await _supabase
        .from('message_group_members')
        .select('''
          group_id,
          message_groups!inner(
            id,
            name,
            type,
            created_at
          )
        ''')
        .eq('user_id', userId);

    final List<ConversationEntity> conversations = [];

    for (final membership in memberships) {
      final group = membership['message_groups'] as Map<String, dynamic>;
      final groupId = group['id'] as String;

      // Get last message for this group (include role for superadmin name transformation)
      final lastMessages = await _supabase
          .from('messages')
          .select('''
            id,
            sender_id,
            group_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .eq('group_id', groupId)
          .order('created_at', ascending: false)
          .limit(1);

      MessageEntity? lastMessage;
      if (lastMessages.isNotEmpty) {
        lastMessage = MessageEntity.fromJson(lastMessages.first, currentUserId: userId);
      }

      // Fetch unread count for group (messages not sent by current user that aren't read)
      final unreadResponse = await _supabase
          .from('messages')
          .select('id')
          .eq('group_id', group['id'])
          .neq('sender_id', userId)
          .eq('is_read', false);

      int unreadCount = unreadResponse.length;

      // Get member IDs
      final members = await _supabase
          .from('message_group_members')
          .select('user_id')
          .eq('group_id', groupId);
      final participantIds = members.map((m) => m['user_id'] as String).toList();

      conversations.add(ConversationEntity(
        id: groupId,
        name: group['name'] as String,
        avatarUrl: null, // Groups don't have avatars by default
        isGroup: true,
        lastMessage: lastMessage,
        unreadCount: unreadCount,
        participantIds: participantIds,
        groupType: group['type'] as String?,
        createdAt: group['created_at'] != null
            ? DateTime.parse(group['created_at'] as String)
            : null,
      ));
    }

    return conversations;
  }

  @override
  Future<List<MessageEntity>> getDirectMessages(
    String otherUserId, {
    int limit = 50,
    String? beforeId,
  }) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      // FIX: Use separate queries for messages sent and received to ensure proper filtering
      // This fixes the issue where messages weren't loading due to complex OR filter syntax

      String? beforeTime;
      if (beforeId != null) {
        // Get the created_at of the beforeId message for pagination
        final beforeMessage = await _supabase
            .from('messages')
            .select('created_at')
            .eq('id', beforeId)
            .single();
        beforeTime = beforeMessage['created_at'] as String;
      }

      // Get messages sent BY current user TO the other user
      var sentQuery = _supabase
          .from('messages')
          .select('''
            id,
            sender_id,
            recipient_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role),
            recipient:profiles!messages_recipient_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .eq('message_type', 'direct')
          .eq('sender_id', userId)
          .eq('recipient_id', otherUserId);

      if (beforeTime != null) {
        sentQuery = sentQuery.lt('created_at', beforeTime);
      }

      final sentMessages = await sentQuery
          .order('created_at', ascending: false)
          .limit(limit);

      // Get messages received BY current user FROM the other user
      var receivedQuery = _supabase
          .from('messages')
          .select('''
            id,
            sender_id,
            recipient_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role),
            recipient:profiles!messages_recipient_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .eq('message_type', 'direct')
          .eq('sender_id', otherUserId)
          .eq('recipient_id', userId);

      if (beforeTime != null) {
        receivedQuery = receivedQuery.lt('created_at', beforeTime);
      }

      final receivedMessages = await receivedQuery
          .order('created_at', ascending: false)
          .limit(limit);

      // Combine and deduplicate messages
      final Map<String, Map<String, dynamic>> messageMap = {};
      for (final msg in sentMessages) {
        messageMap[msg['id'] as String] = msg;
      }
      for (final msg in receivedMessages) {
        messageMap[msg['id'] as String] = msg;
      }

      // Sort by created_at descending and limit
      final allMessages = messageMap.values.toList()
        ..sort((a, b) {
          final aTime = DateTime.parse(a['created_at'] as String);
          final bTime = DateTime.parse(b['created_at'] as String);
          return bTime.compareTo(aTime);
        });

      // Take only the requested limit
      final limitedMessages = allMessages.take(limit).toList();

      return limitedMessages
          .map((data) => MessageEntity.fromJson(data, currentUserId: userId))
          .toList();
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch messages: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch messages: $e');
    }
  }

  @override
  Future<MessageEntity> sendDirectMessage(String recipientId, String content) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'sender_id': userId,
            'recipient_id': recipientId,
            'content': content,
            'message_type': 'direct',
            'is_read': false,
          })
          .select('''
            id,
            sender_id,
            recipient_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role),
            recipient:profiles!messages_recipient_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .single();

      return MessageEntity.fromJson(response, currentUserId: userId);
    } on PostgrestException catch (e) {
      throw ChatException('Failed to send message: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to send message: $e');
    }
  }

  @override
  Future<void> markDirectMessagesAsRead(String otherUserId) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', otherUserId)
          .eq('recipient_id', userId)
          .eq('is_read', false);

      // Notify listeners that conversations and unread count may have changed
      _notifyConversationsChanged();
      _notifyUnreadCountChanged();
    } on PostgrestException catch (e) {
      throw ChatException('Failed to mark messages as read: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to mark messages as read: $e');
    }
  }

  @override
  Future<List<MessageEntity>> getGroupMessages(
    String groupId, {
    int limit = 50,
    String? beforeId,
  }) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      // SECURITY: Verify user is a member of this group before fetching messages
      final membership = await _supabase
          .from('message_group_members')
          .select('user_id')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .maybeSingle();

      if (membership == null) {
        throw const ChatException('You are not a member of this group');
      }

      // Build the base query with filters (include role for superadmin name transformation)
      var filterBuilder = _supabase
          .from('messages')
          .select('''
            id,
            sender_id,
            group_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .eq('group_id', groupId);

      // Add pagination if beforeId is provided
      if (beforeId != null) {
        final beforeMessage = await _supabase
            .from('messages')
            .select('created_at')
            .eq('id', beforeId)
            .single();
        final beforeTime = beforeMessage['created_at'] as String;
        filterBuilder = filterBuilder.lt('created_at', beforeTime);
      }

      final response = await filterBuilder
          .order('created_at', ascending: false)
          .limit(limit);

      return response
          .map((data) => MessageEntity.fromJson(data, currentUserId: userId))
          .toList();
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch group messages: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch group messages: $e');
    }
  }

  @override
  Future<MessageEntity> sendGroupMessage(String groupId, String content) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'sender_id': userId,
            'group_id': groupId,
            'content': content,
            'message_type': 'group',
            'is_read': false,
          })
          .select('''
            id,
            sender_id,
            group_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .single();

      return MessageEntity.fromJson(response, currentUserId: userId);
    } on PostgrestException catch (e) {
      throw ChatException('Failed to send group message: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to send group message: $e');
    }
  }

  @override
  Future<void> markGroupMessagesAsRead(String groupId) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      // For group messages, we mark all messages not sent by current user as read
      // Note: In a production app, you might want a separate table for per-user read status
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('group_id', groupId)
          .neq('sender_id', userId)
          .eq('is_read', false);

      // Notify listeners that conversations and unread count may have changed
      _notifyConversationsChanged();
      _notifyUnreadCountChanged();
    } catch (e) {
      debugPrint('Failed to mark group messages as read: $e');
      // Don't throw - this is a non-critical operation
    }
  }

  @override
  Future<MessageGroupEntity> createGroup(
    String name,
    List<String> memberIds, {
    String type = 'custom',
  }) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      // Get user's profile including role and school_id
      final userProfile = await _supabase
          .from('profiles')
          .select('school_id, role')
          .eq('id', userId)
          .single();
      final userSchoolId = userProfile['school_id'] as String?;
      final userRole = userProfile['role'] as String?;
      final isSuperadmin = userRole == 'superadmin';

      String? schoolId = userSchoolId;

      // Handle superadmin case: they might not have a school_id
      if (schoolId == null) {
        if (isSuperadmin) {
          // For superadmin, try to get school_id from the first non-superadmin member
          if (memberIds.isNotEmpty) {
            final memberProfiles = await _supabase
                .from('profiles')
                .select('school_id, role')
                .inFilter('id', memberIds)
                .neq('role', 'superadmin')
                .limit(1);

            if (memberProfiles.isNotEmpty) {
              schoolId = memberProfiles.first['school_id'] as String?;
            }
          }
          // If still null, allow creating cross-school group (schoolId stays null)
        } else {
          // Non-superadmin users must have a school_id
          throw const ChatException('User has no associated school');
        }
      }

      // Create the group (school_id can be null for superadmin cross-school groups)
      final groupResponse = await _supabase
          .from('message_groups')
          .insert({
            'school_id': schoolId,
            'name': name,
            'type': type,
            'created_by': userId,
          })
          .select()
          .single();

      final groupId = groupResponse['id'] as String;

      // Add creator as member
      await _supabase.from('message_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });

      // Add other members
      for (final memberId in memberIds) {
        if (memberId != userId) {
          await _supabase.from('message_group_members').insert({
            'group_id': groupId,
            'user_id': memberId,
          });
        }
      }

      // Fetch the complete group with members
      return await getGroup(groupId) ?? MessageGroupEntity.fromJson(groupResponse);
    } on PostgrestException catch (e) {
      throw ChatException('Failed to create group: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to create group: $e');
    }
  }

  @override
  Future<void> addGroupMember(String groupId, String userId) async {
    _requireAuth();

    try {
      await _supabase.from('message_group_members').insert({
        'group_id': groupId,
        'user_id': userId,
      });
    } on PostgrestException catch (e) {
      throw ChatException('Failed to add group member: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to add group member: $e');
    }
  }

  @override
  Future<void> removeGroupMember(String groupId, String userId) async {
    _requireAuth();

    try {
      await _supabase
          .from('message_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ChatException('Failed to remove group member: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to remove group member: $e');
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    _requireAuth();
    final userId = _currentUserId!;

    await removeGroupMember(groupId, userId);
  }

  @override
  Future<MessageGroupEntity?> getGroup(String groupId) async {
    _requireAuth();

    try {
      final response = await _supabase
          .from('message_groups')
          .select('''
            id,
            school_id,
            name,
            type,
            created_by,
            created_at
          ''')
          .eq('id', groupId)
          .maybeSingle();

      if (response == null) return null;

      // Get members
      final membersResponse = await _supabase
          .from('message_group_members')
          .select('''
            group_id,
            user_id,
            user:profiles!message_group_members_user_id_fkey(id, first_name, last_name, role, avatar_url)
          ''')
          .eq('group_id', groupId);

      final members = membersResponse
          .map((m) => GroupMemberEntity.fromJson(m))
          .toList();

      return MessageGroupEntity(
        id: response['id'] as String,
        schoolId: response['school_id'] as String?, // Can be null for superadmin cross-school groups
        name: response['name'] as String,
        type: response['type'] as String? ?? 'custom',
        createdBy: response['created_by'] as String,
        createdAt: DateTime.parse(response['created_at'] as String),
        members: members,
      );
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch group: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch group: $e');
    }
  }

  @override
  Future<List<AppUser>> getAvailableRecipients() async {
    _requireAuth();

    try {
      // Use the RPC function which bypasses RLS and handles all role-based logic
      // This is the most reliable way to get messageable users
      final response = await _supabase.rpc('get_messageable_users');

      if (response == null) {
        return [];
      }

      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((r) => AppUser.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      // If the RPC function doesn't exist yet (migration not applied),
      // fall back to the original implementation
      if (e.code == '42883' || e.message.contains('does not exist')) {
        return _getAvailableRecipientsFallback();
      }
      throw ChatException('Failed to fetch recipients: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch recipients: $e');
    }
  }

  /// Fallback implementation for getAvailableRecipients when RPC function
  /// is not available (migration not yet applied).
  Future<List<AppUser>> _getAvailableRecipientsFallback() async {
    final userId = _currentUserId!;

    try {
      // Get current user's profile to determine role and school
      final currentUserProfile = await _supabase
          .from('profiles')
          .select('id, email, role, school_id, first_name, last_name, avatar_url')
          .eq('id', userId)
          .single();

      final role = currentUserProfile['role'] as String?;
      final schoolId = currentUserProfile['school_id'] as String?;

      List<Map<String, dynamic>> recipients = [];

      switch (role) {
        case 'superadmin':
          // Can message all BigAdmins
          recipients = await _supabase
              .from('profiles')
              .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
              .eq('role', UserRole.bigadmin.name)
              .neq('id', userId);
          break;

        case 'bigadmin':
          // Can message everyone in their school
          if (schoolId != null) {
            recipients = await _supabase
                .from('profiles')
                .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                .eq('school_id', schoolId)
                .neq('id', userId);
          }
          break;

        case 'admin':
          // Can message all staff and parents in school
          if (schoolId != null) {
            recipients = await _supabase
                .from('profiles')
                .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                .eq('school_id', schoolId)
                .neq('id', userId)
                .inFilter('role', [UserRole.bigadmin.name, UserRole.admin.name, UserRole.teacher.name, UserRole.parent.name]);
          }
          break;

        case 'teacher':
          // Can message: other teachers, admins, parents of their students
          if (schoolId != null) {
            // Get staff (teachers, admins)
            final staff = await _supabase
                .from('profiles')
                .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                .eq('school_id', schoolId)
                .neq('id', userId)
                .inFilter('role', [UserRole.bigadmin.name, UserRole.admin.name, UserRole.teacher.name]);

            // Get parents of students in teacher's classes
            final teacherSubjects = await _supabase
                .from('subjects')
                .select('class_id')
                .eq('teacher_id', userId);

            final classIds = teacherSubjects.map((s) => s['class_id'] as String).toSet().toList();

            if (classIds.isNotEmpty) {
              final studentIds = await _supabase
                  .from('class_students')
                  .select('student_id')
                  .inFilter('class_id', classIds);

              final studentIdList = studentIds.map((s) => s['student_id'] as String).toSet().toList();

              if (studentIdList.isNotEmpty) {
                final parentIds = await _supabase
                    .from('parent_student')
                    .select('parent_id')
                    .inFilter('student_id', studentIdList);

                final parentIdList = parentIds.map((p) => p['parent_id'] as String).toSet().toList();

                if (parentIdList.isNotEmpty) {
                  final parents = await _supabase
                      .from('profiles')
                      .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                      .inFilter('id', parentIdList);

                  recipients = [...staff, ...parents];
                } else {
                  recipients = staff;
                }
              } else {
                recipients = staff;
              }
            } else {
              recipients = staff;
            }
          }
          break;

        case 'parent':
          // Can message: children's teachers, principal
          if (schoolId != null) {
            // Get principal/admins
            final admins = await _supabase
                .from('profiles')
                .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                .eq('school_id', schoolId)
                .inFilter('role', [UserRole.bigadmin.name, UserRole.admin.name]);

            // Get children's teachers
            final children = await _supabase
                .from('parent_student')
                .select('student_id')
                .eq('parent_id', userId);

            final childIds = children.map((c) => c['student_id'] as String).toList();

            if (childIds.isNotEmpty) {
              final classEnrollments = await _supabase
                  .from('class_students')
                  .select('class_id')
                  .inFilter('student_id', childIds);

              final classIds = classEnrollments.map((e) => e['class_id'] as String).toSet().toList();

              if (classIds.isNotEmpty) {
                final subjects = await _supabase
                    .from('subjects')
                    .select('teacher_id')
                    .inFilter('class_id', classIds);

                final teacherIds = subjects
                    .map((s) => s['teacher_id'] as String?)
                    .where((id) => id != null)
                    .cast<String>()
                    .toSet()
                    .toList();

                if (teacherIds.isNotEmpty) {
                  final teachers = await _supabase
                      .from('profiles')
                      .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                      .inFilter('id', teacherIds);

                  recipients = [...admins, ...teachers];
                } else {
                  recipients = admins;
                }
              } else {
                recipients = admins;
              }
            } else {
              recipients = admins;
            }
          }
          break;

        case 'student':
          // Can message: their teachers
          final enrollments = await _supabase
              .from('class_students')
              .select('class_id')
              .eq('student_id', userId);

          final classIds = enrollments.map((e) => e['class_id'] as String).toList();

          if (classIds.isNotEmpty) {
            final subjects = await _supabase
                .from('subjects')
                .select('teacher_id')
                .inFilter('class_id', classIds);

            final teacherIds = subjects
                .map((s) => s['teacher_id'] as String?)
                .where((id) => id != null)
                .cast<String>()
                .toSet()
                .toList();

            if (teacherIds.isNotEmpty) {
              recipients = await _supabase
                  .from('profiles')
                  .select('id, email, role, school_id, first_name, last_name, avatar_url, created_at')
                  .inFilter('id', teacherIds);
            }
          }
          break;

        default:
          recipients = [];
      }

      // Remove duplicates and convert to AppUser
      final uniqueRecipients = <String, Map<String, dynamic>>{};
      for (final r in recipients) {
        uniqueRecipients[r['id'] as String] = r;
      }

      return uniqueRecipients.values
          .map((r) => AppUser.fromJson(r))
          .toList();
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch recipients: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch recipients: $e');
    }
  }

  @override
  Future<MessageEntity> sendAnnouncement(
    String content, {
    List<String>? targetGroupIds,
  }) async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      final response = await _supabase
          .from('messages')
          .insert({
            'sender_id': userId,
            'content': content,
            'message_type': 'announcement',
            'is_read': false,
          })
          .select('''
            id,
            sender_id,
            content,
            message_type,
            is_read,
            created_at,
            sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role)
          ''')
          .single();

      return MessageEntity.fromJson(response, currentUserId: userId);
    } on PostgrestException catch (e) {
      throw ChatException('Failed to send announcement: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to send announcement: $e');
    }
  }

  @override
  Stream<MessageEntity> subscribeToMessages() {
    _requireAuth();
    final userId = _currentUserId!;

    _messageStreamController?.close();
    _messageStreamController = StreamController<MessageEntity>.broadcast();

    // Set up realtime subscription
    _messageChannel?.unsubscribe();
    _messageChannel = _supabase
        .channel('messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // Listen to INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'messages',
          callback: (payload) async {
            final newRecord = payload.newRecord;
            // Check if message is relevant to this user
            final senderId = newRecord['sender_id'] as String?;
            final recipientId = newRecord['recipient_id'] as String?;
            final groupId = newRecord['group_id'] as String?;

            bool isRelevant = false;

            if (recipientId == userId) {
              // Direct message to this user
              isRelevant = true;
            } else if (groupId != null) {
              // Check if user is member of group
              final membership = await _supabase
                  .from('message_group_members')
                  .select('user_id')
                  .eq('group_id', groupId)
                  .eq('user_id', userId)
                  .maybeSingle();
              isRelevant = membership != null;
            } else if (senderId == userId) {
              // Message sent by this user
              isRelevant = true;
            }

            if (isRelevant && !_messageStreamController!.isClosed) {
              // Fetch full message with joined data (include role for superadmin name transformation)
              try {
                final fullMessage = await _supabase
                    .from('messages')
                    .select('''
                      id,
                      sender_id,
                      recipient_id,
                      group_id,
                      content,
                      message_type,
                      is_read,
                      created_at,
                      sender:profiles!messages_sender_id_fkey(id, first_name, last_name, avatar_url, role),
                      recipient:profiles!messages_recipient_id_fkey(id, first_name, last_name, avatar_url, role)
                    ''')
                    .eq('id', newRecord['id'] as String)
                    .single();

                final message = MessageEntity.fromJson(fullMessage, currentUserId: userId);
                _messageStreamController!.add(message);
              } catch (e, stackTrace) {
                debugPrint('Error fetching message for stream: $e');
                debugPrint('Stack trace: $stackTrace');
                // Continue silently for backwards compatibility
              }
            }
          },
        )
        .subscribe();

    return _messageStreamController!.stream;
  }

  @override
  Stream<List<ConversationEntity>> subscribeToConversations() {
    _conversationStreamController?.close();
    _conversationStreamController = StreamController<List<ConversationEntity>>.broadcast();

    // Initial fetch
    getConversations().then((conversations) {
      if (!_conversationStreamController!.isClosed) {
        _conversationStreamController!.add(conversations);
      }
    });

    // Subscribe to message changes to update conversations
    subscribeToMessages().listen((_) async {
      // Refresh conversations when new message arrives
      try {
        final conversations = await getConversations();
        if (!_conversationStreamController!.isClosed) {
          _conversationStreamController!.add(conversations);
        }
      } catch (e, stackTrace) {
        debugPrint('Error refreshing conversations stream: $e');
        debugPrint('Stack trace: $stackTrace');
        // Continue silently for backwards compatibility
      }
    });

    return _conversationStreamController!.stream;
  }

  @override
  Future<int> getTotalUnreadCount() async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      // Count unread direct messages (where user is recipient)
      final directResponse = await _supabase
          .from('messages')
          .select('id')
          .eq('recipient_id', userId)
          .eq('is_read', false);

      final directCount = directResponse.length;

      // Count unread group messages (where user is member and not sender)
      // First get all groups user is a member of
      final memberships = await _supabase
          .from('message_group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = memberships.map((m) => m['group_id'] as String).toList();

      int groupCount = 0;
      if (groupIds.isNotEmpty) {
        final groupResponse = await _supabase
            .from('messages')
            .select('id')
            .inFilter('group_id', groupIds)
            .neq('sender_id', userId)
            .eq('is_read', false);

        groupCount = groupResponse.length;
      }

      return directCount + groupCount;
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch unread count: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch unread count: $e');
    }
  }

  @override
  Stream<int> subscribeToUnreadCount() {
    _unreadCountStreamController?.close();
    _unreadCountStreamController = StreamController<int>.broadcast();

    // Initial fetch
    getTotalUnreadCount().then((count) {
      if (!_unreadCountStreamController!.isClosed) {
        _unreadCountStreamController!.add(count);
      }
    });

    // Update on message changes
    subscribeToMessages().listen((_) async {
      try {
        final count = await getTotalUnreadCount();
        if (!_unreadCountStreamController!.isClosed) {
          _unreadCountStreamController!.add(count);
        }
      } catch (e, stackTrace) {
        debugPrint('Error updating unread count stream: $e');
        debugPrint('Stack trace: $stackTrace');
        // Continue silently for backwards compatibility
      }
    });

    return _unreadCountStreamController!.stream;
  }

  @override
  Future<List<AppUser>> searchUsers(String query) async {
    _requireAuth();

    try {
      // Use getAvailableRecipients as the base, then filter by query
      // This ensures we only search within users the current user can message
      // and works even if direct profile queries are blocked by RLS
      final availableRecipients = await getAvailableRecipients();

      if (query.isEmpty) {
        return availableRecipients;
      }

      final lowerQuery = query.toLowerCase();
      return availableRecipients.where((user) {
        return user.fullName.toLowerCase().contains(lowerQuery) ||
            (user.email?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } on PostgrestException catch (e) {
      throw ChatException('Failed to search users: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to search users: $e');
    }
  }

  @override
  Future<List<MessageGroupEntity>> getUserGroups() async {
    _requireAuth();
    final userId = _currentUserId!;

    try {
      final memberships = await _supabase
          .from('message_group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = memberships.map((m) => m['group_id'] as String).toList();

      if (groupIds.isEmpty) return [];

      // Batch fetch all groups in ONE query using inFilter (fixes N+1 problem)
      final groupsResponse = await _supabase
          .from('message_groups')
          .select('''
            id,
            school_id,
            name,
            type,
            created_by,
            created_at
          ''')
          .inFilter('id', groupIds);

      if (groupsResponse.isEmpty) return [];

      // Batch fetch all members for all groups in ONE query
      final membersResponse = await _supabase
          .from('message_group_members')
          .select('''
            group_id,
            user_id,
            user:profiles!message_group_members_user_id_fkey(id, first_name, last_name, role, avatar_url)
          ''')
          .inFilter('group_id', groupIds);

      // Group members by group_id for efficient lookup
      final Map<String, List<GroupMemberEntity>> membersByGroupId = {};
      for (final m in membersResponse) {
        final groupId = m['group_id'] as String;
        membersByGroupId.putIfAbsent(groupId, () => []);
        membersByGroupId[groupId]!.add(GroupMemberEntity.fromJson(m));
      }

      // Build MessageGroupEntity list with members
      final List<MessageGroupEntity> groups = [];
      for (final g in groupsResponse) {
        final groupId = g['id'] as String;
        groups.add(MessageGroupEntity(
          id: groupId,
          schoolId: g['school_id'] as String?, // Can be null for superadmin cross-school groups
          name: g['name'] as String,
          type: g['type'] as String? ?? 'custom',
          createdBy: g['created_by'] as String,
          createdAt: DateTime.parse(g['created_at'] as String),
          members: membersByGroupId[groupId] ?? [],
        ));
      }

      return groups;
    } on PostgrestException catch (e) {
      throw ChatException('Failed to fetch user groups: ${e.message}');
    } catch (e) {
      if (e is ChatException) rethrow;
      throw ChatException('Failed to fetch user groups: $e');
    }
  }

  /// Notifies listeners that conversations may have changed.
  void _notifyConversationsChanged() {
    if (_conversationStreamController != null &&
        !_conversationStreamController!.isClosed) {
      getConversations().then((conversations) {
        if (!_conversationStreamController!.isClosed) {
          _conversationStreamController!.add(conversations);
        }
      });
    }
  }

  /// Notifies listeners that unread count may have changed.
  void _notifyUnreadCountChanged() {
    if (_unreadCountStreamController != null &&
        !_unreadCountStreamController!.isClosed) {
      getTotalUnreadCount().then((count) {
        if (!_unreadCountStreamController!.isClosed) {
          _unreadCountStreamController!.add(count);
        }
      });
    }
  }

  /// Disposes of resources.
  void dispose() {
    _messageStreamController?.close();
    _conversationStreamController?.close();
    _unreadCountStreamController?.close();
    _messageChannel?.unsubscribe();
  }
}
