import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/teacher_grade_entity.dart';
import '../providers/teacher_provider.dart';

/// Dialog for adding or editing a grade.
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

  final List<String> _gradeTypes = [
    'Quiz',
    'Test',
    'Homework',
    'Project',
    'Exam',
    'Participation',
    'Other',
  ];

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
    // Only use the value if it exists in _gradeTypes, otherwise default to 'Quiz'
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null && widget.existingGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final score = double.parse(_scoreController.text);
      final weight = double.tryParse(_weightController.text) ?? 1.0;

      bool success;
      if (widget.existingGrade != null) {
        // Update existing grade
        final updatedGrade = widget.existingGrade!.copyWith(
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
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save grade. Please try again.'),
              backgroundColor: Colors.red,
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

  Future<void> _deleteGrade() async {
    if (widget.existingGrade == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: const Text(
          'Are you sure you want to delete this grade? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        final success = await ref.read(addGradeNotifierProvider.notifier).deleteGrade(
              widget.existingGrade!.id,
              widget.subjectId,
            );
        if (mounted) {
          if (success) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Grade deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to delete grade. Please try again.'),
                backgroundColor: Colors.red,
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingGrade != null;
    final students = widget.students ?? [];

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (fixed at top)
                Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_rounded : Icons.add_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Grade' : 'Add Grade',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable form content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Student Selector (only for new grades)
                        if (!isEditing && students.isNotEmpty) ...[
                          DropdownButtonFormField<String>(
                            initialValue: students.any((s) => s.id == _selectedStudentId)
                                ? _selectedStudentId
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Student',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person_rounded),
                            ),
                            isExpanded: true,
                            items: students.map((student) {
                              return DropdownMenuItem(
                                value: student.id,
                                child: Text(
                                  student.fullName,
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
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Grade Type Selector
                        DropdownButtonFormField<String>(
                          initialValue: _selectedGradeType,
                          decoration: InputDecoration(
                            labelText: 'Grade Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category_rounded),
                          ),
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
                        ),
                        const SizedBox(height: 16),

                        // Score and Weight Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Score
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _scoreController,
                                decoration: InputDecoration(
                                  labelText: 'Score',
                                  hintText: '0-100',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  prefixIcon: const Icon(Icons.grade_rounded),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  final score = double.tryParse(value);
                                  if (score == null) {
                                    return 'Invalid number';
                                  }
                                  if (score < 0 || score > 100) {
                                    return '0-100';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Weight
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                decoration: InputDecoration(
                                  labelText: 'Weight',
                                  hintText: '1.0',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d*'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Comment
                        TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: 'Comment (optional)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.comment_rounded),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions (fixed at bottom)
                Row(
                  children: [
                    if (isEditing)
                      TextButton.icon(
                        onPressed: _isLoading ? null : _deleteGrade,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: theme.colorScheme.error,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _saveGrade,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded, size: 18),
                      label: Text(isEditing ? 'Update' : 'Save'),
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
