import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
  String _title = 'Chat'; // Store the title for use in minimal conversation

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
      appBar: _buildAppBar(
        context,
        theme,
        isPlayful,
        conversationName,
        selectedConversation,
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
              _buildSearchBar(theme, isPlayful),

            // Messages list
            Expanded(
              child: _buildMessagesList(
                theme,
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

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    bool isPlayful,
    String conversationName,
    ConversationEntity? conversation,
  ) {
    return AppBar(
      backgroundColor: isPlayful
          ? theme.colorScheme.surface.withValues(alpha: 0.95)
          : theme.colorScheme.surface,
      elevation: isPlayful ? 0 : 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () {
          // Use go instead of pop to handle deep links properly
          // This ensures we always navigate to the messages list
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/messages');
          }
        },
      ),
      title: Row(
        children: [
          // Avatar
          if (conversation != null) ...[
            if (conversation.isGroup)
              GroupAvatar(
                name: conversation.name,
                size: isPlayful ? 42 : 40,
                isPlayful: isPlayful,
              )
            else
              CircleAvatar(
                radius: isPlayful ? 21 : 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: conversation.avatarUrl != null
                    ? NetworkImage(conversation.avatarUrl!)
                    : null,
                child: conversation.avatarUrl == null
                    ? Text(
                        conversation.name.isNotEmpty
                            ? conversation.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: isPlayful ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
            const SizedBox(width: 12),
          ],

          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversationName,
                  style: TextStyle(
                    fontSize: isPlayful ? 18 : 17,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: isPlayful ? 0.2 : 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (conversation?.isGroup == true &&
                    conversation?.participantIds != null)
                  Text(
                    '${conversation!.participantIds.length} members',
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // More options button
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded),
                  SizedBox(width: 12),
                  Text('Info'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search_rounded),
                  SizedBox(width: 12),
                  Text('Search'),
                ],
              ),
            ),
            if (widget.isGroup)
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app_rounded),
                    SizedBox(width: 12),
                    Text('Leave group'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList(
    ThemeData theme,
    bool isPlayful,
    ChatMessagesState messagesState,
  ) {
    if (messagesState.isLoading && messagesState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messagesState.error != null && messagesState.messages.isEmpty) {
      return _buildErrorState(theme, isPlayful, messagesState.error!);
    }

    if (messagesState.messages.isEmpty) {
      return _buildEmptyState(theme, isPlayful);
    }

    // Filter messages when searching
    final displayMessages = _isSearching
        ? _filterMessages(messagesState.messages)
        : messagesState.messages;

    if (_isSearching && displayMessages.isEmpty) {
      return _buildNoSearchResultsState(theme, isPlayful);
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 16 : 12,
      ),
      itemCount: displayMessages.length + (messagesState.hasMore && !_isSearching ? 1 : 0),
      itemBuilder: (context, index) {
        // Show loading indicator at the top for loading more
        if (index == displayMessages.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }

        final message = displayMessages[index];
        final previousMessage = index < displayMessages.length - 1
            ? displayMessages[index + 1]
            : null;

        // Check if we need to show date separator
        final showDateSeparator = previousMessage == null ||
            !_isSameDay(message.createdAt, previousMessage.createdAt);

        return Column(
          children: [
            if (showDateSeparator)
              DateSeparator(
                date: message.createdAt,
                isPlayful: isPlayful,
              ),
            _isSearching && _searchQuery.isNotEmpty
                ? _buildHighlightedMessageBubble(
                    message,
                    theme,
                    isPlayful,
                  )
                : MessageBubble(
                    message: message,
                    showSenderName: widget.isGroup,
                    isPlayful: isPlayful,
                  ),
          ],
        );
      },
    );
  }

  Widget _buildNoSearchResultsState(ThemeData theme, bool isPlayful) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 24 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: isPlayful ? 24 : 20),
            Text(
              'No messages found',
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedMessageBubble(
    MessageEntity message,
    ThemeData theme,
    bool isPlayful,
  ) {
    final isFromMe = message.isFromMe;

    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isFromMe ? 48 : 0,
          right: isFromMe ? 0 : 48,
          bottom: isPlayful ? 8 : 6,
        ),
        child: Column(
          crossAxisAlignment:
              isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender name (for group messages)
            if (widget.isGroup && !isFromMe && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),

            // Message bubble with highlighted text
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 16 : 14,
                vertical: isPlayful ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: isFromMe
                    ? theme.colorScheme.primary
                    : (isPlayful
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surfaceContainerHigh),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isPlayful ? 20 : 16),
                  topRight: Radius.circular(isPlayful ? 20 : 16),
                  bottomLeft: Radius.circular(isFromMe ? (isPlayful ? 20 : 16) : 4),
                  bottomRight: Radius.circular(isFromMe ? 4 : (isPlayful ? 20 : 16)),
                ),
                boxShadow: isPlayful
                    ? [
                        BoxShadow(
                          color: (isFromMe
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.shadow)
                              .withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Highlighted message content
                  _buildHighlightedText(
                    message.content,
                    _searchQuery,
                    TextStyle(
                      fontSize: isPlayful ? 16 : 15,
                      color: isFromMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                    isFromMe
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.3)
                        : theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 4),

                  // Time and read receipt
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat.Hm().format(message.createdAt),
                        style: TextStyle(
                          fontSize: isPlayful ? 12 : 11,
                          color: isFromMe
                              ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      if (isFromMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: isPlayful ? 16 : 14,
                          color: message.isRead
                              ? (isPlayful
                                  ? Colors.lightBlueAccent
                                  : theme.colorScheme.onPrimary.withValues(alpha: 0.9))
                              : theme.colorScheme.onPrimary.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    String query,
    TextStyle baseStyle,
    Color highlightColor,
  ) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // Add remaining text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: highlightColor,
          fontWeight: FontWeight.w600,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: spans,
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isPlayful) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 24 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: isPlayful ? 24 : 20),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message',
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isPlayful, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 64 : 56,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: isPlayful ? 20 : 16),
            Text(
              'Failed to load messages',
              style: TextStyle(
                fontSize: isPlayful ? 18 : 16,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(messagesNotifierProvider(
                            widget.conversationId, widget.isGroup)
                        .notifier)
                    .refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<bool> _handleSendMessage(String content) async {
    return await ref.read(sendMessageNotifierProvider.notifier).sendMessage(
          widget.conversationId,
          content,
          widget.isGroup,
        );
  }

  void _handleMenuAction(String action) {
    // Fetch conversation from conversations list instead of relying on selectedConversationProvider
    final conversations = ref.read(conversationsListProvider);
    final selectedConversation = conversations
        .where((c) => c.id == widget.conversationId)
        .cast<ConversationEntity?>()
        .firstWhere((_) => true, orElse: () => null);

    // If still null, try to build a minimal conversation entity from available data
    final conversation = selectedConversation ?? _buildMinimalConversation();

    switch (action) {
      case 'info':
        _showConversationInfoSheet(conversation);
        break;
      case 'search':
        setState(() {
          _isSearching = true;
        });
        break;
      case 'leave':
        _showLeaveGroupDialog();
        break;
    }
  }

  /// Builds a minimal conversation entity when full data is not available.
  ConversationEntity _buildMinimalConversation() {
    return ConversationEntity(
      id: widget.conversationId,
      name: _title, // Use the title that's already being displayed
      isGroup: widget.isGroup,
      participantIds: [],
      unreadCount: 0,
    );
  }

  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text(
          'Are you sure you want to leave this group? '
          'You will no longer receive messages from this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _leaveGroup();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
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
    if (conversation == null) {
      // Show error snackbar if no conversation data available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to load conversation info'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final theme = Theme.of(context);
    final isPlayful = ref.read(themeNotifierProvider) == ThemeType.playful;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isPlayful ? 24 : 16),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _buildConversationInfoContent(
          context,
          scrollController,
          conversation,
          theme,
          isPlayful,
        ),
      ),
    );
  }

  Widget _buildConversationInfoContent(
    BuildContext context,
    ScrollController scrollController,
    ConversationEntity conversation,
    ThemeData theme,
    bool isPlayful,
  ) {
    // For group conversations, fetch member details
    if (conversation.isGroup) {
      return FutureBuilder<MessageGroupEntity?>(
        future: ref.read(chatRepositoryProvider).getGroup(conversation.id),
        builder: (context, snapshot) {
          final group = snapshot.data;
          final members = group?.members ?? [];
          final memberCount = members.isNotEmpty
              ? members.length
              : conversation.participantIds.length;

          return _buildConversationInfoScrollView(
            scrollController: scrollController,
            conversation: conversation,
            theme: theme,
            isPlayful: isPlayful,
            memberCount: memberCount,
            membersWidget: _buildMembersSection(
              theme: theme,
              isPlayful: isPlayful,
              members: members,
              participantIds: conversation.participantIds,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
            ),
          );
        },
      );
    }

    // For direct messages, no need to fetch members
    return _buildConversationInfoScrollView(
      scrollController: scrollController,
      conversation: conversation,
      theme: theme,
      isPlayful: isPlayful,
      memberCount: conversation.participantIds.length,
      membersWidget: null,
    );
  }

  Widget _buildMembersSection({
    required ThemeData theme,
    required bool isPlayful,
    required List<GroupMemberEntity> members,
    required List<String> participantIds,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Members',
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isPlayful ? 12 : 8),
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          )
        else if (members.isNotEmpty)
          ...members.map(
            (member) => _buildParticipantTile(
              theme,
              isPlayful,
              member.userId,
              participantName: member.userName,
              participantRole: member.userRole,
              avatarUrl: member.avatarUrl,
            ),
          )
        else
          // Fallback to participant IDs when no member details available
          ...participantIds.map(
            (id) => _buildParticipantTile(theme, isPlayful, id),
          ),
      ],
    );
  }

  Widget _buildConversationInfoScrollView({
    required ScrollController scrollController,
    required ConversationEntity conversation,
    required ThemeData theme,
    required bool isPlayful,
    required int memberCount,
    required Widget? membersWidget,
  }) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Avatar and name
          Center(
            child: Column(
              children: [
                if (conversation.isGroup)
                  GroupAvatar(
                    name: conversation.name,
                    size: isPlayful ? 80 : 72,
                    isPlayful: isPlayful,
                  )
                else
                  CircleAvatar(
                    radius: isPlayful ? 40 : 36,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: conversation.avatarUrl != null
                        ? NetworkImage(conversation.avatarUrl!)
                        : null,
                    child: conversation.avatarUrl == null
                        ? Text(
                            conversation.name.isNotEmpty
                                ? conversation.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: isPlayful ? 32 : 28,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                SizedBox(height: isPlayful ? 16 : 12),
                Text(
                  conversation.name,
                  style: TextStyle(
                    fontSize: isPlayful ? 24 : 22,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (conversation.isGroup && conversation.groupType != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversation.groupType!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: isPlayful ? 32 : 24),

          // Info sections
          _buildInfoSection(
            theme,
            isPlayful,
            icon: Icons.people_outline_rounded,
            title: 'Participants',
            value: '$memberCount member${memberCount != 1 ? 's' : ''}',
          ),

          if (conversation.createdAt != null)
            _buildInfoSection(
              theme,
              isPlayful,
              icon: Icons.calendar_today_rounded,
              title: 'Created',
              value: DateFormat.yMMMMd().format(conversation.createdAt!),
            ),

          _buildInfoSection(
            theme,
            isPlayful,
            icon: conversation.isGroup
                ? Icons.group_rounded
                : Icons.person_rounded,
            title: 'Type',
            value: conversation.isGroup ? 'Group Chat' : 'Direct Message',
          ),

          SizedBox(height: isPlayful ? 24 : 20),

          // Participants list (for groups)
          if (membersWidget != null) membersWidget,
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    bool isPlayful, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isPlayful ? 16 : 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isPlayful ? 10 : 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
            child: Icon(
              icon,
              size: isPlayful ? 22 : 20,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(
    ThemeData theme,
    bool isPlayful,
    String participantId, {
    String? participantName,
    String? participantRole,
    String? avatarUrl,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isPlayful ? 8 : 6),
      padding: EdgeInsets.all(isPlayful ? 12 : 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isPlayful ? 18 : 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    (participantName?.isNotEmpty == true)
                        ? participantName![0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: isPlayful ? 14 : 12,
                    ),
                  )
                : null,
          ),
          SizedBox(width: isPlayful ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantName ?? 'Unknown User',
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (participantRole != null)
                  Text(
                    participantRole.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: isPlayful ? 12 : 11,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isPlayful) {
    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isPlayful ? 16 : 12,
                  vertical: isPlayful ? 12 : 10,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? 12 : 8),
          TextButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
              });
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MessageEntity> _filterMessages(List<MessageEntity> messages) {
    if (_searchQuery.isEmpty) return messages;

    return messages.where((message) {
      return message.content.toLowerCase().contains(_searchQuery);
    }).toList();
  }
}
