import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';

/// Position of a message within a group of consecutive messages from the same sender.
enum MessagePosition {
  /// Single standalone message (not grouped).
  single,

  /// First message in a group.
  first,

  /// Middle message in a group.
  middle,

  /// Last message in a group.
  last,
}

/// Type of content within a message.
enum MessageContentType {
  /// Plain text message.
  text,

  /// Image attachment (placeholder for future).
  image,

  /// File attachment (placeholder for future).
  file,

  /// System message (e.g., user joined group).
  system,
}

/// A premium chat message bubble widget with full design system integration.
///
/// Features:
/// - Asymmetric corner radius based on sender
/// - Message grouping support (first/middle/last in group)
/// - Sender name display for group chats
/// - Timestamp and read status indicators
/// - Long press context menu support
/// - Soft shadows on both themes
/// - Fully theme-aware with no hardcoded values
///
/// Example usage:
/// ```dart
/// MessageBubble(
///   message: message,
///   showSenderName: isGroupChat,
///   position: MessagePosition.first,
///   isPlayful: themeNotifier.isPlayful,
///   onLongPress: () => _showContextMenu(message),
/// )
/// ```
class MessageBubble extends StatelessWidget {
  /// Creates a [MessageBubble] widget.
  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = false,
    this.isPlayful = false,
    this.position = MessagePosition.single,
    this.contentType = MessageContentType.text,
    this.onLongPress,
    this.onDoubleTap,
    this.isHighlighted = false,
  });

  /// The message to display.
  final MessageEntity message;

  /// Whether to show the sender's name (for group chats).
  final bool showSenderName;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Position of this message within a group of consecutive messages.
  final MessagePosition position;

  /// Type of content in the message.
  final MessageContentType contentType;

  /// Callback when the message is long-pressed (for context menu).
  final VoidCallback? onLongPress;

  /// Callback when the message is double-tapped (for reactions).
  final VoidCallback? onDoubleTap;

  /// Whether this message should be highlighted (e.g., search result).
  final bool isHighlighted;

  /// Formats the timestamp for display.
  String _formatTime(DateTime dateTime) {
    return DateFormat.Hm().format(dateTime);
  }

  /// Gets the bubble border radius based on message sender, theme, and position.
  BorderRadius _getBubbleRadius(bool isFromMe) {
    // Use the design system's message radius helpers based on position
    switch (position) {
      case MessagePosition.single:
        return AppRadius.messageRadius(isFromMe: isFromMe);
      case MessagePosition.first:
        return AppRadius.messageFirstInGroup(isFromMe: isFromMe);
      case MessagePosition.middle:
        return AppRadius.messageMiddleInGroup(isFromMe: isFromMe);
      case MessagePosition.last:
        return AppRadius.messageLastInGroup(isFromMe: isFromMe);
    }
  }

  /// Gets the vertical margin based on message position in group.
  double _getVerticalMargin() {
    switch (position) {
      case MessagePosition.single:
        return AppSpacing.xs;
      case MessagePosition.first:
        return AppSpacing.xs;
      case MessagePosition.middle:
        return AppSpacing.space2;
      case MessagePosition.last:
        return AppSpacing.space2;
    }
  }

  /// Gets the appropriate background color for the bubble.
  Color _getBubbleColor(ThemeData theme, bool isFromMe) {
    if (isFromMe) {
      // Sent message - use primary color
      return theme.colorScheme.primary;
    } else {
      // Received message - use surface container
      return isPlayful
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.surfaceContainerHigh;
    }
  }

  /// Gets the text color based on bubble background.
  Color _getTextColor(ThemeData theme, bool isFromMe) {
    if (isFromMe) {
      return theme.colorScheme.onPrimary;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  /// Gets the secondary text color (for timestamps, etc.).
  Color _getSecondaryTextColor(ThemeData theme, bool isFromMe) {
    if (isFromMe) {
      return theme.colorScheme.onPrimary.withValues(alpha: AppOpacity.iconOnColor);
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  /// Gets the read indicator color.
  Color _getReadIndicatorColor(ThemeData theme, bool isFromMe, bool isRead) {
    if (!isFromMe) return Colors.transparent;

    if (isRead) {
      // Read - show bright indicator
      return isPlayful
          ? PlayfulColors.info
          : theme.colorScheme.onPrimary.withValues(alpha: 0.9);
    } else {
      // Unread - show subtle indicator
      return theme.colorScheme.onPrimary.withValues(alpha: AppOpacity.iconOnColor);
    }
  }

  /// Builds the sender name widget for group chats.
  Widget _buildSenderName(ThemeData theme) {
    if (!showSenderName || message.isFromMe || message.senderName == null) {
      return const SizedBox.shrink();
    }

    // Only show sender name for first message or single message in group
    if (position != MessagePosition.first && position != MessagePosition.single) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.sm,
        bottom: AppSpacing.xxs,
      ),
      child: Text(
        message.senderName ?? '',
        style: AppTypography.caption(isPlayful: isPlayful).copyWith(
          fontWeight: AppFontWeight.titleSemiBold,
          color: theme.colorScheme.primary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Builds the message content based on content type.
  Widget _buildContent(ThemeData theme, bool isFromMe) {
    switch (contentType) {
      case MessageContentType.text:
        return _buildTextContent(theme, isFromMe);
      case MessageContentType.image:
        return _buildImagePlaceholder(theme, isFromMe);
      case MessageContentType.file:
        return _buildFilePlaceholder(theme, isFromMe);
      case MessageContentType.system:
        return _buildSystemMessage(theme);
    }
  }

  /// Builds text message content.
  Widget _buildTextContent(ThemeData theme, bool isFromMe) {
    return Text(
      message.content,
      style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
        color: _getTextColor(theme, isFromMe),
        height: AppLineHeight.body,
      ),
    );
  }

  /// Builds image placeholder (for future implementation).
  Widget _buildImagePlaceholder(ThemeData theme, bool isFromMe) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: _getTextColor(theme, isFromMe).withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.mdRadius,
      ),
      child: Center(
        child: Icon(
          Icons.image_rounded,
          size: AppIconSize.xxl,
          color: _getTextColor(theme, isFromMe).withValues(alpha: AppOpacity.heavy),
        ),
      ),
    );
  }

  /// Builds file placeholder (for future implementation).
  Widget _buildFilePlaceholder(ThemeData theme, bool isFromMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.attach_file_rounded,
          size: AppIconSize.md,
          color: _getTextColor(theme, isFromMe),
        ),
        SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            'attachment.pdf',
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              color: _getTextColor(theme, isFromMe),
              decoration: TextDecoration.underline,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds system message (e.g., "User joined the group").
  Widget _buildSystemMessage(ThemeData theme) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: AppOpacity.heavy,
          ),
          borderRadius: AppRadius.fullRadius,
        ),
        child: Text(
          message.content,
          style: AppTypography.caption(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds the timestamp and read status row.
  Widget _buildMetadata(ThemeData theme, bool isFromMe) {
    final secondaryColor = _getSecondaryTextColor(theme, isFromMe);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.createdAt),
          style: AppTypography.caption(isPlayful: isPlayful).copyWith(
            color: secondaryColor,
            fontSize: AppFontSize.labelSmall,
          ),
        ),
        if (isFromMe) ...[
          SizedBox(width: AppSpacing.xxs),
          _buildReadIndicator(theme, isFromMe),
        ],
      ],
    );
  }

  /// Builds the read status indicator (single or double check).
  Widget _buildReadIndicator(ThemeData theme, bool isFromMe) {
    final color = _getReadIndicatorColor(theme, isFromMe, message.isRead);

    return Icon(
      message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
      size: AppIconSize.xs,
      color: color,
    );
  }

  /// Gets shadows for the message bubble.
  List<BoxShadow> _getShadows(ThemeData theme, bool isFromMe) {
    // Both themes now get soft shadows for a premium feel
    return AppShadows.message(
      isFromMe: isFromMe,
      primaryColor: theme.colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFromMe = message.isFromMe;

    // Handle system messages differently
    if (contentType == MessageContentType.system) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: _buildSystemMessage(theme),
      );
    }

    final bubbleRadius = _getBubbleRadius(isFromMe);
    final bubbleColor = _getBubbleColor(theme, isFromMe);
    final shadows = _getShadows(theme, isFromMe);
    final verticalMargin = _getVerticalMargin();

    // Highlight border for search results
    final highlightBorder = isHighlighted
        ? Border.all(
            color: isPlayful ? PlayfulColors.warning : CleanColors.warning,
            width: 2,
          )
        : null;

    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              }
            : null,
        onDoubleTap: onDoubleTap != null
            ? () {
                HapticFeedback.lightImpact();
                onDoubleTap!();
              }
            : null,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.only(
            left: isFromMe ? AppSpacing.xxxxl : AppSpacing.space0,
            right: isFromMe ? AppSpacing.space0 : AppSpacing.xxxxl,
            bottom: verticalMargin,
          ),
          child: Column(
            crossAxisAlignment:
                isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Sender name (for group messages)
              _buildSenderName(theme),

              // Message bubble
              AnimatedContainer(
                duration: AppDuration.fast,
                curve: AppCurves.standard,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: bubbleRadius,
                  boxShadow: shadows,
                  border: highlightBorder,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Message content
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildContent(theme, isFromMe),
                    ),
                    SizedBox(height: AppSpacing.xxs),

                    // Timestamp and read status
                    _buildMetadata(theme, isFromMe),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A convenience widget that wraps MessageBubble with a context menu.
///
/// Provides common actions like copy, reply, and delete.
class MessageBubbleWithContextMenu extends StatelessWidget {
  /// Creates a [MessageBubbleWithContextMenu] widget.
  const MessageBubbleWithContextMenu({
    super.key,
    required this.message,
    this.showSenderName = false,
    this.isPlayful = false,
    this.position = MessagePosition.single,
    this.onCopy,
    this.onReply,
    this.onDelete,
    this.onReact,
  });

  /// The message to display.
  final MessageEntity message;

  /// Whether to show the sender's name.
  final bool showSenderName;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Position in message group.
  final MessagePosition position;

  /// Callback when copy is selected.
  final VoidCallback? onCopy;

  /// Callback when reply is selected.
  final VoidCallback? onReply;

  /// Callback when delete is selected.
  final VoidCallback? onDelete;

  /// Callback when a reaction is added.
  final VoidCallback? onReact;

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isFromMe = message.isFromMe;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.bottomSheet(),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: AppSpacing.xxxl,
                height: AppSpacing.xxs,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: AppRadius.fullRadius,
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Actions
              if (onReact != null)
                _ContextMenuItem(
                  icon: Icons.emoji_emotions_outlined,
                  label: 'React',
                  onTap: () {
                    Navigator.pop(context);
                    onReact!();
                  },
                  isPlayful: isPlayful,
                ),
              if (onCopy != null)
                _ContextMenuItem(
                  icon: Icons.copy_rounded,
                  label: 'Copy',
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: message.content));
                    Navigator.pop(context);
                    onCopy!();
                  },
                  isPlayful: isPlayful,
                ),
              if (onReply != null)
                _ContextMenuItem(
                  icon: Icons.reply_rounded,
                  label: 'Reply',
                  onTap: () {
                    Navigator.pop(context);
                    onReply!();
                  },
                  isPlayful: isPlayful,
                ),
              if (onDelete != null && isFromMe)
                _ContextMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  onTap: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                  isPlayful: isPlayful,
                  isDestructive: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MessageBubble(
      message: message,
      showSenderName: showSenderName,
      isPlayful: isPlayful,
      position: position,
      onLongPress: () => _showContextMenu(context),
      onDoubleTap: onReact,
    );
  }
}

/// Internal context menu item widget.
class _ContextMenuItem extends StatelessWidget {
  const _ContextMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPlayful,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPlayful;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? (isPlayful ? PlayfulColors.error : CleanColors.error)
        : theme.colorScheme.onSurface;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
        size: AppIconSize.md,
      ),
      title: Text(
        label,
        style: AppTypography.listTileTitle(isPlayful: isPlayful).copyWith(
          color: color,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
    );
  }
}
