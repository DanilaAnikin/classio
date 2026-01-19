import 'package:flutter/material.dart';

/// A widget that displays an empty state for the chat.
///
/// Shows a message prompting the user to start a conversation
/// when there are no messages yet.
class ChatEmptyState extends StatelessWidget {
  /// Creates a [ChatEmptyState] widget.
  const ChatEmptyState({
    super.key,
    this.isPlayful = false,
  });

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}
