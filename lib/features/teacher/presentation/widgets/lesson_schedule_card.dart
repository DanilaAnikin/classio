import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../dashboard/domain/entities/lesson.dart';

/// A card widget displaying a lesson in the teacher's schedule.
///
/// When [showModifiedIndicator] is true and the lesson is modified from stable,
/// displays a light red background to highlight the change.
class LessonScheduleCard extends StatelessWidget {
  const LessonScheduleCard({
    super.key,
    required this.lesson,
    required this.isPlayful,
    this.onTap,
    this.showAttendanceStatus = false,
    this.attendanceStatus,
    this.showModifiedIndicator = true,
  });

  final Lesson lesson;
  final bool isPlayful;
  final VoidCallback? onTap;
  final bool showAttendanceStatus;
  final String? attendanceStatus; // 'complete', 'partial', 'not_taken'
  final bool showModifiedIndicator;

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isModified = showModifiedIndicator && lesson.modifiedFromStable;

    return Container(
      decoration: isModified
          ? BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(isPlayful ? 18 : 14),
            )
          : null,
      padding: isModified ? const EdgeInsets.all(4) : EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
          child: Container(
          padding: EdgeInsets.all(isPlayful ? 16 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            gradient: isPlayful
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(lesson.subject.color).withValues(alpha: 0.12),
                      Color(lesson.subject.color).withValues(alpha: 0.04),
                    ],
                  )
                : null,
            color: isPlayful ? null : theme.colorScheme.surface,
            border: isPlayful
                ? null
                : Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: isPlayful
                    ? Color(lesson.subject.color).withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isPlayful ? 12 : 6,
                offset: Offset(0, isPlayful ? 4 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Time Column
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(isPlayful ? 10 : 8),
                    decoration: BoxDecoration(
                      color: Color(lesson.subject.color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: Color(lesson.subject.color),
                      size: isPlayful ? 22 : 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Color Indicator
              Container(
                width: 4,
                height: isPlayful ? 56 : 50,
                decoration: BoxDecoration(
                  color: Color(lesson.subject.color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.subject.name,
                            style: TextStyle(
                              fontSize: isPlayful ? 17 : 16,
                              fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isModified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MODIFIED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.error,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatTime(lesson.startTime)} - ${_formatTime(lesson.endTime)}',
                          style: TextStyle(
                            fontSize: isPlayful ? 13 : 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (lesson.room.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.room_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lesson.room,
                              style: TextStyle(
                                fontSize: isPlayful ? 13 : 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Status/Action
              if (showAttendanceStatus && attendanceStatus != null)
                _AttendanceStatusBadge(
                  status: attendanceStatus!,
                  isPlayful: isPlayful,
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _AttendanceStatusBadge extends StatelessWidget {
  const _AttendanceStatusBadge({
    required this.status,
    required this.isPlayful,
  });

  final String status;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'complete':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        label = 'Done';
        break;
      case 'partial':
        color = Colors.orange;
        icon = Icons.pending_rounded;
        label = 'Partial';
        break;
      default:
        color = theme.colorScheme.error;
        icon = Icons.radio_button_unchecked_rounded;
        label = 'Pending';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 10 : 8,
        vertical: isPlayful ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isPlayful ? 12 : 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
