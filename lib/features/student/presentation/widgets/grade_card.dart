import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/theme/theme.dart';
import 'package:classio/shared/widgets/app_card.dart';
import '../../../grades/domain/entities/entities.dart';

/// Card showing a recent grade with premium styling.
///
/// Uses the design system tokens for consistent spacing, typography,
/// and colors. Supports both Clean and Playful themes with appropriate
/// visual variations while maintaining consistency.
///
/// Features:
/// - Theme-aware grade color coding (excellent, good, average, below average, failing)
/// - Subtle hover/press states for interactivity
/// - Clean typography hierarchy with proper spacing
/// - Accessible design with proper contrast ratios
class GradeCard extends StatelessWidget {
  const GradeCard({
    super.key,
    required this.grade,
    required this.isPlayful,
    this.onTap,
  });

  final Grade grade;
  final bool isPlayful;
  final VoidCallback? onTap;

  /// Gets the appropriate grade color based on score and theme.
  Color _getGradeColor(double value) {
    return AppSemanticColors.getGradeColor(value, isPlayful: isPlayful);
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = _getGradeColor(grade.score);

    // Get theme-aware values
    final textPrimary = AppTextColors.primary(isPlayful: isPlayful);
    final textSecondary = AppTextColors.secondary(isPlayful: isPlayful);
    final badgeRadius = AppRadius.badge(isPlayful: isPlayful);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard.interactive(
        onTap: onTap ?? () {
          // Default: Could be used for grade detail view
        },
        padding: AppSpacing.cardInsetsCompact,
        child: Row(
          children: [
            // Grade score badge
            _GradeScoreBadge(
              score: grade.score,
              color: gradeColor,
              isPlayful: isPlayful,
              badgeRadius: badgeRadius,
            ),
            AppSpacing.gapH16,
            // Grade details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.description,
                    style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                      fontSize: AppFontSize.titleSmall,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.gap4,
                  Text(
                    DateFormat('MMM d, yyyy').format(grade.date),
                    style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron indicator for interaction hint
            Icon(
              Icons.chevron_right_rounded,
              size: AppIconSize.sm,
              color: textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget for the grade score badge.
///
/// Displays the numeric grade in a colored, rounded container with
/// theme-appropriate styling.
class _GradeScoreBadge extends StatelessWidget {
  const _GradeScoreBadge({
    required this.score,
    required this.color,
    required this.isPlayful,
    required this.badgeRadius,
  });

  final double score;
  final Color color;
  final bool isPlayful;
  final BorderRadius badgeRadius;

  @override
  Widget build(BuildContext context) {
    // Format score: show decimal only if needed
    final scoreText = score.truncateToDouble() == score
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);

    return Container(
      width: AppSpacing.xxxxl,
      height: AppSpacing.xxxxl,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Center(
        child: Text(
          scoreText,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
