import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';

/// A separator widget displaying a date between messages.
///
/// Features:
/// - Shows "Today", "Yesterday", or formatted date
/// - Subtle centered pill design
/// - Theme-aware styling with proper design tokens
class DateSeparator extends StatelessWidget {
  /// Creates a [DateSeparator] widget.
  const DateSeparator({
    super.key,
    required this.date,
    this.isPlayful = false,
  });

  /// The date to display.
  final DateTime date;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // "Monday", "Tuesday", etc.
    } else if (date.year == now.year) {
      return DateFormat('MMMM d').format(date); // "January 15"
    } else {
      return DateFormat('MMMM d, y').format(date); // "January 15, 2024"
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _formatDate(date);

    // Get theme-appropriate colors
    final lineColor = isPlayful
        ? PlayfulColors.border.withValues(alpha: AppOpacity.soft)
        : CleanColors.border.withValues(alpha: AppOpacity.soft);

    final pillBackgroundColor = isPlayful
        ? PlayfulColors.surfaceSubtle
        : CleanColors.surfaceSubtle;

    final pillBorderColor = isPlayful
        ? PlayfulColors.border.withValues(alpha: AppOpacity.light)
        : CleanColors.border.withValues(alpha: AppOpacity.light);

    final textColor = isPlayful
        ? PlayfulColors.textSecondary
        : CleanColors.textSecondary;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Left line
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    lineColor,
                  ],
                ),
              ),
            ),
          ),

          // Date pill
          Padding(
            padding: AppSpacing.insetsH16,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: pillBackgroundColor,
                borderRadius: AppRadius.chip(),
                border: Border.all(
                  color: pillBorderColor,
                  width: 1,
                ),
              ),
              child: Text(
                dateText,
                style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                  color: textColor,
                  fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),

          // Right line
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    lineColor,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
