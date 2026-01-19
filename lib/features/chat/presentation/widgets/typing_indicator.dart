import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// A premium typing indicator widget with smooth wave animation.
///
/// Displays three animated dots that bounce in a wave pattern to indicate
/// that someone is typing. Fully theme-aware and supports both clean
/// and playful design modes.
///
/// Example usage:
/// ```dart
/// TypingIndicator(isPlayful: themeNotifier.isPlayful)
/// ```
class TypingIndicator extends StatefulWidget {
  /// Creates a [TypingIndicator] widget.
  const TypingIndicator({
    super.key,
    this.isPlayful = false,
    this.dotColor,
    this.bubbleColor,
  });

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Optional custom color for the dots.
  /// If not provided, uses theme-appropriate colors.
  final Color? dotColor;

  /// Optional custom color for the bubble background.
  /// If not provided, uses theme-appropriate colors.
  final Color? bubbleColor;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Number of dots in the indicator.
  static const int _dotCount = 3;

  /// Animation duration for a complete wave cycle.
  static const Duration _animationDuration = Duration(milliseconds: 1200);

  /// Phase offset between each dot (creates wave effect).
  static const double _phaseOffset = 0.25;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = widget.isPlayful;

    // Bubble styling based on theme
    final bubbleColor = widget.bubbleColor ??
        (isPlayful
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh);

    final bubbleRadius = AppRadius.only(
      topLeft: isPlayful ? AppRadius.xl : AppRadius.lg,
      topRight: isPlayful ? AppRadius.xl : AppRadius.lg,
      bottomRight: isPlayful ? AppRadius.xl : AppRadius.lg,
      bottomLeft: AppRadius.xs,
    );

    // Dot styling based on theme
    final dotSize = isPlayful ? 10.0 : 8.0;
    final dotColor = widget.dotColor ??
        (isPlayful
            ? PlayfulColors.textTertiary
            : CleanColors.textTertiary);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.md : AppSpacing.sm,
        vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: bubbleRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_dotCount, (index) {
          return _AnimatedDot(
            controller: _controller,
            index: index,
            phaseOffset: _phaseOffset,
            dotSize: dotSize,
            dotColor: dotColor,
            isPlayful: isPlayful,
          );
        }),
      ),
    );
  }
}

/// Individual animated dot with wave motion.
class _AnimatedDot extends StatelessWidget {
  const _AnimatedDot({
    required this.controller,
    required this.index,
    required this.phaseOffset,
    required this.dotSize,
    required this.dotColor,
    required this.isPlayful,
  });

  final AnimationController controller;
  final int index;
  final double phaseOffset;
  final double dotSize;
  final Color dotColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate the phase for this dot
        final phase = (controller.value + index * phaseOffset) % 1.0;

        // Use a smooth sine wave for natural bounce
        final bounce = math.sin(phase * math.pi * 2);

        // Map bounce to vertical offset (negative = up)
        final maxOffset = isPlayful ? 6.0 : 4.0;
        final offset = -bounce.abs() * maxOffset;

        // Opacity pulse for extra polish
        final opacity = 0.5 + (0.5 * (1 - bounce.abs()));

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isPlayful ? 3.0 : 2.5,
          ),
          child: Transform.translate(
            offset: Offset(0, offset),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A widget that shows the typing indicator with contextual information.
///
/// Displays who is typing along with the animated indicator. Supports
/// showing a user's name, avatar, or both.
///
/// Example usage:
/// ```dart
/// TypingIndicatorWithUser(
///   userName: 'John',
///   userAvatar: CircleAvatar(child: Text('J')),
///   isPlayful: themeNotifier.isPlayful,
/// )
/// ```
class TypingIndicatorWithUser extends StatelessWidget {
  /// Creates a [TypingIndicatorWithUser] widget with a name.
  const TypingIndicatorWithUser({
    super.key,
    required this.userName,
    this.userAvatar,
    this.isPlayful = false,
    this.showAvatar = true,
  });

  /// Name of the user who is typing.
  final String userName;

  /// Optional avatar widget to display.
  final Widget? userAvatar;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Whether to show the avatar (if provided).
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (optional)
          if (showAvatar && userAvatar != null) ...[
            SizedBox(
              width: isPlayful ? 32 : 28,
              height: isPlayful ? 32 : 28,
              child: userAvatar,
            ),
            SizedBox(width: AppSpacing.xs),
          ],

          // Typing indicator with name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // User name label
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.xs,
                  bottom: AppSpacing.xxs,
                ),
                child: Text(
                  '$userName is typing',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isPlayful
                        ? PlayfulColors.textTertiary
                        : CleanColors.textTertiary,
                  ),
                ),
              ),

              // Indicator bubble
              TypingIndicator(isPlayful: isPlayful),
            ],
          ),
        ],
      ),
    );
  }
}

