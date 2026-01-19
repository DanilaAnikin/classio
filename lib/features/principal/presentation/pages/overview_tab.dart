import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../providers/principal_providers.dart';
import '../widgets/school_stats_card.dart';
import '../widgets/generate_invite_dialog.dart';
import '../widgets/create_class_dialog.dart';

/// Overview tab showing school statistics and quick actions.
class OverviewTab extends ConsumerWidget {
  /// Creates an [OverviewTab].
  const OverviewTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
    this.onNavigateToTab,
  });

  final String schoolId;
  final bool isPlayful;

  /// Callback to navigate to a specific tab index.
  /// Tab indices: 0 = Overview, 1 = Staff, 2 = Classes, 3 = Invites
  final void Function(int tabIndex)? onNavigateToTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(schoolStatsProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schoolStatsProvider(schoolId));
      },
      child: ResponsiveCenterScrollView(
        maxWidth: 1000,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome header
            _buildWelcomeHeader(context, theme, ref),
            SizedBox(height: isPlayful ? 28 : 24),

            // Stats card
            statsAsync.when(
              data: (stats) => SchoolStatsCard(stats: stats),
              loading: () => Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Container(
                padding: AppSpacing.dialogInsets,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.error, size: 48),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Failed to load statistics',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isPlayful ? 28 : 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: isPlayful ? 16 : 12),
            _buildQuickActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, ThemeData theme, WidgetRef ref) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          'Principal',
          style: TextStyle(
            fontSize: isPlayful ? 32 : 28,
            fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Wrap(
      spacing: isPlayful ? 14 : 12,
      runSpacing: isPlayful ? 14 : 12,
      children: [
        _QuickActionButton(
          icon: Icons.person_add_outlined,
          label: 'Invite Staff',
          color: theme.colorScheme.primary,
          isPlayful: isPlayful,
          onTap: () => GenerateInviteDialog.show(context, schoolId: schoolId),
        ),
        _QuickActionButton(
          icon: Icons.class_outlined,
          label: 'Add Class',
          color: Colors.green,
          isPlayful: isPlayful,
          onTap: () => CreateClassDialog.show(context, schoolId: schoolId),
        ),
        _QuickActionButton(
          icon: Icons.people_outline,
          label: 'View Staff',
          color: Colors.blue,
          isPlayful: isPlayful,
          onTap: () {
            // Navigate to staff tab (index 1)
            onNavigateToTab?.call(1);
          },
        ),
        _QuickActionButton(
          icon: Icons.school_outlined,
          label: 'View Classes',
          color: Colors.orange,
          isPlayful: isPlayful,
          onTap: () {
            // Navigate to classes tab (index 2)
            onNavigateToTab?.call(2);
          },
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: isPlayful ? 0.15 : 0.1),
      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 22 : 20,
            vertical: isPlayful ? 18 : 16,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: isPlayful ? 24 : 22),
              SizedBox(width: isPlayful ? 10 : 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  fontSize: isPlayful ? 15 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
