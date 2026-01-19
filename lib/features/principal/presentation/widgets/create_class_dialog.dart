import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../providers/principal_providers.dart';

/// A dialog for creating or editing a class.
class CreateClassDialog extends ConsumerStatefulWidget {
  /// Creates a [CreateClassDialog].
  const CreateClassDialog({
    super.key,
    required this.schoolId,
    this.initialName,
    this.initialGradeLevel,
    this.initialAcademicYear,
    this.initialHeadTeacherId,
    this.classId,
  });

  /// The school ID to create the class in.
  final String schoolId;

  /// Initial class name for editing.
  final String? initialName;

  /// Initial grade level for editing.
  final String? initialGradeLevel;

  /// Initial academic year for editing.
  final String? initialAcademicYear;

  /// Initial head teacher ID for editing.
  final String? initialHeadTeacherId;

  /// Class ID if editing an existing class.
  final String? classId;

  /// Whether this is an edit dialog.
  bool get isEditing => classId != null;

  /// Shows the create class dialog.
  static Future<bool?> show(
    BuildContext context, {
    required String schoolId,
    String? initialName,
    String? initialGradeLevel,
    String? initialAcademicYear,
    String? initialHeadTeacherId,
    String? classId,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CreateClassDialog(
        schoolId: schoolId,
        initialName: initialName,
        initialGradeLevel: initialGradeLevel,
        initialAcademicYear: initialAcademicYear,
        initialHeadTeacherId: initialHeadTeacherId,
        classId: classId,
      ),
    );
  }

  @override
  ConsumerState<CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends ConsumerState<CreateClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _gradeLevelController;
  late final TextEditingController _academicYearController;
  String? _selectedTeacherId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _gradeLevelController =
        TextEditingController(text: widget.initialGradeLevel);
    _academicYearController =
        TextEditingController(text: widget.initialAcademicYear);
    _selectedTeacherId = widget.initialHeadTeacherId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeLevelController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(principalNotifierProvider.notifier);

      final bool success;
      if (widget.isEditing) {
        // Update existing class
        final classId = widget.classId;
        if (classId == null) {
          throw StateError('Class ID is required for editing');
        }
        final classInfo = ClassInfo(
          id: classId,
          schoolId: widget.schoolId,
          name: _nameController.text.trim(),
          gradeLevel: _gradeLevelController.text.trim().isNotEmpty
              ? int.tryParse(_gradeLevelController.text.trim())
              : null,
          academicYear: _academicYearController.text.trim().isNotEmpty
              ? _academicYearController.text.trim()
              : null,
        );
        final updated = await notifier.updateClass(
          classInfo,
          headTeacherId: _selectedTeacherId,
        );
        success = updated != null;
      } else {
        // Create new class
        final classInfo = await notifier.createClass(
          schoolId: widget.schoolId,
          name: _nameController.text.trim(),
          gradeLevel: _gradeLevelController.text.trim().isNotEmpty
              ? _gradeLevelController.text.trim()
              : null,
          academicYear: _academicYearController.text.trim().isNotEmpty
              ? _academicYearController.text.trim()
              : null,
          headTeacherId: _selectedTeacherId,
        );
        success = classInfo != null;
      }

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing
                ? 'Class updated successfully'
                : 'Class created successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    final teachersAsync = ref.watch(schoolTeachersProvider(widget.schoolId));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: CleanColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                      ),
                      child: const Icon(
                        Icons.class_outlined,
                        color: CleanColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.isEditing ? 'Edit Class' : 'Create New Class',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CleanColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Name field
                TextFormField(
                  controller: _nameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Class Name',
                    hintText: 'e.g., Class 1A, Section B',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a class name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Grade level and Academic year in a row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gradeLevelController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Grade Level',
                          hintText: 'e.g., 1, 2, 10',
                          prefixIcon: const Icon(Icons.stairs_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null) {
                              return 'Must be a number';
                            }
                            if (parsed < 1 || parsed > 12) {
                              return 'Must be between 1 and 12';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: _academicYearController,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: 'Academic Year',
                          hintText: 'e.g., 2024/2025',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final regex = RegExp(r'^\d{4}/\d{4}$');
                            if (!regex.hasMatch(value.trim())) {
                              return 'Use YYYY/YYYY format';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Head teacher dropdown
                teachersAsync.when(
                  data: (teachers) => DropdownButtonFormField<String>(
                    initialValue: _selectedTeacherId,
                    decoration: InputDecoration(
                      labelText: 'Head Teacher (Optional)',
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                      ),
                    ),
                    isExpanded: true,
                    hint: const Text('Select a teacher'),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No head teacher'),
                      ),
                      ...teachers.map((teacher) => DropdownMenuItem<String>(
                            value: teacher.id,
                            child: Text(
                              teacher.fullName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() => _selectedTeacherId = value);
                          },
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text(
                    'Failed to load teachers',
                    style: TextStyle(color: CleanColors.error),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CleanColors.onPrimary,
                                ),
                              )
                            : Text(widget.isEditing ? 'Save' : 'Create'),
                      ),
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
