import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

/// Settings screen that allows users to customize app preferences.
///
/// Features:
/// - Language selection with flag icons
/// - Theme selection (Clean/Playful)
/// - Premium design using the new design system
/// - Fully theme-aware (Clean vs Playful)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Detects if the current theme is Playful
  bool _isPlayfulTheme(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeNotifierProvider);
    final isPlayful = _isPlayfulTheme(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar.large(
            title: Text(l10n.settings),
            centerTitle: true,
            floating: true,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          // Settings Content
          SliverToBoxAdapter(
            child: ResponsiveCenter(
              maxWidth: 800,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal(context),
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Appearance Section
                  _SectionHeader(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                    isPlayful: isPlayful,
                  ),
                  AppSpacing.gapXs,
                  AppCard.outlined(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: const ThemeToggle(
                      mode: ThemeToggleDisplayMode.dropdown,
                    ),
                  ),
                  AppSpacing.gapXl,

                  // Language Section
                  _SectionHeader(
                    title: l10n.language,
                    icon: Icons.translate_rounded,
                    isPlayful: isPlayful,
                  ),
                  AppSpacing.gapXs,
                  AppCard.outlined(
                    padding: AppSpacing.insetsNone,
                    child: const LanguageSelector(),
                  ),
                  AppSpacing.gapXl,

                  // Current Settings Info Card
                  _CurrentSettingsCard(
                    currentTheme: currentTheme,
                    l10n: l10n,
                    isPlayful: isPlayful,
                  ),
                  AppSpacing.gapXl,

                  // Theme Preview Section
                  _SectionHeader(
                    title: 'Theme Preview',
                    icon: Icons.preview_outlined,
                    isPlayful: isPlayful,
                  ),
                  AppSpacing.gapXs,
                  _ThemePreviewCard(isPlayful: isPlayful),
                  AppSpacing.gapXxl,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with icon and title.
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isPlayful;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppIconSize.sm,
            color: primaryColor,
          ),
          AppSpacing.gapH8,
          Text(
            title,
            style: AppTypography.overline(isPlayful: isPlayful).copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: AppLetterSpacing.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card showing the current settings configuration.
class _CurrentSettingsCard extends StatelessWidget {
  final ThemeType currentTheme;
  final AppLocalizations l10n;
  final bool isPlayful;

  const _CurrentSettingsCard({
    required this.currentTheme,
    required this.l10n,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final primaryContainer =
        isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle;

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryContainer.withValues(alpha: AppOpacity.heavy),
            primaryContainer.withValues(alpha: AppOpacity.soft),
          ],
        ),
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        border: Border.all(
          color: primaryColor.withValues(alpha: AppOpacity.soft),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.insets8,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: AppOpacity.soft),
                  borderRadius: AppRadius.button(isPlayful: isPlayful),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: primaryColor,
                  size: AppIconSize.md,
                ),
              ),
              AppSpacing.gapH12,
              Expanded(
                child: Text(
                  'Current Configuration',
                  style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          _InfoRow(
            label: l10n.theme,
            value: currentTheme == ThemeType.clean
                ? l10n.cleanTheme
                : l10n.playfulTheme,
            icon: currentTheme == ThemeType.clean
                ? Icons.auto_awesome_outlined
                : Icons.palette_outlined,
            isPlayful: isPlayful,
          ),
          AppSpacing.gapXs,
          Consumer(
            builder: (context, ref, _) {
              final currentLocale = ref.watch(localeNotifierProvider);
              final currentLanguage =
                  getLanguageOption(currentLocale.languageCode);
              return _InfoRow(
                label: l10n.language,
                value: '${currentLanguage.flag} ${currentLanguage.nativeName}',
                icon: Icons.translate_rounded,
                isPlayful: isPlayful,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Row displaying a label-value pair with an icon.
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPlayful;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.sm,
          color: textSecondary,
        ),
        AppSpacing.gapH8,
        Text(
          '$label: ',
          style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
            color: textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.primaryText(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card showing a preview of theme elements.
class _ThemePreviewCard extends StatelessWidget {
  final bool isPlayful;

  const _ThemePreviewCard({required this.isPlayful});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UI Elements',
            style: AppTypography.cardTitle(isPlayful: isPlayful),
          ),
          AppSpacing.gapMd,

          // Buttons row
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Text'),
              ),
            ],
          ),
          AppSpacing.gapLg,

          // Color chips section
          Text(
            'Colors',
            style: AppTypography.listTileTitle(isPlayful: isPlayful),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _ColorChip(
                color: theme.colorScheme.primary,
                label: 'Primary',
                isPlayful: isPlayful,
              ),
              _ColorChip(
                color: theme.colorScheme.secondary,
                label: 'Secondary',
                isPlayful: isPlayful,
              ),
              _ColorChip(
                color: theme.colorScheme.tertiary,
                label: 'Tertiary',
                isPlayful: isPlayful,
              ),
              _ColorChip(
                color: theme.colorScheme.error,
                label: 'Error',
                isPlayful: isPlayful,
              ),
            ],
          ),
          AppSpacing.gapLg,

          // Sample chips section
          Text(
            'Chips',
            style: AppTypography.listTileTitle(isPlayful: isPlayful),
          ),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Chip(
                avatar: Icon(Icons.star_rounded, size: AppIconSize.sm),
                label: const Text('Featured'),
              ),
              InputChip(
                label: const Text('Selectable'),
                selected: true,
                onSelected: (_) {},
              ),
              ActionChip(
                avatar: Icon(Icons.add, size: AppIconSize.sm),
                label: const Text('Action'),
                onPressed: () {},
              ),
            ],
          ),
          AppSpacing.gapLg,

          // Progress indicators section
          Text(
            'Progress',
            style: AppTypography.listTileTitle(isPlayful: isPlayful),
          ),
          AppSpacing.gapSm,
          LinearProgressIndicator(
            value: 0.7,
            borderRadius: AppRadius.xsRadius,
          ),
          AppSpacing.gapSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: AppIconSize.xl,
                height: AppIconSize.xl,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: AppSpacing.space2 + 1, // 3px stroke
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small color preview chip.
class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool isPlayful;

  const _ColorChip({
    required this.color,
    required this.label,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isPlayful
        ? PlayfulColors.surfaceSubtle
        : CleanColors.surfaceSubtle;
    final borderColor =
        isPlayful ? PlayfulColors.border : CleanColors.border;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: AppOpacity.heavy),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppIconSize.xs,
            height: AppIconSize.xs,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor.withValues(alpha: AppOpacity.medium),
              ),
            ),
          ),
          AppSpacing.gapH8,
          Text(
            label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
