import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/entities.dart';

/// A card widget displaying school information with statistics.
///
/// Shows school name, subscription status, and user/class counts.
/// Tapping the card triggers the [onTap] callback.
class SchoolCard extends StatelessWidget {
  const SchoolCard({
    super.key,
    required this.school,
    required this.onTap,
  });

  /// The school with statistics to display.
  final SchoolWithStats school;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.trial:
        return Colors.orange;
      case SubscriptionStatus.pro:
        return Colors.blue;
      case SubscriptionStatus.max:
        return Colors.purple;
      case SubscriptionStatus.expired:
        return Colors.grey;
      case SubscriptionStatus.suspended:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(school.subscriptionStatus);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // School Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),

                // School Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                school.subscriptionStatus.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          if (school.createdAt != null) ...[
                            const SizedBox(width: 10),
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _formatDate(school.createdAt!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 28,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 14),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.groups_rounded,
                  label: 'Users',
                  value: school.totalUsers.toString(),
                  color: theme.colorScheme.primary,
                ),
                _StatItem(
                  icon: Icons.person_rounded,
                  label: 'Students',
                  value: school.totalStudents.toString(),
                  color: Colors.green,
                ),
                _StatItem(
                  icon: Icons.school_rounded,
                  label: 'Teachers',
                  value: school.totalTeachers.toString(),
                  color: Colors.blue,
                ),
                _StatItem(
                  icon: Icons.class_rounded,
                  label: 'Classes',
                  value: school.totalClasses.toString(),
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
