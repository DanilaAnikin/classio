import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';

/// A card widget that displays platform-wide statistics for the superadmin dashboard.
///
/// Shows aggregate metrics including total schools, users, students, teachers,
/// classes, and subscription status breakdown (active, trial, expired, suspended).
class PlatformStatsCard extends StatelessWidget {
  /// Creates a [PlatformStatsCard] widget.
  const PlatformStatsCard({
    super.key,
    required this.stats,
  });

  /// The platform statistics to display.
  final PlatformStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All schools and users across Classio',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Stats Row
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Schools',
                  value: stats.totalSchools.toString(),
                  icon: Icons.account_balance_rounded,
                  color: theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Users',
                  value: stats.totalUsers.toString(),
                  icon: Icons.people_rounded,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Classes',
                  value: stats.totalClasses.toString(),
                  icon: Icons.class_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Breakdown
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Students',
                  value: stats.totalStudents.toString(),
                  icon: Icons.person_rounded,
                  color: Colors.teal,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Teachers',
                  value: stats.totalTeachers.toString(),
                  icon: Icons.school_rounded,
                  color: Colors.purple,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 24),

          // Subscription Status Breakdown
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Subscription Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SubscriptionBadge(
                label: 'Active',
                count: stats.activeSubscriptions,
                color: Colors.green,
              ),
              _SubscriptionBadge(
                label: 'Trial',
                count: stats.trialSubscriptions,
                color: Colors.blue,
              ),
              _SubscriptionBadge(
                label: 'Expired',
                count: stats.expiredSubscriptions,
                color: Colors.orange,
              ),
              _SubscriptionBadge(
                label: 'Suspended',
                count: stats.suspendedSchools,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual stat item widget.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Subscription status badge widget.
class _SubscriptionBadge extends StatelessWidget {
  const _SubscriptionBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
