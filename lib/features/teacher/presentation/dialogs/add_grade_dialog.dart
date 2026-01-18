import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../providers/teacher_provider.dart';

/// Dialog for adding a grade to a student.
class AddGradeDialog extends ConsumerStatefulWidget {
  const AddGradeDialog({
    super.key,
    required this.subjectId,
    this.preselectedStudentId,
  });

  final String subjectId;
  final String? preselectedStudentId;

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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
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
            const SnackBar(
              content: Text('Grade added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add grade. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(subjectStudentsProvider(widget.subjectId));

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
                        Icons.grade_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add Grade',
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

                // Student Selector
                studentsAsync.when(
                  data: (students) => DropdownButtonFormField<String>(
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
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(
                    'Failed to load students',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                const SizedBox(height: 16),

                // Score and Weight Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score Field
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
                          prefixIcon: const Icon(Icons.score_rounded),
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
                            return 'Invalid';
                          }
                          if (score < 0 || score > 100) {
                            return '0-100';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Weight Field
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0 || weight > 10) {
                            return '0.1-10';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Grade Type Selector
                DropdownButtonFormField<String>(
                  initialValue: _selectedGradeType,
                  decoration: InputDecoration(
                    labelText: 'Grade Type (optional)',
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
                    setState(() => _selectedGradeType = value);
                  },
                ),
                const SizedBox(height: 16),

                // Comment Field
                TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText: 'Add a note about this grade...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.comment_rounded),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
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
                      onPressed: _isLoading ? null : _addGrade,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Grade'),
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

  String _getStudentName(AppUser student) {
    final parts = <String>[];
    if (student.firstName != null && student.firstName!.isNotEmpty) {
      parts.add(student.firstName!);
    }
    if (student.lastName != null && student.lastName!.isNotEmpty) {
      parts.add(student.lastName!);
    }
    return parts.isEmpty ? (student.email ?? '') : parts.join(' ');
  }

  String _getInitials(AppUser student) {
    final first = student.firstName?.isNotEmpty == true
        ? student.firstName![0].toUpperCase()
        : '';
    final last = student.lastName?.isNotEmpty == true
        ? student.lastName![0].toUpperCase()
        : '';
    if (first.isEmpty && last.isEmpty) {
      return (student.email?.isNotEmpty ?? false) ? student.email![0].toUpperCase() : '?';
    }
    return '$first$last';
  }
}
