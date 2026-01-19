import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/theme.dart';
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
              padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
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
                  SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),

                  // Pending Section
                  if (pendingExcuses.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Pending',
                      count: pendingExcuses.length,
                      color: Colors.orange,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
                    ...pendingExcuses.map((excuse) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? AppSpacing.sm : AppSpacing.xs),
                          child: _ExcuseCard(
                            excuse: excuse,
                            isPlayful: isPlayful,
                            childrenAsync: childrenAsync,
                          ),
                        )),
                    SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
                  ],

                  // Approved Section
                  if (approvedExcuses.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Approved',
                      count: approvedExcuses.length,
                      color: Colors.green,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
                    ...approvedExcuses.map((excuse) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? AppSpacing.sm : AppSpacing.xs),
                          child: _ExcuseCard(
                            excuse: excuse,
                            isPlayful: isPlayful,
                            childrenAsync: childrenAsync,
                          ),
                        )),
                    SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
                  ],

                  // Declined Section
                  if (declinedExcuses.isNotEmpty) ...[
                    _SectionHeader(
                      title: 'Declined',
                      count: declinedExcuses.length,
                      color: Colors.red,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
                    ...declinedExcuses.map((excuse) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? AppSpacing.sm : AppSpacing.xs),
                          child: _ExcuseCard(
                            excuse: excuse,
                            isPlayful: isPlayful,
                            childrenAsync: childrenAsync,
                          ),
                        )),
                  ],

                  const SizedBox(height: AppSpacing.xxxl * 2),
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
                SizedBox(height: AppSpacing.md),
                Text(
                  'Error loading excuses',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  e.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
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
        padding: EdgeInsets.all(isPlayful ? AppSpacing.xxl : AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: isPlayful ? AppIconSize.hero + 8 : AppIconSize.hero,
              color: theme.colorScheme.outline.withValues(alpha: AppOpacity.heavy),
            ),
            SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.md),
            Text(
              'No Excuse Submissions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
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
        SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        Expanded(
          child: _SummaryCard(
            label: 'Approved',
            count: approvedCount,
            color: Colors.green,
            icon: Icons.check_circle_outline,
            isPlayful: isPlayful,
          ),
        ),
        SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: color.withValues(alpha: AppOpacity.soft - 0.02),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.medium + 0.14),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isPlayful ? AppIconSize.lg : AppIconSize.md,
          ),
          SizedBox(height: isPlayful ? AppSpacing.xs : 6),
          Text(
            count.toString(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isPlayful ? AppSpacing.xxs : 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
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
          width: AppSpacing.xxs,
          height: isPlayful ? AppSpacing.xl : AppSpacing.lg,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? AppSpacing.xs + 2 : AppSpacing.xs,
            vertical: isPlayful ? AppSpacing.xxs : 2,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.soft + 0.03),
            borderRadius: BorderRadius.circular(isPlayful ? AppRadius.xs + 2 : AppRadius.xs - 2),
          ),
          child: Text(
            count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
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
    final statusColor = _getStatusColor(excuse.status, isPlayful);
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.md - 2),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: statusColor.withValues(alpha: AppOpacity.medium + 0.14),
          width: isPlayful ? 2 : 1,
        ),
        boxShadow: isPlayful
            ? AppShadows.card(isPlayful: isPlayful)
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: isPlayful ? 14 : 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                        ),
                        SizedBox(width: AppSpacing.xs - 2),
                        Text(
                          excuse.attendanceDate != null
                              ? DateFormat('MMMM d, yyyy')
                                  .format(excuse.attendanceDate!)
                              : 'Unknown date',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    if (excuse.subjectName != null) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Row(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: isPlayful ? 14 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                          ),
                          SizedBox(width: AppSpacing.xs - 2),
                          Text(
                            excuse.subjectName!,
                            style: theme.textTheme.labelSmall?.copyWith(
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
          SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(isPlayful ? AppRadius.xs + 2 : AppRadius.sm),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reason:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  excuse.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Teacher response if declined
          if (excuse.isDeclined && excuse.teacherResponse != null) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
              decoration: BoxDecoration(
                color: (isPlayful ? PlayfulColors.error : CleanColors.error).withValues(alpha: AppOpacity.subtle + 0.04),
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.xs + 2 : AppRadius.sm),
                border: Border.all(
                  color: (isPlayful ? PlayfulColors.error : CleanColors.error).withValues(alpha: AppOpacity.medium + 0.04),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: isPlayful ? AppIconSize.xs : 14,
                        color: isPlayful ? PlayfulColors.error : CleanColors.error,
                      ),
                      SizedBox(width: AppSpacing.xs - 2),
                      Text(
                        'Teacher Response:',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isPlayful ? PlayfulColors.error : CleanColors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs - 2),
                  Text(
                    excuse.teacherResponse!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Submitted date
          SizedBox(height: AppSpacing.sm),
          Text(
            'Submitted ${DateFormat('MMM d, yyyy HH:mm').format(excuse.createdAt)}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: isPlayful ? 11 : 10,
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy - 0.08),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AbsenceExcuseStatus status, bool isPlayful) {
    switch (status) {
      case AbsenceExcuseStatus.pending:
        return isPlayful ? PlayfulColors.warning : CleanColors.warning;
      case AbsenceExcuseStatus.approved:
        return isPlayful ? PlayfulColors.success : CleanColors.success;
      case AbsenceExcuseStatus.declined:
        return isPlayful ? PlayfulColors.error : CleanColors.error;
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
    final theme = Theme.of(context);
    final color = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs + 2,
        vertical: isPlayful ? AppSpacing.xs - 2 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft + 0.03),
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.xs + 2 : AppRadius.xs - 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: isPlayful ? AppIconSize.xs : 14,
            color: color,
          ),
          SizedBox(width: AppSpacing.xs - 2),
          Text(
            status.label,
            style: theme.textTheme.labelSmall?.copyWith(
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
        return isPlayful ? PlayfulColors.warning : CleanColors.warning;
      case AbsenceExcuseStatus.approved:
        return isPlayful ? PlayfulColors.success : CleanColors.success;
      case AbsenceExcuseStatus.declined:
        return isPlayful ? PlayfulColors.error : CleanColors.error;
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
