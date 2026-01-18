import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../invite/presentation/providers/invite_provider.dart';

/// Dialog for inviting students to a class.
class InviteStudentDialog extends ConsumerStatefulWidget {
  const InviteStudentDialog({
    super.key,
    required this.classId,
    required this.className,
  });

  final String classId;
  final String className;

  @override
  ConsumerState<InviteStudentDialog> createState() =>
      _InviteStudentDialogState();
}

class _InviteStudentDialogState extends ConsumerState<InviteStudentDialog> {
  String? _generatedToken;
  bool _isLoading = false;
  bool _hasExpiration = false;
  DateTime? _expiresAt;

  Future<void> _generateToken() async {
    setState(() => _isLoading = true);

    try {
      final token = await ref.read(inviteNotifierProvider.notifier).generateInvite(
            targetRole: UserRole.student,
            classId: widget.classId,
            expiresAt: _hasExpiration ? _expiresAt : null,
          );

      if (token != null && mounted) {
        setState(() => _generatedToken = token);
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

  void _copyToken() {
    if (_generatedToken != null) {
      Clipboard.setData(ClipboardData(text: _generatedToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectExpiration() async {
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inviteState = ref.watch(inviteNotifierProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Student',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'to ${widget.className}',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generate an invite token and share it with the student. They will use this token to join the class.',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Expiration option
              if (_generatedToken == null) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Set Expiration'),
                  subtitle: const Text('Token will expire after this date'),
                  value: _hasExpiration,
                  onChanged: (value) {
                    setState(() {
                      _hasExpiration = value;
                      if (value && _expiresAt == null) {
                        _expiresAt =
                            DateTime.now().add(const Duration(days: 7));
                      }
                    });
                  },
                ),

                if (_hasExpiration) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectExpiration,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
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
                            child: Text(
                              _expiresAt != null
                                  ? _formatDateTime(_expiresAt!)
                                  : 'Select date and time',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // Generated Token Display
              if (_generatedToken != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Token Generated!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _generatedToken!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _copyToken,
                              icon: const Icon(Icons.copy_rounded),
                              tooltip: 'Copy to clipboard',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Error message
              if (inviteState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inviteState.error!,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Actions
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(_generatedToken != null ? 'Done' : 'Cancel'),
                  ),
                  if (_generatedToken == null)
                    FilledButton.icon(
                      onPressed:
                          (_isLoading || inviteState.isLoading) ? null : _generateToken,
                      icon: (_isLoading || inviteState.isLoading)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.vpn_key_rounded, size: 18),
                      label: const Text('Generate Token'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
