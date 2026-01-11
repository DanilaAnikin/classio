import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/grades_provider.dart';

/// Main Grades page for the Classio app.
///
/// Displays grades organized by subject with expandable cards showing:
/// - Subject name and weighted average
/// - Individual grade entries when expanded
/// - Overall average across all subjects
///
/// Supports two theme modes: Clean (minimal/professional) and Playful (colorful/fun).
class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  // Track which subjects are expanded
  final Set<String> _expandedSubjects = {};

  void _toggleSubject(String subjectId) {
    setState(() {
      if (_expandedSubjects.contains(subjectId)) {
        _expandedSubjects.remove(subjectId);
      } else {
        _expandedSubjects.add(subjectId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradesAsync = ref.watch(gradesNotifierProvider);
    final overallAvg = ref.watch(overallAverageProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.gradesTitle),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(gradesNotifierProvider.notifier).refreshGrades();
        },
        child: gradesAsync.when(
          data: (subjects) {
            if (subjects.isEmpty) {
              return _buildEmptyState(theme, isPlayful);
            }

            return ResponsiveCenterScrollView(
              maxWidth: 1000,
              padding: EdgeInsets.all(isPlayful ? 16 : 12),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Overall Average Card
                  _OverallAverageCard(
                    average: overallAvg,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 20 : 16),

                  // Subject Grade Cards
                  ...subjects.map((subject) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                        child: _SubjectGradeCard(
                          subject: subject,
                          isExpanded: _expandedSubjects.contains(subject.subjectId),
                          onTap: () => _toggleSubject(subject.subjectId),
                          isPlayful: isPlayful,
                        ),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorState(theme, isPlayful, error),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isPlayful) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isPlayful ? 120 : 100,
              height: isPlayful ? 120 : 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 28 : 24),
            Text(
              l10n.gradesNoGradesYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.gradesWillAppear,
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

  Widget _buildErrorState(ThemeData theme, bool isPlayful, Object error) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 72 : 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: isPlayful ? 24 : 20),
            Text(
              l10n.gradesFailedToLoad,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(gradesNotifierProvider.notifier).refreshGrades();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.gradesRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card displaying the overall average across all subjects.
class _OverallAverageCard extends StatelessWidget {
  const _OverallAverageCard({
    required this.average,
    required this.isPlayful,
  });

  final double average;
  final bool isPlayful;

  Color _getAverageColor(double avg) {
    if (avg >= 1.0 && avg <= 1.5) return Colors.green;
    if (avg >= 1.6 && avg <= 2.5) return Colors.amber;
    if (avg >= 2.6 && avg <= 3.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final avgColor = _getAverageColor(average);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.gradesOverallAverage,
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: isPlayful ? 0.3 : 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  average > 0 ? average.toStringAsFixed(2) : 'N/A',
                  style: TextStyle(
                    fontSize: isPlayful ? 32 : 28,
                    fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                    color: average > 0 ? avgColor : theme.colorScheme.onSurface,
                    letterSpacing: isPlayful ? 0.5 : -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Badge
          if (average > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 16 : 12,
                vertical: isPlayful ? 10 : 8,
              ),
              decoration: BoxDecoration(
                color: avgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 10),
              ),
              child: Text(
                _getGradeLabel(average, context),
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: avgColor,
                  letterSpacing: isPlayful ? 0.5 : 0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getGradeLabel(double avg, BuildContext context) {
    final l10n = context.l10n;
    if (avg >= 1.0 && avg <= 1.5) return l10n.gradesExcellent;
    if (avg >= 1.6 && avg <= 2.5) return l10n.gradesGood;
    if (avg >= 2.6 && avg <= 3.5) return l10n.gradesFair;
    return l10n.gradesNeedsWork;
  }
}

/// Individual subject grade card with expandable grade list.
class _SubjectGradeCard extends StatelessWidget {
  const _SubjectGradeCard({
    required this.subject,
    required this.isExpanded,
    required this.onTap,
    required this.isPlayful,
  });

  final SubjectGradeStats subject;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isPlayful;

  Color _getAverageColor(double avg) {
    if (avg >= 1.0 && avg <= 1.5) return Colors.green;
    if (avg >= 1.6 && avg <= 2.5) return Colors.amber;
    if (avg >= 2.6 && avg <= 3.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avgColor = _getAverageColor(subject.average);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  subject.subjectColor.withValues(alpha: 0.12),
                  subject.subjectColor.withValues(alpha: 0.04),
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
                ? subject.subjectColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 12 : 6,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Collapsed Header (always visible)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
            child: Padding(
              padding: EdgeInsets.all(isPlayful ? 18 : 14),
              child: Row(
                children: [
                  // Subject Color Indicator
                  Container(
                    width: isPlayful ? 12 : 10,
                    height: isPlayful ? 12 : 10,
                    decoration: BoxDecoration(
                      color: subject.subjectColor,
                      shape: BoxShape.circle,
                      boxShadow: isPlayful
                          ? [
                              BoxShadow(
                                color: subject.subjectColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  SizedBox(width: isPlayful ? 14 : 12),

                  // Subject Name
                  Expanded(
                    child: Text(
                      subject.subjectName,
                      style: TextStyle(
                        fontSize: isPlayful ? 18 : 16,
                        fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: isPlayful ? 0.3 : -0.3,
                      ),
                    ),
                  ),

                  // Average Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPlayful ? 14 : 12,
                      vertical: isPlayful ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: avgColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                    ),
                    child: Text(
                      subject.average.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: isPlayful ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: avgColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SizedBox(width: isPlayful ? 10 : 8),

                  // Navigate to Subject Detail Icon
                  InkWell(
                    onTap: () {
                      context.push(AppRoutes.subjectDetail(subject.subjectId));
                    },
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    child: Container(
                      padding: EdgeInsets.all(isPlayful ? 8 : 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: theme.colorScheme.primary,
                        size: isPlayful ? 20 : 18,
                      ),
                    ),
                  ),
                  SizedBox(width: isPlayful ? 10 : 8),

                  // Expand Icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      size: isPlayful ? 28 : 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content (grades list)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(
                isPlayful ? 18 : 14,
                0,
                isPlayful ? 18 : 14,
                isPlayful ? 18 : 14,
              ),
              child: Column(
                children: [
                  // Divider
                  Divider(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    thickness: isPlayful ? 2 : 1,
                    height: isPlayful ? 8 : 4,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),

                  // Individual Grades
                  if (subject.grades.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(isPlayful ? 16 : 12),
                      child: Text(
                        context.l10n.gradesNoGradesYet,
                        style: TextStyle(
                          fontSize: isPlayful ? 14 : 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    ...subject.grades.map(
                      (grade) => _GradeItem(
                        grade: grade,
                        isPlayful: isPlayful,
                      ),
                    ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

/// Individual grade item showing details of a single grade.
class _GradeItem extends StatelessWidget {
  const _GradeItem({
    required this.grade,
    required this.isPlayful,
  });

  final Grade grade;
  final bool isPlayful;

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  Color _getScoreColor(double score) {
    if (score >= 1.0 && score <= 1.5) return Colors.green;
    if (score >= 1.6 && score <= 2.5) return Colors.amber;
    if (score >= 2.6 && score <= 3.5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(grade.score);

    return Padding(
      padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
      child: Container(
        padding: EdgeInsets.all(isPlayful ? 14 : 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: isPlayful ? 0.5 : 0.8),
          borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description and Score Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Expanded(
                  child: Text(
                    grade.description,
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: isPlayful ? 12 : 8),

                // Score
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPlayful ? 12 : 10,
                    vertical: isPlayful ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
                  ),
                  child: Text(
                    grade.score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: isPlayful ? 16 : 15,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isPlayful ? 8 : 6),

            // Weight and Date Row
            Row(
              children: [
                // Weight
                Icon(
                  Icons.scale_rounded,
                  size: isPlayful ? 16 : 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.gradesWeightLabel(grade.weight.toStringAsFixed(1)),
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isPlayful ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
                SizedBox(width: isPlayful ? 16 : 12),

                // Date
                Icon(
                  Icons.calendar_today_rounded,
                  size: isPlayful ? 16 : 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(grade.date),
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isPlayful ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
