import 'package:flutter/material.dart';

/// An avatar widget for group conversations.
///
/// Features:
/// - Shows a group icon with initials or custom icon
/// - Gradient background for playful theme
/// - Consistent styling with user avatars
class GroupAvatar extends StatelessWidget {
  /// Creates a [GroupAvatar] widget.
  const GroupAvatar({
    super.key,
    required this.name,
    this.size = 48,
    this.isPlayful = false,
  });

  /// The name of the group (used to generate initials).
  final String name;

  /// The size of the avatar (diameter).
  final double size;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  String _getInitials() {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'G';

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : 'G';
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Color _getBackgroundColor(ThemeData theme) {
    // Generate consistent color based on name hash
    final hash = name.hashCode.abs();
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.teal,
      Colors.indigo,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _getBackgroundColor(theme);
    final initials = _getInitials();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.7),
                ],
              )
            : null,
        color: isPlayful ? null : bgColor.withValues(alpha: 0.8),
        boxShadow: isPlayful
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isPlayful ? 0.5 : 0,
          ),
        ),
      ),
    );
  }
}

/// A stacked group avatar showing multiple member avatars.
///
/// Shows up to 3 member avatars in a stacked layout with
/// an optional "+N" indicator for additional members.
class StackedGroupAvatar extends StatelessWidget {
  /// Creates a [StackedGroupAvatar] widget.
  const StackedGroupAvatar({
    super.key,
    required this.memberNames,
    this.size = 48,
    this.isPlayful = false,
    this.maxVisible = 3,
  });

  /// Names of group members.
  final List<String> memberNames;

  /// The overall size of the widget.
  final double size;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Maximum number of avatars to show.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (memberNames.isEmpty) {
      return GroupAvatar(
        name: 'Group',
        size: size,
        isPlayful: isPlayful,
      );
    }

    if (memberNames.length == 1) {
      return _MemberAvatar(
        name: memberNames[0],
        size: size,
        isPlayful: isPlayful,
      );
    }

    final visibleCount = memberNames.length > maxVisible
        ? maxVisible - 1
        : memberNames.length;
    final extraCount = memberNames.length - visibleCount;
    final smallSize = size * 0.6;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // First avatar (bottom right)
          if (memberNames.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              child: _MemberAvatar(
                name: memberNames[0],
                size: smallSize,
                isPlayful: isPlayful,
              ),
            ),
          // Second avatar (top left)
          if (memberNames.length > 1)
            Positioned(
              left: 0,
              top: 0,
              child: _MemberAvatar(
                name: memberNames[1],
                size: smallSize,
                isPlayful: isPlayful,
              ),
            ),
          // Extra count badge
          if (extraCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: smallSize * 0.7,
                height: smallSize * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: TextStyle(
                      fontSize: smallSize * 0.3,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Internal widget for member avatar.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.name,
    required this.size,
    required this.isPlayful,
  });

  final String name;
  final double size;
  final bool isPlayful;

  Color _getColor(ThemeData theme) {
    final hash = name.hashCode.abs();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(theme);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
