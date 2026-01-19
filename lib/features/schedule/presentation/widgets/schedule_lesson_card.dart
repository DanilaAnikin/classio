import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/theme.dart';
import 'package:classio/features/dashboard/domain/entities/lesson.dart';

/// A card widget displaying a single lesson in the schedule.
///
/// Shows:
/// - Time (start - end)
/// - Subject name with colored indicator
/// - Room number
/// - Status badges (cancelled, substitution, modified)
/// - Teacher name if available
///
/// Uses design system tokens for consistent styling across themes.
/// When [showModifiedIndicator] is true and the lesson is modified from stable,
/// displays a light red background to highlight the change.
class ScheduleLessonCard extends ConsumerWidget {
  const ScheduleLessonCard({
    super.key,
    required this.lesson,
    this.showTimeline = false,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
    this.showModifiedIndicator = true,
  });

  final Lesson lesson;
  final bool showTimeline;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;
  final bool showModifiedIndicator;

  String _formatTime(DateTime time) {
    return DateFormat('H:mm').format(time);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final isCancelled = lesson.status == LessonStatus.cancelled;
    final isSubstitution = lesson.status == LessonStatus.substitution;
    final isModified = showModifiedIndicator && lesson.modifiedFromStable;
    final cardRadius = AppRadius.card(isPlayful: isPlayful);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: isModified
              ? BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: AppOpacity.light),
                  borderRadius: cardRadius,
                )
              : null,
          padding: isModified
              ? EdgeInsets.all(AppSpacing.xxs)
              : EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time column
              SizedBox(
                width: AppSpacing.xxxxl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(lesson.startTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isPlayful
                            ? AppFontSize.bodyMedium + 1
                            : AppFontSize.bodyMedium,
                        fontWeight: FontWeight.w600,
                        color: isCancelled
                            ? theme.colorScheme.onSurface.withValues(alpha: AppOpacity.disabled)
                            : theme.colorScheme.onSurface.withValues(alpha: AppOpacity.almostOpaque),
                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                        letterSpacing: isPlayful ? AppLetterSpacing.bodyMedium : 0,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      _formatTime(lesson.endTime),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: isPlayful
                            ? AppFontSize.labelSmall + 1
                            : AppFontSize.labelSmall,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Color indicator
              Container(
                width: isPlayful ? AppSpacing.xs : AppSpacing.xxs + AppSpacing.space2,
                height: AppSpacing.xxxxl + AppSpacing.sm,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.fullRadius,
                  gradient: isPlayful && !isCancelled
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(lesson.subject.color),
                            Color(lesson.subject.color).withValues(alpha: AppOpacity.almostOpaque),
                          ],
                        )
                      : null,
                  color: isCancelled
                      ? theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium)
                      : (isPlayful ? null : Color(lesson.subject.color)),
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Lesson content
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPlayful ? AppSpacing.md : AppSpacing.sm,
                    vertical: isPlayful ? AppSpacing.sm : AppSpacing.sm - AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.button(isPlayful: isPlayful),
                    gradient: isPlayful && !isCancelled
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(lesson.subject.color).withValues(alpha: AppOpacity.soft),
                              Color(lesson.subject.color).withValues(alpha: AppOpacity.subtle),
                            ],
                          )
                        : null,
                    color: isPlayful
                        ? null
                        : isCancelled
                            ? theme.colorScheme.surface.withValues(alpha: AppOpacity.heavy)
                            : theme.colorScheme.surface,
                    border: isPlayful
                        ? null
                        : Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
                            width: 1,
                          ),
                    boxShadow: AppShadows.card(isPlayful: isPlayful),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject name and status badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.subject.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: isPlayful
                                    ? AppFontSize.titleSmall + 1
                                    : AppFontSize.titleSmall,
                                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                                color: isCancelled
                                    ? theme.colorScheme.onSurface.withValues(alpha: AppOpacity.disabled)
                                    : theme.colorScheme.onSurface,
                                decoration: isCancelled ? TextDecoration.lineThrough : null,
                                letterSpacing: isPlayful ? AppLetterSpacing.titleSmall : 0,
                              ),
                            ),
                          ),
                          if (isSubstitution) ...[
                            SizedBox(width: AppSpacing.xs),
                            _StatusBadge(
                              label: 'SUB',
                              color: theme.colorScheme.tertiary,
                              isPlayful: isPlayful,
                            ),
                          ],
                          if (isCancelled) ...[
                            SizedBox(width: AppSpacing.xs),
                            _StatusBadge(
                              label: 'CANCELLED',
                              color: theme.colorScheme.error,
                              isPlayful: isPlayful,
                            ),
                          ],
                          if (isModified && !isCancelled && !isSubstitution) ...[
                            SizedBox(width: AppSpacing.xs),
                            _StatusBadge(
                              label: 'MODIFIED',
                              color: theme.colorScheme.error.withValues(alpha: AppOpacity.almostOpaque),
                              isPlayful: isPlayful,
                            ),
                          ],
                        ],
                      ),

                      SizedBox(height: AppSpacing.xs),

                      // Room and teacher info
                      Row(
                        children: [
                          // Room
                          Flexible(
                            child: _InfoPill(
                              icon: Icons.room_outlined,
                              label: lesson.room,
                              isPlayful: isPlayful,
                              isCancelled: isCancelled,
                            ),
                          ),

                          // Teacher
                          if (lesson.subject.teacherName != null ||
                              lesson.substituteTeacher != null) ...[
                            SizedBox(width: AppSpacing.sm),
                            Flexible(
                              child: _InfoPill(
                                icon: Icons.person_outline_rounded,
                                label: lesson.substituteTeacher ??
                                    lesson.subject.teacherName ??
                                    '',
                                isPlayful: isPlayful,
                                isCancelled: isCancelled,
                                isItalic: lesson.substituteTeacher != null,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Note (if any)
                      if (lesson.note?.isNotEmpty ?? false) ...[
                        SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isPlayful ? AppSpacing.sm : AppSpacing.sm - AppSpacing.space2,
                            vertical: isPlayful ? AppSpacing.xs : AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: isCancelled
                                ? theme.colorScheme.error.withValues(alpha: AppOpacity.light)
                                : theme.colorScheme.primary.withValues(alpha: AppOpacity.light),
                            borderRadius: AppRadius.button(isPlayful: isPlayful),
                            border: isPlayful
                                ? Border.all(
                                    color: isCancelled
                                        ? theme.colorScheme.error.withValues(alpha: AppOpacity.soft)
                                        : theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                                    width: 1,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: isPlayful
                                    ? AppIconSize.xs + AppSpacing.space2
                                    : AppIconSize.xs,
                                color: isCancelled
                                    ? theme.colorScheme.error.withValues(alpha: AppOpacity.iconOnColor)
                                    : theme.colorScheme.primary.withValues(alpha: AppOpacity.iconOnColor),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  lesson.note ?? '',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: isPlayful
                                        ? AppFontSize.labelSmall + 1
                                        : AppFontSize.labelSmall,
                                    color: isCancelled
                                        ? theme.colorScheme.error.withValues(alpha: AppOpacity.almostOpaque)
                                        : theme.colorScheme.primary.withValues(alpha: AppOpacity.almostOpaque),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status badge widget for cancelled/substitution states.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeRadius = AppRadius.badge(isPlayful: isPlayful);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.xs + AppSpacing.space2 : AppSpacing.xs,
        vertical: isPlayful ? AppSpacing.xxs + AppSpacing.space2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.medium),
        borderRadius: badgeRadius,
        boxShadow: isPlayful
            ? [
                BoxShadow(
                  color: color.withValues(alpha: AppOpacity.light),
                  blurRadius: AppSpacing.xs,
                  offset: Offset(0, AppSpacing.space2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: isPlayful
              ? AppFontSize.overline + 1
              : AppFontSize.overline - 1,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: AppLetterSpacing.labelSmall,
        ),
      ),
    );
  }
}

/// Small info pill for room/teacher details.
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.isPlayful,
    this.isCancelled = false,
    this.isItalic = false,
  });

  final IconData icon;
  final String label;
  final bool isPlayful;
  final bool isCancelled;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isPlayful
              ? AppIconSize.xs + AppSpacing.space2
              : AppIconSize.xs,
          color: theme.colorScheme.onSurface.withValues(
            alpha: isCancelled ? AppOpacity.semi : AppOpacity.heavy,
          ),
        ),
        SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: isPlayful
                  ? AppFontSize.bodySmall + 1
                  : AppFontSize.bodySmall,
              fontWeight: isPlayful ? FontWeight.w500 : FontWeight.w400,
              color: theme.colorScheme.onSurface.withValues(
                alpha: isCancelled ? AppOpacity.disabled : AppOpacity.iconOnColor,
              ),
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
