import 'package:flutter/material.dart';

import '../../../../core/router/app_router.dart';
import 'school_analytics_sheet.dart';

/// Quick actions section widget for school management.
///
/// Provides action chips for common school management tasks:
/// - View Users
/// - Settings
/// - Analytics
class SchoolActionsSection extends StatelessWidget {
  const SchoolActionsSection({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        Wrap(
          spacing: isPlayful ? 12 : 8,
          runSpacing: isPlayful ? 12 : 8,
          children: [
            _ActionChip(
              icon: Icons.people_outline,
              label: 'View Users',
              onTap: () => context.pushSuperadminSchoolUsers(schoolId),
              isPlayful: isPlayful,
            ),
            _ActionChip(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () => context.pushSuperadminSchoolSettings(schoolId),
              isPlayful: isPlayful,
            ),
            _ActionChip(
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              onTap: () => _showAnalyticsDialog(context),
              isPlayful: isPlayful,
            ),
          ],
        ),
      ],
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isPlayful ? 24 : 16),
        ),
      ),
      builder: (context) => SchoolAnalyticsSheet(
        schoolId: schoolId,
        isPlayful: isPlayful,
      ),
    );
  }
}

/// Individual action chip widget used within [SchoolActionsSection].
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 8),
      ),
    );
  }
}
