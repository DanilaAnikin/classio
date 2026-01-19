import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../../../schedule/presentation/widgets/widgets.dart';
import '../providers/student_provider.dart';

/// Student Schedule Page.
///
/// Shows the student's weekly class schedule with a day selector
/// and timeline view of lessons.
class StudentSchedulePage extends ConsumerStatefulWidget {
  const StudentSchedulePage({super.key});

  @override
  ConsumerState<StudentSchedulePage> createState() => _StudentSchedulePageState();
}

class _StudentSchedulePageState extends ConsumerState<StudentSchedulePage> {
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0-indexed, Monday = 0

  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<String> _fullWeekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final weeklySchedule = ref.watch(myWeeklyScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedule'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myWeeklyScheduleProvider);
        },
        child: Column(
          children: [
            // Week selector
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 16 : 12,
                vertical: isPlayful ? 12 : 8,
              ),
              child: const WeekSelector(),
            ),
            // Day selector
            Container(
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
                  final isSelected = _selectedDayIndex == index;
                  final isToday = DateTime.now().weekday - 1 == index;
                  final isWeekend = index >= 5;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDayIndex = index),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: isPlayful ? 4 : 2),
                        padding: EdgeInsets.symmetric(
                          vertical: isPlayful ? 14 : 12,
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
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                                    ),
                        ),
                        child: Center(
                          child: Text(
                            _weekdays[index],
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 12,
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
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Selected day header
            Container(
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
                    _fullWeekdays[_selectedDayIndex],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Schedule content
            Expanded(
              child: weeklySchedule.when(
                data: (schedule) {
                  final daySchedule = schedule[_selectedDayIndex] ?? [];
                  if (daySchedule.isEmpty) {
                    return _EmptySchedule(
                      dayName: _fullWeekdays[_selectedDayIndex],
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
                            onTap: () {
                              showLessonDetailDialog(
                                context: context,
                                lesson: lesson,
                              );
                            },
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
                  onRetry: () => ref.invalidate(myWeeklyScheduleProvider),
                ),
              ),
            ),
          ],
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
    this.onTap,
  });

  final Lesson lesson;
  final bool isPlayful;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isModified = lesson.modifiedFromStable;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
        decoration: isModified
            ? BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
              )
            : null,
        padding: isModified ? EdgeInsets.all(AppSpacing.xxs) : EdgeInsets.zero,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.subject.name,
                              style: TextStyle(
                                fontSize: isPlayful ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (isModified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'MODIFIED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.error,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (lesson.subject.teacherName != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: isPlayful ? 16 : 14,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            SizedBox(width: AppSpacing.xxs),
                            Text(
                              lesson.subject.teacherName!,
                              style: TextStyle(
                                fontSize: isPlayful ? 14 : 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.room_outlined,
                            size: isPlayful ? 16 : 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: AppSpacing.xxs),
                          Text(
                            lesson.room,
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            SizedBox(height: AppSpacing.xs),
            Text(
              'You have no classes scheduled for $dayName',
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
            SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md),
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
