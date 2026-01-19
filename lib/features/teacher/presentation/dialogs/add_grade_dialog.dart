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
import '../providers/teacher_provider.dart';

/// Dialog for adding a grade to a student.
///
/// Features premium design with theme-aware styling (Clean vs Playful).
class AddGradeDialog extends ConsumerStatefulWidget {
  const AddGradeDialog({
    super.key,
    required this.subjectId,
    this.preselectedStudentId,
  });

  final String subjectId;
  final String? preselectedStudentId;

  /// Shows the dialog and returns true if a grade was successfully added.
  static Future<bool?> show(
    BuildContext context, {
    required String subjectId,
    String? preselectedStudentId,
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
        return AddGradeDialog(
          subjectId: subjectId,
          preselectedStudentId: preselectedStudentId,
        );
      },
    );
  }

  @override
  ConsumerState<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends ConsumerState<AddGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _weightController = TextEditingController(text: '1.0');
  final _commentController = TextEditingController();

  String? _selectedStudentId;
  String? _selectedGradeType;
  bool _isLoading = false;

  static const List<String> _gradeTypes = [
    'Test',
    'Quiz',
    'Homework',
    'Project',
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
    _selectedStudentId = widget.preselectedStudentId;
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _weightController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addGrade() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedStudentId == null) {
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
      final success = await ref.read(addGradeNotifierProvider.notifier).addGrade(
            studentId: _selectedStudentId!,
            subjectId: widget.subjectId,
            score: double.parse(_scoreController.text),
            weight: double.tryParse(_weightController.text) ?? 1.0,
            gradeType: _selectedGradeType,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Grade added successfully'),
              backgroundColor:
                  _isPlayful ? PlayfulColors.success : CleanColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add grade. Please try again.'),
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
    final studentsAsync = ref.watch(subjectStudentsProvider(widget.subjectId));

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
              constraints: const BoxConstraints(maxWidth: 450),
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

                        // Student Selector
                        studentsAsync.when(
                          data: (students) => _buildStudentDropdown(
                            students: students,
                            isPlayful: isPlayful,
                            textSecondary: textSecondary,
                          ),
                          loading: () => LinearProgressIndicator(
                            color: primaryColor,
                            backgroundColor: primaryColor.withValues(alpha: 0.2),
                          ),
                          error: (error, stack) => Text(
                            'Failed to load students',
                            style: AppTypography.secondaryText(isPlayful: isPlayful)
                                .copyWith(
                              color:
                                  isPlayful ? PlayfulColors.error : CleanColors.error,
                            ),
                          ),
                        ),
                        AppSpacing.gap16,

                        // Score and Weight Row
                        _buildScoreWeightRow(isPlayful: isPlayful),
                        AppSpacing.gap16,

                        // Grade Type Selector
                        _buildGradeTypeDropdown(
                          isPlayful: isPlayful,
                          textSecondary: textSecondary,
                        ),
                        AppSpacing.gap16,

                        // Comment Field
                        AppInput.multiline(
                          controller: _commentController,
                          label: 'Comment (optional)',
                          hint: 'Add a note about this grade...',
                          maxLines: 2,
                          minLines: 2,
                          prefixIcon: Icons.comment_rounded,
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
            Icons.grade_rounded,
            color: primaryColor,
            size: AppIconSize.md,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Add Grade',
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
            prefixIcon: Icons.score_rounded,
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
              if (value == null || value.isEmpty) return 'Required';
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0 || weight > 10) return '0.1-10';
              return null;
            },
          ),
        ),
      ],
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
        labelText: 'Grade Type (optional)',
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
        setState(() => _selectedGradeType = value);
      },
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
          label: 'Add Grade',
          icon: Icons.add_rounded,
          onPressed: _isLoading ? null : _addGrade,
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
