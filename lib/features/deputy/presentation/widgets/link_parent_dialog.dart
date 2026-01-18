import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/providers/theme_provider.dart';
import '../../domain/entities/entities.dart';
import '../providers/deputy_provider.dart';

/// Dialog for linking a parent to a student.
///
/// Features:
/// - Student selector (searchable dropdown)
/// - Optional expiration date picker
/// - Generate invite button
/// - Copy invite code to clipboard
class LinkParentDialog extends ConsumerStatefulWidget {
  const LinkParentDialog({
    super.key,
    required this.schoolId,
    this.preselectedStudent,
  });

  /// The school ID to generate the invite for.
  final String schoolId;

  /// Optional preselected student.
  final StudentWithoutParent? preselectedStudent;

  @override
  ConsumerState<LinkParentDialog> createState() => _LinkParentDialogState();
}

class _LinkParentDialogState extends ConsumerState<LinkParentDialog> {
  StudentWithoutParent? _selectedStudent;
  DateTime? _expiresAt;
  bool _isLoading = false;
  ParentInvite? _generatedInvite;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.preselectedStudent;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _generatedInvite != null
                ? Icons.check_circle_rounded
                : Icons.person_add_alt_rounded,
            color: _generatedInvite != null
                ? Colors.green
                : theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(_generatedInvite != null ? 'Invite Created' : 'Link Parent'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: _generatedInvite != null
            ? _buildSuccessContent(theme, isPlayful)
            : _buildFormContent(theme, isPlayful),
      ),
      actions: _generatedInvite != null
          ? [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Done'),
              ),
            ]
          : [
              TextButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: _isLoading || _selectedStudent == null
                    ? null
                    : _generateInvite,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate Invite'),
              ),
            ],
    );
  }

  Widget _buildFormContent(ThemeData theme, bool isPlayful) {
    final studentsAsync = ref.watch(studentsWithoutParentsProvider(widget.schoolId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instructions
        Container(
          padding: EdgeInsets.all(isPlayful ? 14 : 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Generate an invite code for a parent to link with their child\'s account.',
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Student Selector
        _buildLabel('Student', theme),
        const SizedBox(height: 8),
        studentsAsync.when(
          data: (students) {
            if (students.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All students already have parents linked!',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return DropdownButtonFormField<StudentWithoutParent>(
              decoration: _inputDecoration(isPlayful),
              initialValue: _selectedStudent,
              hint: const Text('Select a student'),
              isExpanded: true,
              items: students.map((student) {
                return DropdownMenuItem(
                  value: student,
                  child: Text(
                    student.className != null
                        ? '${student.fullName} (${student.className})'
                        : student.fullName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (student) {
                setState(() {
                  _selectedStudent = student;
                  _errorMessage = null;
                });
              },
            );
          },
          loading: () => Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Failed to load students: $error',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Expiration Date (Optional)
        _buildLabel('Expiration Date (optional)', theme),
        const SizedBox(height: 8),
        _ExpirationDatePicker(
          expiresAt: _expiresAt,
          isPlayful: isPlayful,
          onDateChanged: (date) {
            setState(() {
              _expiresAt = date;
            });
          },
        ),

        // Error Message
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuccessContent(ThemeData theme, bool isPlayful) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Message
        Container(
          padding: EdgeInsets.all(isPlayful ? 20 : 16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 48,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Text(
                'Invite Generated Successfully!',
                style: TextStyle(
                  fontSize: isPlayful ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Share this code with the parent to link their account.',
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Student Info
        _buildLabel('For Student', theme),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _selectedStudent?.initials ?? '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStudent?.fullName ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (_selectedStudent?.className != null)
                      Text(
                        'Class ${_selectedStudent!.className}',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Invite Code
        _buildLabel('Invite Code', theme),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _generatedInvite!.code,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: _copyInviteCode,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy to clipboard',
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),

        // Expiration info
        if (_generatedInvite!.expiresAt != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Expires: ${_formatDate(_generatedInvite!.expiresAt!)}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isPlayful) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _generateInvite() async {
    if (_selectedStudent == null) {
      setState(() {
        _errorMessage = 'Please select a student';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifier = ref.read(deputyNotifierProvider.notifier);
      final invite = await notifier.generateParentInvite(
        studentId: _selectedStudent!.id,
        schoolId: widget.schoolId,
        expiresAt: _expiresAt,
      );

      if (invite != null) {
        setState(() {
          _generatedInvite = invite;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to generate invite. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _copyInviteCode() {
    if (_generatedInvite == null) return;

    Clipboard.setData(ClipboardData(text: _generatedInvite!.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Expiration date picker widget.
class _ExpirationDatePicker extends StatelessWidget {
  const _ExpirationDatePicker({
    required this.expiresAt,
    required this.isPlayful,
    required this.onDateChanged,
  });

  final DateTime? expiresAt;
  final bool isPlayful;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        expiresAt != null
                            ? '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}'
                            : 'No expiration (never expires)',
                        style: TextStyle(
                          fontSize: 15,
                          color: expiresAt != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    if (expiresAt != null)
                      IconButton(
                        onPressed: () => onDateChanged(null),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select expiration date',
    );

    if (picked != null) {
      // Set to end of day
      onDateChanged(DateTime(
        picked.year,
        picked.month,
        picked.day,
        23,
        59,
        59,
      ));
    }
  }
}
