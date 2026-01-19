import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/theme.dart';
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
  final _formKey = GlobalKey<FormState>();
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
    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _generatedInvite != null
                ? Icons.check_circle_rounded
                : Icons.person_add_alt_rounded,
            color: _generatedInvite != null
                ? successColor
                : theme.colorScheme.primary,
            size: AppIconSize.md,
          ),
          SizedBox(width: AppSpacing.sm),
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
                    ? SizedBox(
                        width: AppIconSize.sm,
                        height: AppIconSize.sm,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate Invite'),
              ),
            ],
    );
  }

  Widget _buildFormContent(ThemeData theme, bool isPlayful) {
    final studentsAsync = ref.watch(studentsWithoutParentsProvider(widget.schoolId));
    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        // Instructions
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: AppOpacity.subtle),
            borderRadius: cardRadius,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: AppIconSize.sm,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Generate an invite code for a parent to link with their child\'s account.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Student Selector
        _buildLabel('Student', theme),
        SizedBox(height: AppSpacing.xs),
        studentsAsync.when(
          data: (students) {
            if (students.isEmpty) {
              return Container(
                padding: AppSpacing.cardInsets,
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: AppOpacity.subtle),
                  borderRadius: cardRadius,
                  border: Border.all(
                    color: successColor.withValues(alpha: AppOpacity.medium),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: successColor,
                      size: AppIconSize.md,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'All students already have parents linked!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: successColor,
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
              onChanged: _isLoading
                  ? null
                  : (student) {
                      setState(() {
                        _selectedStudent = student;
                        _errorMessage = null;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'Please select a student';
                }
                return null;
              },
            );
          },
          loading: () => Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: AppIconSize.sm,
                height: AppIconSize.sm,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, stack) => Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: AppOpacity.subtle),
              borderRadius: cardRadius,
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
              ),
            ),
            child: Text(
              'Failed to load students: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Expiration Date (Optional)
        _buildLabel('Expiration Date (optional)', theme),
        SizedBox(height: AppSpacing.xs),
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
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: AppOpacity.subtle),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: AppIconSize.sm,
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        ],
      ),
    );
  }

  Widget _buildSuccessContent(ThemeData theme, bool isPlayful) {
    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Message
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: successColor.withValues(alpha: AppOpacity.subtle),
            borderRadius: cardRadius,
            border: Border.all(
              color: successColor.withValues(alpha: AppOpacity.medium),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.celebration_rounded,
                size: AppIconSize.xxl,
                color: successColor,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Invite Generated Successfully!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: successColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Share this code with the parent to link their account.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Student Info
        _buildLabel('For Student', theme),
        SizedBox(height: AppSpacing.xs),
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppSpacing.xxxl,
                height: AppSpacing.xxxl,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _selectedStudent?.initials ?? '?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStudent?.fullName ?? 'Unknown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_selectedStudent?.className case final className?)
                      Text(
                        'Class $className',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Invite Code
        _buildLabel('Invite Code', theme),
        SizedBox(height: AppSpacing.xs),
        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: AppOpacity.subtle),
            borderRadius: cardRadius,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: AppOpacity.medium),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  _generatedInvite?.code ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
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
        if (_generatedInvite?.expiresAt case final expiresAt?) ...[
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: AppIconSize.xs,
                color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                'Expires: ${_formatDate(expiresAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
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
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isPlayful) {
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: cardRadius,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _generateInvite() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

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
      final selectedStudent = _selectedStudent;
      if (selectedStudent == null) return;

      final notifier = ref.read(deputyNotifierProvider.notifier);
      final invite = await notifier.generateParentInvite(
        studentId: selectedStudent.id,
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
    final inviteCode = _generatedInvite?.code;
    if (inviteCode == null) return;

    Clipboard.setData(ClipboardData(text: inviteCode));
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _pickDate(context),
              borderRadius: cardRadius,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: cardRadius,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: AppOpacity.heavy),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: AppIconSize.sm,
                      color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        expiresAt != null
                            ? '${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}'
                            : 'No expiration (never expires)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: expiresAt != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                        ),
                      ),
                    ),
                    if (expiresAt != null)
                      IconButton(
                        onPressed: () => onDateChanged(null),
                        icon: Icon(Icons.close_rounded, size: AppIconSize.xs + 2),
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
