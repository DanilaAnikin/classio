import 'package:flutter/material.dart';

/// Header card widget displaying school name and ID.
///
/// Used in the school detail page to show the primary school information
/// with a school icon and the school's unique identifier.
class SchoolHeaderCard extends StatelessWidget {
  const SchoolHeaderCard({
    super.key,
    required this.schoolName,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolName;
  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 24 : 16),
        child: Column(
          children: [
            Container(
              width: isPlayful ? 80 : 64,
              height: isPlayful ? 80 : 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: isPlayful ? 40 : 32,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 16 : 12),
            Text(
              schoolName,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $schoolId',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
