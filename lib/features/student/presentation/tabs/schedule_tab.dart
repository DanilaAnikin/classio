import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/student_provider.dart';
import '../widgets/widgets.dart';

/// Schedule tab showing the weekly timetable.
///
/// Provides a day selector at the top and displays
/// the lessons for the selected day.
class ScheduleTab extends ConsumerStatefulWidget {
  const ScheduleTab({
    super.key,
    required this.isPlayful,
  });

  final bool isPlayful;

  @override
  ConsumerState<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<ScheduleTab> {
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0-indexed, Monday = 0

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final isPlayful = widget.isPlayful;
    final weeklySchedule = ref.watch(myWeeklyScheduleProvider);

    return Column(
      children: [
        // Day selector
        _DaySelector(
          selectedDayIndex: _selectedDayIndex,
          onDaySelected: (index) => setState(() => _selectedDayIndex = index),
          isPlayful: isPlayful,
        ),
        // Schedule content
        Expanded(
          child: weeklySchedule.when(
            data: (schedule) {
              final daySchedule = schedule[_selectedDayIndex] ?? [];
              if (daySchedule.isEmpty) {
                return _EmptySchedule(
                  dayName: _weekdays[_selectedDayIndex],
                  isPlayful: isPlayful,
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(isPlayful ? 16 : 12),
                itemCount: daySchedule.length,
                itemBuilder: (context, index) {
                  final lesson = daySchedule[index];
                  return ScheduleLessonCard(
                    lesson: lesson,
                    isPlayful: isPlayful,
                    isFirst: index == 0,
                    isLast: index == daySchedule.length - 1,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error loading schedule: $e'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Day selector widget for choosing which day to view.
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.isPlayful,
  });

  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;
  final bool isPlayful;

  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isPlayful ? 16 : 12,
        horizontal: isPlayful ? 8 : 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = selectedDayIndex == index;
          final isWeekend = index >= 5;
          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(index),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isPlayful ? 4 : 2),
                padding: EdgeInsets.symmetric(
                  vertical: isPlayful ? 12 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isWeekend
                          ? theme.colorScheme.outline.withValues(alpha: 0.05)
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                  border: isSelected
                      ? null
                      : Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                ),
                child: Center(
                  child: Text(
                    _weekdays[index],
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isWeekend
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Empty state widget when no classes are scheduled.
class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({
    required this.dayName,
    required this.isPlayful,
  });

  final String dayName;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No classes on $dayName',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
