import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';
import '../providers/admin_providers.dart';

/// Dialog for generating invite codes.
class GenerateInviteCodeDialog extends ConsumerStatefulWidget {
  const GenerateInviteCodeDialog({super.key, required this.schoolId});

  final String schoolId;

  @override
  ConsumerState<GenerateInviteCodeDialog> createState() =>
      _GenerateInviteCodeDialogState();
}

class _GenerateInviteCodeDialogState
    extends ConsumerState<GenerateInviteCodeDialog> {
  UserRole _selectedRole = UserRole.student;
  final _usageLimitController = TextEditingController(text: '1');
  String? _generatedCode;
  bool _isGenerating = false;

  @override
  void dispose() {
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final usageLimit = int.tryParse(_usageLimitController.text) ?? 1;

      final inviteCode = await ref.read(adminNotifierProvider.notifier).generateInviteCode(
        schoolId: widget.schoolId,
        role: _selectedRole,
        usageLimit: usageLimit,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      if (mounted) {
        if (inviteCode != null) {
          setState(() {
            _generatedCode = inviteCode.code;
            _isGenerating = false;
          });
        } else {
          // Check for error in admin state
          final adminState = ref.read(adminNotifierProvider);
          setState(() {
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminState.errorMessage ?? 'Failed to generate invite code'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
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

  void _copyToClipboard() {
    final code = _generatedCode;
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
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
            Icons.vpn_key_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Generate Invite Code',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Dropdown
            Text(
              'Role',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
              items: [UserRole.teacher, UserRole.student, UserRole.parent]
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.name[0].toUpperCase() +
                            role.name.substring(1)),
                      ))
                  .toList(),
              initialValue: _selectedRole,
              onChanged: _generatedCode == null
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),

            // Usage Limit Input
            Text(
              'Usage Limit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usageLimitController,
              enabled: _generatedCode == null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Number of times this code can be used',
              ),
            ),
            const SizedBox(height: 24),

            // Generated Code Display
            if (_generatedCode case final generatedCode?) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Invite Code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      generatedCode,
                      style: TextStyle(
                        fontSize: isPlayful ? 24 : 22,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_generatedCode != null ? 'Done' : 'Cancel'),
        ),
        if (_generatedCode == null)
          FilledButton(
            onPressed: _isGenerating ? null : _generateCode,
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate'),
          ),
      ],
    );
  }
}
