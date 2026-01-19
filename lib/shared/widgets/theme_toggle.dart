import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';

// =============================================================================
// THEME TOGGLE - DISPLAY MODE
// =============================================================================

/// Display mode for the theme toggle widget.
enum ThemeToggleDisplayMode {
  /// Compact mode - shows only icons for quick switching.
  /// Best for toolbars, app bars, or space-constrained areas.
  compact,

  /// Full mode - shows icons with labels in a segmented control.
  /// Best for settings pages where space is available.
  full,

  /// Dropdown mode - shows current theme with a dropdown menu.
  /// Best for settings pages with a traditional list tile layout.
  dropdown,
}

// =============================================================================
// UNIFIED THEME TOGGLE WIDGET
// =============================================================================

/// A premium, animated theme toggle widget with multiple display modes.
///
/// Supports three display modes:
/// - [ThemeToggleDisplayMode.compact]: Icon-only segmented control
/// - [ThemeToggleDisplayMode.full]: Icons with labels in segmented control
/// - [ThemeToggleDisplayMode.dropdown]: List tile with bottom sheet selector
///
/// Features:
/// - Smooth animations between states
/// - Proper focus and hover states
/// - Consistent design tokens from the design system
/// - Accessible with proper semantics
///
/// Usage:
/// ```dart
/// // Compact mode (for app bar)
/// ThemeToggle(mode: ThemeToggleDisplayMode.compact)
///
/// // Full mode (for settings)
/// ThemeToggle(mode: ThemeToggleDisplayMode.full)
///
/// // Dropdown mode (for settings list)
/// ThemeToggle(mode: ThemeToggleDisplayMode.dropdown)
/// ```
class ThemeToggle extends ConsumerWidget {
  /// The display mode for the toggle.
  final ThemeToggleDisplayMode mode;

  /// Optional callback when theme changes.
  final ValueChanged<ThemeType>? onChanged;

  const ThemeToggle({
    super.key,
    this.mode = ThemeToggleDisplayMode.full,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (mode) {
      case ThemeToggleDisplayMode.compact:
        return _CompactThemeToggle(onChanged: onChanged);
      case ThemeToggleDisplayMode.full:
        return _FullThemeToggle(onChanged: onChanged);
      case ThemeToggleDisplayMode.dropdown:
        return _DropdownThemeToggle(onChanged: onChanged);
    }
  }
}

// =============================================================================
// COMPACT THEME TOGGLE (Icons Only)
// =============================================================================

class _CompactThemeToggle extends ConsumerWidget {
  final ValueChanged<ThemeType>? onChanged;

