import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/features/admin_panel/domain/entities/invite_code.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../providers/principal_providers.dart';

/// Invite Management Tab for Principal Dashboard.
///
/// Displays and manages all invite codes for the school.
class InviteManagementTab extends ConsumerWidget {
  const InviteManagementTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final invitesAsync = ref.watch(principalInviteCodesProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(principalInviteCodesProvider(schoolId));
      },
      child: invitesAsync.when(
        data: (invites) {
          if (invites.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Separate active and inactive invites
          final activeInvites = invites.where((i) => i.canBeUsed).toList();
          final inactiveInvites = invites.where((i) => !i.canBeUsed).toList();

          return ResponsiveCenterScrollView(
            maxWidth: 1000,
            padding: EdgeInsets.all(isPlayful ? 20 : 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Invite Stats Card
                _InviteStatsCard(
                  totalInvites: invites.length,
                  activeCount: activeInvites.length,
                  usedCount: inactiveInvites.length,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Active Invites Section
                if (activeInvites.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Active Invites',
                    icon: Icons.vpn_key_outlined,
                    count: activeInvites.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...activeInvites.map((invite) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: _InviteCodeCard(
                          invite: invite,
                          isPlayful: isPlayful,
                          onCopy: () => _copyToClipboard(context, invite.code),
                          onDeactivate: () =>
                              _confirmDeactivate(context, ref, invite),
                        ),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Inactive Invites Section
                if (inactiveInvites.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Inactive Invites',
                    icon: Icons.vpn_key_off_outlined,
                    count: inactiveInvites.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...inactiveInvites.map((invite) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: Opacity(
                          opacity: 0.6,
                          child: _InviteCodeCard(
                            invite: invite,
                            isPlayful: isPlayful,
                            onCopy: null,
                            onDeactivate: null,
                          ),
                        ),
                      )),
                ],

                SizedBox(height: isPlayful ? 80 : 72), // Space for FAB
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isPlayful ? 24 : 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.vpn_key_outlined,
                  size: isPlayful ? 56 : 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Invite Codes Yet',
                style: TextStyle(
                  fontSize: isPlayful ? 22 : 20,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate invite codes to add new users to your school.',
                style: TextStyle(
                  fontSize: isPlayful ? 15 : 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(principalInviteCodesProvider(schoolId));
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    WidgetRef ref,
    InviteCode invite,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Invite Code'),
        content: Text(
          'Are you sure you want to deactivate the invite code "${invite.code}"? '
          'This code will no longer be usable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(principalNotifierProvider.notifier)
          .deactivateInviteCode(invite.id, schoolId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Invite code has been deactivated.'
                  : 'Failed to deactivate invite code.',
            ),
            backgroundColor: success ? null : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Invite stats card
class _InviteStatsCard extends StatelessWidget {
  const _InviteStatsCard({
    required this.totalInvites,
    required this.activeCount,
    required this.usedCount,
    required this.isPlayful,
  });

  final int totalInvites;
  final int activeCount;
  final int usedCount;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.vpn_key_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Invites',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalInvites.toString(),
                  style: TextStyle(
                    fontSize: isPlayful ? 28 : 24,
                    fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatBadge(
                label: 'Active',
                count: activeCount,
                color: Colors.green,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              _StatBadge(
                label: 'Inactive',
                count: usedCount,
                color: Colors.grey,
                isPlayful: isPlayful,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small stat badge
class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final int count;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count ',
          style: TextStyle(
            fontSize: isPlayful ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 12 : 11,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.isPlayful,
  });

  final String title;
  final IconData icon;
  final int count;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: isPlayful ? 22 : 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.3 : -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 10 : 8,
            vertical: isPlayful ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Invite code card widget
class _InviteCodeCard extends StatelessWidget {
  const _InviteCodeCard({
    required this.invite,
    required this.isPlayful,
    this.onCopy,
    this.onDeactivate,
  });

  final InviteCode invite;
  final bool isPlayful;
  final VoidCallback? onCopy;
  final VoidCallback? onDeactivate;

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return Colors.purple;
      case UserRole.bigadmin:
        return Colors.deepPurple;
      case UserRole.admin:
        return Colors.indigo;
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      case UserRole.parent:
        return Colors.orange;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(invite.role);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? roleColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Code icon
              Container(
                padding: EdgeInsets.all(isPlayful ? 12 : 10),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  size: isPlayful ? 24 : 20,
                  color: roleColor,
                ),
              ),
              SizedBox(width: isPlayful ? 14 : 12),

              // Code and role info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.code,
                      style: TextStyle(
                        fontSize: isPlayful ? 14 : 12,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: isPlayful ? 4 : 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getRoleLabel(invite.role),
                        style: TextStyle(
                          fontSize: isPlayful ? 12 : 11,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              if (onCopy != null || onDeactivate != null) ...[
                if (onCopy != null)
                  IconButton(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded),
                    iconSize: 20,
                    tooltip: 'Copy code',
                  ),
                if (onDeactivate != null)
                  IconButton(
                    onPressed: onDeactivate,
                    icon: const Icon(Icons.block_rounded),
                    iconSize: 20,
                    tooltip: 'Deactivate',
                    color: theme.colorScheme.error,
                  ),
              ],
            ],
          ),
          SizedBox(height: isPlayful ? 12 : 10),

          // Usage and expiry info
          Container(
            padding: EdgeInsets.all(isPlayful ? 12 : 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Usage',
                    value: '${invite.timesUsed}/${invite.usageLimit}',
                    icon: Icons.people_outline,
                    isPlayful: isPlayful,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Expires',
                    value: _formatDate(invite.expiresAt),
                    icon: Icons.access_time_outlined,
                    isPlayful: isPlayful,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Remaining',
                    value: invite.remainingUses.toString(),
                    icon: Icons.inventory_2_outlined,
                    isPlayful: isPlayful,
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

/// Info item widget
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isPlayful,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: isPlayful ? 18 : 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        SizedBox(height: isPlayful ? 4 : 2),
        Text(
          value,
          style: TextStyle(
            fontSize: isPlayful ? 14 : 13,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 11 : 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
