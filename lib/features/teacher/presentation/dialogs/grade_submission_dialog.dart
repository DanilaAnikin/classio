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
import '../../domain/entities/assignment_entity.dart';
import '../providers/teacher_provider.dart';

/// Dialog for grading an assignment submission.
///
/// Features premium design with theme-aware styling (Clean vs Playful).
class GradeSubmissionDialog extends ConsumerStatefulWidget {
  const GradeSubmissionDialog({
    super.key,
    required this.submission,
    required this.maxScore,
  });

  final SubmissionEntity submission;
  final int maxScore;

  /// Shows the dialog and returns true if a grade was successfully submitted.
  static Future<bool?> show(
    BuildContext context, {
    required SubmissionEntity submission,
    required int maxScore,
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
        return GradeSubmissionDialog(
          submission: submission,
          maxScore: maxScore,
        );
      },
    );
  }

  @override
  ConsumerState<GradeSubmissionDialog> createState() =>
      _GradeSubmissionDialogState();
}

class _GradeSubmissionDialogState extends ConsumerState<GradeSubmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gradeController;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  bool get _isPlayful {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.value == PlayfulColors.primary.value;
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing grade if editing
    _gradeController = TextEditingController(
      text: widget.submission.grade?.toStringAsFixed(0) ?? '',
    );
    _commentController.text = widget.submission.comment ?? '';
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() => _isLoading = true);

    try {
      final grade = double.parse(_gradeController.text);
      final comment = _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim();

      final success = await ref
          .read(assignmentNotifierProvider.notifier)
          .gradeSubmission(
            widget.submission.id,
            grade,
            comment,
            widget.submission.assignmentId,
          );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Grade submitted successfully'),
              backgroundColor:
                  _isPlayful ? PlayfulColors.success : CleanColors.success,
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

  void _setQuickGrade(double percentage) {
    _gradeController.text = (widget.maxScore * percentage).round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful;
    final isEditing = widget.submission.isGraded;

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
                          isEditing: isEditing,
                          primaryColor: primaryColor,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        AppSpacing.gap24,

                        // Submission Info Card
                        if (widget.submission.content?.isNotEmpty ?? false) ...[
                          _buildSubmissionCard(isPlayful: isPlayful),
                          AppSpacing.gap16,
                        ],

                        // Grade Input
                        AppInput(
                          controller: _gradeController,
                          label: 'Grade',
                          hint: '0 - ${widget.maxScore}',
                          helperText: 'Maximum score: ${widget.maxScore}',
                          prefixIcon: Icons.score_rounded,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          autofocus: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a grade';
                            }
                            final grade = double.tryParse(value);
                            if (grade == null) {
                              return 'Please enter a valid number';
                            }
                            if (grade < 0) {
                              return 'Grade cannot be negative';
                            }
                            if (grade > widget.maxScore) {
                              return 'Grade cannot exceed ${widget.maxScore}';
                            }
                            return null;
                          },
                        ),
                        AppSpacing.gap16,

                        // Feedback Input
                        AppInput.multiline(
                          controller: _commentController,
                          label: 'Feedback (optional)',
                          hint: 'Add feedback for the student...',
                          prefixIcon: Icons.comment_rounded,
                          maxLines: 3,
                          minLines: 2,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        AppSpacing.gap20,

                        // Quick Grade Section
                        _buildQuickGradeSection(isPlayful: isPlayful),
                        AppSpacing.gap24,

                        // Actions
                        _buildActions(
                          isPlayful: isPlayful,
                          isEditing: isEditing,
                        ),
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
    required bool isEditing,
    required Color primaryColor,
    required Color textPrimary,
    required Color textSecondary,
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
            isEditing ? Icons.edit_rounded : Icons.grade_rounded,
            color: primaryColor,
            size: AppIconSize.md,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Grade' : 'Grade Submission',
                style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
                  color: textPrimary,
                ),
              ),
              Text(
                widget.submission.studentName ?? 'Student',
                style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        _CloseButton(isPlayful: isPlayful),
      ],
    );
  }

  Widget _buildSubmissionCard({required bool isPlayful}) {
    final cardBgColor =
        isPlayful ? PlayfulColors.surfaceSecondary : CleanColors.surfaceSecondary;
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: AppRadius.card(isPlayful: isPlayful),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                size: AppIconSize.xs,
                color: textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Submission Content',
                style: AppTypography.labelText(isPlayful: isPlayful).copyWith(
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            widget.submission.content ?? '',
            style: AppTypography.secondaryText(isPlayful: isPlayful),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickGradeSection({required bool isPlayful}) {
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;
    final warningColor = isPlayful ? PlayfulColors.warning : CleanColors.warning;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Grade',
          style: AppTypography.labelText(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w600,
            color: textSecondary,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _QuickGradeChip(
              label: '100%',
              color: successColor,
              isPlayful: isPlayful,
              onTap: () => _setQuickGrade(1.0),
            ),
            _QuickGradeChip(
              label: '90%',
              color: successColor.withValues(alpha: 0.7),
              isPlayful: isPlayful,
              onTap: () => _setQuickGrade(0.9),
            ),
            _QuickGradeChip(
              label: '80%',
              color: warningColor,
              isPlayful: isPlayful,
              onTap: () => _setQuickGrade(0.8),
            ),
            _QuickGradeChip(
              label: '70%',
              color: warningColor.withValues(alpha: 0.8),
              isPlayful: isPlayful,
              onTap: () => _setQuickGrade(0.7),
            ),
            _QuickGradeChip(
              label: '60%',
              color: errorColor.withValues(alpha: 0.7),
              isPlayful: isPlayful,
              onTap: () => _setQuickGrade(0.6),
            ),
            _QuickGradeChip(
              label: '50%',
              color: errorColor,
              isPlayful: isPlayful,
              onTap: () => _setQuickGrade(0.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions({
    required bool isPlayful,
    required bool isEditing,
  }) {
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
          label: isEditing ? 'Update Grade' : 'Submit Grade',
          icon: isEditing ? Icons.save_rounded : Icons.check_rounded,
          onPressed: _isLoading ? null : _submitGrade,
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

/// Quick grade chip for percentage-based grading.
class _QuickGradeChip extends StatelessWidget {
  const _QuickGradeChip({
    required this.label,
    required this.color,
    required this.isPlayful,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isPlayful;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: AppTypography.labelText(isPlayful: isPlayful).copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      backgroundColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.chip(isPlayful: isPlayful),
      ),
      onPressed: onTap,
    );
  }
}
