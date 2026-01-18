import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';

/// A widget that displays a single message as a chat bubble.
///
/// Supports different styling for sent vs received messages,
/// shows sender name in group chats, and displays timestamps
/// and read receipts.
class MessageBubble extends StatelessWidget {
  /// Creates a [MessageBubble] widget.
  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = false,
    this.isPlayful = false,
  });

  /// The message to display.
  final MessageEntity message;

  /// Whether to show the sender's name (for group chats).
  final bool showSenderName;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Formats the timestamp for display.
  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            if (showSenderName && !isFromMe && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Message bubble
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
                  // Message content
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: isPlayful ? 16 : 15,
                      color: isFromMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Time and read receipt
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
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
}

