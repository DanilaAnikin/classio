import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../providers/teacher_provider.dart';

/// Dialog for creating a new assignment.
///
/// Features premium design with theme-aware styling (Clean vs Playful).
class CreateAssignmentDialog extends ConsumerStatefulWidget {
  const CreateAssignmentDialog({
    super.key,
    this.preselectedSubjectId,
  });

  final String? preselectedSubjectId;

  /// Shows the dialog and returns true if an assignment was successfully created.
  static Future<bool?> show(
    BuildContext context, {
    String? preselectedSubjectId,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: AppDuration.medium,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.modalEnter,
          reverseCurve: AppCurves.modalExit,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return CreateAssignmentDialog(
          preselectedSubjectId: preselectedSubjectId,
        );
      },
    );
  }

  @override
  ConsumerState<CreateAssignmentDialog> createState() =>
      _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState
    extends ConsumerState<CreateAssignmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');

  String? _selectedSubjectId;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _isLoading = false;

  bool get _isPlayful {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.value == PlayfulColors.primary.value;
  }

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.preselectedSubjectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final isPlayful = _isPlayful;
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;

    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: primaryColor,
                  ),
            ),
            child: child!,
          );
        },
      );

      setState(() {
        _dueDate = date;
        _dueTime = time ?? const TimeOfDay(hour: 23, minute: 59);
      });
    }
  }

  DateTime? get _combinedDueDate {
    final dueDate = _dueDate;
    if (dueDate == null) return null;
    final time = _dueTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _createAssignment() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a subject'),
          backgroundColor: _isPlayful ? PlayfulColors.error : CleanColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(assignmentNotifierProvider.notifier)
          .createAssignment(
            subjectId: _selectedSubjectId!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            dueDate: _combinedDueDate,
            maxScore: int.tryParse(_maxScoreController.text) ?? 100,
          );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assignment created successfully'),
              backgroundColor:
                  _isPlayful ? PlayfulColors.success : CleanColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to create assignment. Please try again.'),
              backgroundColor:
                  _isPlayful ? PlayfulColors.error : CleanColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: _isPlayful ? PlayfulColors.error : CleanColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful;
    final subjectsAsync = ref.watch(mySubjectsProvider);

    // Theme-aware colors
    final surfaceColor =
        isPlayful ? PlayfulColors.surfaceElevated : CleanColors.surfaceElevated;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePaddingMobile,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: AppRadius.dialog(isPlayful: isPlayful),
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.5),
                ),
                boxShadow: AppShadows.modal(isPlayful: isPlayful),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.dialog(isPlayful: isPlayful),
                child: SingleChildScrollView(
                  padding: AppSpacing.dialogInsets,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        _buildHeader(
                          isPlayful: isPlayful,
                          primaryColor: primaryColor,
                          textPrimary: textPrimary,
                        ),
                        AppSpacing.gap24,

                        // Subject Selector
                        subjectsAsync.when(
                          data: (subjects) => _buildSubjectDropdown(
                            subjects: subjects,
                            isPlayful: isPlayful,
                            textSecondary: textSecondary,
                          ),
                          loading: () => LinearProgressIndicator(
                            color: primaryColor,
                            backgroundColor: primaryColor.withValues(alpha: 0.2),
                          ),
                          error: (error, stack) => Text(
                            'Failed to load subjects',
                            style: AppTypography.secondaryText(isPlayful: isPlayful)
                                .copyWith(
                              color:
                                  isPlayful ? PlayfulColors.error : CleanColors.error,
                            ),
                          ),
                        ),
                        AppSpacing.gap16,

                        // Title Field
                        AppInput(
                          controller: _titleController,
                          label: 'Title',
                          hint: 'e.g., Chapter 5 Quiz',
                          prefixIcon: Icons.title_rounded,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.gap16,

                        // Description Field
                        AppInput.multiline(
                          controller: _descriptionController,
                          label: 'Description (optional)',
                          hint: 'Add instructions or details...',
                          prefixIcon: Icons.description_rounded,
                          maxLines: 3,
                          minLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        AppSpacing.gap16,

                        // Due Date and Max Score Row
                        _buildDueDateAndScoreRow(
                          isPlayful: isPlayful,
                          textSecondary: textSecondary,
                        ),
                        AppSpacing.gap24,

                        // Actions
                        _buildActions(isPlayful: isPlayful),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isPlayful,
    required Color primaryColor,
    required Color textPrimary,
  }) {
    final iconBgColor =
        isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: AppRadius.button(isPlayful: isPlayful),
          ),
          child: Icon(
            Icons.assignment_outlined,
            color: primaryColor,
            size: AppIconSize.md,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'New Assignment',
            style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
              color: textPrimary,
            ),
          ),
        ),
        _CloseButton(isPlayful: isPlayful),
      ],
    );
  }

  Widget _buildSubjectDropdown({
    required List<dynamic> subjects,
    required bool isPlayful,
    required Color textSecondary,
  }) {
    final borderColor = isPlayful ? PlayfulColors.inputBorder : CleanColors.inputBorder;
    final focusBorderColor =
        isPlayful ? PlayfulColors.inputBorderFocus : CleanColors.inputBorderFocus;

    return DropdownButtonFormField<String>(
      value: subjects.any((s) => s.id == _selectedSubjectId)
          ? _selectedSubjectId
          : null,
      decoration: InputDecoration(
        labelText: 'Subject',
        labelStyle: AppTypography.inputLabel(isPlayful: isPlayful),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: isPlayful),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: isPlayful),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: isPlayful),
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        prefixIcon: Icon(Icons.menu_book_rounded, color: textSecondary),
        contentPadding: AppSpacing.inputInsets,
      ),
      style: AppTypography.inputText(isPlayful: isPlayful),
      isExpanded: true,
      items: subjects.map((subject) {
        return DropdownMenuItem<String>(
          value: subject.id as String,
          child: Row(
            children: [
              Container(
                width: AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(
                  color: Color(subject.color as int),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  subject.name as String,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedSubjectId = value);
      },
      validator: (value) {
        if (value == null) return 'Please select a subject';
        return null;
      },
    );
  }

  Widget _buildDueDateAndScoreRow({
    required bool isPlayful,
    required Color textSecondary,
  }) {
    final borderColor = isPlayful ? PlayfulColors.inputBorder : CleanColors.inputBorder;
    final surfaceColor =
        isPlayful ? PlayfulColors.surfaceSecondary : CleanColors.surfaceSecondary;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Due Date Picker
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: _selectDueDate,
            borderRadius: AppRadius.input(isPlayful: isPlayful),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: borderColor),
                borderRadius: AppRadius.input(isPlayful: isPlayful),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: textSecondary,
                    size: AppIconSize.sm,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: AppTypography.tertiaryText(isPlayful: isPlayful),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          _dueDate != null
                              ? DateFormat('MMM d, y').format(_dueDate!)
                              : 'No deadline',
                          style: AppTypography.inputText(isPlayful: isPlayful)
                              .copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_dueTime != null && _dueDate != null)
                          Text(
                            'at ${(_dueTime ?? const TimeOfDay(hour: 23, minute: 59)).format(context)}',
                            style: AppTypography.tertiaryText(isPlayful: isPlayful),
                          ),
                      ],
                    ),
                  ),
                  if (_dueDate != null)
                    _ClearDateButton(
                      isPlayful: isPlayful,
                      onPressed: () {
                        setState(() {
                          _dueDate = null;
                          _dueTime = null;
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),

        // Max Score
        Expanded(
          child: AppInput(
            controller: _maxScoreController,
            label: 'Max Score',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              final score = int.tryParse(value);
              if (score == null || score <= 0) {
                return 'Invalid';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions({required bool isPlayful}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          size: ButtonSize.medium,
        ),
        SizedBox(width: AppSpacing.sm),
        AppButton.primary(
          label: 'Create',
          icon: Icons.add_rounded,
          onPressed: _isLoading ? null : _createAssignment,
          isLoading: _isLoading,
          size: ButtonSize.medium,
        ),
      ],
    );
  }
}

/// Close button for the dialog header.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;
    final hoverColor =
        isPlayful ? PlayfulColors.surfaceHover : CleanColors.surfaceHover;

    return Semantics(
      button: true,
      label: 'Close dialog',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: AppRadius.fullRadius,
          hoverColor: hoverColor,
          child: Padding(
            padding: AppSpacing.insets8,
            child: Icon(
              Icons.close_rounded,
              size: AppIconSize.sm,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Clear date button for the due date picker.
class _ClearDateButton extends StatelessWidget {
  const _ClearDateButton({
    required this.isPlayful,
    required this.onPressed,
  });

  final bool isPlayful;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;

    return Semantics(
      button: true,
      label: 'Clear date',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.fullRadius,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxs),
            child: Icon(
              Icons.clear_rounded,
              size: AppIconSize.xs,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
