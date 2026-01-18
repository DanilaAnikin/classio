import 'package:flutter/material.dart';

import '../../domain/entities/teacher_grade_entity.dart';

/// A cell widget for the gradebook grid displaying a grade.
class GradeCell extends StatelessWidget {
  const GradeCell({
    super.key,
    this.grade,
    this.score,
    this.isAverage = false,
    this.onTap,
    required this.isPlayful,
  });

  final TeacherGradeEntity? grade;
  final double? score;
  final bool isAverage;
  final VoidCallback? onTap;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayScore = grade?.score ?? score;

    if (displayScore == null && !isAverage) {
      // Empty cell - click to add grade
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
          child: Container(
            width: isPlayful ? 52 : 48,
            height: isPlayful ? 36 : 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      );
    }

    final scoreValue = displayScore ?? 0;
    final gradeColor = _getGradeColor(scoreValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
        child: Container(
          width: isPlayful ? 52 : 48,
          height: isPlayful ? 36 : 32,
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: isAverage ? 0.25 : 0.15),
            borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
            border: isAverage
                ? Border.all(color: gradeColor, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              scoreValue.toStringAsFixed(scoreValue % 1 == 0 ? 0 : 1),
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                fontWeight: isAverage ? FontWeight.w800 : FontWeight.w600,
                color: _getTextColor(scoreValue),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradeColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getTextColor(double score) {
    if (score >= 70) return Colors.green.shade800;
    if (score >= 50) return Colors.orange.shade800;
    return Colors.red.shade800;
  }
}
