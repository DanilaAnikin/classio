import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

// =============================================================================
// APP LIST TILE
// =============================================================================
// A premium, reusable list tile component with multiple variants.
// Supports Clean and Playful themes with proper state management.
//
// Variants:
// - AppListTile() - Standard list item
// - AppListTile.navigation() - With chevron for navigation
// - AppListTile.switchTile() - With toggle switch
// - AppListTile.checkbox() - With checkbox
// - AppListTile.selectable() - Can be selected (shows checkmark)
//
// Usage Examples:
// ```dart
// // Standard list tile
// AppListTile(
//   title: 'Account Settings',
//   subtitle: 'Manage your account preferences',
//   leading: Icon(Icons.person),
//   onTap: () => navigateToSettings(),
// )
//
// // Navigation tile with chevron
// AppListTile.navigation(
//   title: 'Privacy Policy',
//   leading: Icon(Icons.privacy_tip),
//   onTap: () => navigateToPrivacy(),
// )
//
// // Switch tile for toggleable settings
// AppListTile.switchTile(
//   title: 'Dark Mode',
//   subtitle: 'Enable dark theme',
//   leading: Icon(Icons.dark_mode),
//   switchValue: isDarkMode,
//   onSwitchChanged: (value) => setDarkMode(value),
// )
//
// // Checkbox tile for multi-select
// AppListTile.checkbox(
//   title: 'Enable notifications',
//   checkboxValue: notificationsEnabled,
//   onCheckboxChanged: (value) => setNotifications(value),
// )
//
// // Selectable tile for single/multi selection lists
// AppListTile.selectable(
//   title: 'Option A',
//   isSelected: selectedOption == 'A',
//   onSelect: () => selectOption('A'),
// )
// ```
// =============================================================================

/// The type of list tile variant
enum _AppListTileVariant {
  /// Standard list tile
  standard,

  /// Navigation tile with chevron
  navigation,

  /// Toggle switch tile
  switchTile,

  /// Checkbox tile
  checkbox,

  /// Selectable tile with checkmark
  selectable,
}

