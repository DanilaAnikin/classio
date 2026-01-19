import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/entities.dart';

/// A premium card widget displaying school information with statistics.
///
/// Shows school name, subscription status, and user/class counts.
/// Tapping the card triggers the [onTap] callback. Uses design system
/// tokens and the [AppCard] component for consistent styling.
class SchoolCard extends StatelessWidget {
  const SchoolCard({
    super.key,
    required this.school,
    required this.onTap,
    this.isPlayful = false,
  });

  /// The school with statistics to display.
  final SchoolWithStats school;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  Color _getStatusColor(SubscriptionStatus status) {
    return AppSemanticColors.getSubscriptionColor(
      status.name,
      isPlayful: isPlayful,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(school.subscriptionStatus);

    return AppCard.interactive(
      onTap: onTap,
      semanticLabel: 'School: ${school.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // School Icon Badge
              _SchoolIconBadge(
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primaryContainer,
                isPlayful: isPlayful,
              ),
              SizedBox(width: AppSpacing.md),

              // School Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      school.name,
                      style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Flexible(
                          child: _SubscriptionStatusBadge(
                            status: school.subscriptionStatus,
                            statusColor: statusColor,
                            isPlayful: isPlayful,
                          ),
                        ),
                        if (school.createdAt case final createdAt?) ...[
                          SizedBox(width: AppSpacing.sm),
                          _DateBadge(
                            date: _formatDate(createdAt),
                            isPlayful: isPlayful,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                size: AppIconSize.lg,
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),
          Divider(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
          ),
          SizedBox(height: AppSpacing.md),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.groups_rounded,
                label: 'Users',
                value: school.totalUsers.toString(),
                color: theme.colorScheme.primary,
                isPlayful: isPlayful,
              ),
              _StatItem(
                icon: Icons.person_rounded,
                label: 'Students',
                value: school.totalStudents.toString(),
                color: AppSemanticColors.getStatColor('green', isPlayful: isPlayful),
                isPlayful: isPlayful,
              ),
              _StatItem(
                icon: Icons.school_rounded,
                label: 'Teachers',
                value: school.totalTeachers.toString(),
                color: AppSemanticColors.getStatColor('blue', isPlayful: isPlayful),
                isPlayful: isPlayful,
              ),
              _StatItem(
                icon: Icons.class_rounded,
                label: 'Classes',
                value: school.totalClasses.toString(),
                color: AppSemanticColors.getStatColor('orange', isPlayful: isPlayful),
                isPlayful: isPlayful,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// School icon badge with themed background.
class _SchoolIconBadge extends StatelessWidget {
  const _SchoolIconBadge({
    required this.color,
    required this.backgroundColor,
    required this.isPlayful,
  });

  final Color color;
  final Color backgroundColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.xxxxl,
      height: AppSpacing.xxxxl,
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: AppOpacity.heavy),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Icon(
        Icons.school_rounded,
        size: AppIconSize.lg,
        color: color,
      ),
    );
  }
}

/// Subscription status badge pill.
class _SubscriptionStatusBadge extends StatelessWidget {
  const _SubscriptionStatusBadge({
    required this.status,
    required this.statusColor,
    required this.isPlayful,
  });

  final SubscriptionStatus status;
  final Color statusColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: AppOpacity.medium),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
      ),
      child: Text(
        status.displayName,
        style: AppTypography.badge(isPlayful: isPlayful).copyWith(
          color: statusColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

/// Date badge with calendar icon.
class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.date,
    required this.isPlayful,
  });

  final String date;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: AppIconSize.xs,
          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
        ),
        SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            date,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// Individual statistic item with icon, value, and label.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: AppSpacing.xxxl,
          height: AppSpacing.xxxl,
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.button(isPlayful: isPlayful),
          ),
          child: Icon(
            icon,
            size: AppIconSize.md,
            color: color,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.caption(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
