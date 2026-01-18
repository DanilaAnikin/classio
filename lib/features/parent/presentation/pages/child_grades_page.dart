import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../grades/domain/entities/entities.dart';
import '../providers/parent_provider.dart';

/// Child Grades Page for Parent.
///
/// Shows child's grades organized by subject with overall average
/// and detailed grade breakdown.
class ChildGradesPage extends ConsumerStatefulWidget {
  const ChildGradesPage({
    super.key,
    required this.childId,
  });

  final String childId;

  @override
  ConsumerState<ChildGradesPage> createState() => _ChildGradesPageState();
}

class _ChildGradesPageState extends ConsumerState<ChildGradesPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(childGradesProvider(widget.childId));
      ref.invalidate(childOverallAverageProvider(widget.childId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final grades = ref.watch(childGradesProvider(widget.childId));
    final overallAverage = ref.watch(childOverallAverageProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(childGradesProvider(widget.childId));
        },
        child: ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Overall Average Card
              _OverallAverageCard(
                average: overallAverage,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 24 : 20),

              // Grades by Subject
              Text(
                'Grades by Subject',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
              grades.when(
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

/// Overall average card.
class _OverallAverageCard extends StatelessWidget {
  const _OverallAverageCard({
    required this.average,
    required this.isPlayful,
  });

  final double average;
  final bool isPlayful;

  Color _getGradeColor(double value) {
    if (value >= 5) return Colors.green.shade600;
    if (value >= 4) return Colors.lightGreen.shade600;
    if (value >= 3) return Colors.orange.shade600;
    if (value >= 2) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
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
    final theme = Theme.of(context);
    final gradeColor = average > 0 ? _getGradeColor(average) : theme.colorScheme.outline;

    return Container(
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
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
              borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
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
          SizedBox(width: isPlayful ? 20 : 16),
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
                const SizedBox(height: 4),
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

  Color _getGradeColor(double value) {
    if (value >= 5) return Colors.green;
    if (value >= 4) return Colors.lightGreen;
    if (value >= 3) return Colors.orange;
    if (value >= 2) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeColor = _getGradeColor(widget.stats.average);

    return Card(
      elevation: widget.isPlayful ? 2 : 0,
      margin: EdgeInsets.only(bottom: widget.isPlayful ? 12 : 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.isPlayful ? 16 : 12),
        side: widget.isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(widget.isPlayful ? 16 : 12),
            child: Padding(
              padding: EdgeInsets.all(widget.isPlayful ? 16 : 12),
              child: Row(
                children: [
                  Container(
                    width: widget.isPlayful ? 56 : 48,
                    height: widget.isPlayful ? 56 : 48,
                    decoration: BoxDecoration(
                      color: gradeColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(widget.isPlayful ? 14 : 10),
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
                  SizedBox(width: widget.isPlayful ? 16 : 12),
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
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(widget.isPlayful ? 6 : 4),
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
                  SizedBox(width: widget.isPlayful ? 12 : 8),
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
                      const SizedBox(height: 4),
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
              padding: EdgeInsets.all(widget.isPlayful ? 16 : 12),
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

  Color _getGradeColor(double value) {
    if (value >= 5) return Colors.green;
    if (value >= 4) return Colors.lightGreen;
    if (value >= 3) return Colors.orange;
    if (value >= 2) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeColor = _getGradeColor(grade.score);

    return Padding(
      padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 40 : 34,
            height: isPlayful ? 40 : 34,
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
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
          SizedBox(width: isPlayful ? 12 : 10),
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
                horizontal: isPlayful ? 8 : 6,
                vertical: isPlayful ? 3 : 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isPlayful ? 6 : 4),
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
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 32 : 24),
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
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 24 : 16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 24 : 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
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
