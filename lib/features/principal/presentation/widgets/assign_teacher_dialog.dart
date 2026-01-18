import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/class_with_details.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/principal_providers.dart';

/// A dialog for assigning a head teacher to a class.
class AssignTeacherDialog extends ConsumerStatefulWidget {
  /// Creates an [AssignTeacherDialog].
  const AssignTeacherDialog({
    super.key,
    required this.schoolId,
    required this.classDetails,
  });

  /// The school ID.
  final String schoolId;

  /// The class to assign a teacher to.
  final ClassWithDetails classDetails;

  /// Shows the assign teacher dialog.
  static Future<bool?> show(
    BuildContext context, {
    required String schoolId,
    required ClassWithDetails classDetails,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AssignTeacherDialog(
        schoolId: schoolId,
        classDetails: classDetails,
      ),
    );
  }

  @override
  ConsumerState<AssignTeacherDialog> createState() =>
      _AssignTeacherDialogState();
}

class _AssignTeacherDialogState extends ConsumerState<AssignTeacherDialog> {
  String? _selectedTeacherId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.classDetails.headTeacher?.id;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(principalNotifierProvider.notifier);

      bool success;
      if (_selectedTeacherId == null) {
        success = await notifier.removeHeadTeacher(
          widget.classDetails.id,
          widget.schoolId,
        );
      } else {
        success = await notifier.assignHeadTeacher(
          widget.classDetails.id,
          _selectedTeacherId!,
          widget.schoolId,
        );
      }

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_selectedTeacherId == null
                ? 'Head teacher removed'
                : 'Head teacher assigned successfully'),
            backgroundColor: CleanColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: CleanColors.error,
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
    final teachersAsync =
        ref.watch(schoolTeachersProvider(widget.schoolId));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CleanColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      color: CleanColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assign Head Teacher',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CleanColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.classDetails.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CleanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Current head teacher info
              if (widget.classDetails.headTeacher != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CleanColors.infoLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: CleanColors.info, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Current head teacher: ${widget.classDetails.headTeacher!.fullName}',
                          style: const TextStyle(
                            color: CleanColors.info,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Teacher selection
              const Text(
                'Select Teacher',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CleanColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              teachersAsync.when(
                data: (teachers) {
                  if (teachers.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CleanColors.warningLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_outlined,
                              color: CleanColors.warning),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No teachers available. Invite teachers first.',
                              style: TextStyle(color: CleanColors.warning),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      border: Border.all(color: CleanColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // Option to remove head teacher
                        RadioListTile<String?>(
                          value: null,
                          groupValue: _selectedTeacherId,
                          title: const Text(
                            'No head teacher',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: CleanColors.textSecondary,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _selectedTeacherId = value);
                          },
                        ),
                        const Divider(height: 1),
                        ...teachers.map((teacher) => RadioListTile<String>(
                              value: teacher.id,
                              groupValue: _selectedTeacherId,
                              title: Text(teacher.fullName),
                              subtitle: Text(
                                teacher.email ?? '',
                                style: const TextStyle(fontSize: 12),
                              ),
                              secondary: CircleAvatar(
                                backgroundColor:
                                    CleanColors.primary.withValues(alpha: 0.1),
                                child: Text(
                                  _getInitials(teacher),
                                  style: const TextStyle(
                                    color: CleanColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _selectedTeacherId = value);
                              },
                            )),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CleanColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: CleanColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Failed to load teachers',
                        style: TextStyle(color: CleanColors.error),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
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
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(AppUser user) {
    if (user.firstName != null && user.lastName != null) {
      return '${user.firstName![0]}${user.lastName![0]}'.toUpperCase();
    } else if (user.firstName != null) {
      return user.firstName![0].toUpperCase();
    }
    return (user.email ?? 'U')[0].toUpperCase();
  }
}
