import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/spacing.dart';

// =============================================================================
// APP CARD - Premium Reusable Card Component
// =============================================================================
//
// A premium, theme-aware card component with multiple variants for different
// use cases. Supports Clean and Playful themes with appropriate styling.
//
// ## Variants:
// - `AppCard()` - Standard card with subtle border and shadow
// - `AppCard.elevated()` - More prominent shadow, no border (for featured content)
// - `AppCard.outlined()` - Border only, no shadow (for grouped content)
// - `AppCard.interactive()` - Has hover/press states (for clickable cards)
//
// ## Features:
// - Automatically adapts to Clean or Playful theme
// - Smooth hover/press animations for interactive variant
// - Accessible with proper semantics and focus support
// - Flexible sizing and constraints
// - Premium design with subtle borders and diffused shadows
//
// ## Usage Examples:
//
// ### Basic Card
// ```dart
// AppCard(
//   child: Column(
//     children: [
//       Text('Card Title'),
//       Text('Card content goes here'),
//     ],
//   ),
// )
// ```
//
// ### Elevated Card (Featured Content)
// ```dart
// AppCard.elevated(
//   child: Row(
//     children: [
//       Icon(Icons.star),
//       Text('Featured Item'),
//     ],
//   ),
// )
// ```
//
// ### Outlined Card (Grouped Content)
// ```dart
// AppCard.outlined(
//   child: ListTile(
//     title: Text('List Item'),
//     subtitle: Text('Description'),
//   ),
// )
// ```
//
// ### Interactive Card (Clickable)
// ```dart
// AppCard.interactive(
//   onTap: () => navigateToDetail(),
//   child: Column(
//     children: [
//       Image.network(imageUrl),
//       Text('Tap to view details'),
//     ],
//   ),
// )
// ```
//
// ### Custom Styling
// ```dart
// AppCard(
//   padding: EdgeInsets.all(24),
//   backgroundColor: Colors.blue.shade50,
//   borderRadius: BorderRadius.circular(20),
//   child: Text('Custom styled card'),
// )
// ```
//
// =============================================================================

/// The variant type for AppCard styling.
///
/// Used internally by AppCard constructors to determine styling behavior.
/// Users should use the named constructors (AppCard(), AppCard.elevated(), etc.)
/// rather than specifying variants directly.
enum AppCardVariant {
  /// Standard card with subtle border and shadow
  standard,

  /// Elevated card with prominent shadow, no border
  elevated,

  /// Outlined card with border only, no shadow
  outlined,

  /// Interactive card with hover/press states
  interactive,
}

