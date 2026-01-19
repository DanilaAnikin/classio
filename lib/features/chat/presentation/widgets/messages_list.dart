import 'package:flutter/material.dart';

import '../../../../shared/widgets/empty_state.dart';
import '../../domain/entities/entities.dart';
import '../providers/chat_provider.dart';
import 'date_separator.dart';
import 'highlighted_message_bubble.dart';
import 'message_bubble.dart';

/// A widget that displays a scrollable list of messages.
///
/// Handles date separators, pagination loading indicator,
/// and supports search highlighting.
class MessagesList extends StatelessWidget {
  /// Creates a [MessagesList] widget.
  const MessagesList({
    super.key,
    required this.messagesState,
    required this.scrollController,
    this.isGroup = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.isPlayful = false,
  });

  /// The current state of chat messages.
  final ChatMessagesState messagesState;

  /// The scroll controller for the list.
  final ScrollController scrollController;

  /// Whether this is a group conversation.
  final bool isGroup;

  /// Whether search mode is active.
  final bool isSearching;

  /// The current search query.
  final String searchQuery;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Filters messages based on search query.
  List<MessageEntity> _filterMessages(List<MessageEntity> messages) {
    if (searchQuery.isEmpty) return messages;
    return messages.where((message) {
      return message.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  /// Checks if two dates are on the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter messages when searching
    final displayMessages = isSearching
        ? _filterMessages(messagesState.messages)
        : messagesState.messages;

    // Show empty state if no messages
    if (displayMessages.isEmpty) {
      return const EmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No Messages Yet',
        message: 'Start the conversation by sending a message.',
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 16 : 12,
      ),
      itemCount: displayMessages.length + (messagesState.hasMore && !isSearching ? 1 : 0),
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
            isSearching && searchQuery.isNotEmpty
                ? HighlightedMessageBubble(
                    message: message,
                    searchQuery: searchQuery,
                    showSenderName: isGroup,
                    isPlayful: isPlayful,
                  )
                : MessageBubble(
                    message: message,
                    showSenderName: isGroup,
                    isPlayful: isPlayful,
                  ),
          ],
        );
      },
    );
  }
}
