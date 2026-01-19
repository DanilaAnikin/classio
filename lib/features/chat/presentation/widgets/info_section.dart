import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// A section displaying a single info item with an icon.
///
/// Used in conversation info sheets to display details like
/// participant count, creation date, and conversation type.
class InfoSection extends StatelessWidget {
  /// Creates an [InfoSection] widget.
  const InfoSection({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isPlayful = false,
  });

  /// The icon to display.
  final IconData icon;

  /// The title/label for this info item.
  final String title;

  /// The value to display.
  final String value;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isPlayful ? AppSpacing.md : AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isPlayful ? AppSpacing.xs + 2 : AppSpacing.xs),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: AppOpacity.heavy),
              borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs),
            ),
            child: Icon(
              icon,
              size: isPlayful ? AppIconSize.md - 2 : AppIconSize.sm,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.md : AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
