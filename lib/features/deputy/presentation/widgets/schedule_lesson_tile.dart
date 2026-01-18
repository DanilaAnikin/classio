import 'package:flutter/material.dart';

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          decoration: isModified
              ? BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(widget.isPlayful ? 14 : 10),
                )
              : null,
          padding: isModified ? const EdgeInsets.all(2) : EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isPlayful ? 12 : 8),
              gradient: widget.isPlayful
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: _isHovered ? 0.25 : 0.18),
                        color.withValues(alpha: _isHovered ? 0.15 : 0.08),
                      ],
                    )
                  : null,
              color: widget.isPlayful
                  ? null
                  : color.withValues(alpha: _isHovered ? 0.2 : 0.15),
              border: Border.all(
                color: isModified
                    ? theme.colorScheme.error.withValues(alpha: _isHovered ? 0.7 : 0.5)
                    : color.withValues(alpha: _isHovered ? 0.5 : 0.3),
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
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
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(widget.isPlayful ? 12 : 8),
                      bottomLeft: Radius.circular(widget.isPlayful ? 12 : 8),
                    ),
                  ),
                ),
              ),

              // Modified badge
              if (isModified)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'MOD',
                      style: TextStyle(
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
                padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subject name
                    Flexible(
                      child: Text(
                        widget.lesson.subjectName ?? 'Unknown',
                        style: TextStyle(
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
                    if (widget.lesson.room != null &&
                        widget.lesson.room!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.room_outlined,
                            size: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              widget.lesson.room!,
                              style: TextStyle(
                                fontSize: 9,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    // Teacher name
                    if (widget.lesson.teacherName != null &&
                        widget.lesson.teacherName!.isNotEmpty)
                      Text(
                        widget.lesson.teacherName!,
                        style: TextStyle(
                          fontSize: 9,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
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
              ),
              title: Text(
                'Delete Lesson',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 8),
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
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
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
