import 'package:flutter/material.dart';

import '../../domain/entities/school_stats.dart';

/// A card widget displaying school statistics.
///
/// Shows key metrics about the school in a visually appealing grid layout.
class SchoolStatsCard extends StatelessWidget {
  /// Creates a [SchoolStatsCard].
  const SchoolStatsCard({
    super.key,
    required this.stats,
    this.isPlayful = false,
  });

  /// The school statistics to display.
  final SchoolStats stats;

  /// Whether to use playful styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 12 : 8,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 22 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isPlayful ? 12 : 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isPlayful ? 14 : 12),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: theme.colorScheme.primary,
                    size: isPlayful ? 26 : 24,
                  ),
                ),
                SizedBox(width: isPlayful ? 14 : 12),
                Text(
                  'School Overview',
                  style: TextStyle(
                    fontSize: isPlayful ? 20 : 18,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: isPlayful ? 26 : 24),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: isPlayful ? 18 : 16,
              crossAxisSpacing: isPlayful ? 18 : 16,
              childAspectRatio: 0.75,
              children: [
                _StatTile(
                  icon: Icons.people_outline,
                  label: 'Staff',
                  value: stats.totalStaff.toString(),
                  color: theme.colorScheme.primary,
                  isPlayful: isPlayful,
                ),
                _StatTile(
                  icon: Icons.school_outlined,
                  label: 'Teachers',
                  value: stats.totalTeachers.toString(),
                  color: Colors.blue,
                  isPlayful: isPlayful,
                ),
                _StatTile(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admins',
                  value: stats.totalAdmins.toString(),
                  color: Colors.indigo,
                  isPlayful: isPlayful,
                ),
                _StatTile(
                  icon: Icons.class_outlined,
                  label: 'Classes',
                  value: stats.totalClasses.toString(),
                  color: Colors.green,
                  isPlayful: isPlayful,
                ),
                _StatTile(
                  icon: Icons.person_outline,
                  label: 'Students',
                  value: stats.totalStudents.toString(),
                  color: Colors.orange,
                  isPlayful: isPlayful,
                ),
                _StatTile(
                  icon: Icons.mail_outline,
                  label: 'Invites',
                  value: stats.activeInviteCodes.toString(),
                  color: Colors.red,
                  isPlayful: isPlayful,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
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

    return Container(
      padding: EdgeInsets.all(isPlayful ? 14 : 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isPlayful ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(isPlayful ? 14 : 12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isPlayful ? 26 : 24),
          SizedBox(height: isPlayful ? 6 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isPlayful ? 20 : 18,
              fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: isPlayful ? 2 : 1),
          Text(
            label,
            style: TextStyle(
              fontSize: isPlayful ? 11 : 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
