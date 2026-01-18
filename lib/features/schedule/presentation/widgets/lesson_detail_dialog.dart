import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';
import '../../../dashboard/domain/entities/lesson.dart';

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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 24 : 16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(isPlayful ? 24 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject color indicator
            Row(
              children: [
                Container(
                  width: isPlayful ? 6 : 4,
                  height: isPlayful ? 48 : 40,
                  decoration: BoxDecoration(
                    color: Color(lesson.subject.color),
                    borderRadius: BorderRadius.circular(isPlayful ? 3 : 2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.subject.name,
                        style: TextStyle(
                          fontSize: isPlayful ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (lesson.subject.teacherName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          lesson.subject.teacherName!,
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPlayful ? 10 : 8,
                      vertical: isPlayful ? 4 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
                    ),
                    child: Text(
                      l10n.scheduleLessonModified,
                      style: TextStyle(
                        fontSize: isPlayful ? 11 : 10,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Lesson details
            _DetailRow(
              icon: Icons.access_time,
              label: l10n.scheduleLessonTime,
              value: _formatTimeRange(lesson.startTime, lesson.endTime, locale),
              isPlayful: isPlayful,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.room,
              label: l10n.scheduleLessonRoom,
              value: lesson.room.isNotEmpty ? lesson.room : '-',
              isPlayful: isPlayful,
            ),
            if (lesson.weekStartDate != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.calendar_today,
                label: l10n.scheduleLessonDate,
                value: DateFormat.yMMMd(locale).format(lesson.startTime),
                isPlayful: isPlayful,
              ),
            ],
            if (lesson.substituteTeacher != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.person_outline,
                label: l10n.scheduleLessonSubstitute,
                value: lesson.substituteTeacher!,
                isPlayful: isPlayful,
                valueColor: theme.colorScheme.tertiary,
              ),
            ],
            if (lesson.note != null && lesson.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.note,
                label: l10n.scheduleLessonNote,
                value: lesson.note!,
                isPlayful: isPlayful,
              ),
            ],

            // Changes from stable section
            if (hasChanges) ...[
              const SizedBox(height: 20),
              Divider(color: theme.colorScheme.error.withValues(alpha: 0.3)),
              const SizedBox(height: 12),
              Text(
                l10n.scheduleLessonChangesFromStable,
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              ...changes.entries.map((entry) {
                final fieldLabel = _getFieldLabel(context, entry.key);
                final (stableValue, currentValue) = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(isPlayful ? 12 : 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: isPlayful ? 20 : 18,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.scheduleLessonStableDescription,
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Close button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPlayful ? 20 : 16,
                    vertical: isPlayful ? 10 : 8,
                  ),
                ),
                child: Text(
                  l10n.close,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isPlayful ? 15 : 14,
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
        Icon(
          icon,
          size: isPlayful ? 20 : 18,
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isPlayful ? 12 : 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isPlayful ? 15 : 14,
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
      padding: EdgeInsets.all(isPlayful ? 10 : 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
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
                  style: TextStyle(
                    fontSize: isPlayful ? 11 : 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Stable value (strikethrough)
                    Text(
                      stableValue,
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        decoration: TextDecoration.lineThrough,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: isPlayful ? 14 : 12,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    // Current value (highlighted)
                    Text(
                      currentValue,
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.error,
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
        backgroundColor = theme.colorScheme.error.withValues(alpha: 0.1);
        textColor = theme.colorScheme.error;
        label = l10n.scheduleLessonCancelled;
        break;
      case LessonStatus.substitution:
        backgroundColor = theme.colorScheme.tertiary.withValues(alpha: 0.1);
        textColor = theme.colorScheme.tertiary;
        label = l10n.scheduleLessonSubstitution;
        break;
      case LessonStatus.normal:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 10 : 8,
        vertical: isPlayful ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isPlayful ? 11 : 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
