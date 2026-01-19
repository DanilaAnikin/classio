import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/assignment_entity.dart';
import '../providers/teacher_provider.dart';
import '../widgets/assignment_card.dart';
import '../dialogs/create_assignment_dialog.dart';
import '../dialogs/grade_submission_dialog.dart';

/// Assignments tab for creating and managing assignments.
class AssignmentsTab extends ConsumerStatefulWidget {
  const AssignmentsTab({super.key});

  @override
  ConsumerState<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends ConsumerState<AssignmentsTab> {
  String _filter = 'all'; // all, upcoming, past

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final assignmentsAsync = ref.watch(myAssignmentsProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Bar
          _FilterBar(
            currentFilter: _filter,
            isPlayful: isPlayful,
            onFilterChanged: (filter) {
              setState(() => _filter = filter);
            },
          ),

          // Assignments List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myAssignmentsProvider);
              },
              child: assignmentsAsync.when(
                data: (assignments) {
                  final filtered = _filterAssignments(assignments);

                  if (filtered.isEmpty) {
                    return _EmptyAssignments(
                      filter: _filter,
                      isPlayful: isPlayful,
                    );
                  }

                  return ResponsiveCenterScrollView(
                    maxWidth: 1000,
                    padding: EdgeInsets.all(AppSpacing.md),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filtered.length} ${_filter == 'all' ? 'total' : _filter} assignment${filtered.length == 1 ? '' : 's'}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        ...filtered.map((assignment) => Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm),
                              child: AssignmentCard(
                                assignment: assignment,
                                isPlayful: isPlayful,
                                onTap: () =>
                                    _showAssignmentDetails(context, assignment),
                                onDelete: () =>
                                    _deleteAssignment(assignment),
                              ),
                            )),
                        SizedBox(height: AppSpacing.xxxxl + AppSpacing.xxl), // Space for FAB
                      ],
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: AppIconSize.xxl,
                        color: theme.colorScheme.error,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Failed to load assignments',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      OutlinedButton.icon(
                        onPressed: () => ref.invalidate(myAssignmentsProvider),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Assignment'),
      ),
    );
  }

  List<AssignmentEntity> _filterAssignments(List<AssignmentEntity> assignments) {
    switch (_filter) {
      case 'upcoming':
        return assignments
            .where((a) => a.dueDate != null && !a.isPastDue)
            .toList();
      case 'past':
        return assignments.where((a) => a.isPastDue).toList();
      default:
        return assignments;
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateAssignmentDialog(),
    );
  }

  void _showAssignmentDetails(BuildContext context, AssignmentEntity assignment) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: AppSpacing.sm),
                  width: AppSpacing.xxxl,
                  height: AppSpacing.xxs,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.soft),
                    borderRadius: BorderRadius.circular(AppRadius.xxs),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    // Subject
                    if (assignment.subjectName != null) ...[
                      _DetailRow(
                        icon: Icons.menu_book_rounded,
                        label: 'Subject',
                        value: assignment.subjectName ?? '',
                        color: theme.colorScheme.primary,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],

                    // Due Date
                    if (assignment.dueDate != null) ...[
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Due Date',
                        value: assignment.dueDate != null
                            ? DateFormat('EEEE, MMMM d, y').format(assignment.dueDate!)
                            : '',
                        color: assignment.isPastDue
                            ? theme.colorScheme.error
                            : (isPlayful ? PlayfulColors.success : CleanColors.success),
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: AppSpacing.md),
                    ],

                    // Max Score
                    _DetailRow(
                      icon: Icons.score_rounded,
                      label: 'Max Score',
                      value: assignment.maxScore.toString(),
                      color: theme.colorScheme.tertiary,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Description
                    if (assignment.description?.isNotEmpty ?? false) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          assignment.description ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                    ],

                    // Submissions Section
                    Text(
                      'Submissions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _SubmissionsSection(
                      assignmentId: assignment.id,
                      maxScore: assignment.maxScore,
                      isPlayful: isPlayful,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAssignment(AssignmentEntity assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text(
          'Are you sure you want to delete "${assignment.title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(assignmentNotifierProvider.notifier)
          .deleteAssignment(assignment.id, assignment.subjectId);
    }
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.currentFilter,
    required this.isPlayful,
    required this.onFilterChanged,
  });

  final String currentFilter;
  final bool isPlayful;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: AppIconSize.sm,
          ),
          SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == 'all',
            onSelected: () => onFilterChanged('all'),
          ),
          SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: 'Upcoming',
            isSelected: currentFilter == 'upcoming',
            onSelected: () => onFilterChanged('upcoming'),
          ),
          SizedBox(width: AppSpacing.xs),
          _FilterChip(
            label: 'Past Due',
            isSelected: currentFilter == 'past',
            onSelected: () => onFilterChanged('past'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}

class _EmptyAssignments extends StatelessWidget {
  const _EmptyAssignments({
    required this.filter,
    required this.isPlayful,
  });

  final String filter;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final message = filter == 'upcoming'
        ? 'No upcoming assignments'
        : filter == 'past'
            ? 'No past due assignments'
            : 'No assignments yet';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: AppIconSize.hero,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.medium),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Create a new assignment to get started',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.heavy),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.getButtonRadius(isPlayful: isPlayful),
          ),
          child: Icon(icon, color: color, size: AppIconSize.sm),
        ),
        SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SubmissionsSection extends ConsumerWidget {
  const _SubmissionsSection({
    required this.assignmentId,
    required this.maxScore,
    required this.isPlayful,
  });

  final String assignmentId;
  final int maxScore;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final submissionsAsync =
        ref.watch(assignmentSubmissionsProvider(assignmentId));

    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;

    return submissionsAsync.when(
      data: (submissions) {
        if (submissions.isEmpty) {
          return Container(
            padding: EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: AppIconSize.xxl,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.heavy),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'No submissions yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: submissions.map((submission) {
            return Container(
              margin: EdgeInsets.only(bottom: AppSpacing.xs),
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSpacing.lg,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      submission.studentName?.isNotEmpty == true
                          ? (submission.studentName ?? '?')[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission.studentName ?? 'Unknown Student',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          submission.submittedAt != null
                              ? 'Submitted ${DateFormat('MMM d, h:mm a').format(submission.submittedAt ?? DateTime.now())}'
                              : 'Not submitted',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (submission.isGraded)
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => GradeSubmissionDialog(
                            submission: submission,
                            maxScore: maxScore,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: successColor.withValues(alpha: AppOpacity.soft),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${(submission.grade ?? 0).toInt()}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: successColor,
                          ),
                        ),
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => GradeSubmissionDialog(
                            submission: submission,
                            maxScore: maxScore,
                          ),
                        );
                      },
                      child: const Text('Grade'),
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: const CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Failed to load submissions',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}