/// A premium, reusable card component that adapts to the current theme.
///
/// Use this widget for consistent card styling throughout the application.
/// It automatically detects whether the Clean or Playful theme is active
/// and applies appropriate colors, shadows, and border radius.
///
/// See the file header documentation for comprehensive usage examples.
class AppCard extends StatefulWidget {
  /// Creates a standard card with subtle border and shadow.
  ///
  /// This is the default card style, suitable for most content containers.
  /// Features a subtle 1px border with low opacity and a soft shadow.
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  })  : _variant = AppCardVariant.standard,
        _isPlayful = null;

  /// Creates an elevated card with prominent shadow and no border.
  ///
  /// Use this variant for featured content or elements that need to
  /// stand out from the surrounding UI. The elevated shadow creates
  /// a floating appearance.
  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  })  : _variant = AppCardVariant.elevated,
        _isPlayful = null;

  /// Creates an outlined card with border only, no shadow.
  ///
  /// Use this variant for grouped content or when you want a lighter
  /// visual weight. The flat appearance works well for lists and
  /// secondary content areas.
  const AppCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  })  : _variant = AppCardVariant.outlined,
        _isPlayful = null;

  /// Creates an interactive card with hover and press states.
  ///
  /// Use this variant for clickable cards that navigate to detail views
  /// or trigger actions. Includes smooth animations for hover (desktop)
  /// and press states with visual feedback.
  ///
  /// The [onTap] callback is typically required for this variant, though
  /// [onLongPress] can also be used independently.
  const AppCard.interactive({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  })  : _variant = AppCardVariant.interactive,
        _isPlayful = null;

  /// Internal constructor for testing with explicit theme override.
  ///
  /// This constructor allows tests to explicitly set the theme mode
  /// without relying on context-based detection.
  @visibleForTesting
  // ignore: unused_element
  const AppCard.test({
    super.key,
    required this.child,
    required AppCardVariant variant,
    required bool? isPlayful,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.onLongPress,
    this.width,
    this.height,
    this.constraints,
    this.clipBehavior = Clip.antiAlias,
    this.semanticLabel,
  })  : _variant = variant,
        _isPlayful = isPlayful;

  /// The widget to display inside the card.
  final Widget child;

  /// The padding inside the card.
  ///
  /// Defaults to [AppSpacing.cardInsets] (20px all sides).
  final EdgeInsetsGeometry? padding;

  /// The margin around the card.
  final EdgeInsetsGeometry? margin;

  /// The background color of the card.
  ///
  /// If not specified, uses the theme-appropriate card color:
  /// - Clean theme: [CleanColors.card]
  /// - Playful theme: [PlayfulColors.card]
  final Color? backgroundColor;

  /// The border color of the card.
  ///
  /// If not specified, uses the theme-appropriate border color with
  /// reduced opacity for a subtle appearance.
  final Color? borderColor;

  /// The border radius of the card.
  ///
  /// If not specified, uses the theme-appropriate card radius:
  /// - Clean theme: 12px
  /// - Playful theme: 16px
  final BorderRadiusGeometry? borderRadius;

  /// Custom box shadow for the card.
  ///
  /// If not specified, uses the theme-appropriate shadow based on variant:
  /// - Standard: Subtle card shadow
  /// - Elevated: Medium shadow
  /// - Outlined: No shadow
  /// - Interactive: Dynamic shadow based on state
  final List<BoxShadow>? boxShadow;

  /// Callback when the card is tapped.
  ///
  /// For interactive variant, this enables hover/press visual feedback.
  /// For other variants, wraps the card in an InkWell.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// The width of the card.
  final double? width;

  /// The height of the card.
  final double? height;

  /// Additional constraints for the card.
  final BoxConstraints? constraints;

  /// How to clip the card's content.
  ///
  /// Defaults to [Clip.antiAlias] for smooth rounded corners.
  final Clip clipBehavior;

  /// Semantic label for accessibility.
  ///
  /// If provided, wraps the card in a [Semantics] widget with this label.
  /// Recommended for interactive cards to describe their purpose.
  final String? semanticLabel;

  /// The variant of this card.
  final AppCardVariant _variant;

  /// Override for theme detection (used for testing).
  final bool? _isPlayful;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  /// Whether the card is currently being hovered (desktop).
  bool _isHovered = false;

  /// Whether the card is currently being pressed.
  bool _isPressed = false;

  /// Whether the card has keyboard focus.
  bool _isFocused = false;

  /// Determines if the app is using the Playful theme.
  bool _detectIsPlayful(BuildContext context) {
    // Allow override for testing
    if (widget._isPlayful != null) {
      return widget._isPlayful!;
    }

    // Detect theme based on primary color
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Playful theme uses violet (0xFF7C3AED), Clean uses blue (0xFF0066FF)
    // Check if the primary color is closer to violet by comparing ARGB values
    final playfulPrimary = PlayfulColors.primary;
    return primaryColor.toARGB32() == playfulPrimary.toARGB32() ||
        (primaryColor.r * 255 > 100 && primaryColor.b * 255 > 200);
  }

  /// Gets the appropriate background color.
  Color _getBackgroundColor(bool isPlayful) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    return isPlayful ? PlayfulColors.card : CleanColors.card;
  }

  /// Gets the appropriate border color.
  Color _getBorderColor(bool isPlayful) {
    if (widget.borderColor != null) {
      return widget.borderColor!;
    }
    return isPlayful ? PlayfulColors.cardBorder : CleanColors.cardBorder;
  }

  /// Gets the appropriate border radius.
  BorderRadiusGeometry _getBorderRadius(bool isPlayful) {
    if (widget.borderRadius != null) {
      return widget.borderRadius!;
    }
    return AppRadius.card(isPlayful: isPlayful);
  }

  /// Gets the appropriate box shadow based on variant and state.
  List<BoxShadow> _getBoxShadow(bool isPlayful) {
    if (widget.boxShadow != null) {
      return widget.boxShadow!;
    }

    switch (widget._variant) {
      case AppCardVariant.standard:
        return AppShadows.card(isPlayful: isPlayful);

      case AppCardVariant.elevated:
        return AppShadows.cardHover(isPlayful: isPlayful);

      case AppCardVariant.outlined:
        return AppShadows.none;

      case AppCardVariant.interactive:
        if (_isPressed) {
          return AppShadows.cardPressed(isPlayful: isPlayful);
        } else if (_isHovered || _isFocused) {
          return AppShadows.cardHover(isPlayful: isPlayful);
        }
        return AppShadows.card(isPlayful: isPlayful);
    }
  }

  /// Gets the border based on variant and state.
  Border? _getBorder(bool isPlayful) {
    final borderColor = _getBorderColor(isPlayful);

    switch (widget._variant) {
      case AppCardVariant.standard:
        // Subtle border with low opacity
        return Border.all(
          color: borderColor.withValues(alpha: AppOpacity.cardBorder),
          width: 1.0,
        );

      case AppCardVariant.elevated:
        // No border for elevated cards
        return null;

      case AppCardVariant.outlined:
        // Full opacity border
        return Border.all(
          color: borderColor,
          width: 1.0,
        );

      case AppCardVariant.interactive:
        // Border that changes on hover/focus
        final opacity = (_isHovered || _isFocused)
            ? AppOpacity.soft
            : AppOpacity.cardBorder;
        return Border.all(
          color: borderColor.withValues(alpha: opacity),
          width: 1.0,
        );
    }
  }

  /// Gets the background color based on state for interactive variant.
  Color _getStateBackgroundColor(bool isPlayful) {
    final baseColor = _getBackgroundColor(isPlayful);

    if (widget._variant != AppCardVariant.interactive) {
      return baseColor;
    }

    if (_isPressed) {
      return isPlayful ? PlayfulColors.cardPressed : CleanColors.cardPressed;
    } else if (_isHovered) {
      return isPlayful ? PlayfulColors.cardHover : CleanColors.cardHover;
    }

    return baseColor;
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget._variant == AppCardVariant.interactive) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget._variant == AppCardVariant.interactive) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget._variant == AppCardVariant.interactive) {
      setState(() => _isPressed = false);
    }
  }

  void _handleHover(bool isHovered) {
    if (widget._variant == AppCardVariant.interactive) {
      setState(() => _isHovered = isHovered);
    }
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _detectIsPlayful(context);
    final isInteractive = widget._variant == AppCardVariant.interactive;
    final hasInteraction = widget.onTap != null || widget.onLongPress != null;
    final borderRadius = _getBorderRadius(isPlayful);

    // Build the base card container
    Widget buildCardContainer() {
      return AnimatedContainer(
        duration: AppDuration.fast,
        curve: AppCurves.decelerate,
        width: widget.width,
        height: widget.height,
        constraints: widget.constraints,
        padding: widget.padding ?? AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: _getStateBackgroundColor(isPlayful),
          borderRadius: borderRadius,
          border: _getBorder(isPlayful),
          boxShadow: _getBoxShadow(isPlayful),
        ),
        clipBehavior: widget.clipBehavior,
        child: widget.child,
      );
    }

    Widget result;

    // Build interactive wrapper for interactive variant
    if (isInteractive && hasInteraction) {
      result = MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        cursor: SystemMouseCursors.click,
        child: Focus(
          onFocusChange: _handleFocusChange,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: () {
              // Haptic feedback on tap
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            onLongPress: widget.onLongPress != null
                ? () {
                    HapticFeedback.mediumImpact();
                    widget.onLongPress?.call();
                  }
                : null,
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: AppDuration.fastest,
              curve: AppCurves.decelerate,
              child: buildCardContainer(),
            ),
          ),
        ),
      );
    }
    // For non-interactive variants with tap handlers
    else if (hasInteraction) {
      result = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          borderRadius: borderRadius as BorderRadius?,
          child: buildCardContainer(),
        ),
      );
    } else {
      result = buildCardContainer();
    }

    // Wrap with margin if specified
    if (widget.margin != null) {
      result = Padding(
        padding: widget.margin!,
        child: result,
      );
    }

    // Wrap with semantics if label is provided
    if (widget.semanticLabel != null) {
      result = Semantics(
        label: widget.semanticLabel,
        button: hasInteraction,
        enabled: true,
        child: result,
      );
    }

    return result;
  }
}

