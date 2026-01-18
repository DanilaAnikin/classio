import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _generatedCode != null
              ? _buildSuccessContent()
              : _buildFormContent(),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CleanColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.person_add_outlined,
                color: CleanColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Generate Invite Code',
                style: TextStyle(
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
        const SizedBox(height: 24),

        // Role selection
        const Text(
          'Select Role',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: CleanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<UserRole>(
          initialValue: _selectedRole,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          isExpanded: true,
          items: _availableRoles.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Row(
                children: [
                  Icon(_getRoleIcon(role), size: 20, color: _getRoleColor(role)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_getRoleDisplayName(role)),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
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
        ),

        // Class selection (only for students)
        if (_selectedRole == UserRole.student) ...[
          const SizedBox(height: 16),
          const Text(
            'Assign to Class',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CleanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Student will be automatically enrolled in this class',
            style: TextStyle(
              fontSize: 12,
              color: CleanColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildClassSelector(),
        ],

        const SizedBox(height: 16),

        // Usage limit
        const Text(
          'Usage Limit',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: CleanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _usageLimit.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                label: _usageLimit.toString(),
                onChanged: (value) {
                  setState(() => _usageLimit = value.round());
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: CleanColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_usageLimit',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Expiration toggle
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Set Expiration'),
          subtitle: const Text(
            'Code will become invalid after this date',
            style: TextStyle(fontSize: 12),
          ),
          value: _hasExpiration,
          onChanged: (value) {
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
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectExpirationDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: CleanColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _expiresAt != null
                          ? _formatDateTime(_expiresAt!)
                          : 'Select date and time',
                      style: TextStyle(
                        color: _expiresAt != null
                            ? CleanColors.textPrimary
                            : CleanColors.hint,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
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
            FilledButton.icon(
              onPressed: _isLoading ? null : _generateCode,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CleanColors.onPrimary,
                      ),
                    )
                  : const Icon(Icons.add),
              label: const Text('Generate'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CleanColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: CleanColors.success,
            size: 48,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Invite Code Generated!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CleanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Share this code with the person you want to invite:',
          style: TextStyle(color: CleanColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Code display
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CleanColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CleanColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _generatedCode!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: CleanColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.copy, color: CleanColors.primary),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _generatedCode!));
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
        const SizedBox(height: 16),

        // Role info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getRoleColor(_selectedRole).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getRoleIcon(_selectedRole),
                size: 16,
                color: _getRoleColor(_selectedRole),
              ),
              const SizedBox(width: 8),
              Text(
                'For: ${_getRoleDisplayName(_selectedRole)}',
                style: TextStyle(
                  color: _getRoleColor(_selectedRole),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
    final classesAsync = ref.watch(principalSchoolClassesProvider(widget.schoolId));

    return classesAsync.when(
      data: (classes) {
        if (classes.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CleanColors.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CleanColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: CleanColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No classes available. Create a class first.',
                    style: TextStyle(
                      color: CleanColors.warning,
                      fontSize: 13,
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
            hintText: 'Select a class (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          isExpanded: true,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('No class (assign later)'),
            ),
            ...classes.map((classInfo) {
              return DropdownMenuItem<String>(
                value: classInfo.id,
                child: Row(
                  children: [
                    if (classInfo.gradeLevel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: CleanColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Grade ${classInfo.gradeLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: CleanColors.primary,
                          ),
                        ),
                      ),
                    if (classInfo.gradeLevel != null)
                      const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        classInfo.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${classInfo.studentCount} students',
                      style: TextStyle(
                        fontSize: 12,
                        color: CleanColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() => _selectedClassId = value);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CleanColors.errorLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: CleanColors.error, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Failed to load classes',
                style: TextStyle(color: CleanColors.error, fontSize: 13),
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
