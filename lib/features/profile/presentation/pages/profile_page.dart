import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/generated/app_localizations.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/spacing.dart';
import 'package:classio/core/theme/app_radius.dart';
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
        padding: AppSpacing.pageInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Section (if available)
            if (currentUser != null) ...[
              _UserInfoCard(
                email: currentUser.email ?? '',
                isPlayful: isPlayful,
              ),
              SizedBox(height: AppSpacing.xl),
            ],

            // Appearance Section
            _SectionHeader(
              title: 'Appearance',
              icon: Icons.palette_outlined,
            ),
            SizedBox(height: AppSpacing.xs),
            _SettingsCard(
              children: [
                const ThemeSelector(),
              ],
            ),
            SizedBox(height: AppSpacing.xl),

            // Language Section
            _SectionHeader(
              title: l10n.language,
              icon: Icons.translate_rounded,
            ),
            SizedBox(height: AppSpacing.xs),
            _SettingsCard(
              children: [
                const LanguageSelector(),
              ],
            ),
            SizedBox(height: AppSpacing.xxl),

            // Logout Button
            _LogoutButton(
              onLogout: () async {
                final confirmed = await _showLogoutConfirmation(context, l10n);
                if (confirmed == true) {
                  await ref.read(authNotifierProvider.notifier).signOut();
                }
              },
            ),
            SizedBox(height: AppSpacing.xxl),
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
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: AppIconSize.xxl + AppSpacing.md,
            height: AppIconSize.xxl + AppSpacing.md,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: isPlayful ? AppSpacing.xl : 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
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
                SizedBox(height: AppSpacing.xxs),
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
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppIconSize.sm,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: AppSpacing.xs),
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
        borderRadius: AppRadius.largeBorderRadius,
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
        borderRadius: AppRadius.largeBorderRadius,
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
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mediumBorderRadius,
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
