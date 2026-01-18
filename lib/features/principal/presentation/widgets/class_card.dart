import 'package:flutter/material.dart';

import '../../domain/entities/class_with_details.dart';

/// A card widget displaying class information.
///
/// Shows the class name, grade level, head teacher, student count,
/// and provides action buttons.
class ClassCard extends StatelessWidget {
  /// Creates a [ClassCard].
  const ClassCard({
    super.key,
    required this.classDetails,
    this.onEdit,
    this.onAssignTeacher,
    this.onViewStudents,
    this.onDelete,
    this.isPlayful = false,
  });

  /// The class details to display.
  final ClassWithDetails classDetails;

  /// Callback when the edit action is triggered.
  final VoidCallback? onEdit;

  /// Callback when assign head teacher is triggered.
  final VoidCallback? onAssignTeacher;

  /// Callback when view students is triggered.
  final VoidCallback? onViewStudents;

  /// Callback when delete is triggered.
  final VoidCallback? onDelete;

  /// Whether to use playful styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: InkWell(
          onTap: onViewStudents,
          borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isPlayful ? 18 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class icon
                    Container(
                      padding: EdgeInsets.all(isPlayful ? 14 : 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(isPlayful ? 14 : 12),
                      ),
                      child: Icon(
                        Icons.class_outlined,
                        color: theme.colorScheme.primary,
                        size: isPlayful ? 30 : 28,
                      ),
                    ),
                    SizedBox(width: isPlayful ? 18 : 16),
                    // Class info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classDetails.name,
                            style: TextStyle(
                              fontSize: isPlayful ? 19 : 18,
                              fontWeight: isPlayful
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (classDetails.gradeLevel != null)
                            Text(
                              'Grade ${classDetails.gradeLevel}',
                              style: TextStyle(
                                fontSize: isPlayful ? 15 : 14,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (classDetails.academicYear != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              classDetails.academicYear!,
                              style: TextStyle(
                                fontSize: isPlayful ? 13 : 12,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isPlayful ? 12 : 8),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 20, color: theme.colorScheme.onSurface),
                              const SizedBox(width: 12),
                              const Text('Edit Class'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'assign',
                          child: Row(
                            children: [
                              Icon(Icons.person_add_outlined,
                                  size: 20, color: theme.colorScheme.onSurface),
                              const SizedBox(width: 12),
                              const Text('Assign Head Teacher'),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'students',
                          child: Row(
                            children: [
                              Icon(Icons.people_outline,
                                  size: 20, color: theme.colorScheme.onSurface),
                              const SizedBox(width: 12),
                              const Text('View Students'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: theme.colorScheme.error),
                              const SizedBox(width: 12),
                              Text('Delete Class',
                                  style: TextStyle(
                                      color: theme.colorScheme.error)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'assign':
                            onAssignTeacher?.call();
                            break;
                          case 'students':
                            onViewStudents?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                    ),
                  ],
                ),
                Divider(
                    height: isPlayful ? 28 : 24,
                    color: theme.colorScheme.outline.withValues(alpha: 0.15)),
                // Bottom row with head teacher and student count
                Row(
                  children: [
                    // Head teacher
                    Expanded(
                      child: _buildInfoItem(
                        theme: theme,
                        icon: Icons.school_outlined,
                        label: 'Head Teacher',
                        value:
                            classDetails.headTeacher?.fullName ?? 'Not assigned',
                        isPlaceholder: classDetails.headTeacher == null,
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    ),
                    // Student count
                    Expanded(
                      child: _buildInfoItem(
                        theme: theme,
                        icon: Icons.people_outline,
                        label: 'Students',
                        value: classDetails.studentCount.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
    bool isPlaceholder = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isPlayful ? 10 : 8),
      child: Column(
        children: [
          Icon(
            icon,
            size: isPlayful ? 22 : 20,
            color: isPlaceholder
                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(height: isPlayful ? 6 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isPlayful ? 15 : 14,
              fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
              color: isPlaceholder
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                  : theme.colorScheme.onSurface,
              fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
