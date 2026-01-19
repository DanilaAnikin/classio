import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/theme.dart';
import 'package:classio/features/dashboard/domain/entities/lesson.dart';

/// Shows a detailed dialog for a lesson.
///
/// Displays all lesson information including subject, teacher, time, and room.
/// If the lesson was modified from the stable timetable, shows the differences
/// highlighted in red.
Future<void> showLessonDetailDialog({
  required BuildContext context,
  required Lesson lesson,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => LessonDetailDialog(lesson: lesson),
  );
}

/// Dialog widget showing detailed lesson information.
class LessonDetailDialog extends ConsumerWidget {
  const LessonDetailDialog({
    super.key,
    required this.lesson,
  });

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final l10n = context.l10n;
    final locale = context.currentLocale.languageCode;

    final changes = lesson.getChangesFromStable();
    final hasChanges = changes.isNotEmpty;
    final dialogRadius = AppRadius.dialog(isPlayful: isPlayful);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: dialogRadius,
      ),
      elevation: isPlayful ? AppSpacing.xs : AppSpacing.space2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: AppOpacity.light),
      child: Container(
        constraints: BoxConstraints(maxWidth: AppSpacing.xxxxl * 5),
        padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md + AppSpacing.space2),
        decoration: BoxDecoration(
          borderRadius: dialogRadius,
          gradient: isPlayful
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withValues(alpha: AppOpacity.almostOpaque),
                  ],
                )
              : null,
          color: isPlayful ? null : theme.colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject color indicator
            _DialogHeader(
              lesson: lesson,
              isPlayful: isPlayful,
              l10n: l10n,
            ),

            SizedBox(height: AppSpacing.md + AppSpacing.space2),

            // Lesson details
            _DetailRow(
              icon: Icons.access_time,
              label: l10n.scheduleLessonTime,
              value: _formatTimeRange(lesson.startTime, lesson.endTime, locale),
              isPlayful: isPlayful,
            ),
            SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.room,
              label: l10n.scheduleLessonRoom,
              value: lesson.room.isNotEmpty ? lesson.room : '-',
              isPlayful: isPlayful,
            ),
            if (lesson.weekStartDate != null) ...[
              SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.calendar_today,
                label: l10n.scheduleLessonDate,
                value: DateFormat.yMMMd(locale).format(lesson.startTime),
                isPlayful: isPlayful,
              ),
            ],
            if (lesson.substituteTeacher != null) ...[
              SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.person_outline,
                label: l10n.scheduleLessonSubstitute,
                value: lesson.substituteTeacher ?? '',
                isPlayful: isPlayful,
                valueColor: theme.colorScheme.tertiary,
              ),
            ],
            if (lesson.note?.isNotEmpty ?? false) ...[
              SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.note,
                label: l10n.scheduleLessonNote,
                value: lesson.note ?? '',
                isPlayful: isPlayful,
              ),
            ],

            // Changes from stable section
            if (hasChanges) ...[
              SizedBox(height: AppSpacing.md + AppSpacing.space2),
              Divider(
                color: theme.colorScheme.error.withValues(alpha: AppOpacity.light),
                thickness: 1,
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                l10n.scheduleLessonChangesFromStable,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: isPlayful
                      ? AppFontSize.titleSmall
                      : AppFontSize.bodyMedium,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                  letterSpacing: isPlayful ? AppLetterSpacing.titleSmall : 0,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              ...changes.entries.map((entry) {
                final fieldLabel = _getFieldLabel(context, entry.key);
                final (stableValue, currentValue) = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xs),
                  child: _ChangeRow(
                    fieldLabel: fieldLabel,
                    stableValue: stableValue,
                    currentValue: currentValue,
                    isPlayful: isPlayful,
                  ),
                );
              }),
            ],

            // Stable lesson indicator
            if (lesson.isStable) ...[
              SizedBox(height: AppSpacing.md + AppSpacing.space2),
              _StableIndicator(
                isPlayful: isPlayful,
                description: l10n.scheduleLessonStableDescription,
              ),
            ],

            SizedBox(height: AppSpacing.md + AppSpacing.space2),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPlayful ? AppSpacing.md + AppSpacing.space2 : AppSpacing.md,
                    vertical: isPlayful ? AppSpacing.sm + AppSpacing.space2 : AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button(isPlayful: isPlayful),
                  ),
                ),
                child: Text(
                  l10n.close,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: isPlayful
                        ? AppFontSize.bodyMedium + 1
                        : AppFontSize.bodyMedium,
                    fontWeight: FontWeight.w600,
                    letterSpacing: isPlayful ? AppLetterSpacing.labelLarge : 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end, String locale) {
    final timeFormat = DateFormat.Hm(locale);
    return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
  }

  String _getFieldLabel(BuildContext context, String fieldKey) {
    final l10n = context.l10n;
    switch (fieldKey) {
      case 'subject':
        return l10n.scheduleLessonSubject;
      case 'room':
        return l10n.scheduleLessonRoom;
      case 'startTime':
        return l10n.scheduleLessonStartTime;
      case 'endTime':
        return l10n.scheduleLessonEndTime;
      case 'teacher':
        return l10n.scheduleLessonTeacher;
      default:
        return fieldKey;
    }
  }
}

