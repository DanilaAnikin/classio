import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';

/// Calendar widget displaying attendance status for each day.
///
/// Features:
/// - Monthly view with color-coded days
/// - Navigation between months
/// - Legend explaining color meanings
/// - Theme-aware styling (Clean vs Playful)
class AttendanceCalendarWidget extends ConsumerWidget {
  const AttendanceCalendarWidget({
    super.key,
    required this.month,
    required this.year,
    required this.attendanceData,
    required this.onMonthChanged,
    this.onDayTap,
  });

  /// The month to display (1-12).
  final int month;

  /// The year to display.
  final int year;

  /// Map of dates to their attendance status.
  final Map<DateTime, DailyAttendanceStatus> attendanceData;

  /// Callback when the month is changed.
  final void Function(int month, int year) onMonthChanged;

  /// Optional callback when a day is tapped.
  final void Function(DateTime date)? onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        color: theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
              ),
        boxShadow: AppShadows.card(isPlayful: isPlayful),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month navigation header
          _MonthNavigationHeader(
            month: month,
            year: year,
            onMonthChanged: onMonthChanged,
            isPlayful: isPlayful,
          ),
          SizedBox(height: isPlayful ? AppSpacing.lg : AppSpacing.md),

          // Weekday headers
          _WeekdayHeaders(isPlayful: isPlayful),
          SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),

          // Calendar grid
          _CalendarGrid(
            month: month,
            year: year,
            attendanceData: attendanceData,
            onDayTap: onDayTap,
            isPlayful: isPlayful,
          ),
          SizedBox(height: isPlayful ? AppSpacing.lg : AppSpacing.md),

          // Legend
          _Legend(isPlayful: isPlayful),
        ],
      ),
    );
  }
}

/// Month navigation header with previous/next buttons.
class _MonthNavigationHeader extends StatelessWidget {
  const _MonthNavigationHeader({
    required this.month,
    required this.year,
    required this.onMonthChanged,
    required this.isPlayful,
  });

  final int month;
  final int year;
  final void Function(int month, int year) onMonthChanged;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthDate = DateTime(year, month, 1);
    final monthName = DateFormat('MMMM yyyy').format(monthDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavigationButton(
          icon: Icons.chevron_left_rounded,
          onPressed: () {
            final newDate = DateTime(year, month - 1, 1);
            onMonthChanged(newDate.month, newDate.year);
          },
          isPlayful: isPlayful,
        ),
        Text(
          monthName,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        _NavigationButton(
          icon: Icons.chevron_right_rounded,
          onPressed: () {
            final newDate = DateTime(year, month + 1, 1);
            onMonthChanged(newDate.month, newDate.year);
          },
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

/// Navigation button for month switching.
class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.isPlayful,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: isPlayful ? AppIconSize.lg : AppIconSize.md,
        color: theme.colorScheme.primary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.button(isPlayful: isPlayful),
        ),
      ),
    );
  }
}

/// Weekday headers (Mon, Tue, Wed, etc.).
class _WeekdayHeaders extends StatelessWidget {
  const _WeekdayHeaders({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      children: weekdays.map((day) {
        final isWeekend = day == 'Sat' || day == 'Sun';
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy)
                    : theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// The main calendar grid.
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.year,
    required this.attendanceData,
    required this.onDayTap,
    required this.isPlayful,
  });

  final int month;
  final int year;
  final Map<DateTime, DailyAttendanceStatus> attendanceData;
  final void Function(DateTime date)? onDayTap;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Find the weekday of the first day (1=Monday, 7=Sunday)
    // We want Monday to be at position 0
    final firstWeekday = firstDayOfMonth.weekday;
    final startOffset = firstWeekday - 1;

    // Calculate total cells needed (including empty cells at start)
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    final today = DateTime.now();
    final isCurrentMonth = today.year == year && today.month == month;

    return Column(
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: isPlayful ? AppSpacing.xs : AppSpacing.xxs),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                // Empty cell
                return const Expanded(child: SizedBox());
              }

              final date = DateTime(year, month, dayNumber);
              final isToday = isCurrentMonth && today.day == dayNumber;
              final isWeekend = date.weekday == 6 || date.weekday == 7;
              final status = attendanceData[date];

              return Expanded(
                child: _DayCell(
                  day: dayNumber,
                  status: status,
                  isToday: isToday,
                  isWeekend: isWeekend,
                  isPlayful: isPlayful,
                  onTap: onDayTap != null ? () => onDayTap!(date) : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

/// Individual day cell in the calendar.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.status,
    required this.isToday,
    required this.isWeekend,
    required this.isPlayful,
    this.onTap,
  });

