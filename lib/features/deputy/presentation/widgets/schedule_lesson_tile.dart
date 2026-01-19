import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/schedule_lesson.dart';

/// A compact tile widget displaying a lesson in the schedule grid.
///
/// Shows:
/// - Subject name (color coded)
/// - Room number
/// - Optional edit/delete on hover/long press
class ScheduleLessonTile extends StatefulWidget {
  const ScheduleLessonTile({
    super.key,
    required this.lesson,
    required this.isPlayful,
    required this.onTap,
    required this.onDelete,
  });

  final ScheduleLesson lesson;
  final bool isPlayful;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<ScheduleLessonTile> createState() => _ScheduleLessonTileState();
}

class _ScheduleLessonTileState extends State<ScheduleLessonTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.lesson.subjectColor != null ? Color(widget.lesson.subjectColor!) : theme.colorScheme.primary;
    final isModified = widget.lesson.modifiedFromStable;
    final cardRadius = AppRadius.getCardRadius(isPlayful: widget.isPlayful);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          decoration: isModified
              ? BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: AppOpacity.subtle + 0.04),
                  borderRadius: BorderRadius.circular(widget.isPlayful ? AppRadius.md + 2 : AppRadius.xs + 2),
                )
              : null,
          padding: isModified ? const EdgeInsets.all(2) : EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              gradient: widget.isPlayful
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: _isHovered ? 0.25 : 0.18),
                        color.withValues(alpha: _isHovered ? AppOpacity.soft + 0.03 : AppOpacity.subtle + 0.04),
                      ],
                    )
                  : null,
              color: widget.isPlayful
                  ? null
                  : color.withValues(alpha: _isHovered ? AppOpacity.medium + 0.04 : AppOpacity.soft + 0.03),
              border: Border.all(
                color: isModified
                    ? theme.colorScheme.error.withValues(alpha: _isHovered ? 0.7 : AppOpacity.heavy)
                    : color.withValues(alpha: _isHovered ? AppOpacity.heavy : AppOpacity.medium + 0.14),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: AppOpacity.medium + 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
            children: [
              // Color indicator strip
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: AppSpacing.xxs,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.isPlayful ? AppRadius.sm : AppRadius.xs),
                      bottomLeft: Radius.circular(widget.isPlayful ? AppRadius.sm : AppRadius.xs),
                    ),
                  ),
                ),
              ),

              // Modified badge
              if (isModified)
                Positioned(
                  right: AppSpacing.xxs,
                  bottom: AppSpacing.xxs,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft + 0.03),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'MOD',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.error,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(AppSpacing.xs + 2, AppSpacing.xs - 2, AppSpacing.xs - 2, AppSpacing.xs - 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subject name
                    Flexible(
                      child: Text(
                        widget.lesson.subjectName ?? 'Unknown',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: widget.isPlayful ? 12 : 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Room
                    if (widget.lesson.room?.isNotEmpty ?? false)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.room_outlined,
                            size: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              widget.lesson.room ?? '',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    // Teacher name
                    if (widget.lesson.teacherName?.isNotEmpty ?? false)
                      Text(
                        widget.lesson.teacherName ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Hover actions
              if (_isHovered)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ActionButton(
                        icon: Icons.edit_outlined,
                        onTap: widget.onTap,
                        color: color,
                        isPlayful: widget.isPlayful,
                      ),
                      const SizedBox(width: 2),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        onTap: widget.onDelete,
                        color: theme.colorScheme.error,
                        isPlayful: widget.isPlayful,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: AppIconSize.md,
              ),
              title: const Text('Edit Lesson'),
              onTap: () {
                Navigator.pop(context);
                widget.onTap();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
                size: AppIconSize.md,
              ),
              title: Text(
                'Delete Lesson',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: Text(
          'Are you sure you want to delete "${widget.lesson.subjectName}" from the schedule?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Small action button shown on hover.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xxs),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.soft + 0.03),
            borderRadius: BorderRadius.circular(AppRadius.xxs),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
      ),
    );
  }
}
