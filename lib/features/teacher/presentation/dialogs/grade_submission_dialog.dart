import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/assignment_entity.dart';
import '../providers/teacher_provider.dart';

/// Dialog for grading an assignment submission.
class GradeSubmissionDialog extends ConsumerStatefulWidget {
  const GradeSubmissionDialog({
    super.key,
    required this.submission,
    required this.maxScore,
  });

  final SubmissionEntity submission;
  final int maxScore;

  @override
  ConsumerState<GradeSubmissionDialog> createState() =>
      _GradeSubmissionDialogState();
}

class _GradeSubmissionDialogState extends ConsumerState<GradeSubmissionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _gradeController;
  final _commentController = TextEditingController();
  bool _isLoading = false;

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
    if (!_formKey.currentState!.validate()) return;

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
            const SnackBar(
              content: Text('Grade submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
    final theme = Theme.of(context);
    final isEditing = widget.submission.isGraded;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_rounded : Icons.grade_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Grade' : 'Grade Submission',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.submission.studentName ?? 'Student',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submission Info Card
                if (widget.submission.content != null &&
                    widget.submission.content!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Submission Content',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.submission.content!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Grade Input
                TextFormField(
                  controller: _gradeController,
                  decoration: InputDecoration(
                    labelText: 'Grade',
                    hintText: '0 - ${widget.maxScore}',
                    helperText: 'Maximum score: ${widget.maxScore}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.score_rounded),
                    suffixText: '/ ${widget.maxScore}',
                  ),
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
                const SizedBox(height: 16),

                // Comment Input
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Feedback (optional)',
                    hintText: 'Add feedback for the student...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.comment_rounded),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 24),

                // Quick Grade Buttons
                Text(
                  'Quick Grade',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickGradeChip(
                      label: '100%',
                      value: widget.maxScore.toDouble(),
                      color: Colors.green,
                      onTap: () => _gradeController.text =
                          widget.maxScore.toString(),
                    ),
                    _QuickGradeChip(
                      label: '90%',
                      value: (widget.maxScore * 0.9).roundToDouble(),
                      color: Colors.lightGreen,
                      onTap: () => _gradeController.text =
                          (widget.maxScore * 0.9).round().toString(),
                    ),
                    _QuickGradeChip(
                      label: '80%',
                      value: (widget.maxScore * 0.8).roundToDouble(),
                      color: Colors.amber,
                      onTap: () => _gradeController.text =
                          (widget.maxScore * 0.8).round().toString(),
                    ),
                    _QuickGradeChip(
                      label: '70%',
                      value: (widget.maxScore * 0.7).roundToDouble(),
                      color: Colors.orange,
                      onTap: () => _gradeController.text =
                          (widget.maxScore * 0.7).round().toString(),
                    ),
                    _QuickGradeChip(
                      label: '60%',
                      value: (widget.maxScore * 0.6).roundToDouble(),
                      color: Colors.deepOrange,
                      onTap: () => _gradeController.text =
                          (widget.maxScore * 0.6).round().toString(),
                    ),
                    _QuickGradeChip(
                      label: '50%',
                      value: (widget.maxScore * 0.5).roundToDouble(),
                      color: Colors.red,
                      onTap: () => _gradeController.text =
                          (widget.maxScore * 0.5).round().toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _submitGrade,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              isEditing
                                  ? Icons.save_rounded
                                  : Icons.check_rounded,
                              size: 18,
                            ),
                      label: Text(isEditing ? 'Update Grade' : 'Submit Grade'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickGradeChip extends StatelessWidget {
  const _QuickGradeChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final String label;
  final double value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      side: BorderSide(color: color.withValues(alpha: 0.5)),
      backgroundColor: color.withValues(alpha: 0.1),
      onPressed: onTap,
    );
  }
}
