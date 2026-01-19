import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/entities/entities.dart';
import 'unread_badge.dart';

// =============================================================================
// CONVERSATION TILE
// =============================================================================
// A premium list tile widget for displaying conversations in a chat list.
//
// Features:
// - Theme-aware styling (Clean vs Playful)
// - Proper hover/press states with smooth animations
// - Clean typography hierarchy (name, last message, timestamp)
// - Unread indicator badge
// - Online status indicator support
// - Handles direct messages and group chats
// - Uses AppAvatar component for consistent avatar display
// - No magic numbers - all values from design tokens
//
// Usage:
// ```dart
// ConversationTile(
//   conversation: conversationEntity,
//   onTap: () => navigateToChat(conversation),
//   isOnline: true,
// )
// ```
// =============================================================================

/// A tile widget representing a conversation in the conversations list.
///
/// Displays the conversation avatar, name, last message preview, time,
/// and unread count badge. Supports both direct and group conversations.
class ConversationTile extends StatefulWidget {
  /// Creates a [ConversationTile] widget.
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
    this.isOnline = false,
  });

  /// The conversation to display.
  final ConversationEntity conversation;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Callback when the tile is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether the other participant is currently online (for direct messages).
  final bool isOnline;

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.decelerate,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Determines if the current theme is playful
  bool get _isPlayfulTheme {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

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
    final isPlayful = _isPlayfulTheme;
    final hasUnread = widget.conversation.hasUnread;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildTileContainer(isPlayful, hasUnread),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTileContainer(bool isPlayful, bool hasUnread) {
    final backgroundColor = _getBackgroundColor(isPlayful, hasUnread);
    final borderRadius = AppRadius.button(isPlayful: isPlayful);

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppCurves.standard,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: hasUnread && _isHovered
            ? AppShadows.cardHover(isPlayful: isPlayful)
            : null,
      ),
      child: Row(
        children: [
          // Avatar with optional online indicator
          _buildAvatar(isPlayful),
          SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),

          // Content (name, last message)
          Expanded(
            child: _buildContent(isPlayful, hasUnread),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(bool isPlayful, bool hasUnread) {
    final unreadColor = isPlayful
        ? PlayfulColors.primarySubtle.withValues(alpha: 0.6)
        : CleanColors.primarySubtle.withValues(alpha: 0.5);
    final hoverColor =
        isPlayful ? PlayfulColors.surfaceHover : CleanColors.surfaceHover;
    final pressedColor =
        isPlayful ? PlayfulColors.surfacePressed : CleanColors.surfacePressed;
    final defaultColor = Colors.transparent;

    if (_isPressed) {
      if (hasUnread) {
        return Color.lerp(unreadColor, pressedColor, 0.3)!;
      }
      return pressedColor;
    }

    if (_isHovered) {
      if (hasUnread) {
        return Color.lerp(unreadColor, hoverColor, 0.3)!;
      }
      return hoverColor;
    }

    if (hasUnread) {
      return unreadColor;
    }

    return defaultColor;
  }

  /// Builds the avatar for the conversation.
  Widget _buildAvatar(bool isPlayful) {
    final avatarSize = isPlayful ? AvatarSize.lg : AvatarSize.md;

    // Build online indicator badge if applicable
    Widget? badge;
    if (!widget.conversation.isGroup && widget.isOnline) {
      badge = OnlineIndicator(
        isOnline: widget.isOnline,
        size: isPlayful ? AppSpacing.sm : AppSpacing.xs + 2,
      );
    }

    final avatarUrl = widget.conversation.avatarUrl;

    if (widget.conversation.isGroup) {
      // Group conversation - use group icon
      return AppAvatar.icon(
        icon: Icons.group_rounded,
        size: avatarSize,
        backgroundColor:
            isPlayful ? PlayfulColors.secondarySubtle : CleanColors.secondarySubtle,
        foregroundColor:
            isPlayful ? PlayfulColors.secondary : CleanColors.secondary,
        badge: badge,
        badgePosition: BadgePosition.bottomRight,
      );
    }

    // Direct message - use image or initials
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AppAvatar(
        imageUrl: avatarUrl,
        fallbackName: widget.conversation.name,
        size: avatarSize,
        badge: badge,
        badgePosition: BadgePosition.bottomRight,
      );
    }

    // Fallback to initials
    return AppAvatar.initials(
      name: widget.conversation.name.isNotEmpty
          ? widget.conversation.name
          : '?',
      size: avatarSize,
      badge: badge,
      badgePosition: BadgePosition.bottomRight,
    );
  }

  /// Builds the content section (name, last message, timestamp, unread badge).
  Widget _buildContent(bool isPlayful, bool hasUnread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name and time row
        Row(
          children: [
            Expanded(
              child: _buildNameText(isPlayful, hasUnread),
            ),
            SizedBox(width: AppSpacing.xs),
            _buildTimestamp(isPlayful, hasUnread),
          ],
        ),
        SizedBox(height: isPlayful ? AppSpacing.xxs + 2 : AppSpacing.xxs),

        // Last message preview and unread badge row
        Row(
          children: [
            Expanded(
              child: _buildMessagePreview(isPlayful, hasUnread),
            ),
            if (hasUnread) ...[
              SizedBox(width: AppSpacing.xs),
              UnreadBadge(
                count: widget.conversation.unreadCount,
                size: isPlayful ? BadgeSize.medium : BadgeSize.small,
                isPlayful: isPlayful,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildNameText(bool isPlayful, bool hasUnread) {
    final baseStyle = AppTypography.listTileTitle(isPlayful: isPlayful);

    final nameColor = hasUnread
        ? (isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary)
        : (isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary);

    final nameWeight = hasUnread
        ? FontWeight.w700
        : (isPlayful ? FontWeight.w600 : FontWeight.w500);

    return Text(
      widget.conversation.name,
      style: baseStyle.copyWith(
        color: nameColor,
        fontWeight: nameWeight,
        letterSpacing: isPlayful ? AppLetterSpacing.titleSmall : 0,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTimestamp(bool isPlayful, bool hasUnread) {
    final timestampStyle = AppTypography.caption(isPlayful: isPlayful);

    final timestampColor = hasUnread
        ? (isPlayful ? PlayfulColors.primary : CleanColors.primary)
        : (isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary);

    final timestampWeight = hasUnread ? FontWeight.w600 : FontWeight.w400;

    return Text(
      _formatTime(widget.conversation.lastActivityTime),
      style: timestampStyle.copyWith(
        color: timestampColor,
        fontWeight: timestampWeight,
      ),
    );
  }

  Widget _buildMessagePreview(bool isPlayful, bool hasUnread) {
    final previewStyle = AppTypography.secondaryText(isPlayful: isPlayful);

    final hasMessage = widget.conversation.lastMessagePreview.isNotEmpty;

    final previewColor = hasUnread
        ? (isPlayful
            ? PlayfulColors.textSecondary
            : CleanColors.textSecondary)
        : (isPlayful
            ? PlayfulColors.textTertiary
            : CleanColors.textTertiary);

    final previewWeight = hasUnread ? FontWeight.w500 : FontWeight.w400;

    return Text(
      hasMessage ? widget.conversation.lastMessagePreview : 'No messages yet',
      style: previewStyle.copyWith(
        color: previewColor,
        fontWeight: previewWeight,
        fontStyle: hasMessage ? FontStyle.normal : FontStyle.italic,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// =============================================================================
// CONVERSATION TILE SKELETON
// =============================================================================
// A loading placeholder for conversation tiles.
// =============================================================================

/// A skeleton/shimmer loading placeholder for [ConversationTile].
class ConversationTileSkeleton extends StatelessWidget {
  /// Creates a [ConversationTileSkeleton] widget.
  const ConversationTileSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayfulTheme(context);
    final shimmerBase =
        isPlayful ? PlayfulColors.surfaceSubtle : CleanColors.surfaceSubtle;
    final shimmerHighlight =
        isPlayful ? PlayfulColors.surfaceMuted : CleanColors.surfaceMuted;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs,
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: isPlayful ? AvatarSize.lg.pixels : AvatarSize.md.pixels,
            height: isPlayful ? AvatarSize.lg.pixels : AvatarSize.md.pixels,
            decoration: BoxDecoration(
              color: shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),

          // Content placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and time row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: AppSpacing.md,
                        decoration: BoxDecoration(
                          color: shimmerBase,
                          borderRadius: AppRadius.xsRadius,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xl),
                    Container(
                      width: AppSpacing.xxxl,
                      height: AppSpacing.sm,
                      decoration: BoxDecoration(
                        color: shimmerHighlight,
                        borderRadius: AppRadius.xsRadius,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),

                // Message preview placeholder
                Container(
                  height: AppSpacing.sm,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerHighlight,
                    borderRadius: AppRadius.xsRadius,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isPlayfulTheme(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }
}
