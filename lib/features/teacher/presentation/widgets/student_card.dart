import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';

/// A card widget displaying student information.
class StudentCard extends StatelessWidget {
  const StudentCard({
    super.key,
    required this.student,
    required this.isPlayful,
    this.gradeAverage,
    this.attendancePercent,
    this.onTap,
  });

  final AppUser student;
  final bool isPlayful;
  final double? gradeAverage;
  final double? attendancePercent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              color: theme.colorScheme.outline.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: isPlayful ? 12 : 6,
                offset: Offset(0, isPlayful ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar and Name Row
              Row(
                children: [
                  CircleAvatar(
                    radius: isPlayful ? 24 : 22,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: student.avatarUrl != null
                        ? NetworkImage(student.avatarUrl!)
                        : null,
                    child: student.avatarUrl == null
                        ? Text(
                            student.fullName.isNotEmpty
                                ? student.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: isPlayful ? 20 : 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          style: TextStyle(
                            fontSize: isPlayful ? 16 : 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          student.email ?? '',
                          style: TextStyle(
                            fontSize: isPlayful ? 12 : 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Stats Row
              Row(
                children: [
                  if (gradeAverage != null) ...[
                    _StatPill(
                      icon: Icons.grade_rounded,
                      value: gradeAverage!.toStringAsFixed(0),
                      color: _getGradeColor(gradeAverage!),
                      isPlayful: isPlayful,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (attendancePercent != null) ...[
                    _StatPill(
                      icon: Icons.how_to_reg_rounded,
                      value: '${attendancePercent!.toStringAsFixed(0)}%',
                      color: _getAttendanceColor(attendancePercent!),
                      isPlayful: isPlayful,
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(double grade) {
    if (grade >= 70) return Colors.green;
    if (grade >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getAttendanceColor(double percent) {
    if (percent >= 90) return Colors.green;
    if (percent >= 75) return Colors.orange;
    return Colors.red;
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final String value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 10 : 8,
        vertical: isPlayful ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
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
