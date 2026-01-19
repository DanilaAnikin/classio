import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/lesson.dart';
import '../../domain/entities/attendance_entity.dart';
import '../providers/teacher_provider.dart';
import '../widgets/attendance_toggle.dart';

/// Attendance tab for marking student attendance by lesson.
class AttendanceTab extends ConsumerStatefulWidget {
  const AttendanceTab({super.key});

  @override
  ConsumerState<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<AttendanceTab> {
  Lesson? _selectedLesson;

  @override
  Widget build(BuildContext context) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final selectedDate = ref.watch(selectedDateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date Picker
        _DatePickerHeader(
          selectedDate: selectedDate,
          isPlayful: isPlayful,
          onDateChanged: (date) {
            ref.read(selectedDateProvider.notifier).select(date);
            setState(() => _selectedLesson = null);
          },
        ),

        // Lesson Selector
        _LessonSelector(
          selectedLesson: _selectedLesson,
          isPlayful: isPlayful,
          onLessonSelected: (lesson) {
            setState(() => _selectedLesson = lesson);
          },
        ),

        // Attendance List
        Expanded(
          child: _selectedLesson == null
              ? _EmptyAttendance(isPlayful: isPlayful)
              : _AttendanceList(
                  lesson: _selectedLesson!,
                  date: selectedDate,
                  isPlayful: isPlayful,
                ),
        ),
      ],
    );
  }
}

