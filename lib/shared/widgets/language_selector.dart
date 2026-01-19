import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

// =============================================================================
// LANGUAGE SELECTOR WIDGET
// =============================================================================
// A premium, reusable language selector component with multiple display modes.
//
// Features:
// - Compact mode: Flag + language code (for app bars, tight spaces)
// - Full mode: Flag + language name (for settings pages)
// - Dropdown button style: Material dropdown appearance
// - Menu popup style: Opens as a popup menu
// - Smooth animations and hover/focus states
// - Uses the new design system tokens throughout
// =============================================================================

/// Display mode for the language selector.
enum LanguageSelectorMode {
  /// Just flag and language code (e.g., "EN")
  compact,

  /// Flag and full language name
  full,

  /// Styled as a dropdown button
  dropdown,

  /// Opens a popup menu instead of bottom sheet
  popup,
}

/// Model class representing a language option with its properties.
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

/// List of all supported languages with their properties.
const List<LanguageOption> availableLanguages = [
  LanguageOption(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flag: 'GB',
  ),
  LanguageOption(
    code: 'cs',
    name: 'Czech',
    nativeName: 'Cestina',
    flag: 'CZ',
  ),
  LanguageOption(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: 'DE',
  ),
  LanguageOption(
    code: 'fr',
    name: 'French',
    nativeName: 'Francais',
    flag: 'FR',
  ),
  LanguageOption(
    code: 'ru',
    name: 'Russian',
    nativeName: 'Russkij',
    flag: 'RU',
  ),
  LanguageOption(
    code: 'pl',
    name: 'Polish',
    nativeName: 'Polski',
    flag: 'PL',
  ),
  LanguageOption(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Espanol',
    flag: 'ES',
  ),
  LanguageOption(
    code: 'it',
    name: 'Italian',
    nativeName: 'Italiano',
    flag: 'IT',
  ),
];

/// Returns the [LanguageOption] for a given language code.
LanguageOption getLanguageOption(String code) {
  return availableLanguages.firstWhere(
    (lang) => lang.code == code,
    orElse: () => availableLanguages.first,
  );
}

// =============================================================================
// MAIN LANGUAGE SELECTOR (LIST TILE STYLE)
// =============================================================================

