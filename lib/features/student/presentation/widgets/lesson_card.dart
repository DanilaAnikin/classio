import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../dashboard/domain/entities/entities.dart';

/// Card showing a single lesson in today's schedule.
///
/// Displays lesson subject, time range, and room with theme-aware styling.
/// Features a subject-colored badge with the first letter of the subject name.
///
/// Uses the design system for:
/// - Consistent spacing via AppSpacing
/// - Theme-aware typography via AppTypography
/// - Proper color handling via AppColors/AppOpacity
/// - Premium card styling via AppCard
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.isPlayful,
    this.onTap,
  });

  final Lesson lesson;
  final bool isPlayful;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Theme-aware text colors
    final textPrimary = AppTextColors.primary(isPlayful: isPlayful);
    final textSecondary = AppTextColors.secondary(isPlayful: isPlayful);
    final textTertiary = AppTextColors.tertiary(isPlayful: isPlayful);

    // Subject color for the badge
    final subjectColor = Color(lesson.subject.color);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        padding: AppSpacing.cardInsetsCompact,
        child: Row(
          children: [
            // Subject badge with first letter
            _SubjectBadge(
              subjectName: lesson.subject.name,
              subjectColor: subjectColor,
              isPlayful: isPlayful,
            ),
            AppSpacing.gapH16,
            // Lesson details
            Expanded(
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
                  AppSpacing.gap4,
                  // Time range
                  Text(
                    '${DateFormat('HH:mm').format(lesson.startTime)} - ${DateFormat('HH:mm').format(lesson.endTime)}',
                    style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
                      fontSize: AppFontSize.bodySmall,
                      color: textSecondary,
                    ),
                  ),
                  AppSpacing.gap2,
                  // Room
                  Text(
                    lesson.room,
                    style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                      color: textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal widget for the subject badge.
///
/// Displays the first letter of the subject name in a colored, rounded container.
class _SubjectBadge extends StatelessWidget {
  const _SubjectBadge({
    required this.subjectName,
    required this.subjectColor,
    required this.isPlayful,
  });

  final String subjectName;
  final Color subjectColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    // Get first letter, or '?' if name is empty
    final firstLetter = subjectName.isNotEmpty
        ? subjectName[0].toUpperCase()
        : '?';

    // Badge size based on theme
    final badgeSize = isPlayful ? AppIconSize.xxl + AppSpacing.xs : AppIconSize.xxl;

    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: subjectColor.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w700,
            color: subjectColor,
          ),
        ),
      ),
    );
  }
}