  const _CompactThemeToggle({this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final theme = Theme.of(context);
    final isPlayful = currentTheme == ThemeType.playful;

    return Semantics(
      label: 'Theme selector',
      hint: 'Double tap to switch theme',
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: AppRadius.fullRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CompactThemeOption(
              icon: Icons.auto_awesome_outlined,
              isSelected: !isPlayful,
              tooltip: 'Clean theme',
              onTap: () => _selectTheme(ref, ThemeType.clean),
            ),
            _CompactThemeOption(
              icon: Icons.palette_outlined,
              isSelected: isPlayful,
              tooltip: 'Playful theme',
              onTap: () => _selectTheme(ref, ThemeType.playful),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme(WidgetRef ref, ThemeType type) {
    HapticFeedback.selectionClick();
    ref.read(themeNotifierProvider.notifier).setTheme(type);
    onChanged?.call(type);
  }
}

class _CompactThemeOption extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final String tooltip;
  final VoidCallback onTap;

  const _CompactThemeOption({
    required this.icon,
    required this.isSelected,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_CompactThemeOption> createState() => _CompactThemeOptionState();
}

class _CompactThemeOptionState extends State<_CompactThemeOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = AppSpacing.xxxxl - AppSpacing.xs;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: AppDuration.slow,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Focus(
          onFocusChange: (focused) => setState(() => _isFocused = focused),
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: AnimatedContainer(
                duration: AppDuration.fast,
                curve: AppCurves.standard,
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : _isHovered || _isFocused
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.transparent,
                  borderRadius: AppRadius.fullRadius,
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: AppSpacing.xs,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                  border: _isFocused && !widget.isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          width: 2,
                        )
                      : null,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AppDuration.fast,
                    child: Icon(
                      widget.icon,
                      key: ValueKey(widget.isSelected),
                      size: AppIconSize.sm,
                      color: widget.isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
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
}

// =============================================================================
// FULL THEME TOGGLE (Icons + Labels)
// =============================================================================

class _FullThemeToggle extends ConsumerWidget {
  final ValueChanged<ThemeType>? onChanged;

  const _FullThemeToggle({this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isPlayful = currentTheme == ThemeType.playful;

    return Semantics(
      label: 'Theme selector',
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: AppRadius.lgRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FullThemeOption(
              icon: Icons.auto_awesome_outlined,
              label: l10n.cleanTheme,
              isSelected: !isPlayful,
              onTap: () => _selectTheme(ref, ThemeType.clean),
            ),
            AppSpacing.gapH4,
            _FullThemeOption(
              icon: Icons.palette_outlined,
              label: l10n.playfulTheme,
              isSelected: isPlayful,
              onTap: () => _selectTheme(ref, ThemeType.playful),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme(WidgetRef ref, ThemeType type) {
    HapticFeedback.selectionClick();
    ref.read(themeNotifierProvider.notifier).setTheme(type);
    onChanged?.call(type);
  }
}

class _FullThemeOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FullThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FullThemeOption> createState() => _FullThemeOptionState();
}

class _FullThemeOptionState extends State<_FullThemeOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onTap();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: AppDuration.fast,
              curve: AppCurves.standard,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? theme.colorScheme.primary
                    : _isHovered || _isFocused
                        ? theme.colorScheme.surfaceContainerHighest
                        : Colors.transparent,
                borderRadius: AppRadius.mdRadius,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: AppSpacing.sm,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
                border: _isFocused && !widget.isSelected
                    ? Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: AppDuration.fast,
                    child: Icon(
                      widget.icon,
                      key: ValueKey('${widget.isSelected}_icon'),
                      size: AppIconSize.sm,
                      color: widget.isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  AppSpacing.gapH8,
                  AnimatedDefaultTextStyle(
                    duration: AppDuration.fast,
                    style: theme.textTheme.labelMedium!.copyWith(
                      color: widget.isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DROPDOWN THEME TOGGLE (List Tile with Bottom Sheet)
// =============================================================================

class _DropdownThemeToggle extends ConsumerWidget {
  final ValueChanged<ThemeType>? onChanged;

  const _DropdownThemeToggle({this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isClean = currentTheme == ThemeType.clean;

    return Semantics(
      label: 'Theme selector',
      hint: 'Tap to change theme',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showThemeSheet(context, ref),
          borderRadius: AppRadius.lgRadius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // Leading icon container
                Container(
                  width: AppSpacing.xxxxl,
                  height: AppSpacing.xxxxl,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: AppRadius.lgRadius,
                  ),
                  child: Center(
                    child: Icon(
                      isClean ? Icons.auto_awesome_outlined : Icons.palette_outlined,
                      color: theme.colorScheme.primary,
                      size: AppIconSize.md,
                    ),
                  ),
                ),
                AppSpacing.gapH16,
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.theme,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.gap2,
                      Text(
                        isClean ? l10n.cleanTheme : l10n.playfulTheme,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: AppIconSize.md,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeSelectionSheet(
        title: l10n.selectTheme,
        onThemeSelected: (themeType) {
          HapticFeedback.selectionClick();
          ref.read(themeNotifierProvider.notifier).setTheme(themeType);
          onChanged?.call(themeType);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// =============================================================================
// THEME SELECTION BOTTOM SHEET
// =============================================================================

/// A premium bottom sheet for selecting app theme.
///
/// Shows theme options as visual cards with color previews and descriptions.
class ThemeSelectionSheet extends ConsumerWidget {
  /// The title displayed at the top of the sheet.
  final String title;

  /// Callback when a theme is selected.
  final void Function(ThemeType themeType) onThemeSelected;

  const ThemeSelectionSheet({
    super.key,
    required this.title,
    required this.onThemeSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: AppRadius.fullRadius,
                ),
              ),
            ),
            // Title
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            AppSpacing.gap16,
            // Theme options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _ThemeOptionCard(
                      title: l10n.cleanTheme,
                      description: 'Minimalist & professional',
                      icon: Icons.auto_awesome_outlined,
                      isSelected: currentTheme == ThemeType.clean,
                      onTap: () => onThemeSelected(ThemeType.clean),
                      primaryColor: CleanColors.primary,
                      secondaryColor: CleanColors.secondary,
                      accentColor: CleanColors.success,
                    ),
                  ),
                  AppSpacing.gapH12,
                  Expanded(
                    child: _ThemeOptionCard(
                      title: l10n.playfulTheme,
                      description: 'Fun & colorful',
                      icon: Icons.palette_outlined,
                      isSelected: currentTheme == ThemeType.playful,
                      onTap: () => onThemeSelected(ThemeType.playful),
                      primaryColor: PlayfulColors.primary,
                      secondaryColor: PlayfulColors.secondary,
                      accentColor: PlayfulColors.accentPink,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gap24,
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// THEME OPTION CARD
// =============================================================================

class _ThemeOptionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const _ThemeOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  @override
  State<_ThemeOptionCard> createState() => _ThemeOptionCardState();
}

class _ThemeOptionCardState extends State<_ThemeOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDuration.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: AppDuration.normal,
          curve: AppCurves.standard,
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : theme.colorScheme.surface,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      blurRadius: AppSpacing.md,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: AppSpacing.xs,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color preview circles
              Row(
                children: [
                  _ColorDot(
                    color: widget.primaryColor,
                    size: AppSpacing.xxl,
                    hasShadow: true,
                  ),
                  AppSpacing.gapH4,
                  _ColorDot(
                    color: widget.secondaryColor,
                    size: AppSpacing.lg,
                    hasShadow: false,
                  ),
                  AppSpacing.gapH4,
                  _ColorDot(
                    color: widget.accentColor,
                    size: AppSpacing.md,
                    hasShadow: false,
                  ),
                  const Spacer(),
                  // Selected indicator
                  AnimatedScale(
                    scale: widget.isSelected ? 1.0 : 0.0,
                    duration: AppDuration.fast,
                    curve: AppCurves.emphasized,
                    child: Container(
                      width: AppSpacing.xl,
                      height: AppSpacing.xl,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: AppIconSize.xs,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gap16,
              // Icon
              AnimatedContainer(
                duration: AppDuration.fast,
                child: Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: AppIconSize.lg,
                ),
              ),
              AppSpacing.gap8,
              // Title
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              AppSpacing.gap4,
              // Description
              Text(
                widget.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// COLOR DOT WIDGET
// =============================================================================

class _ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool hasShadow;

  const _ColorDot({
    required this.color,
    required this.size,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: AppSpacing.xs,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

// =============================================================================
// LEGACY WIDGET ALIASES (For Backward Compatibility)
// =============================================================================

/// @deprecated Use [ThemeToggle] with [ThemeToggleDisplayMode.dropdown] instead.
///
/// A reusable widget that displays the current theme and allows selection.
/// Shows a list tile with the current theme name and icon.
/// On tap, opens a modal bottom sheet with available themes.
@Deprecated('Use ThemeToggle(mode: ThemeToggleDisplayMode.dropdown) instead')
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ThemeToggle(mode: ThemeToggleDisplayMode.dropdown);
  }
}

/// @deprecated Use [ThemeToggle] with [ThemeToggleDisplayMode.full] instead.
///
/// Segmented button for theme selection.
@Deprecated('Use ThemeToggle(mode: ThemeToggleDisplayMode.full) instead')
class ThemeSegmentedButton extends ConsumerWidget {
  const ThemeSegmentedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ThemeToggle(mode: ThemeToggleDisplayMode.full);
  }
}

/// @deprecated Use [ThemeToggle] with [ThemeToggleDisplayMode.dropdown] instead.
///
/// A simple toggle switch for quickly switching between themes.
@Deprecated('Use ThemeToggle(mode: ThemeToggleDisplayMode.dropdown) instead')
class ThemeToggleSwitch extends ConsumerWidget {
  const ThemeToggleSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isClean = currentTheme == ThemeType.clean;

    return ListTile(
      leading: Container(
        width: AppSpacing.xxxxl,
        height: AppSpacing.xxxxl,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: AppRadius.lgRadius,
        ),
        child: Center(
          child: Icon(
            isClean ? Icons.auto_awesome_outlined : Icons.palette_outlined,
            color: theme.colorScheme.primary,
            size: AppIconSize.md,
          ),
        ),
      ),
      title: Text(
        l10n.theme,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        isClean ? l10n.cleanTheme : l10n.playfulTheme,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: !isClean,
        onChanged: (_) {
          HapticFeedback.selectionClick();
          ref.read(themeNotifierProvider.notifier).toggleTheme();
        },
      ),
    );
  }
}
