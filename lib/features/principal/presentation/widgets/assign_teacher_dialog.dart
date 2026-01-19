import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
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
      final selectedTeacherId = _selectedTeacherId;
      if (selectedTeacherId == null) {
        success = await notifier.removeHeadTeacher(
          widget.classDetails.id,
          widget.schoolId,
        );
      } else {
        success = await notifier.assignHeadTeacher(
          widget.classDetails.id,
          selectedTeacherId,
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
    final theme = Theme.of(context);
    final teachersAsync =
        ref.watch(schoolTeachersProvider(widget.schoolId));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: AppSpacing.dialogInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.person_add_outlined,
                      color: theme.colorScheme.primary,
                      size: AppIconSize.md,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Head Teacher',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.classDetails.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
              SizedBox(height: AppSpacing.xl),

              // Current head teacher info
              if (widget.classDetails.headTeacher case final headTeacher?) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: CleanColors.info.withValues(alpha: AppOpacity.soft),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: CleanColors.info,
                        size: AppIconSize.sm,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          'Current head teacher: ${headTeacher.fullName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: CleanColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),
              ],

              // Teacher selection
              Text(
                'Select Teacher',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.xs),

              teachersAsync.when(
                data: (teachers) {
                  if (teachers.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: CleanColors.warning.withValues(alpha: AppOpacity.soft),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_outlined,
                            color: CleanColors.warning,
                            size: AppIconSize.md,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'No teachers available. Invite teachers first.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: CleanColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        // Option to remove head teacher
                        RadioListTile<String?>(
                          value: null,
                          groupValue: _selectedTeacherId,
                          title: Text(
                            'No head teacher',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.onSurfaceVariant,
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
                                style: theme.textTheme.labelSmall,
                              ),
                              secondary: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                                child: Text(
                                  _getInitials(teacher),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
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
                loading: () => Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: const CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: CleanColors.error.withValues(alpha: AppOpacity.soft),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: CleanColors.error,
                        size: AppIconSize.md,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        'Failed to load teachers',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: CleanColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? SizedBox(
                            width: AppIconSize.sm,
                            height: AppIconSize.sm,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
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
