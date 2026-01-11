import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/dashboard/domain/entities/lesson.dart';

/// A card widget displaying a single lesson in the schedule.
///
/// Shows:
/// - Time (start - end)
/// - Subject name with colored indicator
/// - Room number
/// - Status badges (cancelled, substitution)
/// - Teacher name if available
class ScheduleLessonCard extends ConsumerWidget {
  const ScheduleLessonCard({
    super.key,
    required this.lesson,
    this.showTimeline = false,
    this.isFirst = false,
    this.isLast = false,
  });

  final Lesson lesson;
  final bool showTimeline;
  final bool isFirst;
  final bool isLast;

  String _formatTime(DateTime time) {
    return DateFormat('H:mm').format(time);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final isCancelled = lesson.status == LessonStatus.cancelled;
    final isSubstitution = lesson.status == LessonStatus.substitution;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(lesson.startTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: isCancelled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.9),
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(lesson.endTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Color indicator
          Container(
            width: 4,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isCancelled
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                  : lesson.subject.color,
            ),
          ),

          const SizedBox(width: 12),

          // Lesson content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isPlayful ? 14 : 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 10),
                gradient: isPlayful && !isCancelled
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          lesson.subject.color.withValues(alpha: 0.12),
                          lesson.subject.color.withValues(alpha: 0.04),
                        ],
                      )
                    : null,
                color: isPlayful
                    ? null
                    : isCancelled
                        ? theme.colorScheme.surface.withValues(alpha: 0.5)
                        : theme.colorScheme.surface,
                border: isPlayful
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.12),
                        width: 1,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isPlayful
                        ? lesson.subject.color.withValues(alpha: isCancelled ? 0.03 : 0.1)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isPlayful ? 10 : 4,
                    offset: Offset(0, isPlayful ? 4 : 2),
                  ),
                ],
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
                          style: TextStyle(
                            fontSize: isPlayful ? 16 : 15,
                            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                            color: isCancelled
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                : theme.colorScheme.onSurface,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      if (isSubstitution) ...[
                        const SizedBox(width: 8),
                        _StatusBadge(
                          label: 'SUB',
                          color: theme.colorScheme.tertiary,
                          isPlayful: isPlayful,
                        ),
                      ],
                      if (isCancelled) ...[
                        const SizedBox(width: 8),
                        _StatusBadge(
                          label: 'CANCELLED',
                          color: theme.colorScheme.error,
                          isPlayful: isPlayful,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Room and teacher info
                  Row(
                    children: [
                      // Room
                      _InfoPill(
                        icon: Icons.room_outlined,
                        label: lesson.room,
                        isPlayful: isPlayful,
                        isCancelled: isCancelled,
                      ),

                      // Teacher
                      if (lesson.subject.teacherName != null ||
                          lesson.substituteTeacher != null) ...[
                        const SizedBox(width: 12),
                        _InfoPill(
                          icon: Icons.person_outline_rounded,
                          label: lesson.substituteTeacher ??
                              lesson.subject.teacherName ??
                              '',
                          isPlayful: isPlayful,
                          isCancelled: isCancelled,
                          isItalic: lesson.substituteTeacher != null,
                        ),
                      ],
                    ],
                  ),

                  // Note (if any)
                  if (lesson.note != null && lesson.note!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isPlayful ? 10 : 8,
                        vertical: isPlayful ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCancelled
                            ? theme.colorScheme.error.withValues(alpha: 0.08)
                            : theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: isCancelled
                                ? theme.colorScheme.error.withValues(alpha: 0.7)
                                : theme.colorScheme.primary.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              lesson.note!,
                              style: TextStyle(
                                fontSize: isPlayful ? 12 : 11,
                                color: isCancelled
                                    ? theme.colorScheme.error.withValues(alpha: 0.8)
                                    : theme.colorScheme.primary.withValues(alpha: 0.8),
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 8 : 6,
        vertical: isPlayful ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isPlayful ? 8 : 4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isPlayful ? 10 : 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
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
          size: isPlayful ? 15 : 14,
          color: theme.colorScheme.onSurface.withValues(alpha: isCancelled ? 0.3 : 0.5),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 13 : 12,
            fontWeight: isPlayful ? FontWeight.w500 : FontWeight.w400,
            color: theme.colorScheme.onSurface.withValues(alpha: isCancelled ? 0.4 : 0.7),
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
