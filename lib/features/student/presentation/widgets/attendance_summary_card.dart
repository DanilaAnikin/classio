import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../domain/entities/entities.dart';

/// Card widget displaying attendance statistics summary.
///
/// Shows:
/// - Attendance percentage as circular progress
/// - Present, absent, late, and excused counts
/// - Color-coded based on attendance performance
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
      child: Container(
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
          gradient: isPlayful
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    stats.percentageColor.withValues(alpha: 0.15),
                    stats.percentageColor.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: isPlayful ? null : theme.colorScheme.surface,
          border: isPlayful
              ? null
              : Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isPlayful
                  ? stats.percentageColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isPlayful ? 16 : 8,
              offset: Offset(0, isPlayful ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: isPlayful ? 18 : 16,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isPlayful ? 16 : 12),
            ],
            Row(
              children: [
                // Circular progress indicator
                _AttendanceCircularProgress(
                  percentage: stats.attendancePercentage,
                  color: stats.percentageColor,
                  isPlayful: isPlayful,
                ),
                SizedBox(width: isPlayful ? 24 : 20),
                // Stats breakdown
                Expanded(
                  child: Column(
                    children: [
                      _StatRow(
                        label: 'Present',
                        value: stats.presentDays,
                        color: AttendanceStatus.present.color,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: isPlayful ? 10 : 8),
                      _StatRow(
                        label: 'Absent',
                        value: stats.absentDays,
                        color: AttendanceStatus.absent.color,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: isPlayful ? 10 : 8),
                      _StatRow(
                        label: 'Late',
                        value: stats.lateDays,
                        color: AttendanceStatus.late.color,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: isPlayful ? 10 : 8),
                      _StatRow(
                        label: 'Excused',
                        value: stats.excusedDays,
                        color: AttendanceStatus.excused.color,
                        isPlayful: isPlayful,
                      ),
                    ],
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
    final size = isPlayful ? 100.0 : 80.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: isPlayful ? 10 : 8,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: isPlayful ? 10 : 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Percentage text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: isPlayful ? 24 : 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                'Attendance',
                style: TextStyle(
                  fontSize: isPlayful ? 10 : 9,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Row showing a single statistic.
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

    return Row(
      children: [
        Container(
          width: isPlayful ? 14 : 12,
          height: isPlayful ? 14 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isPlayful ? 10 : 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 12 : 10,
            vertical: isPlayful ? 4 : 3,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Row(
      children: [
        _CompactStat(
          icon: Icons.check_circle,
          value: stats.presentDays,
          color: AttendanceStatus.present.color,
          isPlayful: isPlayful,
        ),
        SizedBox(width: isPlayful ? 16 : 12),
        _CompactStat(
          icon: Icons.cancel,
          value: stats.absentDays,
          color: AttendanceStatus.absent.color,
          isPlayful: isPlayful,
        ),
        SizedBox(width: isPlayful ? 16 : 12),
        _CompactStat(
          icon: Icons.schedule,
          value: stats.lateDays,
          color: AttendanceStatus.late.color,
          isPlayful: isPlayful,
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 12 : 10,
            vertical: isPlayful ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: stats.percentageColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          ),
          child: Text(
            '${stats.attendancePercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              fontWeight: FontWeight.w700,
              color: stats.percentageColor,
            ),
          ),
        ),
      ],
    );
  }
}

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
          size: isPlayful ? 18 : 16,
          color: color,
        ),
        SizedBox(width: isPlayful ? 4 : 3),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: isPlayful ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
