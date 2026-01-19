import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

// =============================================================================
// APP BUTTON - Premium Reusable Button Component
// =============================================================================
//
// A fully-featured, theme-aware button component with multiple variants,
// sizes, and states. Designed to be consistent with the app's design system.
//
// ## Quick Start
// ```dart
// // Primary button (main CTA)
// AppButton.primary(
//   label: 'Submit',
//   onPressed: () => handleSubmit(),
// )
//
// // Secondary button (outlined/ghost)
// AppButton.secondary(
//   label: 'Cancel',
//   onPressed: () => Navigator.pop(context),
// )
//
// // Tertiary button (text only)
// AppButton.tertiary(
//   label: 'Learn more',
//   onPressed: () => openHelp(),
// )
//
// // Danger button (destructive actions)
// AppButton.danger(
//   label: 'Delete',
//   icon: Icons.delete_outline,
//   onPressed: () => confirmDelete(),
// )
//
// // Icon-only button
// AppButton.icon(
//   icon: Icons.add,
//   onPressed: () => addItem(),
// )
// ```
//
// ## With Options
// ```dart
// AppButton.primary(
//   label: 'Save Changes',
//   icon: Icons.check,
//   trailingIcon: Icons.arrow_forward,
//   size: ButtonSize.large,
//   isLoading: isSubmitting,
//   isFullWidth: true,
//   onPressed: canSubmit ? () => submit() : null, // null = disabled
// )
// ```
//
// ## Theme Awareness
// The button automatically detects Clean vs Playful theme and adjusts:
// - Border radius (8px vs 12px)
// - Shadows (neutral vs violet-tinted)
// - Typography (Inter vs Nunito)
// - Interactive state colors
//
// =============================================================================

/// Button size enumeration with corresponding heights.
enum ButtonSize {
  /// Small button - height: 32px
  small(32),

  /// Medium button (default) - height: 40px
  medium(40),

  /// Large button - height: 48px
  large(48);

  const ButtonSize(this.height);

  /// The height of the button in logical pixels.
  final double height;
}

/// Button variant enumeration for different visual styles.
enum _ButtonVariant {
  /// Filled with primary color - main CTA
  primary,

  /// Outlined/ghost style - secondary actions
  secondary,

  /// Text only, minimal - tertiary actions
  tertiary,

  /// For destructive actions - danger style
  danger,

  /// Icon-only button - compact actions
  icon,
}

