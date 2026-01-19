import 'package:flutter/material.dart';

import 'package:classio/core/theme/spacing.dart';
import 'package:classio/core/theme/app_radius.dart';
import '../../domain/entities/class_info.dart';

/// Class card widget displaying class information with academic year badge.
class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.schoolClass,
    required this.isPlayful,
  });

  final ClassInfo schoolClass;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: isPlayful ? AppRadius.dialogBorderRadius : AppRadius.cardBorderRadius,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Class Icon
          Container(
            width: isPlayful ? 48 : 42,
            height: isPlayful ? 48 : 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isPlayful ? AppRadius.md + 2 : AppRadius.sm + 2),
            ),
            child: Center(
              child: Text(
                schoolClass.name,
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 14,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.sm + 2 : AppSpacing.sm),

          // Class Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class ${schoolClass.name}',
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 15,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                if (schoolClass.gradeLevel != null)
                  Text(
                    'Grade ${schoolClass.gradeLevel}',
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          // Academic Year Badge
          if (schoolClass.academicYear case final academicYear?)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? AppSpacing.sm : AppSpacing.sm - 2,
                vertical: isPlayful ? AppSpacing.xs - 2 : AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm + 2 : AppRadius.sm),
              ),
              child: Text(
                academicYear,
                style: TextStyle(
                  fontSize: isPlayful ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
