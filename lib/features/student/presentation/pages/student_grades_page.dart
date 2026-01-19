import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../grades/domain/entities/entities.dart';
import '../providers/student_provider.dart';

/// Student Grades Page.
///
/// Shows all grades organized by subject with overall average
/// and detailed grade breakdown.
class StudentGradesPage extends ConsumerWidget {
  const StudentGradesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final gradesAsync = ref.watch(myGradesProvider);
    final overallAverage = ref.watch(myOverallAverageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grades'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myGradesProvider);
          ref.invalidate(myOverallAverageProvider);
        },
        child: ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Overall Average Card
              _OverallAverageCard(
                average: overallAverage,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),

              // Grades by Subject
              Text(
                'Grades by Subject',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
              gradesAsync.when(
                data: (gradesList) => gradesList.isEmpty
                    ? _EmptyCard(
                        icon: Icons.grade_outlined,
                        message: 'No grades recorded yet',
                        isPlayful: isPlayful,
                      )
                    : Column(
                        children: gradesList
                            .map((stats) => _SubjectGradeExpandableCard(
                                  stats: stats,
                                  isPlayful: isPlayful,
                                ))
                            .toList(),
                      ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load grades: $e',
                  isPlayful: isPlayful,
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overall average card with gradient.
class _OverallAverageCard extends StatelessWidget {
  const _OverallAverageCard({
    required this.average,
    required this.isPlayful,
  });

  final double average;
  final bool isPlayful;

  Color _getGradeColor(double value, {required bool isPlayful}) {
    return AppSemanticColors.getGradeColor(value, isPlayful: isPlayful);
  }

  String _getGradeDescription(double avg) {
    if (avg >= 5) return 'Excellent performance!';
    if (avg >= 4) return 'Very good work!';
    if (avg >= 3) return 'Good progress';
    if (avg >= 2) return 'Needs improvement';
    if (avg > 0) return 'Keep working hard';
    return 'No grades yet';
  }

  @override
  Widget build(BuildContext context) {
    final gradeColor = average > 0 ? _getGradeColor(average, isPlayful: isPlayful) : Theme.of(context).colorScheme.outline;

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg + AppRadius.xs : AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradeColor,
            gradeColor.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: isPlayful
            ? [
                BoxShadow(
                  color: gradeColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 72 : 64,
            height: isPlayful ? 72 : 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg + AppRadius.xs : AppRadius.lg),
            ),
            child: Center(
              child: Text(
                average > 0 ? average.toStringAsFixed(2) : '-',
                style: TextStyle(
                  fontSize: isPlayful ? 26 : 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.lg : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Average',
                  style: TextStyle(
                    fontSize: isPlayful ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  _getGradeDescription(average),
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable subject grade card showing individual grades.
class _SubjectGradeExpandableCard extends StatefulWidget {
  const _SubjectGradeExpandableCard({
    required this.stats,
    required this.isPlayful,
  });

  final SubjectGradeStats stats;
  final bool isPlayful;

  @override
  State<_SubjectGradeExpandableCard> createState() =>
      _SubjectGradeExpandableCardState();
}

class _SubjectGradeExpandableCardState
    extends State<_SubjectGradeExpandableCard> {
  bool _isExpanded = false;

  Color _getGradeColor(double value, {required bool isPlayful}) {
    return AppSemanticColors.getGradeColor(value, isPlayful: isPlayful);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeColor = _getGradeColor(widget.stats.average, isPlayful: widget.isPlayful);

    return Card(
      elevation: widget.isPlayful ? 2 : 0,
      margin: EdgeInsets.only(bottom: widget.isPlayful ? AppSpacing.sm : AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.isPlayful ? AppRadius.lg : AppRadius.md),
        side: widget.isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(widget.isPlayful ? AppRadius.lg : AppRadius.md),
            child: Padding(
              padding: EdgeInsets.all(widget.isPlayful ? AppSpacing.md : AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: widget.isPlayful ? 56 : 48,
                    height: widget.isPlayful ? 56 : 48,
                    decoration: BoxDecoration(
                      color: gradeColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(widget.isPlayful ? AppRadius.md + 2 : AppRadius.sm + 2),
                    ),
                    child: Center(
                      child: Text(
                        widget.stats.average.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: widget.isPlayful ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: gradeColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: widget.isPlayful ? AppSpacing.md : AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.stats.subjectName,
                          style: TextStyle(
                            fontSize: widget.isPlayful ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs + 2),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(widget.isPlayful ? AppRadius.xs + 2 : AppRadius.xs),
                          child: LinearProgressIndicator(
                            value: widget.stats.average / 6,
                            minHeight: widget.isPlayful ? 8 : 6,
                            backgroundColor: gradeColor.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(gradeColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: widget.isPlayful ? AppSpacing.sm : AppSpacing.xs),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.stats.gradeCount} grades',
                        style: TextStyle(
                          fontSize: widget.isPlayful ? 12 : 11,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
            Padding(
              padding: EdgeInsets.all(widget.isPlayful ? AppSpacing.md : AppSpacing.sm),
              child: Column(
                children: widget.stats.grades
                    .map((grade) => _GradeItem(
                          grade: grade,
                          isPlayful: widget.isPlayful,
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual grade item.
class _GradeItem extends StatelessWidget {
  const _GradeItem({
    required this.grade,
    required this.isPlayful,
  });

  final Grade grade;
  final bool isPlayful;

  Color _getGradeColor(double value, {required bool isPlayful}) {
    return AppSemanticColors.getGradeColor(value, isPlayful: isPlayful);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeColor = _getGradeColor(grade.score, isPlayful: isPlayful);

    return Padding(
      padding: EdgeInsets.only(bottom: isPlayful ? AppSpacing.sm - 2 : AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 40 : 34,
            height: isPlayful ? 40 : 34,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm + 2 : AppRadius.sm),
            ),
            child: Center(
              child: Text(
                grade.score.toStringAsFixed(
                    grade.score.truncateToDouble() == grade.score ? 0 : 1),
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: gradeColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.sm - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (grade.description.isNotEmpty)
                  Text(
                    grade.description,
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  DateFormat('MMM d, y').format(grade.date),
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (grade.weight != 1.0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? AppSpacing.xs : AppSpacing.xs - 2,
                vertical: isPlayful ? 3 : 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.xs + 2 : AppRadius.xs),
              ),
              child: Text(
                'x${grade.weight.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: isPlayful ? 11 : 10,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading card placeholder.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.xxl : AppSpacing.xl),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Error card.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.isPlayful,
  });

  final String message;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.md),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state card.
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.isPlayful,
  });

  final IconData icon;
  final String message;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.md),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
