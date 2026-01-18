import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../providers/parent_provider.dart';

/// Child Timetable Page for Parent.
///
/// Shows the selected child's weekly timetable with:
/// - Child selector dropdown (if multiple children)
/// - Week navigation (previous/current/next week)
/// - Day selector for viewing different days
/// - Timeline view of lessons
class ChildTimetablePage extends ConsumerStatefulWidget {
  const ChildTimetablePage({super.key});

  @override
  ConsumerState<ChildTimetablePage> createState() => _ChildTimetablePageState();
}

class _ChildTimetablePageState extends ConsumerState<ChildTimetablePage> {
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0-indexed, Monday = 0
  DateTime _selectedWeekStart = _getWeekStart(DateTime.now());

  static const List<String> _fullWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _previousWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
    });
  }

  void _goToCurrentWeek() {
    setState(() {
      _selectedWeekStart = _getWeekStart(DateTime.now());
      _selectedDayIndex = DateTime.now().weekday - 1;
    });
  }

  bool get _isCurrentWeek {
    final currentWeekStart = _getWeekStart(DateTime.now());
    return _selectedWeekStart.year == currentWeekStart.year &&
        _selectedWeekStart.month == currentWeekStart.month &&
        _selectedWeekStart.day == currentWeekStart.day;
  }

  String _getWeekRangeText() {
    final weekEnd = _selectedWeekStart.add(const Duration(days: 6));
    final startFormat = DateFormat('MMM d');
    final endFormat = _selectedWeekStart.month == weekEnd.month
        ? DateFormat('d, yyyy')
        : DateFormat('MMM d, yyyy');
    return '${startFormat.format(_selectedWeekStart)} - ${endFormat.format(weekEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final childrenAsync = ref.watch(myChildrenProvider);
    final selectedChildId = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Child\'s Timetable'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: childrenAsync.when(
        data: (children) {
          if (children.isEmpty) {
            return _EmptyChildrenState(isPlayful: isPlayful);
          }

          // Ensure a child is selected
          final currentChildId = selectedChildId ?? children.first.id;

          return Column(
            children: [
              // Child selector (only show if multiple children)
              if (children.length > 1)
                _ChildSelector(
                  children: children,
                  selectedChildId: currentChildId,
                  isPlayful: isPlayful,
                  onChildSelected: (childId) {
                    ref.read(selectedChildProvider.notifier).selectChild(childId);
                  },
                ),

              // Week navigation
              _WeekNavigator(
                weekRangeText: _getWeekRangeText(),
                isCurrentWeek: _isCurrentWeek,
                isPlayful: isPlayful,
                onPreviousWeek: _previousWeek,
                onNextWeek: _nextWeek,
                onGoToCurrentWeek: _goToCurrentWeek,
              ),

              // Day selector
              _DaySelector(
                selectedDayIndex: _selectedDayIndex,
                selectedWeekStart: _selectedWeekStart,
                isPlayful: isPlayful,
                onDaySelected: (index) {
                  setState(() => _selectedDayIndex = index);
                },
              ),

              // Selected day header
              _DayHeader(
                dayName: _fullWeekdays[_selectedDayIndex],
                date: _selectedWeekStart.add(Duration(days: _selectedDayIndex)),
                isPlayful: isPlayful,
              ),

              // Schedule content
              Expanded(
                child: _ScheduleContent(
                  childId: currentChildId,
                  selectedDayIndex: _selectedDayIndex,
                  selectedWeekStart: _selectedWeekStart,
                  isPlayful: isPlayful,
                  onRefresh: () {
                    ref.invalidate(
                        childWeeklyScheduleForWeekProvider((
                          childId: currentChildId,
                          weekStart: _selectedWeekStart,
                        )));
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: 'Error loading children: $e',
          isPlayful: isPlayful,
          onRetry: () => ref.invalidate(myChildrenProvider),
        ),
      ),
    );
  }
}

/// Child selector dropdown.
class _ChildSelector extends StatelessWidget {
  const _ChildSelector({
    required this.children,
    required this.selectedChildId,
    required this.isPlayful,
    required this.onChildSelected,
  });

  final List<AppUser> children;
  final String selectedChildId;
  final bool isPlayful;
  final ValueChanged<String> onChildSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.child_care_rounded,
            size: isPlayful ? 20 : 18,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: isPlayful ? 10 : 8),
          Text(
            'Child:',
            style: TextStyle(
              fontSize: isPlayful ? 15 : 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: isPlayful ? 12 : 8),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedChildId,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  items: children.map((child) {
                    return DropdownMenuItem<String>(
                      value: child.id,
                      child: Text(child.fullName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onChildSelected(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Week navigation controls.
class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.weekRangeText,
    required this.isCurrentWeek,
    required this.isPlayful,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onGoToCurrentWeek,
  });

  final String weekRangeText;
  final bool isCurrentWeek;
  final bool isPlayful;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onGoToCurrentWeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: isPlayful ? 28 : 24,
            ),
            onPressed: onPreviousWeek,
            tooltip: 'Previous week',
          ),
          GestureDetector(
            onTap: isCurrentWeek ? null : onGoToCurrentWeek,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 16 : 12,
                vertical: isPlayful ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: isCurrentWeek
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.outline.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
                border: Border.all(
                  color: isCurrentWeek
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCurrentWeek) ...[
                    Icon(
                      Icons.today_rounded,
                      size: isPlayful ? 16 : 14,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: isPlayful ? 6 : 4),
                  ],
                  Text(
                    weekRangeText,
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      fontWeight: isCurrentWeek ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrentWeek
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              size: isPlayful ? 28 : 24,
            ),
            onPressed: onNextWeek,
            tooltip: 'Next week',
          ),
        ],
      ),
    );
  }
}

