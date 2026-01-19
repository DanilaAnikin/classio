import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/teacher_grade_entity.dart';

/// A premium cell widget for the gradebook grid displaying a grade.
///
/// Features:
/// - Empty state with add indicator
/// - Color-coded grade display
/// - Average cell variant with border emphasis
/// - Hover/press states with haptic feedback
/// - Fully theme-aware (Clean vs Playful)
///
/// Example:
/// ```dart
/// GradeCell(
///   grade: gradeEntity,
///   isPlayful: false,
///   onTap: () => editGrade(gradeEntity),
/// )
///
/// // Average cell
/// GradeCell(
///   score: 85.5,
///   isAverage: true,
///   isPlayful: false,
/// )
///
/// // Empty cell
/// GradeCell(
///   isPlayful: false,
///   onTap: () => addGrade(studentId, assignmentId),
/// )
/// ```
class GradeCell extends StatefulWidget {
  const GradeCell({
    super.key,
    this.grade,
    this.score,
    this.isAverage = false,
    this.onTap,
    required this.isPlayful,
  });

  /// Optional grade entity to display.
  final TeacherGradeEntity? grade;

  /// Optional raw score value (used when grade entity is not available).
  final double? score;

  /// Whether this cell displays an average (gets border emphasis).
  final bool isAverage;

  /// Optional callback when the cell is tapped.
  final VoidCallback? onTap;

  /// Whether the playful theme is active.
  final bool isPlayful;

  @override
  State<GradeCell> createState() => _GradeCellState();
}

class _GradeCellState extends State<GradeCell> {
  bool _isHovered = false;
  bool _isPressed = false;

  /// Cell dimensions based on theme.
  double get _cellWidth => widget.isPlayful ? 52.0 : 48.0;
  double get _cellHeight => widget.isPlayful ? 36.0 : 32.0;

  /// The score to display.
  double? get _displayScore => widget.grade?.score ?? widget.score;

  /// Whether the cell is empty (no grade to display).
  bool get _isEmpty => _displayScore == null && !widget.isAverage;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return _buildEmptyCell(context);
    }

    return _buildGradeCell(context);
  }

  /// Builds an empty cell with add indicator.
  Widget _buildEmptyCell(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline.withValues(
      alpha: _isHovered ? AppOpacity.medium : AppOpacity.cardBorder,
    );
    final iconColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: _isHovered ? AppOpacity.heavy : AppOpacity.medium,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          width: _cellWidth,
          height: _cellHeight,
          transform: _isPressed ? (Matrix4.identity()..setEntry(0, 0, 0.95)..setEntry(1, 1, 0.95)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.badge(isPlayful: widget.isPlayful),
            border: Border.all(
              color: borderColor,
              width: 1,
              style: BorderStyle.solid,
            ),
            color: _isHovered
                ? theme.colorScheme.surfaceContainerLow
                : Colors.transparent,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: AppDuration.fast,
              child: Icon(
                Icons.add_rounded,
                size: AppIconSize.sm,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a cell with grade value.
  Widget _buildGradeCell(BuildContext context) {
    final scoreValue = _displayScore ?? 0;
    final gradeColor = _getGradeColor(scoreValue);
    final textColor = _getTextColor(scoreValue);

    // Background opacity based on state
    final baseOpacity = widget.isAverage ? AppOpacity.medium : AppOpacity.soft;
    final bgOpacity = _isHovered ? baseOpacity + 0.1 : baseOpacity;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          if (widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          width: _cellWidth,
          height: _cellHeight,
          transform: _isPressed ? (Matrix4.identity()..setEntry(0, 0, 0.95)..setEntry(1, 1, 0.95)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: bgOpacity),
            borderRadius: AppRadius.badge(isPlayful: widget.isPlayful),
            border: widget.isAverage
                ? Border.all(
                    color: gradeColor,
                    width: 2,
                  )
                : Border.all(
                    color: gradeColor.withValues(alpha: AppOpacity.medium),
                    width: 1,
                  ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: gradeColor.withValues(alpha: AppOpacity.cardBorder),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              _formatScore(scoreValue),
              style: TextStyle(
                fontSize: widget.isPlayful
                    ? AppFontSize.titleSmall
                    : AppFontSize.bodyMedium,
                fontWeight: widget.isAverage
                    ? FontWeight.w800
                    : FontWeight.w600,
                color: textColor,
                letterSpacing: widget.isPlayful ? 0.2 : 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Formats the score for display.
  String _formatScore(double score) {
    // Show decimal only if not a whole number
    return score % 1 == 0
        ? score.toStringAsFixed(0)
        : score.toStringAsFixed(1);
  }

  /// Returns the appropriate background color for the grade.
  Color _getGradeColor(double score) {
    return AppSemanticColors.getGradeColorPercentage(
      score,
      isPlayful: widget.isPlayful,
    );
  }

  /// Returns the appropriate text color for the grade.
  Color _getTextColor(double score) {
    return AppSemanticColors.getGradeTextColorPercentage(
      score,
      isPlayful: widget.isPlayful,
    );
  }
}

/// A header cell for the gradebook showing assignment info.
///
/// Example:
/// ```dart
/// GradeHeaderCell(
///   title: 'Quiz 1',
///   date: DateTime.now(),
///   maxScore: 100,
///   isPlayful: false,
/// )
/// ```
class GradeHeaderCell extends StatelessWidget {
  const GradeHeaderCell({
    super.key,
    required this.title,
    this.date,
    this.maxScore,
    required this.isPlayful,
    this.onTap,
  });

  /// The assignment title.
  final String title;

  /// Optional assignment date.
  final DateTime? date;

  /// Optional maximum score.
  final double? maxScore;

  /// Whether the playful theme is active.
  final bool isPlayful;

  /// Optional callback when the header is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPlayful ? 52 : 48,
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: AppFontSize.labelSmall,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // Max score if available
            if (maxScore != null) ...[
              SizedBox(height: AppSpacing.xxs),
              Text(
                'max ${maxScore!.toInt()}',
                style: TextStyle(
                  fontSize: AppFontSize.overline,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A student name cell for the gradebook row header.
///
/// Example:
/// ```dart
/// GradeStudentCell(
///   name: 'John Doe',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   isPlayful: false,
///   onTap: () => navigateToStudent(studentId),
/// )
/// ```
class GradeStudentCell extends StatelessWidget {
  const GradeStudentCell({
    super.key,
    required this.name,
    this.avatarUrl,
    required this.isPlayful,
    this.onTap,
  });

  /// The student's name.
  final String name;

  /// Optional avatar URL.
  final String? avatarUrl;

  /// Whether the playful theme is active.
  final bool isPlayful;

  /// Optional callback when the cell is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar or initials
            _buildAvatar(theme),
            SizedBox(width: AppSpacing.sm),

            // Name
            Flexible(
              child: Text(
                name,
                style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: isPlayful ? 14 : 12,
        backgroundImage: NetworkImage(avatarUrl!),
        onBackgroundImageError: (exception, stackTrace) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: isPlayful ? 14 : 12,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          fontSize: isPlayful ? 10 : 9,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
