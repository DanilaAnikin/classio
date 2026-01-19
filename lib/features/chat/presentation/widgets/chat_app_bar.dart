import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/entities/entities.dart';
import 'group_avatar.dart';

/// A custom app bar for the chat page.
///
/// Displays conversation name, avatar, and action buttons for
/// info, search, and leave group (for group chats).
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a [ChatAppBar] widget.
  const ChatAppBar({
    super.key,
    required this.conversationName,
    this.conversation,
    this.isGroup = false,
    this.isPlayful = false,
    this.onInfoPressed,
    this.onSearchPressed,
    this.onLeaveGroupPressed,
  });

  /// The name of the conversation to display.
  final String conversationName;

  /// The conversation entity (optional, for avatar display).
  final ConversationEntity? conversation;

  /// Whether this is a group conversation.
  final bool isGroup;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Callback when info action is pressed.
  final VoidCallback? onInfoPressed;

  /// Callback when search action is pressed.
  final VoidCallback? onSearchPressed;

  /// Callback when leave group action is pressed.
  final VoidCallback? onLeaveGroupPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            if (conversation!.isGroup)
              GroupAvatar(
                name: conversation!.name,
                size: isPlayful ? AvatarSize.lg : AvatarSize.md,
                isPlayful: isPlayful,
              )
            else
              CircleAvatar(
                radius: isPlayful ? 21 : 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: conversation!.avatarUrl != null
                    ? NetworkImage(conversation!.avatarUrl ?? '')
                    : null,
                child: conversation!.avatarUrl == null
                    ? Text(
                        conversation!.name.isNotEmpty
                            ? conversation!.name[0].toUpperCase()
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
                    '${conversation?.participantIds.length ?? 0} members',
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
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onSelected: (action) {
            switch (action) {
              case 'info':
                onInfoPressed?.call();
                break;
              case 'search':
                onSearchPressed?.call();
                break;
              case 'leave':
                onLeaveGroupPressed?.call();
                break;
            }
          },
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
            if (isGroup)
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
}
