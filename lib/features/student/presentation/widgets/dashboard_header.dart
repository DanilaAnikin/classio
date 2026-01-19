import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Welcome card header for the student dashboard.
///
/// Displays a greeting message with a decorative icon
/// and gradient background. Uses design tokens for consistent styling.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.isPlayful,
    this.userName,
  });

  final bool isPlayful;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = isPlayful ? PlayfulGradients.primary.colors : CleanGradients.primary.colors;

    return Container(
      padding: AppSpacing.getCardPadding(isPlayful: isPlayful),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: AppShadows.card(isPlayful: isPlayful),
      ),
      child: Row(
        children: [
          // Icon container
          _buildIconContainer(),
          SizedBox(width: isPlayful ? AppSpacing.lg : AppSpacing.md),
          // Text content
          Expanded(
            child: _buildTextContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    final size = isPlayful ? AppIconSize.hero + AppSpacing.xs : AppIconSize.hero;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: AppOpacity.medium),
        borderRadius: BorderRadius.circular(
          isPlayful ? AppRadius.lg : AppRadius.md,
        ),
      ),
      child: Icon(
        Icons.school_rounded,
        size: isPlayful ? AppIconSize.xl + AppSpacing.xxs : AppIconSize.xl,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextContent(ThemeData theme) {
    final greeting = userName != null ? 'Welcome back, $userName!' : 'Welcome back!';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greeting,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            fontWeight: isPlayful
                ? AppFontWeight.playfulExtraBold
                : AppFontWeight.headlineSemiBold,
            color: Colors.white,
            fontSize: isPlayful ? AppFontSize.titleLarge : AppFontSize.cardTitle,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          'Your learning journey continues',
          style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
            color: Colors.white.withValues(alpha: AppOpacity.almostOpaque),
          ),
        ),
      ],
    );
  }
}
