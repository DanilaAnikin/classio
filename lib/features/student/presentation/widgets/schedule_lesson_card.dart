import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/domain/entities/entities.dart';

/// Card for a lesson in the schedule view with a timeline indicator.
///
/// Displays lesson details with a timeline indicator showing the lesson's
/// position in the day's schedule. Features:
/// - Time column on the left with start/end times
/// - Timeline dot and connecting line for visual continuity
/// - Colored left border on the card matching the subject color
/// - Teacher and room info with icons
///
/// Uses the design system for:
/// - Consistent spacing via AppSpacing
/// - Theme-aware typography via AppTypography
/// - Proper color handling via AppColors/AppOpacity
/// - Premium card styling via AppCard
class ScheduleLessonCard extends StatelessWidget {
  const ScheduleLessonCard({
    super.key,
    required this.lesson,
    required this.isPlayful,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  final Lesson lesson;
  final bool isPlayful;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Theme-aware colors
    final primaryColor = theme.colorScheme.primary;
    final textPrimary = AppTextColors.primary(isPlayful: isPlayful);
    final textSecondary = AppTextColors.secondary(isPlayful: isPlayful);
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;

    // Subject color for the card accent
    final subjectColor = Color(lesson.subject.color);

    // Spacing values based on theme
    final timeColumnWidth = isPlayful ? AppSpacing.space64 - AppSpacing.xxs : AppSpacing.xxxxl + AppSpacing.space2;
    final timelineConnectorHeight = isPlayful ? AppSpacing.space64 - AppSpacing.xxs : AppSpacing.xxxxl + AppSpacing.space2;
    final horizontalGap = isPlayful ? AppSpacing.md : AppSpacing.sm;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          _TimeColumn(
            startTime: lesson.startTime,
            endTime: lesson.endTime,
            primaryColor: primaryColor,
            textSecondary: textSecondary,
            isPlayful: isPlayful,
            width: timeColumnWidth,
          ),
          SizedBox(width: horizontalGap),
          // Timeline indicator
          _TimelineIndicator(
            subjectColor: subjectColor,
            borderColor: borderColor,
            isLast: isLast,
            isPlayful: isPlayful,
            connectorHeight: timelineConnectorHeight,
          ),
          SizedBox(width: horizontalGap),
          // Lesson content card
          Expanded(
            child: _LessonContentCard(
              lesson: lesson,
              subjectColor: subjectColor,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              isPlayful: isPlayful,
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Time column showing start and end times.
class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.startTime,
    required this.endTime,
    required this.primaryColor,
    required this.textSecondary,
    required this.isPlayful,
    required this.width,
  });

  final DateTime startTime;
  final DateTime endTime;
  final Color primaryColor;
  final Color textSecondary;
  final bool isPlayful;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Start time - prominent
          Text(
            DateFormat('HH:mm').format(startTime),
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          AppSpacing.gap2,
          // End time - subdued
          Text(
            DateFormat('HH:mm').format(endTime),
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontSize: AppFontSize.labelSmall,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Timeline indicator with dot and connecting line.
class _TimelineIndicator extends StatelessWidget {
  const _TimelineIndicator({
    required this.subjectColor,
    required this.borderColor,
    required this.isLast,
    required this.isPlayful,
    required this.connectorHeight,
  });

  final Color subjectColor;
  final Color borderColor;
  final bool isLast;
  final bool isPlayful;
  final double connectorHeight;

  @override
  Widget build(BuildContext context) {
    // Dot size based on theme
    final dotSize = isPlayful ? AppSpacing.sm : AppSpacing.xs;
    // Line width
    const lineWidth = 2.0;

    return Column(
      children: [
        // Timeline dot
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: subjectColor,
            shape: BoxShape.circle,
          ),
        ),
        // Connecting line (not shown for last item)
        if (!isLast)
          Container(
            width: lineWidth,
            height: connectorHeight,
            color: borderColor.withValues(alpha: AppOpacity.medium),
          ),
      ],
    );
  }
}

/// The main lesson content card with subject details.
class _LessonContentCard extends StatelessWidget {
  const _LessonContentCard({
    required this.lesson,
    required this.subjectColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.isPlayful,
    this.onTap,
  });

  final Lesson lesson;
  final Color subjectColor;
  final Color textPrimary;
  final Color textSecondary;
  final bool isPlayful;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Left border width based on theme
    final leftBorderWidth = isPlayful ? AppSpacing.xxs : 3.0;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: AppSpacing.cardInsetsCompact,
        decoration: BoxDecoration(
          borderRadius: AppRadius.card(isPlayful: isPlayful),
          border: Border(
            left: BorderSide(
              color: subjectColor,
              width: leftBorderWidth,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject name
            Text(
              lesson.subject.name,
              style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                fontSize: AppFontSize.titleSmall,
                color: textPrimary,
              ),
            ),
            // Teacher name (if available)
            if (lesson.subject.teacherName != null) ...[
              AppSpacing.gap4,
              _InfoRow(
                icon: Icons.person_outline,
                text: lesson.subject.teacherName!,
                color: textSecondary,
                isPlayful: isPlayful,
              ),
            ],
            // Room
            AppSpacing.gap2,
            _InfoRow(
              icon: Icons.room_outlined,
              text: lesson.room,
              color: textSecondary,
              isPlayful: isPlayful,
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row with icon and text.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    // Icon size based on theme
    final iconSize = isPlayful ? AppIconSize.xs : AppIconSize.xs - AppSpacing.space2;

    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color: color,
        ),
        AppSpacing.gapH4,
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
