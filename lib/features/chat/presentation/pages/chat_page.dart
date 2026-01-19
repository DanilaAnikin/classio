import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../domain/entities/entities.dart';
import '../providers/chat_provider.dart';
import '../widgets/widgets.dart';

/// The individual chat/conversation page.
///
/// Features:
/// - Displays messages in chronological order
/// - Message input field at bottom
/// - Real-time message updates
/// - Load more (pagination)
/// - Typing indicators
/// - Read receipts
class ChatPage extends ConsumerStatefulWidget {
  /// Creates a [ChatPage] widget.
  const ChatPage({
    super.key,
    required this.conversationId,
    this.isGroup = false,
  });

  /// The ID of the conversation.
  final String conversationId;

  /// Whether this is a group conversation.
  final bool isGroup;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  String _title = 'Chat';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesNotifierProvider(widget.conversationId, widget.isGroup).notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _onScroll() {
    // Load more when scrolled near the top (since messages are reversed)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      ref
          .read(messagesNotifierProvider(widget.conversationId, widget.isGroup)
              .notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final messagesState = ref.watch(
      messagesNotifierProvider(widget.conversationId, widget.isGroup),
    );
    final selectedConversation = ref.watch(selectedConversationProvider);
    final sendState = ref.watch(sendMessageNotifierProvider);

    // Determine conversation name
    String conversationName = 'Chat';
    if (selectedConversation != null) {
      conversationName = selectedConversation.name;
    }
    // Store title for use in minimal conversation building
    _title = conversationName;

    return Scaffold(
      appBar: ChatAppBar(
        conversationName: conversationName,
        conversation: selectedConversation,
        isGroup: widget.isGroup,
        isPlayful: isPlayful,
        onInfoPressed: () => _showConversationInfoSheet(selectedConversation),
        onSearchPressed: () => setState(() => _isSearching = true),
        onLeaveGroupPressed: _showLeaveGroupDialog,
      ),
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.02),
                    theme.colorScheme.surface,
                  ],
                ),
              )
            : null,
        child: Column(
          children: [
            // Search bar when searching
            if (_isSearching)
              ChatSearchBar(
                controller: _searchController,
                searchQuery: _searchQuery,
                isPlayful: isPlayful,
                onCancel: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              ),

            // Messages list
            Expanded(
              child: _buildMessagesContent(
                isPlayful,
                messagesState,
              ),
            ),

            // Message input (hide when searching)
            if (!_isSearching)
              MessageInput(
                onSend: _handleSendMessage,
                isLoading: sendState.isSending,
                isPlayful: isPlayful,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesContent(
    bool isPlayful,
    ChatMessagesState messagesState,
  ) {
    if (messagesState.isLoading && messagesState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState.error != null && messagesState.messages.isEmpty) {
      return ChatErrorState(
        error: messagesState.error ?? 'Unknown error',
        isPlayful: isPlayful,
        onRetry: () {
          ref
              .read(messagesNotifierProvider(widget.conversationId, widget.isGroup)
                  .notifier)
              .refresh();
        },
      );
    }

    if (messagesState.messages.isEmpty) {
      return ChatEmptyState(isPlayful: isPlayful);
    }

    // Filter messages when searching
    final displayMessages = _isSearching
        ? _filterMessages(messagesState.messages)
        : messagesState.messages;

    if (_isSearching && displayMessages.isEmpty) {
      return NoSearchResultsState(isPlayful: isPlayful);
    }

    return MessagesList(
      messagesState: messagesState,
      scrollController: _scrollController,
      isGroup: widget.isGroup,
      isSearching: _isSearching,
      searchQuery: _searchQuery,
      isPlayful: isPlayful,
    );
  }

  List<MessageEntity> _filterMessages(List<MessageEntity> messages) {
    if (_searchQuery.isEmpty) return messages;
    return messages.where((message) {
      return message.content.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Future<bool> _handleSendMessage(String content) async {
    return await ref.read(sendMessageNotifierProvider.notifier).sendMessage(
          widget.conversationId,
          content,
          widget.isGroup,
        );
  }

  void _showLeaveGroupDialog() {
    LeaveGroupDialog.show(
      context,
      onLeave: _leaveGroup,
    );
  }

  Future<void> _leaveGroup() async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.leaveGroup(widget.conversationId);

      // Refresh conversations list
      ref.read(conversationsNotifierProvider.notifier).refresh();

      // Navigate back to conversations list
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have left the group'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to leave group: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showConversationInfoSheet(ConversationEntity? conversation) {
    // Fetch conversation from conversations list if not available
    final conversations = ref.read(conversationsListProvider);
    final foundConversation = conversations
        .where((c) => c.id == widget.conversationId)
        .cast<ConversationEntity?>()
        .firstWhere((_) => true, orElse: () => null);

    // Use found conversation or build a minimal one
    final conversationToShow = conversation ?? foundConversation ?? _buildMinimalConversation();

    final isPlayful = ref.read(themeNotifierProvider) == ThemeType.playful;

    ConversationInfoSheet.show(
      context,
      conversation: conversationToShow,
      isPlayful: isPlayful,
    );
  }

  /// Builds a minimal conversation entity when full data is not available.
  ConversationEntity _buildMinimalConversation() {
    return ConversationEntity(
      id: widget.conversationId,
      name: _title,
      isGroup: widget.isGroup,
      participantIds: [],
      unreadCount: 0,
    );
  }
}
