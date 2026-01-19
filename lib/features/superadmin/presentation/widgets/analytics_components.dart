import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';

/// Section title widget for analytics sections.
class AnalyticsSectionTitle extends StatelessWidget {
  const AnalyticsSectionTitle({
    super.key,
    required this.title,
    required this.isPlayful,
  });

  final String title;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

/// Individual analytic card widget displaying a metric with icon.
class AnalyticCard extends StatelessWidget {
  const AnalyticCard({
    super.key,
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium + 0.04)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: AppOpacity.soft - 0.02),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isPlayful ? AppIconSize.lg : AppIconSize.md,
              ),
            ),
            SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isPlayful ? AppSpacing.xxs : 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick stats card showing ratios and averages.
class QuickStatsCard extends StatelessWidget {
  const QuickStatsCard({
    super.key,
    required this.analytics,
    required this.isPlayful,
  });

  final SchoolAnalytics analytics;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium + 0.04)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
        child: Column(
          children: [
            _QuickStatRow(
              label: 'Student to Teacher Ratio',
              value: analytics.totalTeachers > 0
                  ? '${(analytics.totalStudents / analytics.totalTeachers).toStringAsFixed(1)} : 1'
                  : 'N/A',
              isPlayful: isPlayful,
            ),
            const Divider(),
            _QuickStatRow(
              label: 'Average Students per Class',
              value: analytics.totalClasses > 0
                  ? (analytics.totalStudents / analytics.totalClasses)
                      .toStringAsFixed(1)
                  : 'N/A',
              isPlayful: isPlayful,
            ),
            const Divider(),
            _QuickStatRow(
              label: 'Subjects per Teacher',
              value: analytics.totalTeachers > 0
                  ? (analytics.totalSubjects / analytics.totalTeachers)
                      .toStringAsFixed(1)
                  : 'N/A',
              isPlayful: isPlayful,
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual quick stat row widget.
class _QuickStatRow extends StatelessWidget {
  const _QuickStatRow({
    required this.label,
    required this.value,
    required this.isPlayful,
  });

  final String label;
  final String value;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isPlayful ? AppSpacing.xs : AppSpacing.xxs + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
