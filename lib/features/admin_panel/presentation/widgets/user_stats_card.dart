import 'package:flutter/material.dart';

import 'stat_badge.dart';

/// User stats card widget displaying total users and role breakdown.
class UserStatsCard extends StatelessWidget {
  const UserStatsCard({
    super.key,
    required this.totalUsers,
    required this.teacherCount,
    required this.studentCount,
    required this.parentCount,
    required this.isPlayful,
  });

  final int totalUsers;
  final int teacherCount;
  final int studentCount;
  final int parentCount;
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
              Icons.groups_rounded,
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
                  'Total Users',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalUsers.toString(),
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
              StatBadge(
                label: 'Teachers',
                count: teacherCount,
                color: Colors.blue,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              StatBadge(
                label: 'Students',
                count: studentCount,
                color: Colors.green,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              StatBadge(
                label: 'Parents',
                count: parentCount,
                color: Colors.orange,
                isPlayful: isPlayful,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