/// Header section of the dialog showing subject name and status.
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.lesson,
    required this.isPlayful,
    required this.l10n,
  });

  final Lesson lesson;
  final bool isPlayful;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjectColor = Color(lesson.subject.color);

    return Row(
      children: [
        // Subject color indicator
        Container(
          width: isPlayful ? AppSpacing.xs + AppSpacing.space2 : AppSpacing.xs,
          height: isPlayful ? AppSpacing.xxl + AppSpacing.sm : AppSpacing.xxl,
          decoration: BoxDecoration(
            gradient: isPlayful
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      subjectColor,
                      subjectColor.withValues(alpha: AppOpacity.almostOpaque),
                    ],
                  )
                : null,
            color: isPlayful ? null : subjectColor,
            borderRadius: AppRadius.fullRadius,
            boxShadow: isPlayful
                ? [
                    BoxShadow(
                      color: subjectColor.withValues(alpha: AppOpacity.light),
                      blurRadius: AppSpacing.xs,
                      offset: Offset(0, AppSpacing.space2),
                    ),
                  ]
                : null,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.subject.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: isPlayful
                      ? AppFontSize.titleMedium + AppSpacing.space2
                      : AppFontSize.titleMedium,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: isPlayful ? AppLetterSpacing.titleMedium : 0,
                ),
              ),
              if (lesson.subject.teacherName != null) ...[
                SizedBox(height: AppSpacing.space2),
                Text(
                  lesson.subject.teacherName ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: isPlayful
                        ? AppFontSize.bodyMedium
                        : AppFontSize.bodySmall + 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Status badge
        if (lesson.status != LessonStatus.normal)
          _StatusBadge(status: lesson.status, isPlayful: isPlayful),
        // Modified indicator
        if (lesson.modifiedFromStable && lesson.status == LessonStatus.normal)
          _ModifiedBadge(isPlayful: isPlayful, label: l10n.scheduleLessonModified),
      ],
    );
  }
}

