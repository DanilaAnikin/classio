import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../attendance/domain/entities/absence_excuse.dart';

/// Dialog for teachers to review and decline absence excuses.
///
/// Provides a text field for entering a response message when declining.
class ReviewAbsenceExcuseDialog extends ConsumerStatefulWidget {
  const ReviewAbsenceExcuseDialog({
    super.key,
    required this.excuse,
    required this.onDecline,
  });

  /// The excuse being reviewed.
  final AbsenceExcuse excuse;

  /// Callback when declining with optional response.
  final Future<void> Function(String? response) onDecline;

  @override
  ConsumerState<ReviewAbsenceExcuseDialog> createState() =>
      _ReviewAbsenceExcuseDialogState();
}

class _ReviewAbsenceExcuseDialogState
    extends ConsumerState<ReviewAbsenceExcuseDialog> {
  final _responseController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: theme.colorScheme.error,
            size: isPlayful ? 28 : 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Decline Excuse'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Student info card
            Container(
              padding: EdgeInsets.all(isPlayful ? 14 : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: isPlayful ? 18 : 16,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          widget.excuse.studentName?.isNotEmpty == true
                              ? widget.excuse.studentName![0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.excuse.studentName ?? 'Unknown Student',
                              style: TextStyle(
                                fontSize: isPlayful ? 15 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.excuse.subjectName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.excuse.subjectName!,
                                style: TextStyle(
                                  fontSize: isPlayful ? 12 : 11,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.excuse.attendanceDate != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: isPlayful ? 14 : 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('MMMM d, yyyy')
                              .format(widget.excuse.attendanceDate!),
                          style: TextStyle(
                            fontSize: isPlayful ? 12 : 11,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Original excuse reason
            Text(
              'Parent\'s Excuse:',
              style: TextStyle(
                fontSize: isPlayful ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isPlayful ? 12 : 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                widget.excuse.reason,
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  color: theme.colorScheme.onSurface,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Response field
            Text(
              'Your Response (Optional):',
              style: TextStyle(
                fontSize: isPlayful ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _responseController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Explain why the excuse is being declined (optional)...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The parent will be notified of your decision.',
              style: TextStyle(
                fontSize: isPlayful ? 11 : 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleDecline,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
          ),
          child: _isLoading
              ? SizedBox(
                  width: isPlayful ? 20 : 18,
                  height: isPlayful ? 20 : 18,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Decline'),
        ),
      ],
    );
  }

  Future<void> _handleDecline() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = _responseController.text.trim();
      await widget.onDecline(response.isEmpty ? null : response);

      if (mounted) {
        Navigator.pop(context);
        final isPlayful = ref.read(themeNotifierProvider) == ThemeType.playful;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Excuse declined'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
