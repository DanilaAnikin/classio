import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
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
                    padding: EdgeInsets.all(isPlayful ? 16 : 12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filtered.length} ${_filter == 'all' ? 'total' : _filter} assignment${filtered.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: isPlayful ? 12 : 10),
                        ...filtered.map((assignment) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AssignmentCard(
                                assignment: assignment,
                                isPlayful: isPlayful,
                                onTap: () =>
                                    _showAssignmentDetails(context, assignment),
                                onDelete: () =>
                                    _deleteAssignment(assignment),
                              ),
                            )),
                        const SizedBox(height: 80), // Space for FAB
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
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load assignments',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 8),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        assignment.title,
                        style: TextStyle(
                          fontSize: isPlayful ? 22 : 20,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Subject
                    if (assignment.subjectName != null) ...[
                      _DetailRow(
                        icon: Icons.menu_book_rounded,
                        label: 'Subject',
                        value: assignment.subjectName!,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Due Date
                    if (assignment.dueDate != null) ...[
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Due Date',
                        value: DateFormat('EEEE, MMMM d, y')
                            .format(assignment.dueDate!),
                        color: assignment.isPastDue
                            ? theme.colorScheme.error
                            : Colors.green,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Max Score
                    _DetailRow(
                      icon: Icons.score_rounded,
                      label: 'Max Score',
                      value: assignment.maxScore.toString(),
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    if (assignment.description != null &&
                        assignment.description!.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          assignment.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Submissions Section
                    Text(
                      'Submissions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
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
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'All',
            isSelected: currentFilter == 'all',
            onSelected: () => onFilterChanged('all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Upcoming',
            isSelected: currentFilter == 'upcoming',
            onSelected: () => onFilterChanged('upcoming'),
          ),
          const SizedBox(width: 8),
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
            size: isPlayful ? 72 : 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: isPlayful ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new assignment to get started',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
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

    return submissionsAsync.when(
      data: (submissions) {
        if (submissions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No submissions yet',
                  style: TextStyle(
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
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      submission.studentName?.isNotEmpty == true
                          ? submission.studentName![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission.studentName ?? 'Unknown Student',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          submission.submittedAt != null
                              ? 'Submitted ${DateFormat('MMM d, h:mm a').format(submission.submittedAt!)}'
                              : 'Not submitted',
                          style: TextStyle(
                            fontSize: 12,
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
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${submission.grade!.toInt()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
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
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => Container(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Failed to load submissions',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}
