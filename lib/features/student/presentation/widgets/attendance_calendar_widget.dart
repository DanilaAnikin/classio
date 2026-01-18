import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../domain/entities/entities.dart';

/// Calendar widget displaying attendance status for each day.
///
/// Features:
/// - Monthly view with color-coded days
/// - Navigation between months
/// - Legend explaining color meanings
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
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        color: theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPlayful ? 0.08 : 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
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
          SizedBox(height: isPlayful ? 20 : 16),

          // Weekday headers
          _WeekdayHeaders(isPlayful: isPlayful),
          SizedBox(height: isPlayful ? 12 : 8),

          // Calendar grid
          _CalendarGrid(
            month: month,
            year: year,
            attendanceData: attendanceData,
            onDayTap: onDayTap,
            isPlayful: isPlayful,
          ),
          SizedBox(height: isPlayful ? 20 : 16),

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
        IconButton(
          onPressed: () {
            final newDate = DateTime(year, month - 1, 1);
            onMonthChanged(newDate.month, newDate.year);
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            size: isPlayful ? 28 : 24,
            color: theme.colorScheme.primary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        Text(
          monthName,
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {
            final newDate = DateTime(year, month + 1, 1);
            onMonthChanged(newDate.month, newDate.year);
          },
          icon: Icon(
            Icons.chevron_right_rounded,
            size: isPlayful ? 28 : 24,
            color: theme.colorScheme.primary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
      ],
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
              style: TextStyle(
                fontSize: isPlayful ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
          padding: EdgeInsets.only(bottom: isPlayful ? 8 : 6),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = isPlayful ? 36.0 : 32.0;

    Color backgroundColor;
    Color textColor;
    BoxBorder? border;

    if (status != null) {
      backgroundColor = status!.color.withValues(alpha: isPlayful ? 0.8 : 0.7);
      textColor = Colors.white;
    } else if (isWeekend) {
      backgroundColor = Colors.transparent;
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
    } else {
      backgroundColor = theme.colorScheme.outline.withValues(alpha: 0.05);
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }

    if (isToday) {
      border = Border.all(
        color: theme.colorScheme.primary,
        width: 2,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: border,
            boxShadow: status != null && isPlayful
                ? [
                    BoxShadow(
                      color: status!.color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontSize: isPlayful ? 14 : 13,
                fontWeight: isToday || status != null
                    ? FontWeight.w700
                    : FontWeight.w500,
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
      spacing: isPlayful ? 16 : 12,
      runSpacing: isPlayful ? 8 : 6,
      children: [
        _LegendItem(
          color: DailyAttendanceStatus.allPresent.color,
          label: 'Present',
          isPlayful: isPlayful,
        ),
        _LegendItem(
          color: DailyAttendanceStatus.wasLate.color,
          label: 'Late',
          isPlayful: isPlayful,
        ),
        _LegendItem(
          color: DailyAttendanceStatus.partialAbsent.color,
          label: 'Partial',
          isPlayful: isPlayful,
        ),
        _LegendItem(
          color: DailyAttendanceStatus.allAbsent.color,
          label: 'Absent',
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isPlayful,
  });

  final Color color;
  final String label;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isPlayful ? 14 : 12,
          height: isPlayful ? 14 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: isPlayful ? 6 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 12 : 11,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