  final int day;
  final DailyAttendanceStatus? status;
  final bool isToday;
  final bool isWeekend;
  final bool isPlayful;
  final VoidCallback? onTap;

  Color _getStatusColor() {
    if (status == null) return Colors.transparent;
    switch (status!) {
      case DailyAttendanceStatus.allPresent:
        return isPlayful
            ? PlayfulColors.attendancePresent
            : CleanColors.attendancePresent;
      case DailyAttendanceStatus.partialAbsent:
        return isPlayful
            ? PlayfulColors.attendanceLate
            : CleanColors.attendanceLate;
      case DailyAttendanceStatus.allAbsent:
        return isPlayful
            ? PlayfulColors.attendanceAbsent
            : CleanColors.attendanceAbsent;
      case DailyAttendanceStatus.wasLate:
        return isPlayful
            ? PlayfulColors.attendanceExcused
            : CleanColors.attendanceExcused;
      case DailyAttendanceStatus.noData:
        return isPlayful
            ? PlayfulColors.attendanceUnknown
            : CleanColors.attendanceUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = isPlayful ? AppSpacing.xxxl : AppSpacing.xxl;
    final statusColor = _getStatusColor();

    Color backgroundColor;
    Color textColor;
    BoxBorder? border;

    if (status != null && status != DailyAttendanceStatus.noData) {
      // Status day - show status color
      backgroundColor = statusColor.withValues(
        alpha: isPlayful ? AppOpacity.dominant : AppOpacity.heavy,
      );
      textColor = Colors.white;
    } else if (isWeekend) {
      // Weekend - lighter appearance
      backgroundColor = Colors.transparent;
      textColor = theme.colorScheme.onSurface.withValues(alpha: AppOpacity.strong);
    } else {
      // Regular day - subtle background
      backgroundColor = theme.colorScheme.outline.withValues(alpha: AppOpacity.subtle);
      textColor = theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant);
    }

    if (isToday) {
      border = Border.all(
        color: theme.colorScheme.primary,
        width: isPlayful ? AppSpacing.space2 : 1.5,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: border,
            boxShadow: status != null &&
                    status != DailyAttendanceStatus.noData &&
                    isPlayful
                ? [
                    BoxShadow(
                      color: statusColor.withValues(alpha: AppOpacity.semi),
                      blurRadius: AppSpacing.xs,
                      offset: const Offset(0, AppSpacing.space2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                fontWeight:
                    isToday || status != null ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Legend explaining the color meanings.
class _Legend extends StatelessWidget {
  const _Legend({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: isPlayful ? AppSpacing.md : AppSpacing.sm,
      runSpacing: isPlayful ? AppSpacing.xs : AppSpacing.xxs,
      children: [
        _LegendItem(
          status: DailyAttendanceStatus.allPresent,
          label: 'Present',
          isPlayful: isPlayful,
        ),
        _LegendItem(
          status: DailyAttendanceStatus.wasLate,
          label: 'Late',
          isPlayful: isPlayful,
        ),
        _LegendItem(
          status: DailyAttendanceStatus.partialAbsent,
          label: 'Partial',
          isPlayful: isPlayful,
        ),
        _LegendItem(
          status: DailyAttendanceStatus.allAbsent,
          label: 'Absent',
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

/// Individual legend item.
class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.status,
    required this.label,
    required this.isPlayful,
  });

  final DailyAttendanceStatus status;
  final String label;
  final bool isPlayful;

  Color _getStatusColor() {
    switch (status) {
      case DailyAttendanceStatus.allPresent:
        return isPlayful
            ? PlayfulColors.attendancePresent
            : CleanColors.attendancePresent;
      case DailyAttendanceStatus.partialAbsent:
        return isPlayful
            ? PlayfulColors.attendanceLate
            : CleanColors.attendanceLate;
      case DailyAttendanceStatus.allAbsent:
        return isPlayful
            ? PlayfulColors.attendanceAbsent
            : CleanColors.attendanceAbsent;
      case DailyAttendanceStatus.wasLate:
        return isPlayful
            ? PlayfulColors.attendanceExcused
            : CleanColors.attendanceExcused;
      case DailyAttendanceStatus.noData:
        return isPlayful
            ? PlayfulColors.attendanceUnknown
            : CleanColors.attendanceUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor();
    final dotSize = isPlayful ? AppSpacing.sm : AppSpacing.xs;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isPlayful ? AppSpacing.xxs : AppSpacing.space2),
        Text(
          label,
          style: AppTypography.caption(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
          ),
        ),
      ],
    );
  }
}
