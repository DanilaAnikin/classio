import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
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
                      color: CleanColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.vpn_key_outlined,
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
                    onPressed: () => Navigator.pop(context, _generatedCode),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_generatedCode == null) ...[
                // Role selection
                const Text(
                  'Role',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CleanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                                _getRoleColor(role).withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: _selectedRole == role
                                  ? _getRoleColor(role)
                                  : CleanColors.textSecondary,
                              fontWeight: _selectedRole == role
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),

                // Usage limit
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Usage Limit',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CleanColors.textPrimary,
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
                const SizedBox(height: 12),

                // Expiry days
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Expires In',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CleanColors.textPrimary,
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
                const SizedBox(height: 24),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isGenerating ? null : _generateCode,
                    child: _isGenerating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CleanColors.onPrimary,
                            ),
                          )
                        : const Text('Generate Code'),
                  ),
                ),
              ] else ...[
                // Generated code display
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CleanColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CleanColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: CleanColors.success,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Invite Code Generated!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CleanColors.success,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: CleanColors.border),
                        ),
                        child: SelectableText(
                          _generatedCode!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 2,
                            color: CleanColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Code details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CleanColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Role',
                        value: _getRoleDisplayName(_selectedRole),
                        icon: Icons.badge_outlined,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Usage Limit',
                        value: '$_usageLimit uses',
                        icon: Icons.people_outline,
                      ),
                      const Divider(height: 16),
                      _DetailRow(
                        label: 'Expires In',
                        value: _expiryDays == 1 ? '1 day' : '$_expiryDays days',
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

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
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: CleanColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: CleanColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: CleanColors.textPrimary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
