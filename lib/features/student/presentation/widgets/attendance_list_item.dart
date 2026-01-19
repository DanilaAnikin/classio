import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';

/// Widget displaying a single attendance record in a list.
///
/// Shows:
/// - Date and time
/// - Subject name
/// - Attendance status with color coding
/// - Excuse status badge if applicable
/// - Theme-aware styling (Clean vs Playful)
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

  Color _getStatusColor({required bool isPlayful}) {
    switch (attendance.status) {
      case AttendanceStatus.present:
        return isPlayful
            ? PlayfulColors.attendancePresent
            : CleanColors.attendancePresent;
      case AttendanceStatus.absent:
        return isPlayful
            ? PlayfulColors.attendanceAbsent
            : CleanColors.attendanceAbsent;
      case AttendanceStatus.late:
        return isPlayful
            ? PlayfulColors.attendanceLate
            : CleanColors.attendanceLate;
      case AttendanceStatus.leftEarly:
        return isPlayful
            ? PlayfulColors.attendanceExcused
            : CleanColors.attendanceExcused;
      case AttendanceStatus.excused:
        return isPlayful ? PlayfulColors.info : CleanColors.info;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final statusColor = _getStatusColor(isPlayful: isPlayful);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card(isPlayful: isPlayful),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        curve: AppCurves.standard,
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: AppRadius.card(isPlayful: isPlayful),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: statusColor.withValues(alpha: AppOpacity.semi),
            width: isPlayful ? AppSpacing.space2 : 1,
          ),
          boxShadow: isPlayful
              ? [
                  BoxShadow(
                    color: statusColor.withValues(alpha: AppOpacity.soft),
                    blurRadius: AppSpacing.xs,
                    offset: const Offset(0, AppSpacing.space2),
                  ),
                ]
              : AppShadows.cleanXs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Date and status
            _HeaderRow(
              attendance: attendance,
              statusColor: statusColor,
              isPlayful: isPlayful,
            ),
            SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),

            // Subject info
            _SubjectRow(
              attendance: attendance,
              isPlayful: isPlayful,
            ),

            // Note if present
            if (attendance.note?.isNotEmpty ?? false) ...[
              SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
              _NoteSection(
                note: attendance.note!,
                isPlayful: isPlayful,
              ),
            ],

            // Excuse status row
            if (attendance.isNegative) ...[
              SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
              _ExcuseRow(
                attendance: attendance,
                showExcuseButton: showExcuseButton,
                onExcuseTap: onExcuseTap,
                isPlayful: isPlayful,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header row with date and status badge.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.attendance,
    required this.statusColor,
    required this.isPlayful,
  });

  final AttendanceEntity attendance;
  final Color statusColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMM d, yyyy').format(attendance.date),
                style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                  fontSize: isPlayful ? AppFontSize.titleSmall : AppFontSize.bodyMedium,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (attendance.lessonStartTime != null) ...[
                SizedBox(height: isPlayful ? AppSpacing.xxs : AppSpacing.space2),
                Text(
                  '${DateFormat('HH:mm').format(attendance.lessonStartTime!)} - ${attendance.lessonEndTime != null ? DateFormat('HH:mm').format(attendance.lessonEndTime!) : ''}',
                  style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
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
    );
  }
}

/// Subject information row.
class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.attendance,
    required this.isPlayful,
  });

  final AttendanceEntity attendance;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.book_outlined,
          size: isPlayful ? AppIconSize.sm : AppIconSize.xs,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: isPlayful ? AppSpacing.xs : AppSpacing.xxs),
        Expanded(
          child: Text(
            attendance.subjectName ?? 'Unknown Subject',
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.almostOpaque),
            ),
          ),
        ),
      ],
    );
  }
}

/// Note section with icon.
class _NoteSection extends StatelessWidget {
  const _NoteSection({
    required this.note,
    required this.isPlayful,
  });

  final String note;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: AppOpacity.subtle),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note_outlined,
            size: isPlayful ? AppIconSize.xs : AppIconSize.badge,
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
          ),
          SizedBox(width: isPlayful ? AppSpacing.xs : AppSpacing.xxs),
          Expanded(
            child: Text(
              note,
              style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Excuse status row with optional button.
class _ExcuseRow extends StatelessWidget {
  const _ExcuseRow({
    required this.attendance,
    required this.showExcuseButton,
    required this.onExcuseTap,
    required this.isPlayful,
  });

  final AttendanceEntity attendance;
  final bool showExcuseButton;
  final VoidCallback? onExcuseTap;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
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
              size: isPlayful ? AppIconSize.sm : AppIconSize.xs,
            ),
            label: Text(
              attendance.excuseStatus == ExcuseStatus.rejected
                  ? 'Resubmit'
                  : 'Submit Excuse',
              style: AppTypography.buttonTextSmall(isPlayful: isPlayful).copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
                vertical: isPlayful ? AppSpacing.xs : AppSpacing.xxs,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.buttonSmall(isPlayful: isPlayful),
              ),
            ),
          ),
      ],
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

  Color _getStatusColor() {
    switch (status) {
      case AttendanceStatus.present:
        return isPlayful
            ? PlayfulColors.attendancePresent
            : CleanColors.attendancePresent;
      case AttendanceStatus.absent:
        return isPlayful
            ? PlayfulColors.attendanceAbsent
            : CleanColors.attendanceAbsent;
      case AttendanceStatus.late:
        return isPlayful
            ? PlayfulColors.attendanceLate
            : CleanColors.attendanceLate;
      case AttendanceStatus.leftEarly:
        return isPlayful
            ? PlayfulColors.attendanceExcused
            : CleanColors.attendanceExcused;
      case AttendanceStatus.excused:
        return isPlayful ? PlayfulColors.info : CleanColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
        vertical: isPlayful ? AppSpacing.xs : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.semi),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: isPlayful ? AppIconSize.xs : AppIconSize.badge,
            color: color,
          ),
          SizedBox(width: isPlayful ? AppSpacing.xxs : AppSpacing.space2),
          Text(
            status.label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w600,
              color: color,
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

  Color _getStatusColor() {
    switch (status) {
      case ExcuseStatus.none:
        return isPlayful
            ? PlayfulColors.attendanceUnknown
            : CleanColors.attendanceUnknown;
      case ExcuseStatus.pending:
        return isPlayful ? PlayfulColors.warning : CleanColors.warning;
      case ExcuseStatus.approved:
        return isPlayful ? PlayfulColors.success : CleanColors.success;
      case ExcuseStatus.rejected:
        return isPlayful ? PlayfulColors.error : CleanColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
        vertical: isPlayful ? AppSpacing.xxs : AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _icon,
            size: isPlayful ? AppIconSize.xs : AppIconSize.badge,
            color: color,
          ),
          SizedBox(width: isPlayful ? AppSpacing.xxs : AppSpacing.space2),
          Text(
            status.label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isPlayful ? AppFontSize.caption : AppFontSize.labelSmall,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
