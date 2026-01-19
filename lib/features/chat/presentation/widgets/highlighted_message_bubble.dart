import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';

/// A message bubble widget that highlights search matches.
///
/// Similar to [MessageBubble] but highlights portions of the message
/// content that match the search query.
class HighlightedMessageBubble extends StatelessWidget {
  /// Creates a [HighlightedMessageBubble] widget.
  const HighlightedMessageBubble({
    super.key,
    required this.message,
    required this.searchQuery,
    this.showSenderName = false,
    this.isPlayful = false,
  });

  /// The message to display.
  final MessageEntity message;

  /// The search query to highlight.
  final String searchQuery;

  /// Whether to show the sender's name (for group chats).
  final bool showSenderName;

  /// Whether to use playful theme styling.
  final bool isPlayful;

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
                  message.senderName ?? '',
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
                    searchQuery,
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
}
