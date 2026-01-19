import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/principal_providers.dart';

/// A dialog for generating staff invite codes.
///
/// Allows principals to generate invite codes for teachers and admins.
class GenerateStaffInviteDialog extends ConsumerStatefulWidget {
  /// Creates a [GenerateStaffInviteDialog].
  const GenerateStaffInviteDialog({
    super.key,
    required this.schoolId,
  });

  /// The school ID to generate the invite for.
  final String schoolId;

  /// Shows the generate staff invite dialog.
  static Future<String?> show(
    BuildContext context, {
    required String schoolId,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => GenerateStaffInviteDialog(schoolId: schoolId),
    );
  }

  @override
  ConsumerState<GenerateStaffInviteDialog> createState() =>
      _GenerateStaffInviteDialogState();
}

class _GenerateStaffInviteDialogState
    extends ConsumerState<GenerateStaffInviteDialog> {
  UserRole _selectedRole = UserRole.teacher;
  int _usageLimit = 1;
  int _expiryDays = 7;
  String? _generatedCode;
  bool _isGenerating = false;

  static const List<int> _usageLimitOptions = [1, 5, 10, 25, 50, 100];
  static const List<int> _expiryOptions = [1, 3, 7, 14, 30, 90];

  Future<void> _generateCode() async {
    setState(() => _isGenerating = true);

    try {
      final notifier = ref.read(principalNotifierProvider.notifier);
      final inviteCode = await notifier.generateInviteCode(
        schoolId: widget.schoolId,
        role: _selectedRole,
        usageLimit: _usageLimit,
        expiryDays: _expiryDays,
      );
      final code = inviteCode?.code;

      if (code != null && mounted) {
        setState(() {
          _generatedCode = code;
          _isGenerating = false;
        });
      } else if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate invite code'),
            backgroundColor: CleanColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: CleanColors.error,
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    final code = _generatedCode;
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invite code copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Admin';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      default:
        return role.name;
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return CleanColors.secondary;
      case UserRole.teacher:
        return CleanColors.info;
      case UserRole.student:
        return CleanColors.success;
      case UserRole.parent:
        return CleanColors.warning;
      default:
        return CleanColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      Icons.vpn_key_outlined,
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
                    onPressed: () => Navigator.pop(context, _generatedCode),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl),

              if (_generatedCode case null) ...[
                // Role selection
                Text(
                  'Role',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [UserRole.teacher, UserRole.admin, UserRole.student, UserRole.parent]
                      .map((role) => ChoiceChip(
                            label: Text(_getRoleDisplayName(role)),
                            selected: _selectedRole == role,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedRole = role);
                              }
                            },
                            selectedColor:
                                _getRoleColor(role).withValues(alpha: AppOpacity.medium),
                            labelStyle: TextStyle(
                              color: _selectedRole == role
                                  ? _getRoleColor(role)
                                  : theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                              fontWeight: _selectedRole == role
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: AppSpacing.lg),

                // Usage limit
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Usage Limit',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButton<int>(
                      value: _usageLimit,
                      items: _usageLimitOptions
                          .map((limit) => DropdownMenuItem<int>(
                                value: limit,
                                child: Text('$limit uses'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _usageLimit = value);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),

                // Expiry days
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Expires In',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButton<int>(
                      value: _expiryDays,
                      items: _expiryOptions
                          .map((days) => DropdownMenuItem<int>(
                                value: days,
                                child: Text(days == 1 ? '1 day' : '$days days'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _expiryDays = value);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isGenerating ? null : _generateCode,
                    child: _isGenerating
                        ? SizedBox(
                            width: AppIconSize.sm,
                            height: AppIconSize.sm,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Generate Code'),
                  ),
                ),
              ] else if (_generatedCode case final generatedCode?) ...[
                // Generated code display
                Container(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: CleanColors.success.withValues(alpha: AppOpacity.soft),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: CleanColors.success.withValues(alpha: AppOpacity.soft),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: CleanColors.success,
                        size: AppIconSize.xxl,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'Invite Code Generated!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: CleanColors.success,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium)),
                        ),
                        child: SelectableText(
                          generatedCode,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: Icon(Icons.copy, size: AppIconSize.xs + 2),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.md),

                // Code details
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Role',
                        value: _getRoleDisplayName(_selectedRole),
                        icon: Icons.badge_outlined,
                      ),
                      Divider(height: AppSpacing.md),
                      _DetailRow(
                        label: 'Usage Limit',
                        value: '$_usageLimit uses',
                        icon: Icons.people_outline,
                      ),
                      Divider(height: AppSpacing.md),
                      _DetailRow(
                        label: 'Expires In',
                        value: _expiryDays == 1 ? '1 day' : '$_expiryDays days',
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg),

                // Done button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _generatedCode),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row showing a label and value with an icon.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.xs + 2,
          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
        ),
        SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
