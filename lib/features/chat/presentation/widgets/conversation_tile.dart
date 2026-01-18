import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';
import 'unread_badge.dart';

/// A tile widget representing a conversation in the conversations list.
///
/// Displays the conversation avatar, name, last message preview, time,
/// and unread count badge. Supports both direct and group conversations.
class ConversationTile extends StatelessWidget {
  /// Creates a [ConversationTile] widget.
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.isPlayful = false,
  });

  /// The conversation to display.
  final ConversationEntity conversation;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Formats the timestamp for display.
  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today: show time
      return DateFormat.Hm().format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      // Within a week: show day name
      return DateFormat.E().format(dateTime);
    } else {
      // Older: show date
      return DateFormat.MMMd().format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.hasUnread;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isPlayful ? 16 : 12,
          vertical: isPlayful ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: hasUnread
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(theme),
            SizedBox(width: isPlayful ? 14 : 12),

            // Content (name, last message)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.name,
                          style: TextStyle(
                            fontSize: isPlayful ? 17 : 16,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : (isPlayful ? FontWeight.w600 : FontWeight.w500),
                            color: theme.colorScheme.onSurface,
                            letterSpacing: isPlayful ? 0.2 : 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.lastActivityTime),
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                          color: hasUnread
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isPlayful ? 6 : 4),

                  // Last message preview and unread badge row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview.isNotEmpty
                              ? conversation.lastMessagePreview
                              : 'No messages yet',
                          style: TextStyle(
                            fontSize: isPlayful ? 15 : 14,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                            color: hasUnread
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontStyle: conversation.lastMessagePreview.isEmpty
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        UnreadBadge(
                          count: conversation.unreadCount,
                          isPlayful: isPlayful,
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

  /// Builds the avatar for the conversation.
  Widget _buildAvatar(ThemeData theme) {
    final size = isPlayful ? 56.0 : 52.0;
    final iconSize = isPlayful ? 28.0 : 24.0;

    if (conversation.avatarUrl != null && conversation.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(conversation.avatarUrl!),
        onBackgroundImageError: (_, _) {},
        child: null,
      );
    }

    // Default avatar based on conversation type
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: conversation.isGroup
          ? theme.colorScheme.secondaryContainer
          : theme.colorScheme.primaryContainer,
      child: conversation.isGroup
          ? Icon(
              Icons.group_rounded,
              size: iconSize,
              color: theme.colorScheme.onSecondaryContainer,
            )
          : Text(
              conversation.name.isNotEmpty
                  ? conversation.name[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
    );
  }
}
