import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/providers/theme_provider.dart';
import '../../domain/entities/entities.dart';
import 'schedule_lesson_tile.dart';

/// A grid widget displaying the weekly schedule.
///
/// Shows a grid with days as columns and time slots as rows.
/// Each cell can display a lesson or be empty (clickable to add).
class ScheduleGrid extends ConsumerWidget {
  const ScheduleGrid({
    super.key,
    required this.lessonsByDay,
    required this.onEmptyCellTap,
    required this.onLessonTap,
    required this.onLessonDelete,
    this.showWeekend = false,
  });

  /// Lessons organized by day of week (1=Monday to 7=Sunday).
  final Map<int, List<ScheduleLesson>> lessonsByDay;

  /// Callback when an empty time slot is tapped.
  final void Function(int dayOfWeek, TimeOfDay time) onEmptyCellTap;

  /// Callback when a lesson is tapped for editing.
  final void Function(ScheduleLesson lesson) onLessonTap;

  /// Callback when a lesson should be deleted.
  final void Function(ScheduleLesson lesson) onLessonDelete;

  /// Whether to show weekend columns.
  final bool showWeekend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    final days = showWeekend ? [1, 2, 3, 4, 5, 6, 7] : [1, 2, 3, 4, 5];
    final timeSlots = ScheduleConfig.defaultTimeSlots;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Day headers
              _DayHeaders(
                days: days,
                isPlayful: isPlayful,
              ),

              // Grid content
              ...List.generate(timeSlots.length, (slotIndex) {
                final slotTime = timeSlots[slotIndex];
                final slotEndTime = ScheduleConfig.getEndTime(slotTime);

                return _TimeSlotRow(
                  slotTime: slotTime,
                  slotEndTime: slotEndTime,
                  days: days,
                  lessonsByDay: lessonsByDay,
                  isPlayful: isPlayful,
                  onEmptyCellTap: onEmptyCellTap,
                  onLessonTap: onLessonTap,
                  onLessonDelete: onLessonDelete,
                  isLastRow: slotIndex == timeSlots.length - 1,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// Day headers row for the schedule grid.
class _DayHeaders extends StatelessWidget {
  const _DayHeaders({
    required this.days,
    required this.isPlayful,
  });

  final List<int> days;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = (screenWidth - 60) / days.length;

    return Container(
      decoration: BoxDecoration(
        color: isPlayful
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Time column header
          SizedBox(
            width: 60,
            height: 48,
            child: Center(
              child: Text(
                'Time',
                style: TextStyle(
                  fontSize: isPlayful ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          // Day column headers
          ...days.map((day) {
            final isToday = DateTime.now().weekday == day;
            return SizedBox(
              width: columnWidth.clamp(80, 150),
              height: 48,
              child: Container(
                decoration: isToday
                    ? BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                child: Center(
                  child: Text(
                    ScheduleConfig.shortDayLabels[day] ?? '',
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                      color: isToday
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// A row representing a time slot in the schedule grid.
class _TimeSlotRow extends StatelessWidget {
  const _TimeSlotRow({
    required this.slotTime,
    required this.slotEndTime,
    required this.days,
    required this.lessonsByDay,
    required this.isPlayful,
    required this.onEmptyCellTap,
    required this.onLessonTap,
    required this.onLessonDelete,
    required this.isLastRow,
  });

  final TimeOfDay slotTime;
  final TimeOfDay slotEndTime;
  final List<int> days;
  final Map<int, List<ScheduleLesson>> lessonsByDay;
  final bool isPlayful;
  final void Function(int dayOfWeek, TimeOfDay time) onEmptyCellTap;
  final void Function(ScheduleLesson lesson) onLessonTap;
  final void Function(ScheduleLesson lesson) onLessonDelete;
  final bool isLastRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final columnWidth = (screenWidth - 60) / days.length;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLastRow
              ? BorderSide.none
              : BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          SizedBox(
            width: 60,
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    ScheduleConfig.formatTime(slotTime),
                    style: TextStyle(
                      fontSize: isPlayful ? 12 : 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    ScheduleConfig.formatTime(slotEndTime),
                    style: TextStyle(
                      fontSize: isPlayful ? 10 : 9,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Day cells
          ...days.map((day) {
            final lesson = _getLessonAtTime(day, slotTime);
            return SizedBox(
              width: columnWidth.clamp(80, 150),
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: lesson != null
                    ? ScheduleLessonTile(
                        lesson: lesson,
                        isPlayful: isPlayful,
                        onTap: () => onLessonTap(lesson),
                        onDelete: () => onLessonDelete(lesson),
                      )
                    : _EmptyCell(
                        dayOfWeek: day,
                        time: slotTime,
                        isPlayful: isPlayful,
                        onTap: () => onEmptyCellTap(day, slotTime),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Returns the lesson at the given day and time, if any.
  ScheduleLesson? _getLessonAtTime(int day, TimeOfDay time) {
    final lessons = lessonsByDay[day] ?? [];
    final timeMinutes = time.hour * 60 + time.minute;

    for (final lesson in lessons) {
      final lessonStart = lesson.startTime.hour * 60 + lesson.startTime.minute;
      final lessonEnd = lesson.endTime.hour * 60 + lesson.endTime.minute;

      // Check if the time slot overlaps with the lesson
      if (timeMinutes >= lessonStart && timeMinutes < lessonEnd) {
        return lesson;
      }
    }
    return null;
  }
}

/// Empty cell widget that can be tapped to add a lesson.
class _EmptyCell extends StatelessWidget {
  const _EmptyCell({
    required this.dayOfWeek,
    required this.time,
    required this.isPlayful,
    required this.onTap,
  });

  final int dayOfWeek;
  final TimeOfDay time;
  final bool isPlayful;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add_rounded,
              size: isPlayful ? 24 : 20,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}
