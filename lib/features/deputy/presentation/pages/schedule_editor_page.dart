import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../schedule/presentation/widgets/week_selector.dart';
import '../../domain/entities/entities.dart';
import '../providers/deputy_provider.dart';
import '../widgets/widgets.dart';

/// Schedule Editor Page for managing class timetables.
///
/// Features:
/// - Class selector dropdown at top
/// - Week view grid showing Mon-Fri with time slots
/// - Click to add lessons to empty slots
/// - Click existing lessons to edit/delete
class ScheduleEditorPage extends ConsumerStatefulWidget {
  const ScheduleEditorPage({
    super.key,
    this.initialClassId,
  });

  /// Optional initial class ID to display.
  final String? initialClassId;

  @override
  ConsumerState<ScheduleEditorPage> createState() => _ScheduleEditorPageState();
}

class _ScheduleEditorPageState extends ConsumerState<ScheduleEditorPage> {
  String? _selectedClassId;
  bool _showWeekend = false;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.initialClassId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final authState = ref.watch(authNotifierProvider);
    final schoolId = authState.userSchoolId;

    if (schoolId == null) {
      return _buildNoSchoolState(context, theme);
    }

    final classesAsync = ref.watch(deputySchoolClassesProvider(schoolId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Editor'),
        centerTitle: true,
        actions: [
          // Weekend toggle
          IconButton(
            icon: Icon(_showWeekend ? Icons.weekend : Icons.work_outline),
            tooltip: _showWeekend ? 'Hide Weekend' : 'Show Weekend',
            onPressed: () {
              setState(() {
                _showWeekend = !_showWeekend;
              });
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              if (_selectedClassId != null) {
                ref.invalidate(classScheduleProvider(_selectedClassId!));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.03),
                    theme.colorScheme.secondary.withValues(alpha: 0.03),
                    theme.colorScheme.tertiary.withValues(alpha: 0.03),
                  ],
                ),
              )
            : null,
        child: Column(
          children: [
            // Class Selector
            _ClassSelector(
              classesAsync: classesAsync,
              selectedClassId: _selectedClassId,
              onClassSelected: (classId) {
                setState(() {
                  _selectedClassId = classId;
                });
              },
              isPlayful: isPlayful,
            ),

            // Schedule Grid or Empty State
            Expanded(
              child: _selectedClassId == null
                  ? _buildSelectClassState(context, theme, isPlayful)
                  : _ScheduleContent(
                      classId: _selectedClassId!,
                      showWeekend: _showWeekend,
                      isPlayful: isPlayful,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSchoolState(BuildContext context, ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Editor'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No School Assigned',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are not assigned to any school.',
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

  Widget _buildSelectClassState(
    BuildContext context,
    ThemeData theme,
    bool isPlayful,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 24 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a Class',
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a class from the dropdown above to view and edit its schedule.',
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Class selector dropdown widget.
class _ClassSelector extends StatelessWidget {
  const _ClassSelector({
    required this.classesAsync,
    required this.selectedClassId,
    required this.onClassSelected,
    required this.isPlayful,
  });

  final AsyncValue<List<ClassInfo>> classesAsync;
  final String? selectedClassId;
  final ValueChanged<String?> onClassSelected;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ResponsiveCenter(
        maxWidth: 1200,
        child: Row(
          children: [
            Icon(
              Icons.class_rounded,
              size: isPlayful ? 24 : 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Class:',
              style: TextStyle(
                fontSize: isPlayful ? 16 : 15,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: classesAsync.when(
                data: (classes) => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                  initialValue: selectedClassId,
                  isExpanded: true,
                  hint: const Text('Select a class'),
                  items: classes.map((classInfo) {
                    return DropdownMenuItem(
                      value: classInfo.id,
                      child: Text(
                        'Class ${classInfo.name} (Grade ${classInfo.gradeLevel ?? "?"})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: onClassSelected,
                ),
                loading: () => Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (error, stack) => Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Failed to load classes',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
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

/// Schedule content widget that shows the grid.
class _ScheduleContent extends ConsumerWidget {
  const _ScheduleContent({
    required this.classId,
    required this.showWeekend,
    required this.isPlayful,
  });

  final String classId;
  final bool showWeekend;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weekView = ref.watch(selectedWeekViewProvider);
    final isViewingStable = weekView == WeekViewType.stable;
    final scheduleAsync = ref.watch(classScheduleProvider(classId));
    final subjectsAsync = ref.watch(classSubjectsProvider(classId));

    return Column(
      children: [
        // Week selector - always visible when a class is selected
        Padding(
          padding: EdgeInsets.all(isPlayful ? 12 : 8),
          child: const WeekSelector(),
        ),

        // Info banner for stable view
        if (isViewingStable)
          Container(
            margin: EdgeInsets.symmetric(horizontal: isPlayful ? 12 : 8),
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 16 : 12,
              vertical: isPlayful ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: isPlayful ? 20 : 18,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Editing stable timetable - changes apply to all weeks unless overridden',
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Schedule content based on async state
        Expanded(
          child: scheduleAsync.when(
            data: (lessons) {
              // Group lessons by day
              final lessonsByDay = <int, List<ScheduleLesson>>{
                for (int i = 1; i <= 7; i++) i: <ScheduleLesson>[],
              };

              for (final lesson in lessons) {
                lessonsByDay[lesson.dayOfWeek]!.add(lesson);
              }

              // Sort each day by start time
              for (final day in lessonsByDay.keys) {
                lessonsByDay[day]!.sort((a, b) {
                  final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
                  final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
                  return aMinutes.compareTo(bMinutes);
                });
              }

              return Column(
                children: [
                  // Stats bar
                  _ScheduleStatsBar(
                    totalLessons: lessons.length,
                    isPlayful: isPlayful,
                    isViewingStable: isViewingStable,
                  ),

                  // Grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(classScheduleProvider(classId));
                      },
                      child: ScheduleGrid(
                        lessonsByDay: lessonsByDay,
                        showWeekend: showWeekend,
                        onEmptyCellTap: (dayOfWeek, time) {
                          _showLessonDialog(
                            context,
                            ref,
                            classId,
                            subjectsAsync,
                            initialDayOfWeek: dayOfWeek,
                            initialTime: time,
                          );
                        },
                        onLessonTap: (lesson) {
                          _showLessonDialog(
                            context,
                            ref,
                            classId,
                            subjectsAsync,
                            existingLesson: lesson,
                          );
                        },
                        onLessonDelete: (lesson) {
                          _confirmDeleteLesson(context, ref, lesson);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.error.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(classScheduleProvider(classId));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLessonDialog(
    BuildContext context,
    WidgetRef ref,
    String classId,
    AsyncValue<List<dynamic>> subjectsAsync, {
    int? initialDayOfWeek,
    TimeOfDay? initialTime,
    ScheduleLesson? existingLesson,
  }) {
    subjectsAsync.when(
      data: (subjects) {
        showDialog(
          context: context,
          builder: (context) => LessonFormDialog(
            classId: classId,
            subjects: subjects.cast(),
            existingLesson: existingLesson,
            initialDayOfWeek: initialDayOfWeek,
            initialTime: initialTime,
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loading subjects...'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load subjects: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }

  void _confirmDeleteLesson(
    BuildContext context,
    WidgetRef ref,
    ScheduleLesson lesson,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text(
          'Are you sure you want to delete "${lesson.subjectName}" from the schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final notifier = ref.read(deputyNotifierProvider.notifier);
                await notifier.deleteLesson(lesson.id, classId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lesson deleted'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete lesson: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Stats bar showing schedule summary.
class _ScheduleStatsBar extends StatelessWidget {
  const _ScheduleStatsBar({
    required this.totalLessons,
    required this.isPlayful,
    this.isViewingStable = false,
  });

  final int totalLessons;
  final bool isPlayful;
  final bool isViewingStable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: isPlayful
            ? theme.colorScheme.primary.withValues(alpha: 0.05)
            : theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isViewingStable ? Icons.schedule : Icons.event_note_rounded,
            size: isPlayful ? 18 : 16,
            color: isViewingStable
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            '$totalLessons ${totalLessons == 1 ? "lesson" : "lessons"} ${isViewingStable ? "(stable)" : "scheduled"}',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          Text(
            isViewingStable
                ? 'Editing base schedule'
                : 'Tap + to override lessons',
            style: TextStyle(
              fontSize: isPlayful ? 12 : 11,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
