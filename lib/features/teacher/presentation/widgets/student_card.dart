import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/domain/entities/app_user.dart';

/// A premium card widget displaying student information.
///
/// Shows student avatar, name, email, and optional stats (grade average,
/// attendance percentage). Uses design system tokens for consistent
/// styling across themes.
///
/// Example:
/// ```dart
/// StudentCard(
///   student: studentUser,
///   isPlayful: false,
///   gradeAverage: 85.0,
///   attendancePercent: 95.0,
///   onTap: () => navigateToStudent(studentUser.id),
/// )
/// ```
class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.isPlayful,
    this.gradeAverage,
    this.attendancePercent,
    this.onTap,
  });

  /// The student user data.
  final AppUser student;

  /// Whether the playful theme is active.
  final bool isPlayful;

  /// Optional grade average (0-100 scale).
  final double? gradeAverage;

  /// Optional attendance percentage (0-100).
  final double? attendancePercent;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard.interactive(
      onTap: onTap,
      padding: AppSpacing.cardInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and Name Row
          Row(
            children: [
              // Avatar
              _buildAvatar(theme),
              AppSpacing.gapH12,

              // Name and email
              Expanded(
                child: _buildStudentInfo(theme),
              ),
            ],
          ),

          const Spacer(),

          // Stats Row
          _buildStatsRow(theme),
        ],
      ),
    );
  }

  /// Builds the student avatar with proper fallback.
  Widget _buildAvatar(ThemeData theme) {
    if (student.avatarUrl != null && student.avatarUrl!.isNotEmpty) {
      return AppAvatar(
        imageUrl: student.avatarUrl!,
        fallbackName: student.fullName,
        size: isPlayful ? AvatarSize.lg : AvatarSize.md,
        showShadow: true,
      );
    }

    return AppAvatar.initials(
      name: student.fullName.isNotEmpty ? student.fullName : '?',
      size: isPlayful ? AvatarSize.lg : AvatarSize.md,
      showShadow: true,
    );
  }

  /// Builds the student name and email column.
  Widget _buildStudentInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student name
        Text(
          student.fullName,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        AppSpacing.gap4,

        // Email
        Text(
          student.email ?? '',
          style: AppTypography.caption(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  /// Builds the stats row with grade and attendance badges.
  Widget _buildStatsRow(ThemeData theme) {
    return Row(
      children: [
        // Grade badge
        if (gradeAverage != null) ...[
          _StatPill(
            icon: Icons.grade_rounded,
            value: (gradeAverage ?? 0).toStringAsFixed(0),
            color: _getGradeColor(gradeAverage ?? 0),
            isPlayful: isPlayful,
          ),
          AppSpacing.gapH8,
        ],

        // Attendance badge
        if (attendancePercent != null)
          _StatPill(
            icon: Icons.how_to_reg_rounded,
            value: '${(attendancePercent ?? 0).toStringAsFixed(0)}%',
            color: _getAttendanceColor(attendancePercent ?? 0),
            isPlayful: isPlayful,
          ),

        const Spacer(),

        // Chevron icon
        Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant.withValues(
            alpha: AppOpacity.heavy,
          ),
          size: AppIconSize.md,
        ),
      ],
    );
  }

  /// Returns the appropriate color for the grade value.
  Color _getGradeColor(double grade) {
    if (grade >= 70) {
      return isPlayful ? PlayfulColors.gradeExcellent : CleanColors.gradeExcellent;
    }
    if (grade >= 50) {
      return isPlayful ? PlayfulColors.gradeAverage : CleanColors.gradeAverage;
    }
    return isPlayful ? PlayfulColors.gradeFailing : CleanColors.gradeFailing;
  }

  /// Returns the appropriate color for the attendance percentage.
  Color _getAttendanceColor(double percent) {
    if (percent >= 90) {
      return isPlayful ? PlayfulColors.success : CleanColors.success;
    }
    if (percent >= 75) {
      return isPlayful ? PlayfulColors.warning : CleanColors.warning;
    }
    return isPlayful ? PlayfulColors.error : CleanColors.error;
  }
}

/// A compact pill-shaped badge displaying a stat with icon.
class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final String value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.medium),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: AppIconSize.xs,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSize.labelSmall,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
