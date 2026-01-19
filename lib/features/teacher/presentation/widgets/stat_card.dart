import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';

/// A premium card widget displaying a single statistic.
///
/// Supports both Clean and Playful themes with appropriate visual
/// variations while maintaining consistency through design tokens.
///
/// Example:
/// ```dart
/// StatCard(
///   title: 'Students',
///   value: '42',
///   icon: Icons.people_outline,
///   color: CleanColors.statBlue,
///   isPlayful: false,
///   onTap: () => navigateToStudents(),
/// )
/// ```
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isPlayful,
    this.onTap,
    this.subtitle,
    this.trend,
  });

  /// The label text displayed below the value.
  final String title;

  /// The main statistic value to display prominently.
  final String value;

  /// The icon displayed in the colored container.
  final IconData icon;

  /// The accent color used for the icon container and gradient.
  final Color color;

  /// Whether the playful theme is active.
  final bool isPlayful;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  /// Optional subtitle text displayed below the title.
  final String? subtitle;

  /// Optional trend indicator (e.g., "+5%", "-2%").
  final String? trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build the card content
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon Container
        _buildIconContainer(),
        AppSpacing.gapSm,

        // Value
        _buildValue(theme),
        AppSpacing.gap4,

        // Title and optional trend
        _buildTitleRow(theme),

        // Optional subtitle
        if (subtitle != null) ...[
          AppSpacing.gap4,
          _buildSubtitle(theme),
        ],
      ],
    );

    // Wrap with gradient for playful theme, or use AppCard
    if (isPlayful) {
      return _buildPlayfulCard(cardContent);
    }

    return _buildCleanCard(cardContent);
  }

  /// Builds the icon container with accent color.
  Widget _buildIconContainer() {
    return Container(
      padding: AppSpacing.insets8,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.medium),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Icon(
        icon,
        color: color,
        size: AppIconSize.md,
      ),
    );
  }

  /// Builds the main value text.
  Widget _buildValue(ThemeData theme) {
    return Text(
      value,
      style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
        letterSpacing: isPlayful ? 0.3 : -0.5,
      ),
    );
  }

  /// Builds the title row with optional trend indicator.
  Widget _buildTitleRow(ThemeData theme) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trend != null) ...[
          AppSpacing.gapH8,
          _buildTrendBadge(theme),
        ],
      ],
    );
  }

  /// Builds the trend indicator badge.
  Widget _buildTrendBadge(ThemeData theme) {
    final isPositive = trend?.startsWith('+') ?? false;
    final isNegative = trend?.startsWith('-') ?? false;

    final trendColor = isPositive
        ? (isPlayful ? PlayfulColors.success : CleanColors.success)
        : isNegative
            ? (isPlayful ? PlayfulColors.error : CleanColors.error)
            : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
      ),
      child: Text(
        trend!,
        style: TextStyle(
          fontSize: AppFontSize.labelSmall,
          fontWeight: FontWeight.w600,
          color: trendColor,
        ),
      ),
    );
  }

  /// Builds the optional subtitle text.
  Widget _buildSubtitle(ThemeData theme) {
    return Text(
      subtitle!,
      style: AppTypography.caption(isPlayful: isPlayful).copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(
          alpha: AppOpacity.heavy,
        ),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the card with playful gradient styling.
  Widget _buildPlayfulCard(Widget content) {
    return AppCard.interactive(
      onTap: onTap,
      padding: AppSpacing.cardInsets,
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: AppOpacity.soft),
              color.withValues(alpha: AppOpacity.subtle),
            ],
          ),
          borderRadius: AppRadius.card(isPlayful: true),
        ),
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: content,
        ),
      ),
    );
  }

  /// Builds the card with clean minimal styling.
  Widget _buildCleanCard(Widget content) {
    if (onTap != null) {
      return AppCard.interactive(
        onTap: onTap,
        padding: AppSpacing.cardInsets,
        child: content,
      );
    }

    return AppCard(
      padding: AppSpacing.cardInsets,
      child: content,
    );
  }
}
