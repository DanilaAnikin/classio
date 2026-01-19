import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/entities.dart';

/// A premium card widget that displays platform-wide statistics for the superadmin dashboard.
///
/// Shows aggregate metrics including total schools, users, students, teachers,
/// classes, and subscription status breakdown (active, trial, expired, suspended).
/// Uses design system tokens and the [AppCard] component for consistent styling.
class PlatformStatsCard extends StatelessWidget {
  /// Creates a [PlatformStatsCard] widget.
  const PlatformStatsCard({
    super.key,
    required this.stats,
    required this.isPlayful,
  });

  /// The platform statistics to display.
  final PlatformStats stats;

  /// Whether the playful theme is active.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardRadius = AppRadius.card(isPlayful: isPlayful);

    return AppCard.elevated(
      padding: AppSpacing.dialogInsets,
      borderRadius: cardRadius,
      boxShadow: AppShadows.cardHover(isPlayful: isPlayful),
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _HeaderSection(
            theme: theme,
            isPlayful: isPlayful,
          ),
          SizedBox(height: AppSpacing.xl),

          // Main Stats Row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Schools',
                  value: stats.totalSchools.toString(),
                  icon: Icons.account_balance_rounded,
                  color: theme.colorScheme.primary,
                  isPlayful: isPlayful,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Users',
                  value: stats.totalUsers.toString(),
                  icon: Icons.people_rounded,
                  color: AppSemanticColors.getStatColor('blue', isPlayful: isPlayful),
                  isPlayful: isPlayful,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Classes',
                  value: stats.totalClasses.toString(),
                  icon: Icons.class_rounded,
                  color: AppSemanticColors.getStatColor('green', isPlayful: isPlayful),
                  isPlayful: isPlayful,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // User Breakdown
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Students',
                  value: stats.totalStudents.toString(),
                  icon: Icons.person_rounded,
                  color: AppSemanticColors.getStatColor('teal', isPlayful: isPlayful),
                  isPlayful: isPlayful,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Teachers',
                  value: stats.totalTeachers.toString(),
                  icon: Icons.school_rounded,
                  color: AppSemanticColors.getStatColor('purple', isPlayful: isPlayful),
                  isPlayful: isPlayful,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          // Subscription Status Breakdown
          _SubscriptionSection(
            stats: stats,
            theme: theme,
            isPlayful: isPlayful,
          ),
        ],
      ),
    );
  }
}

/// Header section with icon and title.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.theme,
    required this.isPlayful,
  });

  final ThemeData theme;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSpacing.xxxxl,
          height: AppSpacing.xxxxl,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                theme.colorScheme.secondary.withValues(alpha: AppOpacity.subtle),
              ],
            ),
            borderRadius: AppRadius.button(isPlayful: isPlayful),
          ),
          child: Icon(
            Icons.analytics_rounded,
            size: AppIconSize.xl,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platform Overview',
                style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xxs),
              Text(
                'All schools and users across Classio',
                style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Subscription status section with badges.
class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection({
    required this.stats,
    required this.theme,
    required this.isPlayful,
  });

  final PlatformStats stats;
  final ThemeData theme;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Subscription Status',
          style: AppTypography.cardSubtitle(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.almostOpaque),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _SubscriptionBadge(
              label: 'Active',
              count: stats.activeSubscriptions,
              color: AppSemanticColors.success(isPlayful: isPlayful),
              isPlayful: isPlayful,
            ),
            _SubscriptionBadge(
              label: 'Trial',
              count: stats.trialSubscriptions,
              color: AppSemanticColors.getSubscriptionColor('trial', isPlayful: isPlayful),
              isPlayful: isPlayful,
            ),
            _SubscriptionBadge(
              label: 'Expired',
              count: stats.expiredSubscriptions,
              color: AppSemanticColors.warning(isPlayful: isPlayful),
              isPlayful: isPlayful,
            ),
            _SubscriptionBadge(
              label: 'Suspended',
              count: stats.suspendedSchools,
              color: AppSemanticColors.error(isPlayful: isPlayful),
              isPlayful: isPlayful,
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual stat item widget with icon, label, and value.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: AppIconSize.sm,
              color: color,
            ),
            SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Subscription status badge widget with pill design.
class _SubscriptionBadge extends StatelessWidget {
  const _SubscriptionBadge({
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
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.medium),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: AppOpacity.almostOpaque),
            ),
          ),
        ],
      ),
    );
  }
}
