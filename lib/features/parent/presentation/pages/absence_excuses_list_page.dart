import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../attendance/domain/entities/absence_excuse.dart';
import '../../../attendance/presentation/providers/absence_excuse_provider.dart';
import '../providers/parent_provider.dart';

/// Page showing a list of submitted absence excuses for a parent.
///
/// Displays all excuses submitted for all children with their current status.
class AbsenceExcusesListPage extends ConsumerWidget {
  const AbsenceExcusesListPage({
    super.key,
    this.childId,
  });

  /// Optional child ID to filter excuses. If null, shows all children's excuses.
  final String? childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    // Get excuses based on whether filtering by child or all
    final excusesAsync = childId != null
        ? ref.watch(childAbsenceExcusesProvider(childId!))
        : ref.watch(allParentAbsenceExcusesProvider);

    // Get children data for display
    final childrenAsync = ref.watch(myChildrenProvider);

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
              if (childId != null) {
                ref.invalidate(childAbsenceExcusesProvider(childId!));
              } else {
                ref.invalidate(allParentAbsenceExcusesProvider);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (childId != null) {
            ref.invalidate(childAbsenceExcusesProvider(childId!));
          } else {
            ref.invalidate(allParentAbsenceExcusesProvider);
          }
        },
        child: excusesAsync.when(
          data: (excuses) {
            if (excuses.isEmpty) {
              return _EmptyState(isPlayful: isPlayful);
            }

            // Group excuses by status
            final pendingExcuses =
                excuses.where((e) => e.isPending).toList();
            final approvedExcuses =
                excuses.where((e) => e.isApproved).toList();
            final declinedExcuses =
                excuses.where((e) => e.isDeclined).toList();

            return ResponsiveCenterScrollView(
              maxWidth: 800,
              padding: EdgeInsets.all(isPlayful ? 16 : 12),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  _SummaryRow(
                    pendingCount: pendingExcuses.length,
                    approvedCount: approvedExcuses.length,
                    declinedCount: declinedExcuses.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 24 : 20),

                  // Pending Section
                  if (pendingExcuses.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Pending',
                      count: pendingExcuses.length,
                      color: Colors.orange,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? 12 : 8),
                    ...pendingExcuses.map((excuse) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                          child: _ExcuseCard(
                            excuse: excuse,
                            isPlayful: isPlayful,
                            childrenAsync: childrenAsync,
                          ),
                        )),
                    SizedBox(height: isPlayful ? 16 : 12),
                  ],

                  // Approved Section
                  if (approvedExcuses.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Approved',
                      count: approvedExcuses.length,
                      color: Colors.green,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? 12 : 8),
                    ...approvedExcuses.map((excuse) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                          child: _ExcuseCard(
                            excuse: excuse,
                            isPlayful: isPlayful,
                            childrenAsync: childrenAsync,
                          ),
                        )),
                    SizedBox(height: isPlayful ? 16 : 12),
                  ],

                  // Declined Section
                  if (declinedExcuses.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Declined',
                      count: declinedExcuses.length,
                      color: Colors.red,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? 12 : 8),
                    ...declinedExcuses.map((excuse) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                          child: _ExcuseCard(
                            excuse: excuse,
                            isPlayful: isPlayful,
                            childrenAsync: childrenAsync,
                          ),
                        )),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
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
                  e.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    if (childId != null) {
                      ref.invalidate(childAbsenceExcusesProvider(childId!));
                    } else {
                      ref.invalidate(allParentAbsenceExcusesProvider);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state when no excuses exist.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isPlayful});

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
              Icons.inbox_outlined,
              size: isPlayful ? 72 : 64,
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
            ),
            SizedBox(height: isPlayful ? 24 : 16),
            Text(
              'No Excuse Submissions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            Text(
              'You haven\'t submitted any absence excuses yet.\nSubmit excuses from the attendance page.',
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

/// Summary row showing counts by status.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.pendingCount,
    required this.approvedCount,
    required this.declinedCount,
    required this.isPlayful,
  });

  final int pendingCount;
  final int approvedCount;
  final int declinedCount;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            count: pendingCount,
            color: Colors.orange,
            icon: Icons.hourglass_empty_rounded,
            isPlayful: isPlayful,
          ),
        ),
        SizedBox(width: isPlayful ? 12 : 8),
        Expanded(
          child: _SummaryCard(
            label: 'Approved',
            count: approvedCount,
            color: Colors.green,
            icon: Icons.check_circle_outline,
            isPlayful: isPlayful,
          ),
        ),
        SizedBox(width: isPlayful ? 12 : 8),
        Expanded(
          child: _SummaryCard(
            label: 'Declined',
            count: declinedCount,
            color: Colors.red,
            icon: Icons.cancel_outlined,
            isPlayful: isPlayful,
          ),
        ),
      ],
    );
  }
}

/// Individual summary card.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.isPlayful,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isPlayful ? 28 : 24,
          ),
          SizedBox(height: isPlayful ? 8 : 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isPlayful ? 4 : 2),
          Text(
            label,
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header with title and count.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.isPlayful,
  });

  final String title;
  final int count;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 4,
          height: isPlayful ? 24 : 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 10 : 8,
            vertical: isPlayful ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual excuse card.
class _ExcuseCard extends ConsumerWidget {
  const _ExcuseCard({
    required this.excuse,
    required this.isPlayful,
    required this.childrenAsync,
  });

  final AbsenceExcuse excuse;
  final bool isPlayful;
  final AsyncValue childrenAsync;

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
                  color: statusColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (excuse.studentName != null)
                      Text(
                        excuse.studentName!,
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
              _StatusBadge(
                status: excuse.status,
                isPlayful: isPlayful,
              ),
            ],
          ),

          // Reason
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPlayful ? 12 : 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason:',
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  excuse.reason,
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Teacher response if declined
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
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: isPlayful ? 16 : 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Teacher Response:',
                        style: TextStyle(
                          fontSize: isPlayful ? 12 : 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    excuse.teacherResponse!,
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      color: theme.colorScheme.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Submitted date
          const SizedBox(height: 12),
          Text(
            'Submitted ${DateFormat('MMM d, yyyy HH:mm').format(excuse.createdAt)}',
            style: TextStyle(
              fontSize: isPlayful ? 11 : 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
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
