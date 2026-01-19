import 'package:flutter/material.dart';

/// Statistics section widget displaying school metrics.
///
/// Shows a row of stat cards with icons and values for:
/// - Number of students
/// - Number of teachers
/// - Number of classes
class SchoolStatsSection extends StatelessWidget {
  const SchoolStatsSection({
    super.key,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClasses,
    required this.isPlayful,
  });

  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people_outline,
                label: 'Students',
                value: totalStudents.toString(),
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _StatCard(
                icon: Icons.person_outline,
                label: 'Teachers',
                value: totalTeachers.toString(),
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _StatCard(
                icon: Icons.class_outlined,
                label: 'Classes',
                value: totalClasses.toString(),
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual stat card widget used within [SchoolStatsSection].
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        child: Column(
          children: [
            Icon(
              icon,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: isPlayful ? 8 : 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