/// A row showing a single detail with icon and label.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPlayful,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPlayful;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(isPlayful ? AppSpacing.xs : AppSpacing.xxs + AppSpacing.space2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
            borderRadius: isPlayful
                ? AppRadius.fullRadius
                : AppRadius.smRadius,
          ),
          child: Icon(
            icon,
            size: isPlayful
                ? AppIconSize.sm
                : AppIconSize.xs + AppSpacing.space2,
            color: theme.colorScheme.primary.withValues(alpha: AppOpacity.iconOnColor),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: isPlayful
                      ? AppFontSize.labelSmall + 1
                      : AppFontSize.overline,
                  color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                  letterSpacing: isPlayful ? AppLetterSpacing.labelSmall : 0,
                ),
              ),
              SizedBox(height: AppSpacing.space2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: isPlayful
                      ? AppFontSize.bodyMedium + 1
                      : AppFontSize.bodyMedium,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A row showing a change from stable to current value.
class _ChangeRow extends StatelessWidget {
  const _ChangeRow({
    required this.fieldLabel,
    required this.stableValue,
    required this.currentValue,
    required this.isPlayful,
  });

  final String fieldLabel;
  final String stableValue;
  final String currentValue;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.sm + AppSpacing.space2 : AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: AppOpacity.subtle),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fieldLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: isPlayful
                        ? AppFontSize.overline + 1
                        : AppFontSize.overline,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error.withValues(alpha: AppOpacity.almostOpaque),
                    letterSpacing: isPlayful ? AppLetterSpacing.labelSmall : 0,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Row(
                  children: [
                    // Stable value (strikethrough)
                    Flexible(
                      child: Text(
                        stableValue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: isPlayful
                              ? AppFontSize.bodySmall + 1
                              : AppFontSize.bodySmall,
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.arrow_forward,
                      size: isPlayful
                          ? AppIconSize.xs
                          : AppIconSize.xs - AppSpacing.space2,
                      color: theme.colorScheme.error,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    // Current value (highlighted)
                    Flexible(
                      child: Text(
                        currentValue,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: isPlayful
                              ? AppFontSize.bodySmall + 1
                              : AppFontSize.bodySmall,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge showing the lesson status.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isPlayful,
  });

  final LessonStatus status;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case LessonStatus.cancelled:
        backgroundColor = theme.colorScheme.error.withValues(alpha: AppOpacity.soft);
        textColor = theme.colorScheme.error;
        label = l10n.scheduleLessonCancelled;
      case LessonStatus.substitution:
        backgroundColor = theme.colorScheme.tertiary.withValues(alpha: AppOpacity.soft);
        textColor = theme.colorScheme.tertiary;
        label = l10n.scheduleLessonSubstitution;
      case LessonStatus.normal:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.sm + AppSpacing.space2 : AppSpacing.sm,
        vertical: isPlayful ? AppSpacing.xxs + AppSpacing.space2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        boxShadow: isPlayful
            ? [
                BoxShadow(
                  color: textColor.withValues(alpha: AppOpacity.light),
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
              : AppFontSize.overline,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: AppLetterSpacing.labelSmall,
        ),
      ),
    );
  }
}

/// Badge for modified lessons.
class _ModifiedBadge extends StatelessWidget {
  const _ModifiedBadge({
    required this.isPlayful,
    required this.label,
  });

  final bool isPlayful;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.sm + AppSpacing.space2 : AppSpacing.sm,
        vertical: isPlayful ? AppSpacing.xxs + AppSpacing.space2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        boxShadow: isPlayful
            ? [
                BoxShadow(
                  color: theme.colorScheme.error.withValues(alpha: AppOpacity.light),
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
              : AppFontSize.overline,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.error,
          letterSpacing: AppLetterSpacing.labelSmall,
        ),
      ),
    );
  }
}

/// Indicator for stable timetable lessons.
class _StableIndicator extends StatelessWidget {
  const _StableIndicator({
    required this.isPlayful,
    required this.description,
  });

  final bool isPlayful;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.sm - AppSpacing.space2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: AppOpacity.light),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isPlayful ? AppSpacing.xxs + AppSpacing.space2 : AppSpacing.xxs),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: AppOpacity.medium),
              borderRadius: isPlayful
                  ? AppRadius.fullRadius
                  : AppRadius.smRadius,
            ),
            child: Icon(
              Icons.schedule,
              size: isPlayful
                  ? AppIconSize.sm
                  : AppIconSize.xs + AppSpacing.space2,
              color: theme.colorScheme.secondary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: isPlayful
                    ? AppFontSize.bodySmall + 1
                    : AppFontSize.bodySmall,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
