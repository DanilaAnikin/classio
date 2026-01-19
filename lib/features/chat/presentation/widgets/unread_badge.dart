import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';

/// A premium unread message badge with smooth animations.
///
/// Features:
/// - Pill-shaped or circular depending on count
/// - Primary color background with white text
/// - Shows count (99+ for large numbers) or indicator dot
/// - Subtle scale animation when count changes
/// - Smooth entrance/exit animations
/// - Fully theme-aware (Clean/Playful)
class UnreadBadge extends StatefulWidget {
  /// Creates an [UnreadBadge] widget.
  const UnreadBadge({
    super.key,
    required this.count,
    this.size = BadgeSize.medium,
    this.showDotOnly = false,
    this.backgroundColor,
    this.textColor,
    this.isPlayful = false,
  });

  /// The number of unread messages.
  final int count;

  /// The size variant of the badge.
  final BadgeSize size;

  /// If true, shows only a small indicator dot regardless of count.
  final bool showDotOnly;

  /// Optional background color override.
  final Color? backgroundColor;

  /// Optional text color override.
  final Color? textColor;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  State<UnreadBadge> createState() => _UnreadBadgeState();
}

class _UnreadBadgeState extends State<UnreadBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    _controller = AnimationController(
      duration: AppDuration.normal,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: AppCurves.decelerate)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: AppCurves.standard)),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppCurves.decelerate,
      ),
    );

    // Animate entrance if count > 0
    if (widget.count > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(UnreadBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when count changes
    if (widget.count != oldWidget.count) {
      if (widget.count > 0 && oldWidget.count == 0) {
        // Entrance animation
        _controller.forward(from: 0.0);
      } else if (widget.count == 0 && oldWidget.count > 0) {
        // Exit animation
        _controller.reverse();
      } else if (widget.count != oldWidget.count && widget.count > 0) {
        // Count change pulse animation
        _controller.forward(from: 0.0);
      }
      _previousCount = oldWidget.count;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) {
      return AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          if (_opacityAnimation.value == 0.0 && _previousCount == 0) {
            return const SizedBox.shrink();
          }
          return Opacity(
            opacity: _opacityAnimation.value,
            child: _buildBadge(context),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildBadge(context),
    );
  }

  Widget _buildBadge(BuildContext context) {
    final isPlayful = widget.isPlayful;
    final dimensions = _getDimensions();

    // Determine colors
    final bgColor = widget.backgroundColor ??
        (isPlayful ? PlayfulColors.primary : CleanColors.primary);
    final txtColor = widget.textColor ??
        (isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary);

    // Dot-only mode
    if (widget.showDotOnly) {
      return Container(
        width: dimensions.dotSize,
        height: dimensions.dotSize,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    // Count display
    final displayText =
        widget.count > 99 ? '99+' : widget.count.toString();
    final isWide = displayText.length > 1;

    // Calculate min width for pill shape
    final minWidth = isWide
        ? dimensions.height + (displayText.length - 1) * dimensions.charWidth
        : dimensions.height;

    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth,
        minHeight: dimensions.height,
        maxHeight: dimensions.height,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? dimensions.horizontalPadding : 0,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(dimensions.height / 2),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        displayText,
        style: AppTypography.badge(isPlayful: isPlayful).copyWith(
          color: txtColor,
          fontSize: dimensions.fontSize,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }

  _BadgeDimensions _getDimensions() {
    switch (widget.size) {
      case BadgeSize.small:
        return const _BadgeDimensions(
          height: 16,
          fontSize: 9,
          dotSize: 8,
          horizontalPadding: AppSpacing.xxs,
          charWidth: 5,
        );
      case BadgeSize.medium:
        return const _BadgeDimensions(
          height: 20,
          fontSize: 11,
          dotSize: 10,
          horizontalPadding: AppSpacing.xs,
          charWidth: 6,
        );
      case BadgeSize.large:
        return const _BadgeDimensions(
          height: 24,
          fontSize: 13,
          dotSize: 12,
          horizontalPadding: AppSpacing.sm,
          charWidth: 7,
        );
    }
  }
}

/// Size variants for the unread badge.
enum BadgeSize {
  /// Small badge (16px height)
  small,

  /// Medium badge (20px height) - default
  medium,

  /// Large badge (24px height)
  large,
}

/// Internal helper class for badge dimensions.
class _BadgeDimensions {
  const _BadgeDimensions({
    required this.height,
    required this.fontSize,
    required this.dotSize,
    required this.horizontalPadding,
    required this.charWidth,
  });

  final double height;
  final double fontSize;
  final double dotSize;
  final double horizontalPadding;
  final double charWidth;
}

/// A widget that overlays an [UnreadBadge] on its child.
///
/// Positions the badge at the top-right corner of the child widget
/// with smooth entrance/exit animations.
class UnreadBadgeOverlay extends StatelessWidget {
  /// Creates an [UnreadBadgeOverlay] widget.
  const UnreadBadgeOverlay({
    super.key,
    required this.count,
    required this.child,
    this.badgeSize = BadgeSize.small,
    this.showDotOnly = false,
    this.offset = const Offset(-4, -4),
    this.isPlayful = false,
  });

  /// The number of unread messages.
  final int count;

  /// The widget to overlay the badge on.
  final Widget child;

  /// The size of the badge.
  final BadgeSize badgeSize;

  /// If true, shows only a small indicator dot.
  final bool showDotOnly;

  /// Offset from the top-right corner.
  final Offset offset;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: offset.dy,
          right: offset.dx,
          child: AnimatedSwitcher(
            duration: AppDuration.fast,
            switchInCurve: AppCurves.decelerate,
            switchOutCurve: AppCurves.accelerate,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: count > 0
                ? UnreadBadge(
                    key: ValueKey('badge_$count'),
                    count: count,
                    size: badgeSize,
                    showDotOnly: showDotOnly,
                    isPlayful: isPlayful,
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),
      ],
    );
  }
}

/// A simple indicator dot for minimal unread notifications.
///
/// Use when you just need to indicate "something new" without a count.
class UnreadIndicatorDot extends StatelessWidget {
  /// Creates an [UnreadIndicatorDot] widget.
  const UnreadIndicatorDot({
    super.key,
    this.isVisible = true,
    this.size = 8.0,
    this.color,
    this.isPlayful = false,
  });

  /// Whether the dot is visible.
  final bool isVisible;

  /// The size of the dot.
  final double size;

  /// Optional color override.
  final Color? color;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final dotColor = color ??
        (isPlayful ? PlayfulColors.primary : CleanColors.primary);

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: AppDuration.fast,
      curve: AppCurves.standard,
      child: AnimatedScale(
        scale: isVisible ? 1.0 : 0.0,
        duration: AppDuration.fast,
        curve: AppCurves.decelerate,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