/// Day selector row.
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDayIndex,
    required this.selectedWeekStart,
    required this.isPlayful,
    required this.onDaySelected,
  });

  final int selectedDayIndex;
  final DateTime selectedWeekStart;
  final bool isPlayful;
  final ValueChanged<int> onDaySelected;

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
    final now = DateTime.now();
    final todayWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final isCurrentWeek = selectedWeekStart.year == todayWeekStart.year &&
        selectedWeekStart.month == todayWeekStart.month &&
        selectedWeekStart.day == todayWeekStart.day;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isPlayful ? 16 : 12,
        horizontal: isPlayful ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = selectedDayIndex == index;
          final isToday = isCurrentWeek && now.weekday - 1 == index;
          final isWeekend = index >= 5;
          final dayDate = selectedWeekStart.add(Duration(days: index));

          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(index),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isPlayful ? 4 : 2),
                padding: EdgeInsets.symmetric(
                  vertical: isPlayful ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isWeekend
                          ? theme.colorScheme.outline.withValues(alpha: 0.05)
                          : theme.colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                  border: isToday && !isSelected
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : isSelected
                          ? null
                          : Border.all(
                              color:
                                  theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _weekdays[index],
                      style: TextStyle(
                        fontSize: isPlayful ? 12 : 11,
                        fontWeight: isSelected || isToday
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? theme.colorScheme.primary
                                : isWeekend
                                    ? theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dayDate.day.toString(),
                      style: TextStyle(
                        fontSize: isPlayful ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isToday
                                ? theme.colorScheme.primary
                                : isWeekend
                                    ? theme.colorScheme.onSurface
                                        .withValues(alpha: 0.4)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Day header showing full day name and date.
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.dayName,
    required this.date,
    required this.isPlayful,
  });

  final String dayName;
  final DateTime date;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM d, yyyy');

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 12 : 8,
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: isPlayful ? 20 : 18,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: isPlayful ? 10 : 8),
          Text(
            dayName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateFormat.format(date),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

/// Schedule content area with lessons.
class _ScheduleContent extends ConsumerWidget {
  const _ScheduleContent({
    required this.childId,
    required this.selectedDayIndex,
    required this.selectedWeekStart,
    required this.isPlayful,
    required this.onRefresh,
  });

  final String childId;
  final int selectedDayIndex;
  final DateTime selectedWeekStart;
  final bool isPlayful;
  final VoidCallback onRefresh;

  static const List<String> _fullWeekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklySchedule = ref.watch(
        childWeeklyScheduleForWeekProvider((
          childId: childId,
          weekStart: selectedWeekStart,
        )));

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: weeklySchedule.when(
        data: (schedule) {
          // Convert 0-indexed to 1-indexed for the map lookup
          final daySchedule = schedule[selectedDayIndex + 1] ?? [];

          if (daySchedule.isEmpty) {
            return _EmptySchedule(
              dayName: _fullWeekdays[selectedDayIndex],
              isPlayful: isPlayful,
            );
          }

          return ResponsiveCenterScrollView(
            maxWidth: 800,
            padding: EdgeInsets.all(isPlayful ? 16 : 12),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                ...daySchedule.asMap().entries.map((entry) {
                  final index = entry.key;
                  final lesson = entry.value;
                  return _ScheduleLessonCard(
                    lesson: lesson,
                    isPlayful: isPlayful,
                    isFirst: index == 0,
                    isLast: index == daySchedule.length - 1,
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(
          message: 'Error loading schedule: $e',
          isPlayful: isPlayful,
          onRetry: onRefresh,
        ),
      ),
    );
  }
}

/// Card for a lesson in the schedule view with timeline.
class _ScheduleLessonCard extends StatelessWidget {
  const _ScheduleLessonCard({
    required this.lesson,
    required this.isPlayful,
    required this.isFirst,
    required this.isLast,
  });

  final Lesson lesson;
  final bool isPlayful;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: isPlayful ? 60 : 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(lesson.startTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(lesson.endTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isPlayful ? 16 : 12),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: isPlayful ? 14 : 12,
                height: isPlayful ? 14 : 12,
                decoration: BoxDecoration(
                  color: Color(lesson.subject.color),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: isPlayful ? 70 : 60,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
            ],
          ),
          SizedBox(width: isPlayful ? 16 : 12),
          // Lesson content
          Expanded(
            child: Card(
              elevation: isPlayful ? 2 : 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                side: isPlayful
                    ? BorderSide.none
                    : BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Container(
                padding: EdgeInsets.all(isPlayful ? 16 : 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  border: Border(
                    left: BorderSide(
                      color: Color(lesson.subject.color),
                      width: isPlayful ? 4 : 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.subject.name,
                      style: TextStyle(
                        fontSize: isPlayful ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (lesson.subject.teacherName != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isPlayful ? 16 : 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lesson.subject.teacherName!,
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 12,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.room_outlined,
                          size: isPlayful ? 16 : 14,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.room,
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no children are linked.
class _EmptyChildrenState extends StatelessWidget {
  const _EmptyChildrenState({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isPlayful ? 80 : 72,
              height: isPlayful ? 80 : 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.child_care_outlined,
                size: isPlayful ? 40 : 36,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: isPlayful ? 24 : 20),
            Text(
              'No Children Linked',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Contact your school administrator to link your children',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no classes scheduled.
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
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 32 : 24),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPlayful ? 80 : 72,
                height: isPlayful ? 80 : 72,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_available_outlined,
                  size: isPlayful ? 40 : 36,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: isPlayful ? 24 : 20),
              Text(
                'No Classes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No classes scheduled for $dayName',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.isPlayful,
    required this.onRetry,
  });

  final String message;
  final bool isPlayful;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
