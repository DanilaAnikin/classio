import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/entities/entities.dart';
import '../providers/deputy_provider.dart';
import 'lesson_form_dialog.dart';
import 'manage_class_students_dialog.dart';
import 'schedule_grid.dart';

/// Schedule Editor Tab Widget.
///
/// Features:
/// - Class selector dropdown at top
/// - Weekly schedule grid (Mon-Fri columns, time rows)
/// - Click empty slot to add lesson
/// - Click existing lesson to edit/delete
class ScheduleEditorTab extends ConsumerWidget {
  const ScheduleEditorTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(deputySchoolClassesProvider(schoolId));
    final selectedClassId = ref.watch(selectedScheduleClassProvider.select((s) => s));

    return Column(
      children: [
        // Class Selector
        Container(
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: classesAsync.when(
            data: (classes) => _ClassSelector(
              classes: classes,
              selectedClassId: selectedClassId,
              isPlayful: isPlayful,
              schoolId: schoolId,
              onClassSelected: (classId) {
                ref.read(selectedScheduleClassProvider.notifier).select(classId);
              },
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => Text(
              'Error loading classes',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),

        // Schedule Grid
        Expanded(
          child: selectedClassId == null
              ? _EmptyClassSelection(isPlayful: isPlayful)
              : _ScheduleContent(
                  classId: selectedClassId,
                  schoolId: schoolId,
                  isPlayful: isPlayful,
                ),
        ),
      ],
    );
  }
}

class _ClassSelector extends StatelessWidget {
  const _ClassSelector({
    required this.classes,
    required this.selectedClassId,
    required this.isPlayful,
    required this.onClassSelected,
    required this.schoolId,
  });

  final List<ClassInfo> classes;
  final String? selectedClassId;
  final bool isPlayful;
  final ValueChanged<String?> onClassSelected;
  final String schoolId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedClass = selectedClassId != null
        ? classes.where((c) => c.id == selectedClassId).firstOrNull
        : null;

    return Row(
      children: [
        Icon(
          Icons.class_rounded,
          color: theme.colorScheme.primary,
          size: isPlayful ? 24 : 22,
        ),
        SizedBox(width: isPlayful ? 12 : 10),
        Text(
          'Class:',
          style: TextStyle(
            fontSize: isPlayful ? 16 : 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(width: isPlayful ? 12 : 10),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 16 : 12,
              vertical: isPlayful ? 4 : 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedClassId,
                hint: Text(
                  'Select a class',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                isExpanded: true,
                items: classes
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            '${c.name}${c.gradeLevel != null ? ' (Grade ${c.gradeLevel})' : ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: onClassSelected,
              ),
            ),
          ),
        ),
        if (selectedClass != null) ...[
          SizedBox(width: isPlayful ? 12 : 10),
          IconButton(
            icon: Icon(
              Icons.group_rounded,
              color: theme.colorScheme.primary,
            ),
            tooltip: 'Manage Students',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ManageClassStudentsDialog(
                  classInfo: selectedClass,
                  schoolId: schoolId,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _EmptyClassSelection extends StatelessWidget {
  const _EmptyClassSelection({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
              Icons.calendar_month_outlined,
              size: isPlayful ? 64 : 56,
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
            'Choose a class from the dropdown above\nto view and edit its schedule.',
            style: TextStyle(
              fontSize: isPlayful ? 15 : 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScheduleContent extends ConsumerWidget {
  const _ScheduleContent({
    required this.classId,
    required this.schoolId,
    required this.isPlayful,
  });

  final String classId;
  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lessonsByDay = ref.watch(scheduleLessonsByDayProvider(classId));
    final subjectsAsync = ref.watch(classSubjectsProvider(classId));
    final deputyState = ref.watch(deputyNotifierProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(classScheduleProvider(classId));
            ref.invalidate(classSubjectsProvider(classId));
          },
          child: ScheduleGrid(
            lessonsByDay: lessonsByDay,
            onEmptyCellTap: (dayOfWeek, time) {
              _showLessonDialog(
                context,
                ref,
                subjectsAsync: subjectsAsync,
                classId: classId,
                dayOfWeek: dayOfWeek,
                time: time,
              );
            },
            onLessonTap: (lesson) {
              _showLessonDialog(
                context,
                ref,
                subjectsAsync: subjectsAsync,
                classId: classId,
                lesson: lesson,
              );
            },
            onLessonDelete: (lesson) {
              _confirmDeleteLesson(context, ref, lesson);
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showLessonDialog(
              context,
              ref,
              subjectsAsync: subjectsAsync,
              classId: classId,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Lesson'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
        if (deputyState.isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _showLessonDialog(
    BuildContext context,
    WidgetRef ref, {
    required AsyncValue<List<Subject>> subjectsAsync,
    required String classId,
    ScheduleLesson? lesson,
    int? dayOfWeek,
    TimeOfDay? time,
  }) {
    subjectsAsync.when(
      data: (subjects) {
        showDialog(
          context: context,
          builder: (context) => LessonFormDialog(
            classId: classId,
            subjects: subjects,
            existingLesson: lesson,
            initialDayOfWeek: dayOfWeek,
            initialTime: time,
          ),
        );
      },
      loading: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading subjects...')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $error')),
        );
      },
    );
  }

  void _confirmDeleteLesson(
    BuildContext context,
    WidgetRef ref,
    ScheduleLesson lesson,
  ) {
    final theme = Theme.of(context);

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
              await ref
                  .read(deputyNotifierProvider.notifier)
                  .deleteLesson(lesson.id, classId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
