import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../attendance/domain/entities/absence_excuse.dart';
import '../../../attendance/presentation/providers/absence_excuse_provider.dart';
import '../dialogs/review_absence_excuse_dialog.dart';

/// Page for teachers to review pending absence excuses.
///
/// Shows a list of all pending excuses for the teacher's classes
/// with ability to approve or decline each one.
class AbsenceExcusesPage extends ConsumerStatefulWidget {
  const AbsenceExcusesPage({super.key});

  @override
  ConsumerState<AbsenceExcusesPage> createState() => _AbsenceExcusesPageState();
}

class _AbsenceExcusesPageState extends ConsumerState<AbsenceExcusesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final pendingExcuses = ref.watch(teacherPendingExcusesProvider);
    final allExcuses = ref.watch(teacherAllExcusesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absence Excuses'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(teacherPendingExcusesProvider);
              ref.invalidate(teacherAllExcusesProvider);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(
            fontSize: isPlayful ? 14 : 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  const SizedBox(width: 6),
                  pendingExcuses.when(
                    data: (excuses) => _CountBadge(
                      count: excuses.length,
                      color: Colors.orange,
                      isPlayful: isPlayful,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            const Tab(text: 'Approved'),
            const Tab(text: 'Declined'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherPendingExcusesProvider);
          ref.invalidate(teacherAllExcusesProvider);
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Pending Tab
            _ExcuseListView(
              excusesAsync: pendingExcuses,
              emptyMessage: 'No pending excuses',
              emptySubMessage: 'All excuses have been reviewed',
              isPlayful: isPlayful,
              showActions: true,
            ),

            // Approved Tab
            allExcuses.when(
              data: (excuses) {
                final approved = excuses.where((e) => e.isApproved).toList();
                return _ExcuseListView(
                  excusesAsync: AsyncData(approved),
                  emptyMessage: 'No approved excuses',
                  emptySubMessage: 'Approved excuses will appear here',
                  isPlayful: isPlayful,
                  showActions: false,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(error: e.toString()),
            ),

            // Declined Tab
            allExcuses.when(
              data: (excuses) {
                final declined = excuses.where((e) => e.isDeclined).toList();
                return _ExcuseListView(
                  excusesAsync: AsyncData(declined),
                  emptyMessage: 'No declined excuses',
                  emptySubMessage: 'Declined excuses will appear here',
                  isPlayful: isPlayful,
                  showActions: false,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(error: e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Count badge widget.
class _CountBadge extends StatelessWidget {
  const _CountBadge({
    required this.count,
    required this.color,
    required this.isPlayful,
  });

  final int count;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 8 : 6,
        vertical: isPlayful ? 2 : 1,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: isPlayful ? 12 : 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// List view for excuses.
class _ExcuseListView extends ConsumerWidget {
  const _ExcuseListView({
    required this.excusesAsync,
    required this.emptyMessage,
    required this.emptySubMessage,
    required this.isPlayful,
    required this.showActions,
  });

  final AsyncValue<List<AbsenceExcuse>> excusesAsync;
  final String emptyMessage;
  final String emptySubMessage;
  final bool isPlayful;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return excusesAsync.when(
      data: (excuses) {
        if (excuses.isEmpty) {
          return _EmptyState(
            message: emptyMessage,
            subMessage: emptySubMessage,
            isPlayful: isPlayful,
          );
        }

        return ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: excuses
                .map((excuse) => Padding(
                      padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                      child: _TeacherExcuseCard(
                        excuse: excuse,
                        isPlayful: isPlayful,
                        showActions: showActions,
                      ),
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(error: e.toString()),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    required this.subMessage,
    required this.isPlayful,
  });

  final String message;
  final String subMessage;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: isPlayful ? 72 : 64,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            SizedBox(height: isPlayful ? 24 : 16),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            Text(
              subMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
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

/// Error view widget.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading excuses',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
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

/// Teacher excuse card with review actions.
class _TeacherExcuseCard extends ConsumerWidget {
  const _TeacherExcuseCard({
    required this.excuse,
    required this.isPlayful,
    required this.showActions,
  });

  final AbsenceExcuse excuse;
  final bool isPlayful;
  final bool showActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(excuse.status);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: isPlayful ? 2 : 1,
        ),
        boxShadow: isPlayful
            ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with student info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isPlayful ? 24 : 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  excuse.studentName?.isNotEmpty == true
                      ? excuse.studentName![0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: isPlayful ? 18 : 16,
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
                      excuse.studentName ?? 'Unknown Student',
                      style: TextStyle(
                        fontSize: isPlayful ? 16 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: isPlayful ? 14 : 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          excuse.attendanceDate != null
                              ? DateFormat('MMMM d, yyyy')
                                  .format(excuse.attendanceDate!)
                              : 'Unknown date',
                          style: TextStyle(
                            fontSize: isPlayful ? 13 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    if (excuse.subjectName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: isPlayful ? 14 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            excuse.subjectName!,
                            style: TextStyle(
                              fontSize: isPlayful ? 13 : 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!showActions)
                _StatusBadge(
                  status: excuse.status,
                  isPlayful: isPlayful,
                ),
            ],
          ),

          // Reason
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPlayful ? 14 : 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: isPlayful ? 16 : 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Excuse Reason',
                      style: TextStyle(
                        fontSize: isPlayful ? 12 : 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  excuse.reason,
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 13,
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Parent info
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: isPlayful ? 14 : 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 6),
              Text(
                'Submitted by: ${excuse.parentName ?? 'Parent'}',
                style: TextStyle(
                  fontSize: isPlayful ? 12 : 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, HH:mm').format(excuse.createdAt),
                style: TextStyle(
                  fontSize: isPlayful ? 11 : 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),

          // Teacher response (for declined)
          if (excuse.isDeclined && excuse.teacherResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isPlayful ? 12 : 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Response:',
                    style: TextStyle(
                      fontSize: isPlayful ? 12 : 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    excuse.teacherResponse!,
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action buttons
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showDeclineDialog(context, ref),
                  icon: Icon(
                    Icons.close_rounded,
                    size: isPlayful ? 18 : 16,
                  ),
                  label: Text(
                    'Decline',
                    style: TextStyle(fontSize: isPlayful ? 14 : 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isPlayful ? 16 : 12,
                      vertical: isPlayful ? 10 : 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _approveExcuse(context, ref),
                  icon: Icon(
                    Icons.check_rounded,
                    size: isPlayful ? 18 : 16,
                  ),
                  label: Text(
                    'Approve',
                    style: TextStyle(fontSize: isPlayful ? 14 : 13),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: isPlayful ? 16 : 12,
                      vertical: isPlayful ? 10 : 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _approveExcuse(BuildContext context, WidgetRef ref) async {
    final isPlayful = ref.read(themeNotifierProvider) == ThemeType.playful;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Excuse'),
        content: Text(
          'Are you sure you want to approve this excuse for ${excuse.studentName ?? 'the student'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(excuseReviewerProvider.notifier).approveExcuse(excuse.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Excuse approved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
          ),
        );
      }
    }
  }

  void _showDeclineDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => ReviewAbsenceExcuseDialog(
        excuse: excuse,
        onDecline: (response) async {
          await ref
              .read(excuseReviewerProvider.notifier)
              .declineExcuse(excuse.id, response: response);
        },
      ),
    );
  }

  Color _getStatusColor(AbsenceExcuseStatus status) {
    switch (status) {
      case AbsenceExcuseStatus.pending:
        return Colors.orange;
      case AbsenceExcuseStatus.approved:
        return Colors.green;
      case AbsenceExcuseStatus.declined:
        return Colors.red;
    }
  }
}

/// Status badge widget.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isPlayful,
  });

  final AbsenceExcuseStatus status;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 12 : 10,
        vertical: isPlayful ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: isPlayful ? 16 : 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AbsenceExcuseStatus status) {
    switch (status) {
      case AbsenceExcuseStatus.pending:
        return Colors.orange;
      case AbsenceExcuseStatus.approved:
        return Colors.green;
      case AbsenceExcuseStatus.declined:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AbsenceExcuseStatus status) {
    switch (status) {
      case AbsenceExcuseStatus.pending:
        return Icons.hourglass_empty_rounded;
      case AbsenceExcuseStatus.approved:
        return Icons.check_circle_outline;
      case AbsenceExcuseStatus.declined:
        return Icons.cancel_outlined;
    }
  }
}
