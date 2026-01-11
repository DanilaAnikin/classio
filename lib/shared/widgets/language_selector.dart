import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';

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
    flag: '🇬🇧',
  ),
  LanguageOption(
    code: 'cs',
    name: 'Czech',
    nativeName: 'Čeština',
    flag: '🇨🇿',
  ),
  LanguageOption(
    code: 'de',
    name: 'German',
    nativeName: 'Deutsch',
    flag: '🇩🇪',
  ),
  LanguageOption(
    code: 'fr',
    name: 'French',
    nativeName: 'Français',
    flag: '🇫🇷',
  ),
  LanguageOption(
    code: 'ru',
    name: 'Russian',
    nativeName: 'Русский',
    flag: '🇷🇺',
  ),
  LanguageOption(
    code: 'pl',
    name: 'Polish',
    nativeName: 'Polski',
    flag: '🇵🇱',
  ),
  LanguageOption(
    code: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
  ),
  LanguageOption(
    code: 'it',
    name: 'Italian',
    nativeName: 'Italiano',
    flag: '🇮🇹',
  ),
];

/// Returns the [LanguageOption] for a given language code.
LanguageOption getLanguageOption(String code) {
  return availableLanguages.firstWhere(
    (lang) => lang.code == code,
    orElse: () => availableLanguages.first,
  );
}

/// A reusable widget that displays the current language and allows selection.
///
/// Shows a list tile with the current language flag and name.
/// On tap, opens a modal bottom sheet with all available languages.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
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
          child: Text(
            currentLanguage.flag,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      title: Text(
        l10n.language,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        currentLanguage.nativeName,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: () => _showLanguageBottomSheet(context, ref),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

/// Bottom sheet widget for selecting a language.
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

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
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
              // Language list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: availableLanguages.length,
                  itemBuilder: (context, index) {
                    final language = availableLanguages[index];
                    final isSelected = currentLocale.languageCode == language.code;

                    return _LanguageListTile(
                      language: language,
                      isSelected: isSelected,
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

/// Individual language list tile with selection indicator.
class _LanguageListTile extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageListTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Flag
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Language names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.nativeName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Check mark
                if (isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact language selector button for use in app bars or small spaces.
class CompactLanguageSelector extends ConsumerWidget {
  const CompactLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLanguageBottomSheet(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguage.flag,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                currentLanguage.code.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
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
