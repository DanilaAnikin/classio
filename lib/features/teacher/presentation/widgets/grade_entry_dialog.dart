import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/teacher_grade_entity.dart';
import '../providers/teacher_provider.dart';

/// Dialog for adding or editing a grade.
///
/// Features premium design with theme-aware styling (Clean vs Playful).
class GradeEntryDialog extends ConsumerStatefulWidget {
  const GradeEntryDialog({
    super.key,
    required this.subjectId,
    this.students,
    this.existingGrade,
    this.preselectedStudent,
    this.preselectedGradeType,
  });

  final String subjectId;
  final List<AppUser>? students;
  final TeacherGradeEntity? existingGrade;
  final AppUser? preselectedStudent;
  final String? preselectedGradeType;

  /// Shows the dialog and returns true if a grade was successfully saved.
  static Future<bool?> show(
    BuildContext context, {
    required String subjectId,
    List<AppUser>? students,
    TeacherGradeEntity? existingGrade,
    AppUser? preselectedStudent,
    String? preselectedGradeType,
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
        return GradeEntryDialog(
          subjectId: subjectId,
          students: students,
          existingGrade: existingGrade,
          preselectedStudent: preselectedStudent,
          preselectedGradeType: preselectedGradeType,
        );
      },
    );
  }

  @override
  ConsumerState<GradeEntryDialog> createState() => _GradeEntryDialogState();
}

