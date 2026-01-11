import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';

/// A reusable widget that displays the current theme and allows selection.
///
/// Shows a list tile with the current theme name and icon.
/// On tap, opens a modal bottom sheet with available themes.
class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            currentTheme == ThemeType.clean
                ? Icons.auto_awesome_outlined
                : Icons.palette_outlined,
            color: theme.colorScheme.primary,
            size: 24,
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
        currentTheme == ThemeType.clean ? l10n.cleanTheme : l10n.playfulTheme,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showThemeBottomSheet(context, ref),
    );
  }

  void _showThemeBottomSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => ThemeSelectionSheet(
        title: l10n.selectTheme,
        onThemeSelected: (themeType) {
          ref.read(themeNotifierProvider.notifier).setTheme(themeType);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Bottom sheet widget for selecting a theme.
class ThemeSelectionSheet extends ConsumerWidget {
  final String title;
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
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Theme options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _ThemeOptionCard(
                    title: l10n.cleanTheme,
                    description: 'Minimalist & professional',
                    icon: Icons.auto_awesome_outlined,
                    isSelected: currentTheme == ThemeType.clean,
                    onTap: () => onThemeSelected(ThemeType.clean),
                    primaryColor: const Color(0xFF1E3A5F),
                    secondaryColor: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ThemeOptionCard(
                    title: l10n.playfulTheme,
                    description: 'Fun & colorful',
                    icon: Icons.palette_outlined,
                    isSelected: currentTheme == ThemeType.playful,
                    onTap: () => onThemeSelected(ThemeType.playful),
                    primaryColor: const Color(0xFF7C3AED),
                    secondaryColor: const Color(0xFFF97316),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Individual theme option card with preview colors.
class _ThemeOptionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color secondaryColor;

  const _ThemeOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme preview circles
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Icon
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              // Description
              Text(
                description,
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

/// A simple toggle switch for quickly switching between themes.
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            isClean ? Icons.auto_awesome_outlined : Icons.palette_outlined,
            color: theme.colorScheme.primary,
            size: 24,
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
          ref.read(themeNotifierProvider.notifier).toggleTheme();
        },
      ),
    );
  }
}

/// Segmented button for theme selection.
class ThemeSegmentedButton extends ConsumerWidget {
  const ThemeSegmentedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final l10n = AppLocalizations.of(context);

    return SegmentedButton<ThemeType>(
      segments: [
        ButtonSegment(
          value: ThemeType.clean,
          label: Text(l10n.cleanTheme),
          icon: const Icon(Icons.auto_awesome_outlined),
        ),
        ButtonSegment(
          value: ThemeType.playful,
          label: Text(l10n.playfulTheme),
          icon: const Icon(Icons.palette_outlined),
        ),
      ],
      selected: {currentTheme},
      onSelectionChanged: (selection) {
        ref.read(themeNotifierProvider.notifier).setTheme(selection.first);
      },
    );
  }
}