/// A premium language selector widget that displays the current language
/// and allows selection through a modal bottom sheet.
///
/// This is the primary variant used in settings pages.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPlayful = theme.brightness == Brightness.light &&
        theme.colorScheme.primary == PlayfulColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLanguageBottomSheet(context, ref),
        borderRadius: AppRadius.lgRadius,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          padding: AppSpacing.listItemInsets,
          decoration: BoxDecoration(
            borderRadius: AppRadius.lgRadius,
          ),
          child: Row(
            children: [
              // Flag container with premium styling
              _FlagContainer(
                flagCode: currentLanguage.flag,
                size: AppSpacing.xxxxl,
                isPlayful: isPlayful,
              ),
              SizedBox(width: AppSpacing.md),
              // Language info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.language,
                      style: AppTypography.listTileTitle(isPlayful: isPlayful),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      currentLanguage.nativeName,
                      style: AppTypography.listTileSubtitle(isPlayful: isPlayful),
                    ),
                  ],
                ),
              ),
              // Chevron icon
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: AppIconSize.md,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectionSheet(
        title: l10n.selectLanguage,
        onLanguageSelected: (languageCode) {
          ref.read(localeNotifierProvider.notifier).setLocaleByCode(languageCode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// =============================================================================
// COMPACT LANGUAGE SELECTOR
// =============================================================================

/// Compact language selector button for use in app bars or small spaces.
///
/// Shows just the flag and language code (e.g., "EN").
class CompactLanguageSelector extends ConsumerStatefulWidget {
  /// Whether to show the language code text
  final bool showCode;

  /// Custom size for the flag
  final double? flagSize;

  const CompactLanguageSelector({
    super.key,
    this.showCode = true,
    this.flagSize,
  });

  @override
  ConsumerState<CompactLanguageSelector> createState() =>
      _CompactLanguageSelectorState();
}

class _CompactLanguageSelectorState extends ConsumerState<CompactLanguageSelector>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
    final theme = Theme.of(context);
    final isPlayful = theme.brightness == Brightness.light &&
        theme.colorScheme.primary == PlayfulColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _showLanguageBottomSheet(context, ref),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.08),
            borderRadius: AppRadius.mdRadius,
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FlagContainer(
                flagCode: currentLanguage.flag,
                size: widget.flagSize ?? 20,
                isPlayful: isPlayful,
                compact: true,
              ),
              if (widget.showCode) ...[
                SizedBox(width: AppSpacing.xs),
                AnimatedDefaultTextStyle(
                  duration: AppDuration.fast,
                  style: AppTypography.buttonTextSmall(isPlayful: isPlayful).copyWith(
                    color: _isHovered
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text(currentLanguage.code.toUpperCase()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectionSheet(
        title: l10n.selectLanguage,
        onLanguageSelected: (languageCode) {
          ref.read(localeNotifierProvider.notifier).setLocaleByCode(languageCode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// =============================================================================
// DROPDOWN LANGUAGE SELECTOR
// =============================================================================

/// Language selector styled as a dropdown button.
///
/// Shows the current language with a dropdown icon.
class DropdownLanguageSelector extends ConsumerStatefulWidget {
  /// Whether to show the full language name or just the code
  final bool showFullName;

  /// Whether to show the flag
  final bool showFlag;

  const DropdownLanguageSelector({
    super.key,
    this.showFullName = true,
    this.showFlag = true,
  });

  @override
  ConsumerState<DropdownLanguageSelector> createState() =>
      _DropdownLanguageSelectorState();
}

class _DropdownLanguageSelectorState extends ConsumerState<DropdownLanguageSelector> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
    final theme = Theme.of(context);
    final isPlayful = theme.brightness == Brightness.light &&
        theme.colorScheme.primary == PlayfulColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () => _showLanguageBottomSheet(context, ref),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: _isPressed
                ? theme.colorScheme.surfaceContainerHighest
                : _isHovered
                    ? theme.colorScheme.surfaceContainerHigh
                    : theme.colorScheme.surfaceContainerLow,
            borderRadius: AppRadius.button(isPlayful: isPlayful),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.outline
                  : theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showFlag) ...[
                _FlagContainer(
                  flagCode: currentLanguage.flag,
                  size: 24,
                  isPlayful: isPlayful,
                ),
                SizedBox(width: AppSpacing.sm),
              ],
              Text(
                widget.showFullName
                    ? currentLanguage.nativeName
                    : currentLanguage.code.toUpperCase(),
                style: AppTypography.buttonTextMedium(isPlayful: isPlayful).copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              AnimatedRotation(
                duration: AppDuration.fast,
                turns: 0,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: AppIconSize.sm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectionSheet(
        title: l10n.selectLanguage,
        onLanguageSelected: (languageCode) {
          ref.read(localeNotifierProvider.notifier).setLocaleByCode(languageCode);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// =============================================================================
// POPUP LANGUAGE SELECTOR
// =============================================================================

/// Language selector that opens a popup menu instead of a bottom sheet.
///
/// Ideal for desktop and web where popup menus feel more native.
class PopupLanguageSelector extends ConsumerStatefulWidget {
  /// Whether to show the full language name or just the code
  final bool showFullName;

  /// Whether to show the flag
  final bool showFlag;

  const PopupLanguageSelector({
    super.key,
    this.showFullName = false,
    this.showFlag = true,
  });

  @override
  ConsumerState<PopupLanguageSelector> createState() =>
      _PopupLanguageSelectorState();
}

class _PopupLanguageSelectorState extends ConsumerState<PopupLanguageSelector> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
    final theme = Theme.of(context);
    final isPlayful = theme.brightness == Brightness.light &&
        theme.colorScheme.primary == PlayfulColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: PopupMenuButton<String>(
        tooltip: 'Select language',
        offset: const Offset(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.popupMenu(isPlayful: isPlayful),
        ),
        color: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        elevation: AppElevation.lg,
        onSelected: (languageCode) {
          ref.read(localeNotifierProvider.notifier).setLocaleByCode(languageCode);
        },
        itemBuilder: (context) => availableLanguages.map((language) {
          final isSelected = currentLocale.languageCode == language.code;
          return PopupMenuItem<String>(
            value: language.code,
            child: _PopupLanguageItem(
              language: language,
              isSelected: isSelected,
              isPlayful: isPlayful,
            ),
          );
        }).toList(),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.mdRadius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showFlag) ...[
                _FlagContainer(
                  flagCode: currentLanguage.flag,
                  size: 22,
                  isPlayful: isPlayful,
                  compact: true,
                ),
                if (widget.showFullName) SizedBox(width: AppSpacing.xs),
              ],
              if (widget.showFullName)
                Text(
                  currentLanguage.nativeName,
                  style: AppTypography.buttonTextSmall(isPlayful: isPlayful).copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                )
              else
                Text(
                  currentLanguage.code.toUpperCase(),
                  style: AppTypography.buttonTextSmall(isPlayful: isPlayful).copyWith(
                    color: _isHovered
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.expand_more_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: AppIconSize.sm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item displayed in the popup menu.
class _PopupLanguageItem extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final bool isPlayful;

  const _PopupLanguageItem({
    required this.language,
    required this.isSelected,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _FlagContainer(
          flagCode: language.flag,
          size: 24,
          isPlayful: isPlayful,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                language.nativeName,
                style: AppTypography.buttonTextMedium(isPlayful: isPlayful).copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              Text(
                language.name,
                style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Icon(
            Icons.check_rounded,
            color: theme.colorScheme.primary,
            size: AppIconSize.sm,
          ),
      ],
    );
  }
}

// =============================================================================
// LANGUAGE SELECTION BOTTOM SHEET
// =============================================================================

/// Bottom sheet widget for selecting a language.
///
/// Displays all available languages in a scrollable list with
/// premium styling and smooth animations.
class LanguageSelectionSheet extends ConsumerWidget {
  final String title;
  final void Function(String languageCode) onLanguageSelected;

  const LanguageSelectionSheet({
    super.key,
    required this.title,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final theme = Theme.of(context);
    final isPlayful = theme.brightness == Brightness.light &&
        theme.colorScheme.primary == PlayfulColors.primary;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppRadius.bottomSheet(),
            boxShadow: [
              BoxShadow(
                color: (isPlayful ? PlayfulColors.shadow : CleanColors.shadow)
                    .withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              _SheetHandle(isPlayful: isPlayful),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Text(
                  title,
                  style: AppTypography.sectionTitle(isPlayful: isPlayful),
                  textAlign: TextAlign.center,
                ),
              ),
              // Divider
              Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              // Language list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = availableLanguages[index];
                    final isSelected = currentLocale.languageCode == language.code;

                    return _LanguageListTile(
                      language: language,
                      isSelected: isSelected,
                      isPlayful: isPlayful,
                      onTap: () => onLanguageSelected(language.code),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Handle bar at the top of the bottom sheet.
class _SheetHandle extends StatelessWidget {
  final bool isPlayful;

  const _SheetHandle({required this.isPlayful});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: EdgeInsets.only(top: AppSpacing.sm),
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
          borderRadius: AppRadius.fullRadius,
        ),
      ),
    );
  }
}

// =============================================================================
// LANGUAGE LIST TILE
// =============================================================================

/// Individual language list tile with selection indicator and hover states.
class _LanguageListTile extends StatefulWidget {
  final LanguageOption language;
  final bool isSelected;
  final bool isPlayful;
  final VoidCallback onTap;

  const _LanguageListTile({
    required this.language,
    required this.isSelected,
    required this.isPlayful,
    required this.onTap,
  });

  @override
  State<_LanguageListTile> createState() => _LanguageListTileState();
}

class _LanguageListTileState extends State<_LanguageListTile>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xxs,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: AppCurves.standard,
            padding: AppSpacing.listItemInsets,
            decoration: BoxDecoration(
              color: _getBackgroundColor(theme),
              borderRadius: AppRadius.lgRadius,
              border: widget.isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Flag with premium container
                _FlagContainer(
                  flagCode: widget.language.flag,
                  size: AppSpacing.xxxxl,
                  isPlayful: widget.isPlayful,
                  isSelected: widget.isSelected,
                ),
                SizedBox(width: AppSpacing.md),
                // Language names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: AppDuration.fast,
                        style: AppTypography.listTileTitle(isPlayful: widget.isPlayful)
                            .copyWith(
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: widget.isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                        child: Text(widget.language.nativeName),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        widget.language.name,
                        style: AppTypography.caption(isPlayful: widget.isPlayful).copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Selection indicator with animation
                AnimatedScale(
                  duration: AppDuration.fast,
                  curve: AppCurves.decelerate,
                  scale: widget.isSelected ? 1.0 : 0.0,
                  child: Container(
                    width: AppSpacing.xl,
                    height: AppSpacing.xl,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (_isPressed) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.2);
    }
    if (widget.isSelected) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.15);
    }
    if (_isHovered) {
      return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);
    }
    return Colors.transparent;
  }
}

// =============================================================================
// FLAG CONTAINER WIDGET
// =============================================================================

/// Premium flag display container with consistent styling.
///
/// Displays a country code as a styled badge with proper sizing
/// and theme-aware styling.
class _FlagContainer extends StatelessWidget {
  final String flagCode;
  final double size;
  final bool isPlayful;
  final bool compact;
  final bool isSelected;

  const _FlagContainer({
    required this.flagCode,
    required this.size,
    required this.isPlayful,
    this.compact = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate font size based on container size
    final fontSize = compact ? size * 0.55 : size * 0.45;

    return AnimatedContainer(
      duration: AppDuration.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: compact
            ? AppRadius.xsRadius
            : AppRadius.mdRadius,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          flagCode,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ADAPTIVE LANGUAGE SELECTOR
// =============================================================================

/// Adaptive language selector that automatically chooses the best display mode
/// based on the platform and available space.
///
/// - On mobile: Shows compact selector that opens a bottom sheet
/// - On desktop/web: Shows dropdown or popup menu style
class AdaptiveLanguageSelector extends ConsumerWidget {
  /// Force a specific mode instead of auto-detecting
  final LanguageSelectorMode? mode;

  const AdaptiveLanguageSelector({
    super.key,
    this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveMode = mode ?? _detectMode(context);

    switch (effectiveMode) {
      case LanguageSelectorMode.compact:
        return const CompactLanguageSelector();
      case LanguageSelectorMode.full:
        return const LanguageSelector();
      case LanguageSelectorMode.dropdown:
        return const DropdownLanguageSelector();
      case LanguageSelectorMode.popup:
        return const PopupLanguageSelector();
    }
  }

  LanguageSelectorMode _detectMode(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final platform = Theme.of(context).platform;

    // Desktop platforms prefer popup style
    if (platform == TargetPlatform.macOS ||
        platform == TargetPlatform.windows ||
        platform == TargetPlatform.linux) {
      return LanguageSelectorMode.popup;
    }

    // Large screens on mobile platforms use dropdown
    if (width > 600) {
      return LanguageSelectorMode.dropdown;
    }

    // Default to compact for mobile
    return LanguageSelectorMode.compact;
  }
}
