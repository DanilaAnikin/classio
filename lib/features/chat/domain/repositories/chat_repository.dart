import '../../../auth/domain/entities/app_user.dart';
import '../entities/entities.dart';

/// Repository interface for chat operations.
///
/// Defines the contract for all chat-related data operations including
/// messages, conversations, and groups. Implementations should handle
/// the actual data fetching, whether from Supabase, mock data, or other sources.
abstract class ChatRepository {
  /// Gets all conversations for the current user.
  ///
  /// Returns both direct conversations and group conversations,
  /// sorted by last message time (most recent first).
  Future<List<ConversationEntity>> getConversations();

  /// Gets direct messages between the current user and another user.
  ///
  /// [otherUserId] - The ID of the other user in the conversation.
  /// [limit] - Maximum number of messages to return (default: 50).
  /// [beforeId] - Load messages before this message ID (for pagination).
  Future<List<MessageEntity>> getDirectMessages(
    String otherUserId, {
    int limit = 50,
    String? beforeId,
  });

  /// Sends a direct message to another user.
  ///
  /// [recipientId] - The ID of the message recipient.
  /// [content] - The message content/text.
  /// Returns the created message.
  Future<MessageEntity> sendDirectMessage(String recipientId, String content);

  /// Marks all direct messages from a user as read.
  ///
  /// [otherUserId] - The ID of the user whose messages to mark as read.
  Future<void> markDirectMessagesAsRead(String otherUserId);

  /// Gets messages from a message group.
  ///
  /// [groupId] - The ID of the message group.
  /// [limit] - Maximum number of messages to return (default: 50).
  /// [beforeId] - Load messages before this message ID (for pagination).
  Future<List<MessageEntity>> getGroupMessages(
    String groupId, {
    int limit = 50,
    String? beforeId,
  });

  /// Sends a message to a message group.
  ///
  /// [groupId] - The ID of the message group.
  /// [content] - The message content/text.
  /// Returns the created message.
  Future<MessageEntity> sendGroupMessage(String groupId, String content);

  /// Marks all messages in a group as read for the current user.
  ///
  /// [groupId] - The ID of the message group.
  Future<void> markGroupMessagesAsRead(String groupId);

  /// Creates a new message group.
  ///
  /// [name] - The name of the group.
  /// [memberIds] - List of user IDs to add as members.
  /// [type] - Type of group (default: 'custom').
  /// Returns the created group.
  Future<MessageGroupEntity> createGroup(
    String name,
    List<String> memberIds, {
    String type = 'custom',
  });

  /// Adds a user to a message group.
  ///
  /// [groupId] - The ID of the message group.
  /// [userId] - The ID of the user to add.
  Future<void> addGroupMember(String groupId, String userId);

  /// Removes a user from a message group.
  ///
  /// [groupId] - The ID of the message group.
  /// [userId] - The ID of the user to remove.
  Future<void> removeGroupMember(String groupId, String userId);

  /// Leaves a message group (removes current user).
  ///
  /// [groupId] - The ID of the message group to leave.
  Future<void> leaveGroup(String groupId);

  /// Gets the details of a message group.
  ///
  /// [groupId] - The ID of the message group.
  Future<MessageGroupEntity?> getGroup(String groupId);

  /// Gets available recipients based on the current user's role.
  ///
  /// Role-based filtering:
  /// - SuperAdmin: All BigAdmins
  /// - BigAdmin: Everyone in their school
  /// - Admin: All staff and parents in school
  /// - Teacher: Other teachers, admins, parents of their students
  /// - Parent: Teachers of their children, Principal
  /// - Student: Their teachers
  Future<List<AppUser>> getAvailableRecipients();

  /// Sends a school-wide announcement (Principal/Admin only).
  ///
  /// [content] - The announcement content.
  /// [targetGroupIds] - Optional list of group IDs to target. If null, sends to all.
  /// Returns the created announcement message.
  Future<MessageEntity> sendAnnouncement(
    String content, {
    List<String>? targetGroupIds,
  });

  /// Subscribes to new messages for the current user.
  ///
  /// Returns a stream that emits new messages as they arrive.
  Stream<MessageEntity> subscribeToMessages();

  /// Subscribes to conversation updates.
  ///
  /// Returns a stream that emits the updated conversation list
  /// when changes occur (new messages, read status changes, etc.).
  Stream<List<ConversationEntity>> subscribeToConversations();

  /// Gets the total unread message count for the current user.
  Future<int> getTotalUnreadCount();

  /// Subscribes to unread count changes.
  ///
  /// Returns a stream that emits the new unread count when it changes.
  Stream<int> subscribeToUnreadCount();

  /// Searches for users by name or email.
  ///
  /// [query] - The search query string.
  /// Returns a list of users matching the query.
  Future<List<AppUser>> searchUsers(String query);

  /// Gets user groups (message groups the user is a member of).
  Future<List<MessageGroupEntity>> getUserGroups();
}
