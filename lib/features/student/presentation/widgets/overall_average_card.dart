import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Card displaying the overall grade average with a gradient background.
///
/// Uses semantic grade colors and design tokens for consistent styling.
/// The card adapts its appearance based on the grade performance level.
class OverallAverageCard extends StatelessWidget {
  const OverallAverageCard({
    super.key,
    required this.average,
    required this.isPlayful,
    this.onTap,
  });

  final double average;
  final bool isPlayful;
  final VoidCallback? onTap;

  /// Returns the appropriate color based on the grade average.
  Color _getAverageColor() {
    if (isPlayful) {
      if (average >= 5) return PlayfulColors.gradeExcellent;
      if (average >= 4) return PlayfulColors.gradeGood;
      if (average >= 3) return PlayfulColors.gradeAverage;
      if (average >= 2) return PlayfulColors.gradeBelowAverage;
      return PlayfulColors.gradeFailing;
    } else {
      if (average >= 5) return CleanColors.gradeExcellent;
      if (average >= 4) return CleanColors.gradeGood;
      if (average >= 3) return CleanColors.gradeAverage;
      if (average >= 2) return CleanColors.gradeBelowAverage;
      return CleanColors.gradeFailing;
    }
  }

  /// Returns a descriptive message based on the grade average.
  String _getAverageDescription() {
    if (average >= 5) return 'Excellent performance!';
    if (average >= 4) return 'Very good work!';
    if (average >= 3) return 'Good progress';
    if (average >= 2) return 'Needs improvement';
    return 'Keep working hard';
  }

  /// Returns the appropriate icon based on the grade average.
  IconData _getAverageIcon() {
    if (average >= 5) return Icons.emoji_events_rounded;
    if (average >= 4) return Icons.star_rounded;
    if (average >= 3) return Icons.thumb_up_rounded;
    if (average >= 2) return Icons.trending_up_rounded;
    return Icons.trending_flat_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAverageColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppCurves.standard,
        padding: AppSpacing.getCardPadding(isPlayful: isPlayful),
        decoration: BoxDecoration(
          borderRadius: AppRadius.card(isPlayful: isPlayful),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withValues(alpha: AppOpacity.dominant + AppOpacity.light),
            ],
          ),
          boxShadow: isPlayful
              ? AppShadows.colored(
                  AppShadows.cardHover(isPlayful: true),
                  color,
                )
              : AppShadows.card(isPlayful: false),
        ),
        child: Row(
          children: [
            // Average display container
            _buildAverageDisplay(color),
            SizedBox(width: isPlayful ? AppSpacing.lg : AppSpacing.md),
            // Text content
            Expanded(
              child: _buildTextContent(),
            ),
            // Decorative icon
            _buildDecorativeIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageDisplay(Color color) {
    final size = isPlayful
        ? AppIconSize.hero + AppSpacing.xs
        : AppIconSize.hero;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppOpacity.medium),
        borderRadius: BorderRadius.circular(
          isPlayful ? AppRadius.lg : AppRadius.md,
        ),
      ),
      child: Center(
        child: Text(
          average.toStringAsFixed(2),
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            fontWeight: isPlayful
                ? AppFontWeight.playfulExtraBold
                : AppFontWeight.headlineSemiBold,
            color: Colors.white,
            fontSize: isPlayful ? AppFontSize.titleLarge : AppFontSize.cardTitle,
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Overall Average',
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            fontWeight: isPlayful
                ? AppFontWeight.playfulTitleSemiBold
                : AppFontWeight.titleSemiBold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          _getAverageDescription(),
          style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
            color: Colors.white.withValues(alpha: AppOpacity.almostOpaque),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeIcon() {
    return Container(
      padding: AppSpacing.insets8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppOpacity.soft),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(
        _getAverageIcon(),
        size: AppIconSize.lg,
        color: Colors.white.withValues(alpha: AppOpacity.almostOpaque),
      ),
    );
  }
}
