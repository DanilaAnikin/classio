import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/assignment_entity.dart';

/// A card widget displaying an assignment.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.isPlayful,
    this.onTap,
    this.onDelete,
  });

  final AssignmentEntity assignment;
  final bool isPlayful;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPastDue = assignment.isPastDue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Container(
          padding: EdgeInsets.all(isPlayful ? 16 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: isPastDue
                  ? theme.colorScheme.error.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(isPlayful ? 12 : 10),
                decoration: BoxDecoration(
                  color: isPastDue
                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: isPastDue
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: isPlayful ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: TextStyle(
                        fontSize: isPlayful ? 17 : 16,
                        fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (assignment.subjectName != null) ...[
                          Icon(
                            Icons.menu_book_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              assignment.subjectName!,
                              style: TextStyle(
                                fontSize: isPlayful ? 13 : 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (assignment.dueDate != null) ...[
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: isPastDue
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d').format(assignment.dueDate!),
                            style: TextStyle(
                              fontSize: isPlayful ? 13 : 12,
                              color: isPastDue
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isPastDue ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (assignment.description != null &&
                        assignment.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        assignment.description!,
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPastDue
                          ? theme.colorScheme.error.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isPastDue ? 'Past Due' : 'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPastDue ? theme.colorScheme.error : Colors.green,
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(height: 8),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      tooltip: 'Delete assignment',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
