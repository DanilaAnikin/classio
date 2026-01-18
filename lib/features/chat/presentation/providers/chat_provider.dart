import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/supabase_chat_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_provider.g.dart';

// ============================================================================
// Role Hierarchy Utilities
// ============================================================================

/// Role hierarchy for determining communication permissions.
/// Lower numbers indicate higher authority in the hierarchy.
const chatRoleHierarchy = {
  'superadmin': 0,
  'bigadmin': 1,
  'admin': 2,
  'teacher': 3,
  'parent': 4,
  'student': 5,
};

/// Returns the hierarchy level for a UserRole.
/// Returns a high number (999) for unknown roles.
int getUserRoleHierarchyLevel(UserRole? role) {
  if (role == null) return 999;
  return chatRoleHierarchy[role.name.toLowerCase()] ?? 999;
}

/// Checks if a user with [initiatorRole] can initiate a conversation with [targetRole].
/// Higher hierarchy (lower number) can always message lower hierarchy.
/// Same level can message each other.
/// Lower hierarchy cannot initiate with higher hierarchy.
bool canUserRoleInitiateConversation(UserRole? initiatorRole, UserRole? targetRole) {
  final initiatorLevel = getUserRoleHierarchyLevel(initiatorRole);
  final targetLevel = getUserRoleHierarchyLevel(targetRole);
  return initiatorLevel <= targetLevel;
}

// ============================================================================
// Repository Provider
// ============================================================================

/// Provider for the ChatRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
ChatRepository chatRepository(Ref ref) {
  return SupabaseChatRepository();
}

// ============================================================================
// Conversations Providers
// ============================================================================

/// Notifier for managing conversations state.
///
/// Handles loading, refreshing, and real-time updates of conversations.
@Riverpod(keepAlive: true)
class ConversationsNotifier extends _$ConversationsNotifier {
  late final ChatRepository _repository;
  StreamSubscription<List<ConversationEntity>>? _subscription;
  bool _mounted = true;

  @override
  Future<List<ConversationEntity>> build() async {
    _repository = ref.watch(chatRepositoryProvider);
    _mounted = true;

    // Set up real-time subscription
    _setupSubscription();

    // Clean up on dispose
    ref.onDispose(() {
      _mounted = false;
      _subscription?.cancel();
    });

    return await _repository.getConversations();
  }

  void _setupSubscription() {
    _subscription?.cancel();
    _subscription = _repository.subscribeToConversations().listen(
      (conversations) {
        if (_mounted) {
          state = AsyncValue.data(conversations);
        }
      },
      onError: (error) {
        // Keep current data on error, don't replace with error state
      },
    );
  }