class _GradeEntryDialogState extends ConsumerState<GradeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _scoreController;
  late TextEditingController _weightController;
  late TextEditingController _commentController;

  String? _selectedStudentId;
  String _selectedGradeType = 'Quiz';
  bool _isLoading = false;

  static const List<String> _gradeTypes = [
    'Quiz',
    'Test',
    'Homework',
    'Project',
    'Exam',
    'Participation',
    'Other',
  ];

  bool get _isPlayful {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.value == PlayfulColors.primary.value;
  }

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.existingGrade?.score.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.existingGrade?.weight.toString() ?? '1.0',
    );
    _commentController = TextEditingController(
      text: widget.existingGrade?.comment ?? '',
    );
    _selectedStudentId =
        widget.existingGrade?.studentId ?? widget.preselectedStudent?.id;

    // Determine the grade type, ensuring it's a valid option from _gradeTypes
    final rawGradeType = widget.existingGrade?.gradeType ??
        widget.preselectedGradeType ??
        'Quiz';
    _selectedGradeType = _gradeTypes.contains(rawGradeType) ? rawGradeType : 'Quiz';
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _weightController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedStudentId == null && widget.existingGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a student'),
          backgroundColor: _isPlayful ? PlayfulColors.error : CleanColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final score = double.parse(_scoreController.text);
      final weight = double.tryParse(_weightController.text) ?? 1.0;

      bool success;
      final existingGrade = widget.existingGrade;
      if (existingGrade != null) {
        // Update existing grade
        final updatedGrade = existingGrade.copyWith(
          score: score,
          weight: weight,
          gradeType: _selectedGradeType,
          comment: _commentController.text.isEmpty
              ? null
              : _commentController.text,
        );
        success = await ref.read(addGradeNotifierProvider.notifier).updateGrade(updatedGrade);
      } else {
        // Add new grade
        success = await ref.read(addGradeNotifierProvider.notifier).addGrade(
              studentId: _selectedStudentId!,
              subjectId: widget.subjectId,
              score: score,
              weight: weight,
              gradeType: _selectedGradeType,
              comment: _commentController.text.isEmpty
                  ? null
                  : _commentController.text,
            );
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingGrade != null
                  ? 'Grade updated successfully'
                  : 'Grade added successfully'),
              backgroundColor:
                  _isPlayful ? PlayfulColors.success : CleanColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to save grade. Please try again.'),
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

  Future<void> _deleteGrade() async {
    if (widget.existingGrade == null) return;
    final isPlayful = _isPlayful;

    final confirmed = await showGeneralDialog<bool>(
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
        return _DeleteConfirmationDialog(isPlayful: isPlayful);
      },
    );

    final existingGrade = widget.existingGrade;
    if (confirmed == true && existingGrade != null) {
      setState(() => _isLoading = true);
      try {
        final success = await ref.read(addGradeNotifierProvider.notifier).deleteGrade(
              existingGrade.id,
              widget.subjectId,
            );
        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Grade deleted successfully'),
                backgroundColor:
                    _isPlayful ? PlayfulColors.success : CleanColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to delete grade. Please try again.'),
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
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful;
    final isEditing = widget.existingGrade != null;
    final students = widget.students ?? [];

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
              constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed Header
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: _buildHeader(
                        isPlayful: isPlayful,
                        isEditing: isEditing,
                        primaryColor: primaryColor,
                        textPrimary: textPrimary,
                      ),
                    ),

                    // Scrollable Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.md,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Student Selector (only for new grades)
                              if (!isEditing && students.isNotEmpty) ...[
                                _buildStudentDropdown(
                                  students: students,
                                  isPlayful: isPlayful,
                                  textSecondary: textSecondary,
                                ),
                                AppSpacing.gap16,
                              ],

                              // Grade Type Selector
                              _buildGradeTypeDropdown(
                                isPlayful: isPlayful,
                                textSecondary: textSecondary,
                              ),
                              AppSpacing.gap16,

                              // Score and Weight Row
                              _buildScoreWeightRow(isPlayful: isPlayful),
                              AppSpacing.gap16,

                              // Comment Field
                              AppInput.multiline(
                                controller: _commentController,
                                label: 'Comment (optional)',
                                hint: 'Add a note about this grade...',
                                prefixIcon: Icons.comment_rounded,
                                maxLines: 2,
                                minLines: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Fixed Actions
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: _buildActions(
                        isPlayful: isPlayful,
                        isEditing: isEditing,
                      ),
                    ),
                  ],
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
    required bool isEditing,
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
            isEditing ? Icons.edit_rounded : Icons.add_rounded,
            color: primaryColor,
            size: AppIconSize.md,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            isEditing ? 'Edit Grade' : 'Add Grade',
            style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
              color: textPrimary,
            ),
          ),
        ),
        _CloseButton(isPlayful: isPlayful),
      ],
    );
  }

  Widget _buildStudentDropdown({
    required List<AppUser> students,
    required bool isPlayful,
    required Color textSecondary,
  }) {
    final borderColor = isPlayful ? PlayfulColors.inputBorder : CleanColors.inputBorder;
    final focusBorderColor =
        isPlayful ? PlayfulColors.inputBorderFocus : CleanColors.inputBorderFocus;

    return DropdownButtonFormField<String>(
      value: students.any((s) => s.id == _selectedStudentId)
          ? _selectedStudentId
          : null,
      decoration: InputDecoration(
        labelText: 'Student',
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
        prefixIcon: Icon(Icons.person_rounded, color: textSecondary),
        contentPadding: AppSpacing.inputInsets,
      ),
      style: AppTypography.inputText(isPlayful: isPlayful),
      isExpanded: true,
      items: students.map((student) {
        return DropdownMenuItem(
          value: student.id,
          child: Text(
            _getStudentName(student),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedStudentId = value);
      },
      validator: (value) {
        if (value == null) return 'Please select a student';
        return null;
      },
    );
  }

  Widget _buildGradeTypeDropdown({
    required bool isPlayful,
    required Color textSecondary,
  }) {
    final borderColor = isPlayful ? PlayfulColors.inputBorder : CleanColors.inputBorder;
    final focusBorderColor =
        isPlayful ? PlayfulColors.inputBorderFocus : CleanColors.inputBorderFocus;

    return DropdownButtonFormField<String>(
      value: _selectedGradeType,
      decoration: InputDecoration(
        labelText: 'Grade Type',
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
        prefixIcon: Icon(Icons.category_rounded, color: textSecondary),
        contentPadding: AppSpacing.inputInsets,
      ),
      style: AppTypography.inputText(isPlayful: isPlayful),
      isExpanded: true,
      items: _gradeTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedGradeType = value);
        }
      },
    );
  }

  Widget _buildScoreWeightRow({required bool isPlayful}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Field
        Expanded(
          flex: 2,
          child: AppInput(
            controller: _scoreController,
            label: 'Score',
            hint: '0-100',
            prefixIcon: Icons.grade_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final score = double.tryParse(value);
              if (score == null) return 'Invalid';
              if (score < 0 || score > 100) return '0-100';
              return null;
            },
          ),
        ),
        SizedBox(width: AppSpacing.sm),

        // Weight Field
        Expanded(
          child: AppInput(
            controller: _weightController,
            label: 'Weight',
            hint: '1.0',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return null; // Optional
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0 || weight > 10) return '0.1-10';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActions({
    required bool isPlayful,
    required bool isEditing,
  }) {
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;

    return Row(
      children: [
        if (isEditing)
          AppButton.danger(
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            onPressed: _isLoading ? null : _deleteGrade,
            size: ButtonSize.medium,
          ),
        const Spacer(),
        AppButton.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          size: ButtonSize.medium,
        ),
        SizedBox(width: AppSpacing.sm),
        AppButton.primary(
          label: isEditing ? 'Update' : 'Save',
          icon: Icons.save_rounded,
          onPressed: _isLoading ? null : _saveGrade,
          isLoading: _isLoading,
          size: ButtonSize.medium,
        ),
      ],
    );
  }

  String _getStudentName(AppUser student) {
    final parts = <String>[];
    final firstName = student.firstName;
    final lastName = student.lastName;
    if (firstName != null && firstName.isNotEmpty) {
      parts.add(firstName);
    }
    if (lastName != null && lastName.isNotEmpty) {
      parts.add(lastName);
    }
    return parts.isEmpty ? (student.email ?? '') : parts.join(' ');
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

/// Confirmation dialog for deleting a grade.
class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isPlayful ? PlayfulColors.surfaceElevated : CleanColors.surfaceElevated;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final errorSubtle =
        isPlayful ? PlayfulColors.errorSubtle : CleanColors.errorSubtle;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePaddingMobile,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: AppRadius.dialog(isPlayful: isPlayful),
                border: Border.all(
                  color: borderColor.withValues(alpha: 0.5),
                ),
                boxShadow: AppShadows.modal(isPlayful: isPlayful),
              ),
              child: Padding(
                padding: AppSpacing.dialogInsets,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon and Title
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: errorSubtle,
                            borderRadius: AppRadius.button(isPlayful: isPlayful),
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: errorColor,
                            size: AppIconSize.md,
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Delete Grade',
                            style: AppTypography.sectionTitle(isPlayful: isPlayful)
                                .copyWith(color: textPrimary),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gap16,

                    // Message
                    Text(
                      'Are you sure you want to delete this grade? This action cannot be undone.',
                      style: AppTypography.secondaryText(isPlayful: isPlayful)
                          .copyWith(color: textSecondary),
                    ),
                    AppSpacing.gap24,

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppButton.secondary(
                          label: 'Cancel',
                          onPressed: () => Navigator.of(context).pop(false),
                          size: ButtonSize.medium,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        AppButton.danger(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          onPressed: () => Navigator.of(context).pop(true),
                          size: ButtonSize.medium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
