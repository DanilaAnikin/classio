import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/teacher_provider.dart';

/// Dialog for creating a new assignment.
class CreateAssignmentDialog extends ConsumerStatefulWidget {
  const CreateAssignmentDialog({
    super.key,
    this.preselectedSubjectId,
  });

  final String? preselectedSubjectId;

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
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? const TimeOfDay(hour: 23, minute: 59),
      );

      setState(() {
        _dueDate = date;
        _dueTime = time ?? const TimeOfDay(hour: 23, minute: 59);
      });
    }
  }

  DateTime? get _combinedDueDate {
    if (_dueDate == null) return null;
    final time = _dueTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
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
            const SnackBar(
              content: Text('Assignment created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create assignment. Please try again.'),
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
    final subjectsAsync = ref.watch(mySubjectsProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                    Icon(
                      Icons.assignment_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New Assignment',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Subject Selector
                subjectsAsync.when(
                  data: (subjects) => DropdownButtonFormField<String>(
                    initialValue: subjects.any((s) => s.id == _selectedSubjectId)
                        ? _selectedSubjectId
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.menu_book_rounded),
                    ),
                    isExpanded: true,
                    items: subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(subject.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                subject.name,
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
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(
                    'Failed to load subjects',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Chapter 5 Quiz',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Add instructions or details...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description_rounded),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Due Date and Max Score Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Due Date Picker
                    Expanded(
                      flex: 2,
                      child: InkWell(
                        onTap: _selectDueDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Due Date',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _dueDate != null
                                          ? DateFormat('MMM d, y')
                                              .format(_dueDate!)
                                          : 'No deadline',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    if (_dueTime != null && _dueDate != null)
                                      Text(
                                        'at ${_dueTime!.format(context)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _dueDate = null;
                                      _dueTime = null;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Max Score
                    Expanded(
                      child: TextFormField(
                        controller: _maxScoreController,
                        decoration: InputDecoration(
                          labelText: 'Max Score',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                ),
                const SizedBox(height: 24),

                // Actions
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _createAssignment,
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
                      label: const Text('Create Assignment'),
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