/// A premium, theme-aware list tile component.
///
/// This widget provides a consistent list item design across the app,
/// with support for multiple variants and proper state handling.
class AppListTile extends StatefulWidget {
  /// Creates a standard list tile.
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isEnabled = true,
    this.dense = false,
    this.contentPadding,
    this.backgroundColor,
    this.selectedColor,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.showDivider = false,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
  })  : _variant = _AppListTileVariant.standard,
        switchValue = null,
        onSwitchChanged = null,
        checkboxValue = null,
        onCheckboxChanged = null,
        onSelect = null,
        tristate = false;

  /// Creates a navigation list tile with a chevron icon.
  const AppListTile.navigation({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isEnabled = true,
    this.dense = false,
    this.contentPadding,
    this.backgroundColor,
    this.selectedColor,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.showDivider = false,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
  })  : _variant = _AppListTileVariant.navigation,
        switchValue = null,
        onSwitchChanged = null,
        checkboxValue = null,
        onCheckboxChanged = null,
        onSelect = null,
        tristate = false;

  /// Creates a list tile with a toggle switch.
  const AppListTile.switchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.switchValue,
    required this.onSwitchChanged,
    this.onTap,
    this.onLongPress,
    this.isEnabled = true,
    this.dense = false,
    this.contentPadding,
    this.backgroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.showDivider = false,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
  })  : _variant = _AppListTileVariant.switchTile,
        trailing = null,
        isSelected = false,
        selectedColor = null,
        checkboxValue = null,
        onCheckboxChanged = null,
        onSelect = null,
        tristate = false;

  /// Creates a list tile with a checkbox.
  const AppListTile.checkbox({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    this.tristate = false,
    this.onTap,
    this.onLongPress,
    this.isEnabled = true,
    this.dense = false,
    this.contentPadding,
    this.backgroundColor,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.showDivider = false,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
  })  : _variant = _AppListTileVariant.checkbox,
        trailing = null,
        isSelected = false,
        selectedColor = null,
        switchValue = null,
        onSwitchChanged = null,
        onSelect = null;

  /// Creates a selectable list tile that shows a checkmark when selected.
  const AppListTile.selectable({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.isSelected,
    required this.onSelect,
    this.onLongPress,
    this.isEnabled = true,
    this.dense = false,
    this.contentPadding,
    this.backgroundColor,
    this.selectedColor,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.showDivider = false,
    this.dividerIndent = 0,
    this.dividerEndIndent = 0,
  })  : _variant = _AppListTileVariant.selectable,
        onTap = null,
        switchValue = null,
        onSwitchChanged = null,
        checkboxValue = null,
        onCheckboxChanged = null,
        tristate = false;

  /// The variant type of this list tile
  final _AppListTileVariant _variant;

  /// The primary text content of the tile.
  final String title;

  /// Optional secondary text below the title.
  final String? subtitle;

  /// Optional widget to display before the title.
  /// Typically an [Icon], [CircleAvatar], or custom widget.
  final Widget? leading;

  /// Optional widget to display after the title (or at the end of the tile).
  /// For switch/checkbox variants, this is ignored.
  final Widget? trailing;

  /// Called when the user taps the tile.
  final VoidCallback? onTap;

  /// Called when the user long-presses the tile.
  final VoidCallback? onLongPress;

  /// Whether this tile is currently selected.
  /// Used for selectable variant and visual highlighting.
  final bool isSelected;

  /// Whether this tile is enabled and can be interacted with.
  final bool isEnabled;

  /// Whether to use reduced vertical padding (dense layout).
  final bool dense;

  /// Custom padding for the tile content.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom background color for the tile.
  final Color? backgroundColor;

  /// Custom color for the selected state.
  final Color? selectedColor;

  /// Custom text style for the title.
  final TextStyle? titleStyle;

  /// Custom text style for the subtitle.
  final TextStyle? subtitleStyle;

  /// Custom border radius for the tile.
  final BorderRadius? borderRadius;

  /// Whether to show a divider below the tile.
  final bool showDivider;

  /// Left indent for the divider.
  final double dividerIndent;

  /// Right indent for the divider.
  final double dividerEndIndent;

  // Switch variant properties
  /// The current value of the switch (for switchTile variant).
  final bool? switchValue;

  /// Called when the switch value changes (for switchTile variant).
  final ValueChanged<bool>? onSwitchChanged;

  // Checkbox variant properties
  /// The current value of the checkbox (for checkbox variant).
  /// Can be true, false, or null if tristate is enabled.
  final bool? checkboxValue;

  /// Called when the checkbox value changes (for checkbox variant).
  final ValueChanged<bool?>? onCheckboxChanged;

  /// Whether the checkbox supports three states (for checkbox variant).
  final bool tristate;

  // Selectable variant properties
  /// Called when the tile is selected (for selectable variant).
  final VoidCallback? onSelect;

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile>
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

  bool get _isPlayfulTheme {
    final primaryColor = Theme.of(context).colorScheme.primary;
    // Detect playful theme by checking if primary matches PlayfulColors
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }

  bool get _isInteractive {
    return widget.isEnabled &&
        (widget.onTap != null ||
            widget.onSelect != null ||
            widget.onSwitchChanged != null ||
            widget.onCheckboxChanged != null);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isInteractive) return;
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isInteractive) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    if (!_isInteractive) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (!_isInteractive) return;

    switch (widget._variant) {
      case _AppListTileVariant.selectable:
        widget.onSelect?.call();
        break;
      case _AppListTileVariant.switchTile:
        widget.onSwitchChanged?.call(!(widget.switchValue ?? false));
        break;
      case _AppListTileVariant.checkbox:
        if (widget.tristate) {
          // Cycle: false -> true -> null -> false
          final newValue = widget.checkboxValue == null
              ? false
              : widget.checkboxValue == false
                  ? true
                  : null;
          widget.onCheckboxChanged?.call(newValue);
        } else {
          widget.onCheckboxChanged?.call(!(widget.checkboxValue ?? false));
        }
        break;
      default:
        widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayfulTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: _isInteractive
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _handleTap,
            onLongPress: widget.isEnabled ? widget.onLongPress : null,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildTileContainer(isPlayful),
                );
              },
            ),
          ),
        ),
        if (widget.showDivider) _buildDivider(isPlayful),
      ],
    );
  }

  Widget _buildTileContainer(bool isPlayful) {
    final backgroundColor = _getBackgroundColor(isPlayful);
    final borderRadius =
        widget.borderRadius ?? AppRadius.button(isPlayful: isPlayful);

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppCurves.standard,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: widget.contentPadding ??
            EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: widget.dense ? AppSpacing.xs : AppSpacing.sm,
            ),
        child: Row(
          children: [
            if (widget.leading != null) ...[
              _buildLeading(isPlayful),
              SizedBox(width: AppSpacing.sm),
            ],
            Expanded(child: _buildContent(isPlayful)),
            if (_hasTrailing) ...[
              SizedBox(width: AppSpacing.sm),
              _buildTrailing(isPlayful),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isPlayful) {
    if (!widget.isEnabled) {
      return isPlayful
          ? PlayfulColors.disabledBackground
          : CleanColors.disabledBackground;
    }

    final selectedColor = widget.selectedColor ??
        (isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle);
    final hoverColor = widget.backgroundColor?.withValues(alpha: 0.8) ??
        (isPlayful ? PlayfulColors.surfaceHover : CleanColors.surfaceHover);
    final pressedColor = isPlayful
        ? PlayfulColors.surfacePressed
        : CleanColors.surfacePressed;
    final defaultColor = widget.backgroundColor ?? Colors.transparent;

    if (widget.isSelected) {
      if (_isPressed) {
        return Color.lerp(selectedColor, pressedColor, 0.3)!;
      }
      if (_isHovered) {
        return Color.lerp(selectedColor, hoverColor, 0.3)!;
      }
      return selectedColor;
    }

    if (_isPressed) {
      return pressedColor;
    }

    if (_isHovered) {
      return hoverColor;
    }

    return defaultColor;
  }

  Widget _buildLeading(bool isPlayful) {
    final iconColor = !widget.isEnabled
        ? (isPlayful ? PlayfulColors.disabled : CleanColors.disabled)
        : widget.isSelected
            ? (isPlayful ? PlayfulColors.primary : CleanColors.primary)
            : (isPlayful
                ? PlayfulColors.textSecondary
                : CleanColors.textSecondary);

    return IconTheme(
      data: IconThemeData(
        color: iconColor,
        size: AppIconSize.listTile,
      ),
      child: widget.leading!,
    );
  }

  Widget _buildContent(bool isPlayful) {
    final titleColor = !widget.isEnabled
        ? (isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled)
        : widget.isSelected
            ? (isPlayful ? PlayfulColors.primary : CleanColors.primary)
            : (isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary);

    final subtitleColor = !widget.isEnabled
        ? (isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled)
        : (isPlayful
            ? PlayfulColors.textSecondary
            : CleanColors.textSecondary);

    final titleStyle = widget.titleStyle ??
        AppTypography.listTileTitle(isPlayful: isPlayful).copyWith(
          color: titleColor,
        );

    final subtitleStyle = widget.subtitleStyle ??
        AppTypography.listTileSubtitle(isPlayful: isPlayful).copyWith(
          color: subtitleColor,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: titleStyle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null) ...[
          SizedBox(height: widget.dense ? 2 : 4),
          Text(
            widget.subtitle!,
            style: subtitleStyle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  bool get _hasTrailing {
    return widget.trailing != null ||
        widget._variant == _AppListTileVariant.navigation ||
        widget._variant == _AppListTileVariant.switchTile ||
        widget._variant == _AppListTileVariant.checkbox ||
        (widget._variant == _AppListTileVariant.selectable &&
            widget.isSelected);
  }

  Widget _buildTrailing(bool isPlayful) {
    switch (widget._variant) {
      case _AppListTileVariant.navigation:
        return _buildNavigationChevron(isPlayful);

      case _AppListTileVariant.switchTile:
        return _buildSwitch(isPlayful);

      case _AppListTileVariant.checkbox:
        return _buildCheckbox(isPlayful);

      case _AppListTileVariant.selectable:
        if (widget.isSelected) {
          return _buildSelectedCheckmark(isPlayful);
        }
        return widget.trailing ?? const SizedBox.shrink();

      default:
        if (widget.trailing != null) {
          return _buildCustomTrailing(isPlayful);
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationChevron(bool isPlayful) {
    final iconColor = !widget.isEnabled
        ? (isPlayful ? PlayfulColors.disabled : CleanColors.disabled)
        : (isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.trailing != null) ...[
          _buildCustomTrailing(isPlayful),
          SizedBox(width: AppSpacing.xs),
        ],
        Icon(
          Icons.chevron_right_rounded,
          color: iconColor,
          size: AppIconSize.md,
        ),
      ],
    );
  }

  Widget _buildSwitch(bool isPlayful) {
    final activeThumbColor =
        isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary;
    final activeTrackColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final inactiveTrackColor =
        isPlayful ? PlayfulColors.border : CleanColors.border;
    final inactiveThumbColor =
        isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;

    return Switch.adaptive(
      value: widget.switchValue ?? false,
      onChanged: widget.isEnabled ? widget.onSwitchChanged : null,
      activeTrackColor: activeTrackColor,
      activeThumbColor: activeThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildCheckbox(bool isPlayful) {
    final activeColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final checkColor =
        isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary;

    return Checkbox(
      value: widget.checkboxValue,
      onChanged: widget.isEnabled ? widget.onCheckboxChanged : null,
      tristate: widget.tristate,
      activeColor: activeColor,
      checkColor: checkColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.xsRadius,
      ),
      side: BorderSide(
        color: isPlayful ? PlayfulColors.border : CleanColors.border,
        width: 1.5,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSelectedCheckmark(bool isPlayful) {
    final primaryColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppCurves.decelerate,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2),
      child: Icon(
        Icons.check_rounded,
        color: isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary,
        size: AppIconSize.sm,
      ),
    );
  }

  Widget _buildCustomTrailing(bool isPlayful) {
    final iconColor = !widget.isEnabled
        ? (isPlayful ? PlayfulColors.disabled : CleanColors.disabled)
        : (isPlayful
            ? PlayfulColors.textSecondary
            : CleanColors.textSecondary);

    return IconTheme(
      data: IconThemeData(
        color: iconColor,
        size: AppIconSize.md,
      ),
      child: DefaultTextStyle(
        style: AppTypography.secondaryText(isPlayful: isPlayful),
        child: widget.trailing!,
      ),
    );
  }

  Widget _buildDivider(bool isPlayful) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: widget.dividerIndent,
      endIndent: widget.dividerEndIndent,
      color: isPlayful ? PlayfulColors.divider : CleanColors.divider,
    );
  }
}

// =============================================================================
// LIST TILE GROUP
// =============================================================================
// A convenience widget for grouping multiple list tiles with proper styling.
//
// Usage:
// ```dart
// AppListTileGroup(
//   title: 'Settings',
//   tiles: [
//     AppListTile.navigation(title: 'Account', ...),
//     AppListTile.navigation(title: 'Privacy', ...),
//     AppListTile.navigation(title: 'Notifications', ...),
//   ],
// )
// ```
// =============================================================================

/// A container for grouping related list tiles with optional header.
class AppListTileGroup extends StatelessWidget {
  const AppListTileGroup({
    super.key,
    this.title,
    required this.tiles,
    this.showDividers = true,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.showBorder = false,
    this.borderColor,
  });

  /// Optional title displayed above the group.
  final String? title;

  /// The list of tiles to display in this group.
  final List<AppListTile> tiles;

  /// Whether to show dividers between tiles.
  final bool showDividers;

  /// Custom background color for the group container.
  final Color? backgroundColor;

  /// Custom border radius for the group container.
  final BorderRadius? borderRadius;

  /// Padding inside the group container.
  final EdgeInsetsGeometry? padding;

  /// Margin outside the group container.
  final EdgeInsetsGeometry? margin;

  /// Whether to show a border around the group.
  final bool showBorder;

  /// Custom border color when showBorder is true.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful =
        theme.colorScheme.primary.toARGB32() == PlayfulColors.primary.toARGB32();

    final containerColor = backgroundColor ??
        (isPlayful ? PlayfulColors.surface : CleanColors.surface);
    final containerRadius =
        borderRadius ?? AppRadius.card(isPlayful: isPlayful);
    final containerBorderColor = borderColor ??
        (isPlayful ? PlayfulColors.border : CleanColors.border);

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                bottom: AppSpacing.xs,
              ),
              child: Text(
                title!.toUpperCase(),
                style: AppTypography.overline(isPlayful: isPlayful),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: containerRadius,
              border: showBorder
                  ? Border.all(
                      color: containerBorderColor,
                      width: 1,
                    )
                  : null,
            ),
            padding: padding,
            child: ClipRRect(
              borderRadius: containerRadius,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildTilesWithDividers(isPlayful),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTilesWithDividers(bool isPlayful) {
    final List<Widget> result = [];

    for (int i = 0; i < tiles.length; i++) {
      final tile = tiles[i];
      final isLast = i == tiles.length - 1;

      // Override the tile's showDivider if we're managing dividers
      result.add(
        AppListTile(
          key: tile.key,
          title: tile.title,
          subtitle: tile.subtitle,
          leading: tile.leading,
          trailing: tile.trailing,
          onTap: tile.onTap,
          onLongPress: tile.onLongPress,
          isSelected: tile.isSelected,
          isEnabled: tile.isEnabled,
          dense: tile.dense,
          contentPadding: tile.contentPadding,
          backgroundColor: tile.backgroundColor,
          selectedColor: tile.selectedColor,
          titleStyle: tile.titleStyle,
          subtitleStyle: tile.subtitleStyle,
          borderRadius: BorderRadius.zero, // Remove individual radius
          showDivider: showDividers && !isLast,
          dividerIndent: tile.leading != null ? AppSpacing.md + AppIconSize.listTile + AppSpacing.sm : AppSpacing.md,
          dividerEndIndent: AppSpacing.md,
        ),
      );
    }

    return result;
  }
}
