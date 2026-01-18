import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/generated/app_localizations.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/shared/widgets/theme_toggle.dart';
import 'package:classio/shared/widgets/language_selector.dart';
import 'package:classio/shared/widgets/responsive_center.dart';

/// Profile page for managing user settings and preferences.
///
/// Features:
/// - Theme switcher (Clean Mode / Playful Mode)
/// - Language selector
/// - Logout button
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ResponsiveCenterScrollView(
        maxWidth: 800,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Section (if available)
            if (currentUser != null) ...[
              _UserInfoCard(
                email: currentUser.email ?? '',
                isPlayful: isPlayful,
              ),
              const SizedBox(height: 24),
            ],

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
            const SizedBox(height: 32),

            // Logout Button
            _LogoutButton(
              onLogout: () async {
                final confirmed = await _showLogoutConfirmation(context, l10n);
                if (confirmed == true) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmation(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

/// Card displaying user information.
class _UserInfoCard extends StatelessWidget {
  final String email;
  final bool isPlayful;

  const _UserInfoCard({
    required this.email,
    required this.isPlayful,
  });

  String _getDisplayName(String email) {
    final name = email.split('@').first;
    return name.isNotEmpty
        ? '${name[0].toUpperCase()}${name.substring(1)}'
        : 'User';
  }

  String _getInitials(String email) {
    final name = email.split('@').first;
    if (name.isEmpty) return 'U';
    if (name.length == 1) return name.toUpperCase();
    return '${name[0].toUpperCase()}${name[1].toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = _getDisplayName(email);
    final initials = _getInitials(email);

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
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: isPlayful ? 24 : 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

/// Logout button with destructive styling.
class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.error,
          side: BorderSide(
            color: theme.colorScheme.error.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: Text(
          l10n.logout,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
