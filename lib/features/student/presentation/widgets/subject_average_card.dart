import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';

/// Card showing a subject's average grade with a progress bar.
///
/// Displays the subject name, numeric average, and a visual progress bar
/// indicating the grade level. Features theme-aware color coding for
/// excellent, good, average, below average, and failing grades.
///
/// Uses the design system for:
/// - Consistent spacing via AppSpacing
/// - Theme-aware typography via AppTypography
/// - Proper color handling via AppColors/AppOpacity
/// - Premium card styling via AppCard
/// - Grade color semantics via AppSemanticColors
class SubjectAverageCard extends StatelessWidget {
  const SubjectAverageCard({
    super.key,
    required this.subjectName,
    required this.average,
    required this.isPlayful,
    this.maxGrade = 6.0,
    this.onTap,
  });

  final String subjectName;
  final double average;
  final bool isPlayful;
  final double maxGrade;
  final VoidCallback? onTap;

  /// Gets the appropriate grade color based on average and theme.
  Color _getGradeColor() {
    return AppSemanticColors.getGradeColor(average, isPlayful: isPlayful);
  }

  @override
  Widget build(BuildContext context) {
    // Theme-aware colors
    final textPrimary = AppTextColors.primary(isPlayful: isPlayful);
    final gradeColor = _getGradeColor();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: AppSpacing.cardInsetsCompact,
        child: Row(
          children: [
            // Average score badge
            _AverageScoreBadge(
              average: average,
              color: gradeColor,
              isPlayful: isPlayful,
            ),
            AppSpacing.gapH16,
            // Subject name and progress bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name
                  Text(
                    subjectName,
                    style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                      fontSize: AppFontSize.titleSmall,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.gap8,
                  // Progress bar
                  _GradeProgressBar(
                    value: average / maxGrade,
                    color: gradeColor,
                    isPlayful: isPlayful,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget for the average score badge.
///
/// Displays the numeric average in a colored, rounded container with
/// theme-appropriate styling.
class _AverageScoreBadge extends StatelessWidget {
  const _AverageScoreBadge({
    required this.average,
    required this.color,
    required this.isPlayful,
  });

  final double average;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    // Badge size based on theme
    final badgeSize = isPlayful
        ? AppIconSize.hero - AppSpacing.xs
        : AppIconSize.xxl;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Center(
        child: Text(
          average.toStringAsFixed(1),
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Internal widget for the grade progress bar.
///
/// Displays a horizontal progress bar showing the grade level relative
/// to the maximum grade.
class _GradeProgressBar extends StatelessWidget {
  const _GradeProgressBar({
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final double value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    // Progress bar height based on theme
    final barHeight = isPlayful ? AppSpacing.xs : AppSpacing.sm - AppSpacing.space2;
    // Border radius based on theme
    final barRadius = isPlayful
        ? AppRadius.xsRadius
        : AppRadius.circular(AppRadius.xs - AppSpacing.space2);

    return ClipRRect(
      borderRadius: barRadius,
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: barHeight,
        backgroundColor: color.withValues(alpha: AppOpacity.soft),
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}