/// A compact typing indicator that only shows the animated dots.
///
/// Useful for inline typing status in conversation lists or
/// message input areas where space is limited.
class TypingIndicatorCompact extends StatefulWidget {
  /// Creates a [TypingIndicatorCompact] widget.
  const TypingIndicatorCompact({
    super.key,
    this.isPlayful = false,
    this.dotColor,
  });

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Optional custom color for the dots.
  final Color? dotColor;

  @override
  State<TypingIndicatorCompact> createState() => _TypingIndicatorCompactState();
}

class _TypingIndicatorCompactState extends State<TypingIndicatorCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const int _dotCount = 3;
  static const Duration _animationDuration = Duration(milliseconds: 1000);
  static const double _phaseOffset = 0.2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = widget.isPlayful;
    final dotSize = isPlayful ? 6.0 : 5.0;
    final dotColor = widget.dotColor ??
        (isPlayful
            ? PlayfulColors.textTertiary
            : CleanColors.textTertiary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final phase = (_controller.value + index * _phaseOffset) % 1.0;
            final scale = 0.6 + (0.4 * math.sin(phase * math.pi));
            final opacity = 0.4 + (0.6 * math.sin(phase * math.pi));

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// A typing indicator that shows multiple users typing.
///
/// Displays a formatted string like "John, Jane, and 2 others are typing"
/// along with the animated indicator.
class TypingIndicatorMultiUser extends StatelessWidget {
  /// Creates a [TypingIndicatorMultiUser] widget.
  const TypingIndicatorMultiUser({
    super.key,
    required this.userNames,
    this.isPlayful = false,
    this.maxNamesToShow = 2,
  });

  /// List of user names who are typing.
  final List<String> userNames;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Maximum number of names to show before collapsing to "X others".
  final int maxNamesToShow;

  String _buildTypingText() {
    if (userNames.isEmpty) return '';
    if (userNames.length == 1) return '${userNames.first} is typing';

    if (userNames.length <= maxNamesToShow) {
      final allButLast = userNames.sublist(0, userNames.length - 1).join(', ');
      return '$allButLast and ${userNames.last} are typing';
    }

    final shownNames = userNames.take(maxNamesToShow).join(', ');
    final othersCount = userNames.length - maxNamesToShow;
    final othersText = othersCount == 1 ? '1 other' : '$othersCount others';
    return '$shownNames and $othersText are typing';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (userNames.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.xs,
              bottom: AppSpacing.xxs,
            ),
            child: Text(
              _buildTypingText(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: isPlayful
                    ? PlayfulColors.textTertiary
                    : CleanColors.textTertiary,
              ),
            ),
          ),
          TypingIndicator(isPlayful: isPlayful),
        ],
      ),
    );
  }
}

// =============================================================================
// LEGACY SUPPORT
// =============================================================================

/// @deprecated Use [TypingIndicatorWithUser] instead.
/// Legacy widget that shows typing indicator with a user's name.
@Deprecated('Use TypingIndicatorWithUser instead')
class TypingIndicatorWithName extends StatelessWidget {
  /// Creates a [TypingIndicatorWithName] widget.
  const TypingIndicatorWithName({
    super.key,
    required this.userName,
    this.isPlayful = false,
  });

  /// Name of the user who is typing.
  final String userName;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return TypingIndicatorWithUser(
      userName: userName,
      isPlayful: isPlayful,
      showAvatar: false,
    );
  }
}
