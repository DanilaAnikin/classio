import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/providers/theme_provider.dart';
import '../providers/admin_providers.dart';

/// Dialog for creating a new class.
class CreateClassDialog extends ConsumerStatefulWidget {
  const CreateClassDialog({super.key, required this.schoolId});

  final String schoolId;

  @override
  ConsumerState<CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends ConsumerState<CreateClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _academicYearController = TextEditingController(
    text: '${DateTime.now().year}/${DateTime.now().year + 1}',
  );
  bool _isCreating = false;

  @override
  void dispose() {
    _classNameController.dispose();
    _gradeLevelController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _createClass() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final gradeLevel = int.tryParse(_gradeLevelController.text) ?? 1;

      final classInfo = await ref.read(adminNotifierProvider.notifier).createClass(
        schoolId: widget.schoolId,
        name: _classNameController.text.trim(),
        gradeLevel: gradeLevel,
        academicYear: _academicYearController.text.trim(),
      );

      if (mounted) {
        if (classInfo != null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Class "${_classNameController.text}" created'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Check for error in admin state
          final adminState = ref.read(adminNotifierProvider);
          setState(() {
            _isCreating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminState.errorMessage ?? 'Failed to create class'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.class_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Create Class'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Class Name Input
              Text(
                'Class Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _classNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'e.g., 3.B, 4.A',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Grade Level Input
              Text(
                'Grade Level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gradeLevelController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'e.g., 3, 4, 5',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a grade level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Academic Year Input
              Text(
                'Academic Year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _academicYearController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'e.g., 2025/2026',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an academic year';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isCreating ? null : _createClass,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
