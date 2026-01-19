import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/school_stats.dart';

// =============================================================================
// SCHOOL STATS CARD - Principal Dashboard Overview
// =============================================================================
// A premium card component for displaying school statistics with a
// visually appealing grid layout and proper visual hierarchy.
//
// Features:
// - Uses AppCard.elevated for featured content styling
// - AppTypography for all text styles
// - AppSpacing for all margins/padding
// - AppRadius for border radius
// - Semantic color coding for each stat
// - Theme-aware styling (Clean vs Playful)
// =============================================================================

/// A card widget displaying school statistics.
///
/// Shows key metrics about the school in a visually appealing grid layout.
class SchoolStatsCard extends StatelessWidget {
  /// Creates a [SchoolStatsCard].
  const SchoolStatsCard({
    super.key,
    required this.stats,
  });

  /// The school statistics to display.
  final SchoolStats stats;

  /// Detects if the current theme is playful.
  bool _isPlayful(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        (primaryColor.r * 255 > 100 && primaryColor.b * 255 > 200);
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful(context);
    final primaryColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;

    return AppCard.elevated(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          _CardHeader(isPlayful: isPlayful, primaryColor: primaryColor),
          SizedBox(height: AppSpacing.xl),
          // Stats grid
          _StatsGrid(stats: stats, isPlayful: isPlayful),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBCOMPONENTS
// =============================================================================

/// Card header with analytics icon and title.
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.isPlayful,
    required this.primaryColor,
  });

  final bool isPlayful;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle;

    return Row(
      children: [
        // Icon container
        Container(
          padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.xs),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppRadius.badge(isPlayful: isPlayful),
          ),
          child: Icon(
            Icons.analytics_outlined,
            color: primaryColor,
            size: isPlayful ? AppIconSize.lg : AppIconSize.md,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        // Title
        Text(
          'School Overview',
          style: AppTypography.sectionTitle(isPlayful: isPlayful),
        ),
      ],
    );
  }
}

/// Grid displaying all statistics.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.stats,
    required this.isPlayful,
  });

  final SchoolStats stats;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.75,
      children: [
        _StatTile(
          icon: Icons.people_outline,
          label: 'Staff',
          value: stats.totalStaff.toString(),
          color: isPlayful ? PlayfulColors.statPurple : CleanColors.statPurple,
          isPlayful: isPlayful,
        ),
        _StatTile(
          icon: Icons.school_outlined,
          label: 'Teachers',
          value: stats.totalTeachers.toString(),
          color: isPlayful ? PlayfulColors.statBlue : CleanColors.statBlue,
          isPlayful: isPlayful,
        ),
        _StatTile(
          icon: Icons.admin_panel_settings_outlined,
          label: 'Admins',
          value: stats.totalAdmins.toString(),
          color: isPlayful ? PlayfulColors.statIndigo : CleanColors.statIndigo,
          isPlayful: isPlayful,
        ),
        _StatTile(
          icon: Icons.class_outlined,
          label: 'Classes',
          value: stats.totalClasses.toString(),
          color: isPlayful ? PlayfulColors.statGreen : CleanColors.statGreen,
          isPlayful: isPlayful,
        ),
        _StatTile(
          icon: Icons.person_outline,
          label: 'Students',
          value: stats.totalStudents.toString(),
          color: isPlayful ? PlayfulColors.statOrange : CleanColors.statOrange,
          isPlayful: isPlayful,
        ),
        _StatTile(
          icon: Icons.mail_outline,
          label: 'Invites',
          value: stats.activeInviteCodes.toString(),
          color: isPlayful ? PlayfulColors.statPink : CleanColors.statPink,
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

/// Individual stat tile with icon, value, and label.
class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = color.withValues(
      alpha: isPlayful ? AppOpacity.soft : AppOpacity.subtle,
    );
    final borderColor = color.withValues(alpha: AppOpacity.medium);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            icon,
            color: color,
            size: isPlayful ? AppIconSize.lg : AppIconSize.md,
          ),
          SizedBox(height: isPlayful ? AppSpacing.xs : AppSpacing.xxs),
          // Value
          Text(
            value,
            style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
              fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: AppSpacing.space2),
          // Label
          Text(
            label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              color: isPlayful
                  ? PlayfulColors.textSecondary
                  : CleanColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
