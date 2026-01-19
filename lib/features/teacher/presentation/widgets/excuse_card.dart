import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/attendance_entity.dart';

/// A premium card widget displaying a pending excuse request.
///
/// Features:
/// - Student avatar with initials fallback
/// - Date and status information
/// - Excuse note preview
/// - Approve/Reject action buttons
/// - Fully theme-aware (Clean vs Playful)
///
/// Example:
/// ```dart
/// ExcuseCard(
///   attendance: attendanceEntity,
///   isPlayful: false,
///   onApprove: () => approveExcuse(attendance.id),
///   onReject: () => rejectExcuse(attendance.id),
/// )
/// ```
class ExcuseCard extends StatelessWidget {
  const ExcuseCard({
    super.key,
    required this.attendance,
    required this.isPlayful,
    required this.onApprove,
    required this.onReject,
  });

  /// The attendance entity containing excuse information.
  final AttendanceEntity attendance;

  /// Whether the playful theme is active.
  final bool isPlayful;

  /// Callback when the approve button is pressed.
  final VoidCallback onApprove;

  /// Callback when the reject button is pressed.
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warningColor = isPlayful ? PlayfulColors.warning : CleanColors.warning;

    return AppCard(
      padding: AppSpacing.cardInsets,
      borderColor: warningColor.withValues(alpha: AppOpacity.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          _buildHeader(theme),

          // Excuse Note (if available)
          if (attendance.excuseNote?.isNotEmpty ?? false) ...[
            AppSpacing.gapSm,
            _buildExcuseNote(theme),
          ],

          // Action Buttons
          AppSpacing.gapMd,
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  /// Builds the header row with avatar, name, date, and status.
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        // Avatar
        _buildAvatar(theme),
        AppSpacing.gapH12,

        // Name and date
        Expanded(
          child: _buildStudentInfo(theme),
        ),

        // Status badge
        _buildStatusBadge(theme),
      ],
    );
  }

  /// Builds the student avatar with fallback.
  Widget _buildAvatar(ThemeData theme) {
    if (attendance.studentAvatarUrl != null &&
        attendance.studentAvatarUrl!.isNotEmpty) {
      return AppAvatar(
        imageUrl: attendance.studentAvatarUrl!,
        fallbackName: attendance.studentName ?? '?',
        size: isPlayful ? AvatarSize.lg : AvatarSize.md,
        showShadow: true,
      );
    }

    return AppAvatar.initials(
      name: attendance.studentName?.isNotEmpty == true
          ? attendance.studentName!
          : '?',
      size: isPlayful ? AvatarSize.lg : AvatarSize.md,
      showShadow: true,
    );
  }

  /// Builds the student name and date column.
  Widget _buildStudentInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student name
        Text(
          attendance.studentName ?? 'Unknown Student',
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.gap4,

        // Date
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: AppIconSize.xs,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.xxs),
            Text(
              DateFormat('EEEE, MMMM d').format(attendance.date),
              style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the status badge.
  Widget _buildStatusBadge(ThemeData theme) {
    final statusColor = _getStatusColor(attendance.status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        border: Border.all(
          color: statusColor.withValues(alpha: AppOpacity.medium),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(attendance.status),
            size: AppIconSize.xs,
            color: statusColor,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            attendance.status.displayName,
            style: TextStyle(
              fontSize: AppFontSize.labelSmall,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the excuse note section.
  Widget _buildExcuseNote(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.insets12,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        border: Border.all(
          color: (isPlayful ? PlayfulColors.border : CleanColors.border)
              .withValues(alpha: AppOpacity.soft),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                size: AppIconSize.xs,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                'Excuse Note',
                style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,

          // Note content
          Text(
            attendance.excuseNote!,
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              height: AppLineHeight.body,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons row.
  Widget _buildActionButtons(ThemeData theme) {
    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Reject button
        AppButton.secondary(
          label: 'Reject',
          icon: Icons.close_rounded,
          onPressed: onReject,
          size: ButtonSize.small,
          foregroundColor: errorColor,
        ),
        AppSpacing.gapH8,

        // Approve button
        AppButton.primary(
          label: 'Approve',
          icon: Icons.check_rounded,
          onPressed: onApprove,
          size: ButtonSize.small,
          backgroundColor: successColor,
        ),
      ],
    );
  }

  /// Returns the appropriate color for the attendance status.
  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return isPlayful ? PlayfulColors.success : CleanColors.success;
      case AttendanceStatus.absent:
        return isPlayful ? PlayfulColors.error : CleanColors.error;
      case AttendanceStatus.late:
        return isPlayful ? PlayfulColors.warning : CleanColors.warning;
      case AttendanceStatus.excused:
        return isPlayful ? PlayfulColors.info : CleanColors.info;
    }
  }

  /// Returns the appropriate icon for the attendance status.
  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.late:
        return Icons.schedule_outlined;
      case AttendanceStatus.excused:
        return Icons.verified_outlined;
    }
  }
}
