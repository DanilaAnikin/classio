import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/principal_providers.dart';

/// A dialog for generating invite codes.
class GenerateInviteDialog extends ConsumerStatefulWidget {
  /// Creates a [GenerateInviteDialog].
  const GenerateInviteDialog({
    super.key,
    required this.schoolId,
  });

  /// The school ID to generate the invite for.
  final String schoolId;

  /// Shows the generate invite dialog.
  static Future<bool?> show(BuildContext context, {required String schoolId}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => GenerateInviteDialog(schoolId: schoolId),
    );
  }

  @override
  ConsumerState<GenerateInviteDialog> createState() =>
      _GenerateInviteDialogState();
}

class _GenerateInviteDialogState extends ConsumerState<GenerateInviteDialog> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.teacher;
  int _usageLimit = 1;
  bool _hasExpiration = false;
  DateTime? _expiresAt;
  bool _isLoading = false;
  String? _generatedCode;
  String? _selectedClassId;

  final List<UserRole> _availableRoles = [
    UserRole.admin,
    UserRole.teacher,
    UserRole.student,
    UserRole.parent,
  ];

  Future<void> _generateCode() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(principalNotifierProvider.notifier);

      final inviteCode = await notifier.generateInviteCode(
        schoolId: widget.schoolId,
        role: _selectedRole,
        classId: _selectedRole == UserRole.student ? _selectedClassId : null,
        usageLimit: _usageLimit,
        expiresAt: _hasExpiration ? _expiresAt : null,
      );

      if (inviteCode != null && mounted) {
        setState(() => _generatedCode = inviteCode.code);
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

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_expiresAt ?? now),
      );

      if (time != null) {
        setState(() {
          _expiresAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: AppSpacing.dialogInsets,
          child: _generatedCode != null
              ? _buildSuccessContent()
              : _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
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
              child: Text(
                'Generate Invite Code',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),

        // Role selection
        Text(
          'Select Role',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<UserRole>(
          initialValue: _selectedRole,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          isExpanded: true,
          items: _availableRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Icon(_getRoleIcon(role), size: AppIconSize.sm, color: _getRoleColor(role)),
                  SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(_getRoleDisplayName(role)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                      // Reset class selection when role changes
                      if (value != UserRole.student) {
                        _selectedClassId = null;
                      }
                    });
                  }
                },
          validator: (value) {
            if (value == null) {
              return 'Please select a role';
            }
            return null;
          },
        ),

        // Class selection (only for students)
        if (_selectedRole == UserRole.student) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            'Assign to Class',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            'Student will be automatically enrolled in this class',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          _buildClassSelector(),
        ],

        SizedBox(height: AppSpacing.md),

        // Usage limit
        Text(
          'Usage Limit',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _usageLimit.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                label: _usageLimit.toString(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() => _usageLimit = value.round());
                      },
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '$_usageLimit',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Expiration toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Set Expiration'),
          subtitle: Text(
            'Code will become invalid after this date',
            style: theme.textTheme.labelSmall,
          ),
          value: _hasExpiration,
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() {
                    _hasExpiration = value;
                    if (value && _expiresAt == null) {
                      _expiresAt = DateTime.now().add(const Duration(days: 7));
                    }
                  });
                },
        ),

        // Expiration date picker
        if (_hasExpiration) ...[
          SizedBox(height: AppSpacing.xs),
          InkWell(
            onTap: _selectExpirationDate,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium)),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: AppIconSize.sm),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final expiresAt = _expiresAt;
                        return Text(
                          expiresAt != null
                              ? _formatDateTime(expiresAt)
                              : 'Select date and time',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: expiresAt != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                          ),
                        );
                      },
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
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
            FilledButton.icon(
              onPressed: _isLoading ? null : _generateCode,
              icon: _isLoading
                  ? SizedBox(
                      width: AppIconSize.sm,
                      height: AppIconSize.sm,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.add),
              label: const Text('Generate'),
            ),
          ],
        ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    final theme = Theme.of(context);
    final generatedCode = _generatedCode ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: CleanColors.success.withValues(alpha: AppOpacity.soft),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: CleanColors.success,
            size: AppIconSize.xxl,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        Text(
          'Invite Code Generated!',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          'Share this code with the person you want to invite:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xl),

        // Code display
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    generatedCode,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: generatedCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),

        // Role info
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: _getRoleColor(_selectedRole).withValues(alpha: AppOpacity.soft),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(_selectedRole),
                size: AppIconSize.xs,
                color: _getRoleColor(_selectedRole),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                'For: ${_getRoleDisplayName(_selectedRole)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _getRoleColor(_selectedRole),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),

        // Done button
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }

  /// Builds the class selector dropdown for student invites.
  Widget _buildClassSelector() {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(principalSchoolClassesProvider(widget.schoolId));

    return classesAsync.when(
      data: (classes) {
        if (classes.isEmpty) {
          return Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: CleanColors.warning.withValues(alpha: AppOpacity.soft),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: CleanColors.warning.withValues(alpha: AppOpacity.soft)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: CleanColors.warning, size: AppIconSize.sm),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'No classes available. Create a class first.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: CleanColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return DropdownButtonFormField<String>(
          initialValue: _selectedClassId,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.class_outlined),
            hintText: 'Select a class',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          isExpanded: true,
          items: classes.map((classInfo) {
            return DropdownMenuItem<String>(
              value: classInfo.id,
              child: Row(
                children: [
                  if (classInfo.gradeLevel != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'Grade ${classInfo.gradeLevel}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  if (classInfo.gradeLevel != null)
                    SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      classInfo.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${classInfo.studentCount} students',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() => _selectedClassId = value);
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a class for the student';
            }
            return null;
          },
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: AppIconSize.sm),
            SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                'Failed to load classes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return CleanColors.error;
      case UserRole.bigadmin:
        return CleanColors.primary;
      case UserRole.admin:
        return CleanColors.secondary;
      case UserRole.teacher:
        return CleanColors.info;
      case UserRole.student:
        return CleanColors.success;
      case UserRole.parent:
        return CleanColors.warning;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return Icons.admin_panel_settings;
      case UserRole.bigadmin:
        return Icons.supervisor_account;
      case UserRole.admin:
        return Icons.manage_accounts;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.student:
        return Icons.person;
      case UserRole.parent:
        return Icons.family_restroom;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }
}