  /// Refreshes the conversations list.
  Future<void> refresh() async {
    if (!_mounted) return;

    state = const AsyncValue.loading();
    try {
      final conversations = await _repository.getConversations();
      if (_mounted) {
        state = AsyncValue.data(conversations);
      }
    } catch (e, stack) {
      if (_mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}

/// Provider that returns the conversations list or empty list.
@riverpod
List<ConversationEntity> conversationsList(Ref ref) {
  final conversationsAsync = ref.watch(conversationsNotifierProvider);
  return conversationsAsync.when(
    data: (conversations) => conversations,
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider for filtered conversations by type (all, direct, groups).
@riverpod
List<ConversationEntity> filteredConversations(
  Ref ref,
  ConversationFilter filter,
) {
  final conversations = ref.watch(conversationsListProvider);

  switch (filter) {
    case ConversationFilter.all:
      return conversations;
    case ConversationFilter.direct:
      return conversations.where((c) => !c.isGroup).toList();
    case ConversationFilter.groups:
      return conversations.where((c) => c.isGroup).toList();
  }
}

/// Filter options for conversations.
enum ConversationFilter { all, direct, groups }

/// Provider for the currently selected conversation filter.
@riverpod
class ConversationFilterNotifier extends _$ConversationFilterNotifier {
  @override
  ConversationFilter build() => ConversationFilter.all;

  void setFilter(ConversationFilter filter) {
    state = filter;
  }
}

// ============================================================================
// Messages Providers
// ============================================================================

/// State class for chat messages.
class ChatMessagesState {
  final List<MessageEntity> messages;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const ChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  ChatMessagesState copyWith({
    List<MessageEntity>? messages,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Notifier for managing messages in a conversation.
@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  late final ChatRepository _repository;
  late final String _conversationId;
  late final bool _isGroup;
  StreamSubscription<MessageEntity>? _subscription;
  bool _mounted = true;

  @override
  ChatMessagesState build(String conversationId, bool isGroup) {
    _repository = ref.watch(chatRepositoryProvider);
    _conversationId = conversationId;
    _isGroup = isGroup;
    _mounted = true;

    // Load initial messages
    _loadMessages();

    // Set up real-time subscription
    _setupSubscription();

    // Mark as read
    _markAsRead();

    // Clean up on dispose
    ref.onDispose(() {
      _mounted = false;
      _subscription?.cancel();
    });

    return const ChatMessagesState(isLoading: true);
  }

  void _safeSetState(ChatMessagesState newState) {
    if (_mounted) {
      state = newState;
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messages = _isGroup
          ? await _repository.getGroupMessages(_conversationId)
          : await _repository.getDirectMessages(_conversationId);

      _safeSetState(state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: messages.length >= 50,
      ));
    } catch (e) {
      _safeSetState(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _setupSubscription() {
    _subscription?.cancel();
    _subscription = _repository.subscribeToMessages().listen(
      (message) {
        if (!_mounted) return;

        // Check if message belongs to this conversation
        final belongsHere = _isGroup
            ? message.groupId == _conversationId
            : (message.senderId == _conversationId ||
                message.recipientId == _conversationId);

        if (belongsHere) {
          // Add new message to the beginning (messages are sorted newest first)
          final updatedMessages = [message, ...state.messages];
          _safeSetState(state.copyWith(messages: updatedMessages));
          _markAsRead();
        }
      },
    );
  }

  Future<void> _markAsRead() async {
    if (!_mounted) return;

    try {
      if (_isGroup) {
        await _repository.markGroupMessagesAsRead(_conversationId);
      } else {
        await _repository.markDirectMessagesAsRead(_conversationId);
      }

      // Refresh conversations and unread count to update the UI
      // This is necessary because the repository's stream controllers are not shared
      // between different provider instances
      // Use Future.wait to refresh both in parallel and await completion
      await Future.wait([
        ref.read(conversationsNotifierProvider.notifier).refresh(),
        ref.read(unreadCountNotifierProvider.notifier).refresh(),
      ]);
    } catch (_) {
      // Ignore mark as read errors - this is a non-critical operation
      // The badge will update on the next refresh cycle
    }
  }

  /// Loads more (older) messages for pagination.
  Future<void> loadMore() async {
    if (!_mounted || state.isLoading || !state.hasMore || state.messages.isEmpty) return;

    _safeSetState(state.copyWith(isLoading: true));

    try {
      final lastMessageId = state.messages.last.id;
      final olderMessages = _isGroup
          ? await _repository.getGroupMessages(
              _conversationId,
              beforeId: lastMessageId,
            )
          : await _repository.getDirectMessages(
              _conversationId,
              beforeId: lastMessageId,
            );

      _safeSetState(state.copyWith(
        messages: [...state.messages, ...olderMessages],
        isLoading: false,
        hasMore: olderMessages.length >= 50,
      ));
    } catch (e) {
      _safeSetState(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Refreshes the messages list.
  Future<void> refresh() async {
    if (!_mounted) return;

    _safeSetState(state.copyWith(isLoading: true, messages: []));
    await _loadMessages();
  }
}

// ============================================================================
// Send Message Provider
// ============================================================================

/// State for send message operation.
class SendMessageState {
  final bool isSending;
  final String? error;

  const SendMessageState({
    this.isSending = false,
    this.error,
  });
}

/// Notifier for sending messages.
@riverpod
class SendMessageNotifier extends _$SendMessageNotifier {
  late final ChatRepository _repository;

  @override
  SendMessageState build() {
    _repository = ref.watch(chatRepositoryProvider);
    return const SendMessageState();
  }

  /// Sends a message to a conversation.
  Future<bool> sendMessage(
    String conversationId,
    String content,
    bool isGroup,
  ) async {
    state = const SendMessageState(isSending: true);

    try {
      if (isGroup) {
        await _repository.sendGroupMessage(conversationId, content);
      } else {
        await _repository.sendDirectMessage(conversationId, content);
      }

      state = const SendMessageState();
      return true;
    } catch (e) {
      state = SendMessageState(error: e.toString());
      return false;
    }
  }

  /// Clears any error state.
  void clearError() {
    state = const SendMessageState();
  }
}

// ============================================================================
// Available Recipients Provider
// ============================================================================

/// Notifier for available recipients.
@riverpod
class AvailableRecipientsNotifier extends _$AvailableRecipientsNotifier {
  late final ChatRepository _repository;

  @override
  Future<List<AppUser>> build() async {
    _repository = ref.watch(chatRepositoryProvider);
    return await _repository.getAvailableRecipients();
  }

  /// Refreshes the recipients list.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final recipients = await _repository.getAvailableRecipients();
      state = AsyncValue.data(recipients);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Searches for users by query.
  Future<List<AppUser>> search(String query) async {
    if (query.isEmpty) {
      return state.value ?? [];
    }

    try {
      return await _repository.searchUsers(query);
    } catch (_) {
      return [];
    }
  }
}

/// Provider that filters available recipients based on role hierarchy.
/// Only returns recipients that the current user can initiate conversations with.
@riverpod
List<AppUser> filteredRecipientsByRoleHierarchy(Ref ref) {
  final recipientsAsync = ref.watch(availableRecipientsNotifierProvider);
  final currentUser = ref.watch(currentUserProvider);

  return recipientsAsync.when(
    data: (recipients) {
      if (currentUser == null) return recipients;

      // Filter recipients based on role hierarchy
      return recipients.where((recipient) {
        return canUserRoleInitiateConversation(currentUser.role, recipient.role);
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider for the current user's role string.
@riverpod
String? currentUserRoleString(Ref ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser?.role.name;
}

// ============================================================================
// Unread Count Provider
// ============================================================================

/// Notifier for unread message count.
@Riverpod(keepAlive: true)
class UnreadCountNotifier extends _$UnreadCountNotifier {
  late final ChatRepository _repository;
  StreamSubscription<int>? _subscription;
  bool _mounted = true;

  @override
  int build() {
    _repository = ref.watch(chatRepositoryProvider);
    _mounted = true;

    // Load initial count
    _loadCount();

    // Set up subscription
    _setupSubscription();

    // Clean up
    ref.onDispose(() {
      _mounted = false;
      _subscription?.cancel();
    });

    return 0;
  }

  Future<void> _loadCount() async {
    try {
      final count = await _repository.getTotalUnreadCount();
      if (_mounted) {
        state = count;
      }
    } catch (_) {
      // Ignore errors
    }
  }

  void _setupSubscription() {
    _subscription?.cancel();
    _subscription = _repository.subscribeToUnreadCount().listen(
      (count) {
        if (_mounted) {
          state = count;
        }
      },
    );
  }

  /// Refreshes the unread count.
  Future<void> refresh() async {
    if (!_mounted) return;
    await _loadCount();
  }
}

// ============================================================================
// Create Group Provider
// ============================================================================

/// State for group creation.
class CreateGroupState {
  final bool isCreating;
  final MessageGroupEntity? createdGroup;
  final String? error;

  const CreateGroupState({
    this.isCreating = false,
    this.createdGroup,
    this.error,
  });
}

/// Notifier for creating groups.
@riverpod
class CreateGroupNotifier extends _$CreateGroupNotifier {
  late final ChatRepository _repository;

  @override
  CreateGroupState build() {
    _repository = ref.watch(chatRepositoryProvider);
    return const CreateGroupState();
  }

  /// Creates a new message group.
  Future<MessageGroupEntity?> createGroup(
    String name,
    List<String> memberIds,
  ) async {
    state = const CreateGroupState(isCreating: true);

    try {
      final group = await _repository.createGroup(name, memberIds);

      state = CreateGroupState(createdGroup: group);

      // Refresh conversations
      ref.read(conversationsNotifierProvider.notifier).refresh();

      return group;
    } catch (e) {
      state = CreateGroupState(error: e.toString());
      return null;
    }
  }

  /// Clears the state.
  void reset() {
    state = const CreateGroupState();
  }
}

// ============================================================================
// Selected Conversation Provider
// ============================================================================

/// Provider for the currently selected conversation.
@riverpod
class SelectedConversation extends _$SelectedConversation {
  @override
  ConversationEntity? build() => null;

  void select(ConversationEntity? conversation) {
    state = conversation;
  }

  void clear() {
    state = null;
  }
}

// ============================================================================
// User Groups Provider
// ============================================================================

/// Provider for user's message groups.
@riverpod
Future<List<MessageGroupEntity>> userGroups(Ref ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getUserGroups();
}

// ============================================================================
// Group Details Provider
// ============================================================================

/// Provider for group details.
@riverpod
Future<MessageGroupEntity?> groupDetails(Ref ref, String groupId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getGroup(groupId);
}
