import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/language_selector.dart';
import '../../shared/widgets/theme_toggle.dart';
import '../../shared/widgets/responsive_center.dart';

/// Settings screen that allows users to customize app preferences.
///
/// Features:
/// - Language selection with flag icons
/// - Theme selection (Clean/Playful)
/// - Beautiful, themed UI following the app's design system
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeNotifierProvider);

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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Appearance Section
                  _SectionHeader(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      const ThemeSelector(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Language Section
                  _SectionHeader(
                    title: l10n.language,
                    icon: Icons.translate_rounded,
                  ),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    children: [
                      const LanguageSelector(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Current Settings Info Card
                  _CurrentSettingsCard(
                    currentTheme: currentTheme,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 24),

                  // Theme Preview Section
                  _SectionHeader(
                    title: 'Theme Preview',
                    icon: Icons.preview_outlined,
                  ),
                  const SizedBox(height: 8),
                  _ThemePreviewCard(),
                  const SizedBox(height: 32),
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

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card wrapper for settings items.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

/// Card showing the current settings configuration.
class _CurrentSettingsCard extends StatelessWidget {
  final ThemeType currentTheme;
  final AppLocalizations l10n;

  const _CurrentSettingsCard({
    required this.currentTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Current Configuration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: l10n.theme,
            value: currentTheme == ThemeType.clean ? l10n.cleanTheme : l10n.playfulTheme,
            icon: currentTheme == ThemeType.clean
                ? Icons.auto_awesome_outlined
                : Icons.palette_outlined,
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final currentLocale = ref.watch(localeNotifierProvider);
              final currentLanguage = getLanguageOption(currentLocale.languageCode);
              return _InfoRow(
                label: l10n.language,
                value: '${currentLanguage.flag} ${currentLanguage.nativeName}',
                icon: Icons.translate_rounded,
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

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card showing a preview of theme elements.
class _ThemePreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UI Elements',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Buttons row
          Wrap(
            spacing: 12,
            runSpacing: 12,
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
          const SizedBox(height: 20),
          // Color chips
          Text(
            'Colors',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ColorChip(
                color: theme.colorScheme.primary,
                label: 'Primary',
              ),
              _ColorChip(
                color: theme.colorScheme.secondary,
                label: 'Secondary',
              ),
              _ColorChip(
                color: theme.colorScheme.tertiary,
                label: 'Tertiary',
              ),
              _ColorChip(
                color: theme.colorScheme.error,
                label: 'Error',
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Sample chips
          Text(
            'Chips',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.star_rounded, size: 18),
                label: const Text('Featured'),
              ),
              InputChip(
                label: const Text('Selectable'),
                selected: true,
                onSelected: (_) {},
              ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Action'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress indicators
          Text(
            'Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.7,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 3,
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

  const _ColorChip({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