class _DatePickerHeader extends StatelessWidget {
  const _DatePickerHeader({
    required this.selectedDate,
    required this.isPlayful,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final bool isPlayful;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: theme.colorScheme.primary,
            size: isPlayful ? 24 : 22,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              DateFormat('EEEE, MMMM d, y').format(selectedDate),
              style: TextStyle(
                fontSize: isPlayful ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  onDateChanged(selectedDate.subtract(const Duration(days: 1)));
                },
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Previous day',
              ),
              OutlinedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    onDateChanged(date);
                  }
                },
                child: const Text('Select Date'),
              ),
              IconButton(
                onPressed: () {
                  onDateChanged(selectedDate.add(const Duration(days: 1)));
                },
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Next day',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonSelector extends ConsumerWidget {
  const _LessonSelector({
    required this.selectedLesson,
    required this.isPlayful,
    required this.onLessonSelected,
  });

  final Lesson? selectedLesson;
  final bool isPlayful;
  final ValueChanged<Lesson?> onLessonSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lessonsAsync = ref.watch(todaysLessonsProvider);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.md : AppSpacing.sm,
        vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: lessonsAsync.when(
        data: (lessons) {
          if (lessons.isEmpty) {
            return Text(
              'No lessons scheduled for this day',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: lessons.map((lesson) {
                final isSelected = selectedLesson?.id == lesson.id;
                final timeStr =
                    '${DateFormat('HH:mm').format(lesson.startTime)} - ${DateFormat('HH:mm').format(lesson.endTime)}';

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.subject.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isPlayful ? 13 : 12,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: isPlayful ? 11 : 10,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      onLessonSelected(selected ? lesson : null);
                    },
                    avatar: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(lesson.subject.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    selectedColor: Color(lesson.subject.color).withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => Text(
          'Failed to load lessons',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}

class _EmptyAttendance extends StatelessWidget {
  const _EmptyAttendance({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_reg_rounded,
            size: isPlayful ? 72 : 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Select a lesson to mark attendance',
            style: TextStyle(
              fontSize: isPlayful ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Choose a lesson from the list above',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceList extends ConsumerStatefulWidget {
  const _AttendanceList({
    required this.lesson,
    required this.date,
    required this.isPlayful,
  });

  final Lesson lesson;
  final DateTime date;
  final bool isPlayful;

  @override
  ConsumerState<_AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends ConsumerState<_AttendanceList> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(lessonStudentsProvider(widget.lesson.id));
    final existingAttendanceAsync = ref.watch(
      lessonAttendanceProvider(widget.lesson.id, widget.date),
    );
    final attendanceState = ref.watch(attendanceNotifierProvider);

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Text(
              'No students in this class',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          );
        }

        return existingAttendanceAsync.when(
          data: (existingAttendance) {
            // Create a map of existing attendance
            final existingMap = <String, AttendanceEntity>{};
            for (final a in existingAttendance) {
              existingMap[a.studentId] = a;
            }

            return Column(
              children: [
                // Actions Bar
                _AttendanceActionsBar(
                  students: students,
                  isPlayful: widget.isPlayful,
                  isSaving: _isSaving,
                  onMarkAllPresent: () {
                    ref.read(attendanceNotifierProvider.notifier).setAllPresent(
                          students.map((s) => s.id).toList(),
                        );
                  },
                  onSave: () => _saveAttendance(students),
                ),

                // Student List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(widget.isPlayful ? AppSpacing.md : AppSpacing.sm),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final existing = existingMap[student.id];
                      final currentStatus = attendanceState[student.id] ??
                          existing?.status ??
                          AttendanceStatus.present;

                      return _StudentAttendanceRow(
                        student: student,
                        status: currentStatus,
                        hasExcuse: existing?.excuseNote != null,
                        excuseStatus: existing?.excuseStatus,
                        isPlayful: widget.isPlayful,
                        onStatusChanged: (status) {
                          ref
                              .read(attendanceNotifierProvider.notifier)
                              .setStatus(student.id, status);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Failed to load attendance: $e',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Failed to load students: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  Future<void> _saveAttendance(List<AppUser> students) async {
    setState(() => _isSaving = true);

    try {
      final success = await ref
          .read(attendanceNotifierProvider.notifier)
          .saveAttendance(widget.lesson.id, widget.date);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Attendance saved successfully'
                  : 'Failed to save attendance',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _AttendanceActionsBar extends StatelessWidget {
  const _AttendanceActionsBar({
    required this.students,
    required this.isPlayful,
    required this.isSaving,
    required this.onMarkAllPresent,
    required this.onSave,
  });

  final List<AppUser> students;
  final bool isPlayful;
  final bool isSaving;
  final VoidCallback onMarkAllPresent;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            '${students.length} students',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              OutlinedButton.icon(
                onPressed: onMarkAllPresent,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Mark All Present'),
              ),
              FilledButton.icon(
                onPressed: isSaving ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: const Text('Save Attendance'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentAttendanceRow extends StatelessWidget {
  const _StudentAttendanceRow({
    required this.student,
    required this.status,
    required this.hasExcuse,
    this.excuseStatus,
    required this.isPlayful,
    required this.onStatusChanged,
  });

  final AppUser student;
  final AttendanceStatus status;
  final bool hasExcuse;
  final ExcuseStatus? excuseStatus;
  final bool isPlayful;
  final ValueChanged<AttendanceStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      padding: EdgeInsets.all(isPlayful ? AppSpacing.sm + 2 : AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: isPlayful ? 22 : 20,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: student.avatarUrl != null
                ? NetworkImage(student.avatarUrl!)
                : null,
            child: student.avatarUrl == null
                ? Text(
                    student.fullName.isNotEmpty
                        ? student.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: isPlayful ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
          ),
          SizedBox(width: AppSpacing.sm),

          // Name and excuse indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (hasExcuse) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        excuseStatus == ExcuseStatus.approved
                            ? Icons.check_circle_rounded
                            : excuseStatus == ExcuseStatus.rejected
                                ? Icons.cancel_rounded
                                : Icons.pending_rounded,
                        size: 14,
                        color: excuseStatus == ExcuseStatus.approved
                            ? Colors.green
                            : excuseStatus == ExcuseStatus.rejected
                                ? Colors.red
                                : Colors.orange,
                      ),
                      SizedBox(width: AppSpacing.xxs),
                      Text(
                        'Has excuse note',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Attendance Toggle
          AttendanceToggle(
            status: status,
            onStatusChanged: onStatusChanged,
            isPlayful: isPlayful,
          ),
        ],
      ),
    );
  }
}
