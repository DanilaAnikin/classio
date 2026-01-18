import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../domain/entities/entities.dart';

/// Widget displaying a single attendance record in a list.
///
/// Shows:
/// - Date and time
/// - Subject name
/// - Attendance status with color coding
/// - Excuse status badge if applicable
class AttendanceListItem extends ConsumerWidget {
  const AttendanceListItem({
    super.key,
    required this.attendance,
    this.onTap,
    this.showExcuseButton = false,
    this.onExcuseTap,
  });

  /// The attendance record to display.
  final AttendanceEntity attendance;

  /// Optional callback when the item is tapped.
  final VoidCallback? onTap;

  /// Whether to show the excuse button (for parents).
  final bool showExcuseButton;

  /// Callback when the excuse button is tapped.
  final VoidCallback? onExcuseTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
      child: Container(
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: attendance.status.color.withValues(alpha: 0.3),
            width: isPlayful ? 2 : 1,
          ),
          boxShadow: isPlayful
              ? [
                  BoxShadow(
                    color: attendance.status.color.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Date and status
            Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(attendance.date),
                        style: TextStyle(
                          fontSize: isPlayful ? 16 : 14,
                          fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (attendance.lessonStartTime != null) ...[
                        SizedBox(height: isPlayful ? 4 : 2),
                        Text(
                          '${DateFormat('HH:mm').format(attendance.lessonStartTime!)} - ${attendance.lessonEndTime != null ? DateFormat('HH:mm').format(attendance.lessonEndTime!) : ''}',
                          style: TextStyle(
                            fontSize: isPlayful ? 13 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Status badge
                _StatusBadge(
                  status: attendance.status,
                  isPlayful: isPlayful,
                ),
              ],
            ),
            SizedBox(height: isPlayful ? 12 : 10),

            // Subject info
            Row(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: isPlayful ? 18 : 16,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: isPlayful ? 8 : 6),
                Expanded(
                  child: Text(
                    attendance.subjectName ?? 'Unknown Subject',
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),

            // Note if present
            if (attendance.note != null && attendance.note!.isNotEmpty) ...[
              SizedBox(height: isPlayful ? 10 : 8),
              Container(
                padding: EdgeInsets.all(isPlayful ? 10 : 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: isPlayful ? 16 : 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: isPlayful ? 8 : 6),
                    Expanded(
                      child: Text(
                        attendance.note!,
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Excuse status row
            if (attendance.isNegative) ...[
              SizedBox(height: isPlayful ? 12 : 10),
              Row(
                children: [
                  // Excuse status badge
                  ExcuseStatusBadge(
                    status: attendance.excuseStatus,
                    isPlayful: isPlayful,
                  ),
                  const Spacer(),
                  // Submit excuse button (for parents)
                  if (showExcuseButton && attendance.canSubmitExcuse)
                    TextButton.icon(
                      onPressed: onExcuseTap,
                      icon: Icon(
                        Icons.edit_note_rounded,
                        size: isPlayful ? 20 : 18,
                      ),
                      label: Text(
                        attendance.excuseStatus == ExcuseStatus.rejected
                            ? 'Resubmit'
                            : 'Submit Excuse',
                        style: TextStyle(
                          fontSize: isPlayful ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPlayful ? 12 : 10,
                          vertical: isPlayful ? 8 : 6,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Badge showing the attendance status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isPlayful,
  });

  final AttendanceStatus status;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 14 : 12,
        vertical: isPlayful ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: isPlayful ? 18 : 16,
            color: status.color,
          ),
          SizedBox(width: isPlayful ? 6 : 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge showing the excuse status.
class ExcuseStatusBadge extends StatelessWidget {
  const ExcuseStatusBadge({
    super.key,
    required this.status,
    required this.isPlayful,
  });

  final ExcuseStatus status;
  final bool isPlayful;

  IconData get _icon {
    switch (status) {
      case ExcuseStatus.none:
        return Icons.remove_circle_outline;
      case ExcuseStatus.pending:
        return Icons.hourglass_empty_rounded;
      case ExcuseStatus.approved:
        return Icons.check_circle_outline;
      case ExcuseStatus.rejected:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 10 : 8,
        vertical: isPlayful ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: isPlayful ? 16 : 14,
            color: status.color,
          ),
          SizedBox(width: isPlayful ? 6 : 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: isPlayful ? 12 : 11,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}
