import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';

/// Card widget displaying attendance statistics summary.
///
/// Features:
/// - Overall attendance rate with visual progress indicator
/// - Breakdown of attendance types (present, absent, late, excused)
/// - Color-coded statistics based on performance
/// - Theme-aware styling (Clean vs Playful)
class AttendanceSummaryCard extends ConsumerWidget {
  const AttendanceSummaryCard({
    super.key,
    required this.stats,
    this.title,
    this.onTap,
  });

  /// The attendance statistics to display.
  final AttendanceStats stats;

  /// Optional title for the card.
  final String? title;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  Color _getPercentageColor({required bool isPlayful}) {
    final percentage = stats.attendancePercentage;
    if (percentage >= 95) {
      return isPlayful
          ? PlayfulColors.attendancePresent
          : CleanColors.attendancePresent;
    } else if (percentage >= 90) {
      return isPlayful ? PlayfulColors.success : CleanColors.success;
    } else if (percentage >= 80) {
      return isPlayful ? PlayfulColors.warning : CleanColors.warning;
    } else if (percentage >= 70) {
      return isPlayful
          ? PlayfulColors.attendanceLate
          : CleanColors.attendanceLate;
    } else {
      return isPlayful ? PlayfulColors.error : CleanColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final percentageColor = _getPercentageColor(isPlayful: isPlayful);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card(isPlayful: isPlayful),
      child: AnimatedContainer(
        duration: AppDuration.normal,
        curve: AppCurves.standard,
        padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadius.card(isPlayful: isPlayful),
          gradient: isPlayful
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    percentageColor.withValues(alpha: AppOpacity.soft),
                    percentageColor.withValues(alpha: AppOpacity.subtle),
                  ],
                )
              : null,
          color: isPlayful ? null : theme.colorScheme.surface,
          border: isPlayful
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium),
                ),
          boxShadow: isPlayful
              ? [
                  BoxShadow(
                    color: percentageColor.withValues(alpha: AppOpacity.medium),
                    blurRadius: AppSpacing.lg,
                    offset: const Offset(0, AppSpacing.xs),
                  ),
                ]
              : AppShadows.cleanSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
            ],
            // Main content: Progress ring + Stats
            Row(
              children: [
                // Circular progress indicator
                _AttendanceCircularProgress(
                  percentage: stats.attendancePercentage,
                  color: percentageColor,
                  isPlayful: isPlayful,
                ),
                SizedBox(width: isPlayful ? AppSpacing.xl : AppSpacing.lg),
                // Stats breakdown
                Expanded(
                  child: _StatsBreakdown(
                    stats: stats,
                    isPlayful: isPlayful,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular progress indicator for attendance percentage.
class _AttendanceCircularProgress extends StatelessWidget {
  const _AttendanceCircularProgress({
    required this.percentage,
    required this.color,
    required this.isPlayful,
  });

  final double percentage;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Circular progress indicator sizes: 100px for playful, 80px for clean
    final size = isPlayful ? AppSpacing.space96 + AppSpacing.space4 : AppSpacing.space80;
    final strokeWidth = isPlayful ? AppSpacing.sm : AppSpacing.xs;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
              ),
            ),
          ),
          // Progress indicator with animation
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              duration: AppDuration.slow,
              curve: AppCurves.emphasized,
              tween: Tween<double>(begin: 0, end: percentage / 100),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Center percentage text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<int>(
                duration: AppDuration.slow,
                tween: IntTween(begin: 0, end: percentage.round()),
                builder: (context, value, child) {
                  return Text(
                    '$value%',
                    style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: isPlayful ? AppFontSize.titleLarge : AppFontSize.titleMedium,
                      color: color,
                    ),
                  );
                },
              ),
              Text(
                'Attendance',
                style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: isPlayful ? AppFontSize.labelSmall : AppFontSize.overline,
                  color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stats breakdown showing individual attendance categories.
class _StatsBreakdown extends StatelessWidget {
  const _StatsBreakdown({
    required this.stats,
    required this.isPlayful,
  });

  final AttendanceStats stats;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatRow(
          label: 'Present',
          value: stats.presentDays,
          color: isPlayful
              ? PlayfulColors.attendancePresent
              : CleanColors.attendancePresent,
          isPlayful: isPlayful,
        ),
        SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        _StatRow(
          label: 'Absent',
          value: stats.absentDays,
          color: isPlayful
              ? PlayfulColors.attendanceAbsent
              : CleanColors.attendanceAbsent,
          isPlayful: isPlayful,
        ),
        SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        _StatRow(
          label: 'Late',
          value: stats.lateDays,
          color: isPlayful
              ? PlayfulColors.attendanceLate
              : CleanColors.attendanceLate,
          isPlayful: isPlayful,
        ),
        SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        _StatRow(
          label: 'Excused',
          value: stats.excusedDays,
          color: isPlayful ? PlayfulColors.info : CleanColors.info,
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

/// Row showing a single statistic with label and value.
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final int value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotSize = isPlayful ? AppSpacing.sm : AppSpacing.xs;

    return Row(
      children: [
        // Color indicator dot
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isPlayful
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: AppOpacity.strong),
                      blurRadius: AppSpacing.xxs,
                      offset: const Offset(0, AppSpacing.space2),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        // Label
        Expanded(
          child: Text(
            label,
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
            ),
          ),
        ),
        // Value badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
            vertical: isPlayful ? AppSpacing.xxs : AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.badge(isPlayful: isPlayful),
            border: Border.all(
              color: color.withValues(alpha: AppOpacity.semi),
              width: isPlayful ? 1 : 0.5,
            ),
          ),
          child: Text(
            value.toString(),
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact version of attendance summary for list items.
class AttendanceSummaryCompact extends ConsumerWidget {
  const AttendanceSummaryCompact({
    super.key,
    required this.stats,
  });

  final AttendanceStats stats;

  Color _getPercentageColor({required bool isPlayful}) {
    final percentage = stats.attendancePercentage;
    if (percentage >= 95) {
      return isPlayful
          ? PlayfulColors.attendancePresent
          : CleanColors.attendancePresent;
    } else if (percentage >= 90) {
      return isPlayful ? PlayfulColors.success : CleanColors.success;
    } else if (percentage >= 80) {
      return isPlayful ? PlayfulColors.warning : CleanColors.warning;
    } else if (percentage >= 70) {
      return isPlayful
          ? PlayfulColors.attendanceLate
          : CleanColors.attendanceLate;
    } else {
      return isPlayful ? PlayfulColors.error : CleanColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final percentageColor = _getPercentageColor(isPlayful: isPlayful);

    return Row(
      children: [
        _CompactStat(
          icon: Icons.check_circle_rounded,
          value: stats.presentDays,
          color: isPlayful
              ? PlayfulColors.attendancePresent
              : CleanColors.attendancePresent,
          isPlayful: isPlayful,
        ),
        SizedBox(width: isPlayful ? AppSpacing.md : AppSpacing.sm),
        _CompactStat(
          icon: Icons.cancel_rounded,
          value: stats.absentDays,
          color: isPlayful
              ? PlayfulColors.attendanceAbsent
              : CleanColors.attendanceAbsent,
          isPlayful: isPlayful,
        ),
        SizedBox(width: isPlayful ? AppSpacing.md : AppSpacing.sm),
        _CompactStat(
          icon: Icons.access_time_rounded,
          value: stats.lateDays,
          color: isPlayful
              ? PlayfulColors.attendanceLate
              : CleanColors.attendanceLate,
          isPlayful: isPlayful,
        ),
        const Spacer(),
        // Percentage badge
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
            vertical: isPlayful ? AppSpacing.xxs : AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: percentageColor.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.badge(isPlayful: isPlayful),
            border: Border.all(
              color: percentageColor.withValues(alpha: AppOpacity.semi),
            ),
          ),
          child: Text(
            '${stats.attendancePercentage.toStringAsFixed(0)}%',
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w700,
              color: percentageColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact stat item with icon and value.
class _CompactStat extends StatelessWidget {
  const _CompactStat({
    required this.icon,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final int value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isPlayful ? AppIconSize.sm : AppIconSize.xs,
          color: color,
        ),
        SizedBox(width: isPlayful ? AppSpacing.xxs : AppSpacing.space2),
        Text(
          value.toString(),
          style: AppTypography.caption(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Mini attendance summary for dashboard cards.
class AttendanceMiniCard extends ConsumerWidget {
  const AttendanceMiniCard({
    super.key,
    required this.stats,
    this.onTap,
  });

  final AttendanceStats stats;
  final VoidCallback? onTap;

  Color _getPercentageColor({required bool isPlayful}) {
    final percentage = stats.attendancePercentage;
    if (percentage >= 95) {
      return isPlayful
          ? PlayfulColors.attendancePresent
          : CleanColors.attendancePresent;
    } else if (percentage >= 85) {
      return isPlayful ? PlayfulColors.success : CleanColors.success;
    } else if (percentage >= 75) {
      return isPlayful ? PlayfulColors.warning : CleanColors.warning;
    } else {
      return isPlayful ? PlayfulColors.error : CleanColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final percentageColor = _getPercentageColor(isPlayful: isPlayful);
    final percentage = stats.attendancePercentage.round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: AppRadius.card(isPlayful: isPlayful),
          gradient: isPlayful
              ? LinearGradient(
                  colors: [
                    percentageColor.withValues(alpha: AppOpacity.soft),
                    percentageColor.withValues(alpha: AppOpacity.light),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isPlayful
              ? null
              : percentageColor.withValues(alpha: AppOpacity.soft),
          border: Border.all(
            color: percentageColor.withValues(alpha: AppOpacity.semi),
            width: isPlayful ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Mini progress indicator
            _MiniProgressIndicator(
              percentage: stats.attendancePercentage,
              color: percentageColor,
              isPlayful: isPlayful,
            ),
            SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Rate',
                    style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isPlayful ? AppSpacing.space2 : 0),
                  Row(
                    children: [
                      Text(
                        '$percentage%',
                        style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                          color: percentageColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: isPlayful ? AppSpacing.xs : AppSpacing.xxs),
                      Text(
                        '(${stats.totalDays} days)',
                        style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow if tappable
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: isPlayful ? AppIconSize.md : AppIconSize.sm,
                color: percentageColor.withValues(alpha: AppOpacity.dominant),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mini circular progress indicator for compact view.
class _MiniProgressIndicator extends StatelessWidget {
  const _MiniProgressIndicator({
    required this.percentage,
    required this.color,
    required this.isPlayful,
  });

  final double percentage;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = isPlayful ? AppSpacing.xxxl : AppSpacing.xxl;
    final strokeWidth = isPlayful ? AppSpacing.xxs : AppSpacing.space2 + 1;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
            ),
          ),
          // Progress
          TweenAnimationBuilder<double>(
            duration: AppDuration.slow,
            curve: AppCurves.emphasized,
            tween: Tween<double>(begin: 0, end: percentage / 100),
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              );
            },
          ),
          // Center icon
          Icon(
            percentage >= 85
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: isPlayful ? AppIconSize.xs : AppIconSize.badge,
            color: color,
          ),
        ],
      ),
    );
  }
}
