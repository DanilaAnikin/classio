import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../shared/widgets/language_selector.dart';
import '../settings/settings_screen.dart';

/// Dashboard/Home screen - the main landing page of the app.
///
/// Features:
/// - Welcome message in the selected language
/// - Current theme and language info display
/// - Sample cards demonstrating the theme
/// - Navigation to Settings
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar.large(
            title: Text(l10n.appName),
            centerTitle: true,
            floating: true,
            pinned: true,
            actions: [
              // Language indicator button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _LanguageIndicator(
                  flag: currentLanguage.flag,
                  onTap: () => _navigateToSettings(context),
                ),
              ),
              // Settings button
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _navigateToSettings(context),
                tooltip: l10n.settings,
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Dashboard Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Card
                _WelcomeCard(
                  welcomeMessage: l10n.welcomeMessage,
                  currentTheme: currentTheme,
                  l10n: l10n,
                ),
                const SizedBox(height: 24),

                // Quick Stats Section
                _SectionTitle(title: 'Quick Overview'),
                const SizedBox(height: 12),
                _QuickStatsRow(),
                const SizedBox(height: 24),

                // Feature Cards Section
                _SectionTitle(title: 'Features'),
                const SizedBox(height: 12),
                _FeatureCardsGrid(currentTheme: currentTheme),
                const SizedBox(height: 24),

                // Current Settings Card
                _SectionTitle(title: 'Your Settings'),
                const SizedBox(height: 12),
                _SettingsPreviewCard(
                  currentTheme: currentTheme,
                  currentLanguage: currentLanguage,
                  l10n: l10n,
                  onSettingsTap: () => _navigateToSettings(context),
                ),
                const SizedBox(height: 24),

                // Action Buttons Demo
                _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickActionsCard(
                  onSettingsTap: () => _navigateToSettings(context),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToSettings(context),
        icon: const Icon(Icons.tune_rounded),
        label: Text(l10n.settings),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}

/// Language indicator button showing the current flag.
class _LanguageIndicator extends StatelessWidget {
  final String flag;
  final VoidCallback onTap;

  const _LanguageIndicator({
    required this.flag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            flag,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

/// Section title widget.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }
}

/// Welcome card with greeting and theme info.
class _WelcomeCard extends StatelessWidget {
  final String welcomeMessage;
  final ThemeType currentTheme;
  final AppLocalizations l10n;

  const _WelcomeCard({
    required this.welcomeMessage,
    required this.currentTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = currentTheme == ThemeType.playful;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPlayful
              ? [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  theme.colorScheme.secondary.withValues(alpha: 0.6),
                ]
              : [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.85),
                ],
        ),
        borderRadius: BorderRadius.circular(isPlayful ? 24 : 16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPlayful ? Icons.waving_hand_rounded : Icons.school_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          // Welcome message
          Text(
            welcomeMessage,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            'Your learning journey starts here',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 20),
          // Theme badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPlayful ? Icons.palette_outlined : Icons.auto_awesome_outlined,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${l10n.theme}: ${isPlayful ? l10n.playfulTheme : l10n.cleanTheme}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick stats row showing sample metrics.
class _QuickStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.book_outlined,
            value: '12',
            label: 'Courses',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            value: '48',
            label: 'Completed',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: '24h',
            label: 'Study Time',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }
}

/// Individual stat card.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Grid of feature cards.
class _FeatureCardsGrid extends StatelessWidget {
  final ThemeType currentTheme;

  const _FeatureCardsGrid({required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    final isPlayful = currentTheme == ThemeType.playful;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.quiz_outlined,
                title: 'Quizzes',
                subtitle: 'Test your knowledge',
                color: isPlayful ? const Color(0xFF7C3AED) : const Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.library_books_outlined,
                title: 'Library',
                subtitle: 'Browse materials',
                color: isPlayful ? const Color(0xFFF97316) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.people_outline,
                title: 'Community',
                subtitle: 'Connect with peers',
                color: isPlayful ? const Color(0xFF22C55E) : const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.analytics_outlined,
                title: 'Progress',
                subtitle: 'Track your growth',
                color: isPlayful ? const Color(0xFFEC4899) : const Color(0xFF0284C7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual feature card.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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

/// Settings preview card with current configuration.
class _SettingsPreviewCard extends StatelessWidget {
  final ThemeType currentTheme;
  final LanguageOption currentLanguage;
  final AppLocalizations l10n;
  final VoidCallback onSettingsTap;

  const _SettingsPreviewCard({
    required this.currentTheme,
    required this.currentLanguage,
    required this.l10n,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = currentTheme == ThemeType.playful;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSettingsTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
          child: Row(
            children: [
              // Theme indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPlayful
                        ? [const Color(0xFF7C3AED), const Color(0xFFF97316)]
                        : [const Color(0xFF1E3A5F), const Color(0xFF64748B)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPlayful ? Icons.palette_rounded : Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Settings info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentLanguage.flag,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentLanguage.nativeName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.theme}: ${isPlayful ? l10n.playfulTheme : l10n.cleanTheme}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick actions card with buttons.
class _QuickActionsCard extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _QuickActionsCard({
    required this.onSettingsTap,
  });

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Learning'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSettingsTap,
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Customize'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.help_outline_rounded),
                  label: const Text('Help'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
