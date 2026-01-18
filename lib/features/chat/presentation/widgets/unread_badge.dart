import 'package:flutter/material.dart';

/// A circular badge displaying unread message count.
///
/// Features:
/// - Displays count number
/// - Shows "99+" for counts over 99
/// - Can be positioned on other widgets using [Stack]
/// - Theme-aware styling
class UnreadBadge extends StatelessWidget {
  /// Creates an [UnreadBadge] widget.
  const UnreadBadge({
    super.key,
    required this.count,
    this.size = 20,
    this.backgroundColor,
    this.textColor,
    this.isPlayful = false,
  });

  /// The number of unread messages.
  final int count;

  /// The size of the badge (diameter).
  final double size;

  /// Optional background color (defaults to error color).
  final Color? backgroundColor;

  /// Optional text color (defaults to onError color).
  final Color? textColor;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final displayText = count > 99 ? '99+' : count.toString();
    final bgColor = backgroundColor ?? theme.colorScheme.error;
    final txtColor = textColor ?? theme.colorScheme.onError;

    // Adjust width for larger numbers
    final minWidth = displayText.length > 2 ? size + 8 : size;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: displayText.length > 1 ? 4 : 0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        displayText,
        style: TextStyle(
          color: txtColor,
          fontSize: size * 0.55,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// A widget that overlays an [UnreadBadge] on its child.
///
/// Positions the badge at the top-right corner of the child widget.
class UnreadBadgeOverlay extends StatelessWidget {
  /// Creates an [UnreadBadgeOverlay] widget.
  const UnreadBadgeOverlay({
    super.key,
    required this.count,
    required this.child,
    this.badgeSize = 18,
    this.offset = const Offset(-4, -4),
  });

  /// The number of unread messages.
  final int count;

  /// The widget to overlay the badge on.
  final Widget child;

  /// The size of the badge.
  final double badgeSize;

  /// Offset from the top-right corner.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: offset.dy,
            right: offset.dx,
            child: UnreadBadge(
              count: count,
              size: badgeSize,
            ),
          ),
      ],
    );
  }
}
