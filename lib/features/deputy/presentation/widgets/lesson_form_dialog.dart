import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/spacing.dart';
import 'package:classio/core/theme/app_radius.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../../schedule/presentation/widgets/week_selector.dart';
import '../../domain/entities/entities.dart';
import '../providers/deputy_provider.dart';

/// Dialog for creating or editing a lesson.
///
/// Shows:
/// - Subject dropdown
/// - Day of week selector
/// - Start/End time pickers
/// - Room text field
class LessonFormDialog extends ConsumerStatefulWidget {
  const LessonFormDialog({
    super.key,
    required this.classId,
    required this.subjects,
    this.existingLesson,
    this.initialDayOfWeek,
    this.initialTime,
  });

  /// The class ID to create/edit the lesson for.
  final String classId;

  /// Available subjects for the dropdown.
  final List<Subject> subjects;

  /// Existing lesson if editing (null if creating).
  final ScheduleLesson? existingLesson;

  /// Initial day of week for new lessons.
  final int? initialDayOfWeek;

  /// Initial time for new lessons.
  final TimeOfDay? initialTime;

  @override
  ConsumerState<LessonFormDialog> createState() => _LessonFormDialogState();
}

class _LessonFormDialogState extends ConsumerState<LessonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomController = TextEditingController();

  String? _selectedSubjectId;
  int _selectedDayOfWeek = 1;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 45);
  bool _isLoading = false;

  bool get _isEditing => widget.existingLesson != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      // Populate form with existing lesson data
      final lesson = widget.existingLesson!;
      _selectedSubjectId = lesson.subjectId;
      _selectedDayOfWeek = lesson.dayOfWeek;
      _startTime = lesson.startTime;
      _endTime = lesson.endTime;
      _roomController.text = lesson.room ?? '';
    } else {
      // Use initial values for new lesson
      if (widget.initialDayOfWeek != null) {
        _selectedDayOfWeek = widget.initialDayOfWeek!;
      }
      if (widget.initialTime != null) {
        _startTime = widget.initialTime!;
        _endTime = ScheduleConfig.getEndTime(widget.initialTime!);
      }
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final weekView = ref.watch(selectedWeekViewProvider);
    final isEditingStable = weekView == WeekViewType.stable;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                _isEditing ? Icons.edit_calendar_rounded : Icons.add_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(_isEditing ? 'Edit Lesson' : 'Add Lesson'),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: isEditingStable
                  ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm - 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEditingStable ? Icons.schedule : Icons.event_note,
                  size: 14,
                  color: isEditingStable
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                ),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  isEditingStable
                      ? 'Editing Stable Timetable'
                      : 'Editing Week-Specific',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isEditingStable
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Subject Dropdown
                _buildLabel('Subject', theme),
                SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  decoration: _inputDecoration(isPlayful),
                  initialValue: _selectedSubjectId,
                  hint: const Text('Select a subject'),
                  isExpanded: true,
                  items: widget.subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Color(subject.color),
                              borderRadius: BorderRadius.circular(AppRadius.xs - 1),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              subject.teacherName != null
                                  ? '${subject.name} (${subject.teacherName})'
                                  : subject.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedSubjectId = value;
                        });
                      },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subject';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),

              // Day of Week Selector
              _buildLabel('Day', theme),
              SizedBox(height: AppSpacing.xs),
              _DaySelector(
                selectedDay: _selectedDayOfWeek,
                onDaySelected: (day) {
                  setState(() {
                    _selectedDayOfWeek = day;
                  });
                },
                isPlayful: isPlayful,
              ),
              SizedBox(height: AppSpacing.lg),

              // Time Pickers Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Start Time', theme),
                        SizedBox(height: AppSpacing.xs),
                        _TimePicker(
                          time: _startTime,
                          onTimeChanged: (time) {
                            setState(() {
                              _startTime = time;
                              // Auto-adjust end time to maintain 45 min duration
                              final endMinutes = time.hour * 60 + time.minute + 45;
                              _endTime = TimeOfDay(
                                hour: endMinutes ~/ 60,
                                minute: endMinutes % 60,
                              );
                            });
                          },
                          isPlayful: isPlayful,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('End Time', theme),
                        SizedBox(height: AppSpacing.xs),
                        _TimePicker(
                          time: _endTime,
                          onTimeChanged: (time) {
                            setState(() {
                              _endTime = time;
                            });
                          },
                          isPlayful: isPlayful,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg),

              // Room Field
              _buildLabel('Room (optional)', theme),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _roomController,
                enabled: !_isLoading,
                decoration: _inputDecoration(isPlayful).copyWith(
                  hintText: 'e.g., A101, Gym',
                  prefixIcon: const Icon(Icons.room_outlined),
                ),
                validator: (value) {
                  // Optional field, but if provided it should not be just whitespace
                  if (value != null && value.isNotEmpty && value.trim().isEmpty) {
                    return 'Room cannot be only whitespace';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveLesson,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isPlayful) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: isPlayful ? AppRadius.cardBorderRadius : AppRadius.buttonBorderRadius,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }

  Future<void> _saveLesson() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(deputyRepositoryProvider);
      final weekView = ref.read(selectedWeekViewProvider);
      final weekStartDate = ref.read(selectedWeekStartDateProvider);

      final startTimeStr =
          '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:00';
      final endTimeStr =
          '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}:00';

      // Determine if creating stable or week-specific lesson
      final isStable = weekView == WeekViewType.stable;

      final existingLesson = widget.existingLesson;
      if (_isEditing && existingLesson != null) {
        await repository.updateLesson(
          lessonId: existingLesson.id,
          subjectId: _selectedSubjectId,
          dayOfWeek: _selectedDayOfWeek,
          startTime: startTimeStr,
          endTime: endTimeStr,
          // Pass the room value directly - empty string will clear the room
          room: _roomController.text,
        );
      } else {
        await repository.createLesson(
          classId: widget.classId,
          subjectId: _selectedSubjectId!,
          dayOfWeek: _selectedDayOfWeek,
          startTime: startTimeStr,
          endTime: endTimeStr,
          room: _roomController.text.isNotEmpty ? _roomController.text : null,
          isStable: isStable,
          weekStartDate: isStable ? null : weekStartDate,
        );
      }

      // Invalidate the schedule provider to refresh
      ref.invalidate(classScheduleProvider(widget.classId));

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save lesson: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Day selector widget with buttons for each weekday.
class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.selectedDay,
    required this.onDaySelected,
    required this.isPlayful,
  });

  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: List.generate(5, (index) {
        final day = index + 1; // 1=Monday to 5=Friday
        final isSelected = selectedDay == day;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onDaySelected(day),
            borderRadius: isPlayful ? AppRadius.cardBorderRadius : AppRadius.buttonBorderRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: isPlayful ? AppRadius.cardBorderRadius : AppRadius.buttonBorderRadius,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                ScheduleConfig.shortDayLabels[day] ?? '',
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Time picker button that shows a time picker dialog.
class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.time,
    required this.onTimeChanged,
    required this.isPlayful,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true,
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onTimeChanged(picked);
          }
        },
        borderRadius: isPlayful ? AppRadius.cardBorderRadius : AppRadius.buttonBorderRadius,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: isPlayful ? AppRadius.cardBorderRadius : AppRadius.buttonBorderRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                ScheduleConfig.formatTime(time),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