/// A premium, theme-aware button component with multiple variants and states.
///
/// Use the named constructors for each variant:
/// - [AppButton.primary] - Main call-to-action buttons
/// - [AppButton.secondary] - Secondary/outlined buttons
/// - [AppButton.tertiary] - Text-only buttons
/// - [AppButton.danger] - Destructive action buttons
/// - [AppButton.icon] - Icon-only buttons
///
/// See the file header for usage examples.
class AppButton extends StatefulWidget {
  /// Creates a primary (filled) button.
  ///
  /// Use this for main call-to-action buttons.
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  })  : _variant = _ButtonVariant.primary,
        _iconOnly = null;

  /// Creates a secondary (outlined/ghost) button.
  ///
  /// Use this for secondary actions alongside primary buttons.
  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  })  : _variant = _ButtonVariant.secondary,
        _iconOnly = null;

  /// Creates a tertiary (text-only) button.
  ///
  /// Use this for low-emphasis actions like "Learn more" or "Skip".
  const AppButton.tertiary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  })  : _variant = _ButtonVariant.tertiary,
        _iconOnly = null;

  /// Creates a danger (destructive) button.
  ///
  /// Use this for destructive actions like delete or remove.
  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  })  : _variant = _ButtonVariant.danger,
        _iconOnly = null;

  /// Creates an icon-only button.
  ///
  /// Use this for compact actions in toolbars, cards, etc.
  const AppButton.icon({
    super.key,
    required IconData icon,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  })  : label = '',
        _variant = _ButtonVariant.icon,
        _iconOnly = icon,
        this.icon = null,
        trailingIcon = null,
        isFullWidth = false;

  /// The button label text.
  ///
  /// For icon-only buttons, this is not displayed but should be set
  /// for accessibility purposes in the tooltip.
  final String label;

  /// Callback when the button is pressed.
  ///
  /// If null, the button will be displayed in a disabled state.
  final VoidCallback? onPressed;

  /// Optional leading icon displayed before the label.
  final IconData? icon;

  /// Optional trailing icon displayed after the label.
  final IconData? trailingIcon;

  /// The size of the button.
  ///
  /// Defaults to [ButtonSize.medium].
  final ButtonSize size;

  /// Whether the button is in a loading state.
  ///
  /// When true, displays a spinner and disables interaction.
  final bool isLoading;

  /// Whether the button should expand to fill its container.
  ///
  /// Defaults to false.
  final bool isFullWidth;

  /// Optional background color override.
  ///
  /// If not specified, uses the theme-appropriate color for the variant.
  final Color? backgroundColor;

  /// Optional foreground (text/icon) color override.
  ///
  /// If not specified, uses the theme-appropriate color for the variant.
  final Color? foregroundColor;

  /// Optional tooltip text for accessibility.
  ///
  /// For icon-only buttons, this is highly recommended.
  final String? tooltip;

  // Internal
  final _ButtonVariant _variant;
  final IconData? _iconOnly;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppCurves.buttonPress,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;
  bool get _isIconOnly => widget._variant == _ButtonVariant.icon;

  bool _detectTheme(BuildContext context) {
    // Detect if playful theme by checking primary color
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Playful theme uses violet (#7C3AED), Clean uses blue (#0066FF)
    return primaryColor.value == PlayfulColors.primary.value;
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _detectTheme(context);

    final buttonWidget = _buildButton(context, isPlayful);

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }

  Widget _buildButton(BuildContext context, bool isPlayful) {
    final colors = _getColors(isPlayful);
    final borderRadius = _getBorderRadius(isPlayful);
    final padding = _getPadding();
    final textStyle = _getTextStyle(isPlayful);
    final iconSize = _getIconSize();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: MouseRegion(
        cursor: _isDisabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          onTapDown: (_) => _handlePress(true),
          onTapUp: (_) => _handlePress(false),
          onTapCancel: () => _handlePress(false),
          onTap: _isDisabled ? null : widget.onPressed,
          child: Focus(
            onFocusChange: _handleFocusChange,
            child: AnimatedContainer(
              duration: AppDuration.fast,
              curve: AppCurves.standard,
              width: widget.isFullWidth ? double.infinity : null,
              height: widget.size.height,
              decoration: BoxDecoration(
                color: _getBackgroundColor(colors, isPlayful),
                borderRadius: borderRadius,
                border: _getBorder(colors, isPlayful),
                boxShadow: _getBoxShadow(isPlayful),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: _isDisabled ? null : widget.onPressed,
                  borderRadius: borderRadius,
                  splashColor: colors.splashColor,
                  highlightColor: Colors.transparent,
                  child: Container(
                    padding: padding,
                    child: _buildContent(
                      colors,
                      textStyle,
                      iconSize,
                      isPlayful,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    _ButtonColors colors,
    TextStyle textStyle,
    double iconSize,
    bool isPlayful,
  ) {
    if (widget.isLoading) {
      return _buildLoadingIndicator(colors);
    }

    if (_isIconOnly) {
      return Icon(
        widget._iconOnly,
        size: iconSize,
        color: _getForegroundColor(colors),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: iconSize,
            color: _getForegroundColor(colors),
          ),
          SizedBox(width: AppSpacing.iconTextGap),
        ],
        Text(
          widget.label,
          style: textStyle.copyWith(
            color: _getForegroundColor(colors),
          ),
        ),
        if (widget.trailingIcon != null) ...[
          SizedBox(width: AppSpacing.iconTextGap),
          Icon(
            widget.trailingIcon,
            size: iconSize,
            color: _getForegroundColor(colors),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(_ButtonColors colors) {
    final size = _getIconSize() - 4;
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          _getForegroundColor(colors),
        ),
      ),
    );
  }

  // ============================================================================
  // STYLE HELPERS
  // ============================================================================

  _ButtonColors _getColors(bool isPlayful) {
    switch (widget._variant) {
      case _ButtonVariant.primary:
        return _ButtonColors(
          background: widget.backgroundColor ??
              (isPlayful ? PlayfulColors.primary : CleanColors.primary),
          backgroundHover: isPlayful
              ? PlayfulColors.primaryHover
              : CleanColors.primaryHover,
          backgroundPressed: isPlayful
              ? PlayfulColors.primaryPressed
              : CleanColors.primaryPressed,
          foreground: widget.foregroundColor ??
              (isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary),
          border: Colors.transparent,
          borderHover: Colors.transparent,
          splashColor: (isPlayful
                  ? PlayfulColors.primaryLight
                  : CleanColors.primaryLight)
              .withValues(alpha: 0.3),
          disabledBackground:
              isPlayful ? PlayfulColors.stone300 : CleanColors.slate300,
          disabledForeground:
              isPlayful ? PlayfulColors.stone500 : CleanColors.slate500,
        );

      case _ButtonVariant.secondary:
        return _ButtonColors(
          background:
              widget.backgroundColor ?? Colors.transparent,
          backgroundHover: (isPlayful
                  ? PlayfulColors.primary
                  : CleanColors.primary)
              .withValues(alpha: 0.08),
          backgroundPressed: (isPlayful
                  ? PlayfulColors.primary
                  : CleanColors.primary)
              .withValues(alpha: 0.12),
          foreground: widget.foregroundColor ??
              (isPlayful ? PlayfulColors.primary : CleanColors.primary),
          border: isPlayful ? PlayfulColors.border : CleanColors.border,
          borderHover:
              isPlayful ? PlayfulColors.primary : CleanColors.primary,
          splashColor:
              (isPlayful ? PlayfulColors.primary : CleanColors.primary)
                  .withValues(alpha: 0.15),
          disabledBackground: Colors.transparent,
          disabledForeground:
              isPlayful ? PlayfulColors.disabled : CleanColors.disabled,
        );

      case _ButtonVariant.tertiary:
        return _ButtonColors(
          background:
              widget.backgroundColor ?? Colors.transparent,
          backgroundHover: (isPlayful
                  ? PlayfulColors.primary
                  : CleanColors.primary)
              .withValues(alpha: 0.05),
          backgroundPressed: (isPlayful
                  ? PlayfulColors.primary
                  : CleanColors.primary)
              .withValues(alpha: 0.1),
          foreground: widget.foregroundColor ??
              (isPlayful ? PlayfulColors.primary : CleanColors.primary),
          border: Colors.transparent,
          borderHover: Colors.transparent,
          splashColor:
              (isPlayful ? PlayfulColors.primary : CleanColors.primary)
                  .withValues(alpha: 0.1),
          disabledBackground: Colors.transparent,
          disabledForeground:
              isPlayful ? PlayfulColors.disabled : CleanColors.disabled,
        );

      case _ButtonVariant.danger:
        return _ButtonColors(
          background: widget.backgroundColor ??
              (isPlayful ? PlayfulColors.error : CleanColors.error),
          backgroundHover: isPlayful
              ? PlayfulColors.errorHover
              : CleanColors.errorHover,
          backgroundPressed: isPlayful
              ? PlayfulColors.errorPressed
              : CleanColors.errorPressed,
          foreground: widget.foregroundColor ??
              (isPlayful ? PlayfulColors.onError : CleanColors.onError),
          border: Colors.transparent,
          borderHover: Colors.transparent,
          splashColor: (isPlayful
                  ? PlayfulColors.errorLight
                  : CleanColors.errorLight)
              .withValues(alpha: 0.3),
          disabledBackground:
              isPlayful ? PlayfulColors.stone300 : CleanColors.slate300,
          disabledForeground:
              isPlayful ? PlayfulColors.stone500 : CleanColors.slate500,
        );

      case _ButtonVariant.icon:
        return _ButtonColors(
          background: widget.backgroundColor ?? Colors.transparent,
          backgroundHover: (isPlayful
                  ? PlayfulColors.textPrimary
                  : CleanColors.textPrimary)
              .withValues(alpha: 0.08),
          backgroundPressed: (isPlayful
                  ? PlayfulColors.textPrimary
                  : CleanColors.textPrimary)
              .withValues(alpha: 0.12),
          foreground: widget.foregroundColor ??
              (isPlayful
                  ? PlayfulColors.textSecondary
                  : CleanColors.textSecondary),
          border: Colors.transparent,
          borderHover: Colors.transparent,
          splashColor: (isPlayful
                  ? PlayfulColors.textPrimary
                  : CleanColors.textPrimary)
              .withValues(alpha: 0.1),
          disabledBackground: Colors.transparent,
          disabledForeground:
              isPlayful ? PlayfulColors.disabled : CleanColors.disabled,
        );
    }
  }

  Color _getBackgroundColor(_ButtonColors colors, bool isPlayful) {
    if (_isDisabled) {
      return colors.disabledBackground;
    }
    if (_isPressed) {
      return colors.backgroundPressed;
    }
    if (_isHovered) {
      return colors.backgroundHover;
    }
    return colors.background;
  }

  Color _getForegroundColor(_ButtonColors colors) {
    if (_isDisabled) {
      return colors.disabledForeground;
    }
    return colors.foreground;
  }

  Border? _getBorder(_ButtonColors colors, bool isPlayful) {
    if (widget._variant != _ButtonVariant.secondary) {
      return null;
    }

    final borderColor = _isDisabled
        ? colors.disabledForeground.withValues(alpha: 0.3)
        : (_isHovered || _isFocused)
            ? colors.borderHover
            : colors.border;

    return Border.all(
      color: borderColor,
      width: 1.5,
    );
  }

  BorderRadius _getBorderRadius(bool isPlayful) {
    if (_isIconOnly) {
      return BorderRadius.circular(widget.size.height / 2);
    }
    return AppRadius.button(isPlayful: isPlayful);
  }

  EdgeInsets _getPadding() {
    if (_isIconOnly) {
      // Square padding for icon buttons
      final padding = (widget.size.height - _getIconSize()) / 2;
      return EdgeInsets.all(padding);
    }

    switch (widget.size) {
      case ButtonSize.small:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingSmHorizontal,
          vertical: AppSpacing.buttonPaddingSmVertical,
        );
      case ButtonSize.medium:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingMdHorizontal,
          vertical: AppSpacing.buttonPaddingMdVertical,
        );
      case ButtonSize.large:
        return EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingLgHorizontal,
          vertical: AppSpacing.buttonPaddingLgVertical,
        );
    }
  }

  TextStyle _getTextStyle(bool isPlayful) {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.buttonTextSmall(isPlayful: isPlayful);
      case ButtonSize.medium:
        return AppTypography.buttonTextMedium(isPlayful: isPlayful);
      case ButtonSize.large:
        return AppTypography.buttonTextLarge(isPlayful: isPlayful);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppIconSize.xs; // 16
      case ButtonSize.medium:
        return AppIconSize.sm; // 20
      case ButtonSize.large:
        return AppIconSize.md; // 24
    }
  }

  List<BoxShadow>? _getBoxShadow(bool isPlayful) {
    // Only primary and danger buttons get shadows
    if (widget._variant != _ButtonVariant.primary &&
        widget._variant != _ButtonVariant.danger) {
      return null;
    }

    if (_isDisabled) {
      return null;
    }

    if (_isPressed) {
      return AppShadows.buttonPressed(isPlayful: isPlayful);
    }

    if (_isHovered) {
      return AppShadows.buttonHover(isPlayful: isPlayful);
    }

    return AppShadows.button(isPlayful: isPlayful);
  }

  // ============================================================================
  // INTERACTION HANDLERS
  // ============================================================================

  void _handleHover(bool isHovered) {
    if (_isDisabled) return;
    setState(() => _isHovered = isHovered);
  }

  void _handlePress(bool isPressed) {
    if (_isDisabled) return;
    setState(() => _isPressed = isPressed);
    if (isPressed) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleFocusChange(bool isFocused) {
    setState(() => _isFocused = isFocused);
  }
}

/// Internal color configuration for button variants.
class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.backgroundHover,
    required this.backgroundPressed,
    required this.foreground,
    required this.border,
    required this.borderHover,
    required this.splashColor,
    required this.disabledBackground,
    required this.disabledForeground,
  });

  final Color background;
  final Color backgroundHover;
  final Color backgroundPressed;
  final Color foreground;
  final Color border;
  final Color borderHover;
  final Color splashColor;
  final Color disabledBackground;
  final Color disabledForeground;
}
