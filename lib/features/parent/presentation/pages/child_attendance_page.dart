import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../student/domain/entities/entities.dart';
import '../../../student/presentation/widgets/widgets.dart';
import '../providers/parent_provider.dart';

/// Child Attendance Page for Parent.
///
/// Shows child's attendance history with ability to submit excuses.
class ChildAttendancePage extends ConsumerStatefulWidget {
  const ChildAttendancePage({
    super.key,
    required this.childId,
  });

  final String childId;

  @override
  ConsumerState<ChildAttendancePage> createState() => _ChildAttendancePageState();
}

class _ChildAttendancePageState extends ConsumerState<ChildAttendancePage> {
  @override
  void initState() {
    super.initState();
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(childAttendanceStatsProvider(widget.childId));
      ref.invalidate(childAttendanceIssuesProvider(widget.childId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final attendanceStats = ref.watch(childAttendanceStatsProvider(widget.childId));
    final selectedMonth = ref.watch(parentSelectedAttendanceMonthProvider);
    final calendarData = ref.watch(
      childAttendanceCalendarProvider(
        widget.childId,
        selectedMonth.month,
        selectedMonth.year,
      ),
    );
    final attendanceIssues =
        ref.watch(childAttendanceIssuesProvider(widget.childId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(childAttendanceStatsProvider(widget.childId));
          ref.invalidate(childAttendanceIssuesProvider(widget.childId));
        },
        child: ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Attendance Summary Card
              attendanceStats.when(
                data: (stats) => AttendanceSummaryCard(
                  stats: stats,
                ),
                loading: () => Container(
                  height: isPlayful ? 180 : 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Container(
                  padding: AppSpacing.cardInsets,
                  child: Text('Error loading stats: $e'),
                ),
              ),
              SizedBox(height: isPlayful ? 24 : 20),

              // Attendance Calendar
              Text(
                'Attendance Calendar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
              calendarData.when(
                data: (data) => AttendanceCalendarWidget(
                  month: selectedMonth.month,
                  year: selectedMonth.year,
                  attendanceData: data,
                  onMonthChanged: (month, year) {
                    ref
                        .read(parentSelectedAttendanceMonthProvider.notifier)
                        .setMonth(DateTime(year, month));
                  },
                ),
                loading: () => Container(
                  height: isPlayful ? 350 : 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Container(
                  padding: AppSpacing.cardInsets,
                  child: Text('Error loading calendar: $e'),
                ),
              ),
              SizedBox(height: isPlayful ? 24 : 20),

              // Recent Issues Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Absences & Lates',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showPendingExcuses(context, ref),
                    icon: Icon(
                      Icons.history_rounded,
                      size: isPlayful ? 20 : 18,
                    ),
                    label: Text(
                      'Excuses',
                      style: TextStyle(
                        fontSize: isPlayful ? 14 : 13,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isPlayful ? 12 : 8),

              // Attendance Issues List
              attendanceIssues.when(
                data: (issues) {
                  if (issues.isEmpty) {
                    return Card(
                      elevation: isPlayful ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isPlayful ? 16 : 12),
                        side: isPlayful
                            ? BorderSide.none
                            : BorderSide(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isPlayful ? 24 : 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 48,
                              color: Colors.green.withValues(alpha: 0.6),
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'No attendance issues',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Your child has a great attendance record!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: issues
                        .map((attendance) => Padding(
                              padding:
                                  EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                              child: AttendanceListItem(
                                attendance: attendance,
                                showExcuseButton: true,
                                onExcuseTap: () => _showExcuseDialog(
                                  context,
                                  ref,
                                  attendance,
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: AppSpacing.dialogInsets,
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error loading attendance issues: $e'),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showExcuseDialog(
    BuildContext context,
    WidgetRef ref,
    AttendanceEntity attendance,
  ) {
    final theme = Theme.of(context);
    final isPlayful =
        ref.read(themeNotifierProvider) == ThemeType.playful;
    final excuseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.edit_note_rounded,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: AppSpacing.xs),
            const Text('Submit Excuse'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Attendance info
            Container(
              padding: EdgeInsets.all(isPlayful ? 12 : 10),
              decoration: BoxDecoration(
                color: attendance.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, yyyy').format(attendance.date),
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        attendance.status.icon,
                        size: isPlayful ? 16 : 14,
                        color: attendance.status.color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${attendance.status.label} - ${attendance.subjectName ?? 'Unknown Subject'}',
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Excuse reason input
            TextFormField(
              controller: excuseController,
              decoration: InputDecoration(
                labelText: 'Reason for absence',
                hintText: 'Please explain the reason...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
              ),
              maxLines: 4,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Note: Excuse submissions are reviewed by teachers.',
              style: TextStyle(
                fontSize: isPlayful ? 12 : 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final submitterState = ref.watch(excuseSubmitterProvider);
              final isLoading = submitterState.isLoading;

              return FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (excuseController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a reason'),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(excuseSubmitterProvider.notifier)
                            .submitExcuse(
                              attendance.id,
                              excuseController.text.trim(),
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Excuse submitted successfully'),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Submit'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPendingExcuses(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful =
        ref.read(themeNotifierProvider) == ThemeType.playful;
    final allExcusesAsync = ref.watch(allExcusesProvider(widget.childId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isPlayful ? 24 : 16),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isPlayful ? 16 : 12),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Excuse History',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: allExcusesAsync.when(
                data: (excuses) {
                  if (excuses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'No excuse submissions yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.all(isPlayful ? 16 : 12),
                    itemCount: excuses.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: isPlayful ? 12 : 8),
                    itemBuilder: (context, index) {
                      final excuse = excuses[index];
                      return _ExcuseHistoryItem(
                        excuse: excuse,
                        isPlayful: isPlayful,
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Error loading excuses: $e'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget showing excuse history item.
class _ExcuseHistoryItem extends StatelessWidget {
  const _ExcuseHistoryItem({
    required this.excuse,
    required this.isPlayful,
  });

  final AttendanceEntity excuse;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: excuse.excuseStatus.color.withValues(alpha: 0.3),
          width: isPlayful ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(excuse.date),
                      style: TextStyle(
                        fontSize: isPlayful ? 15 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      excuse.subjectName ?? 'Unknown Subject',
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ExcuseStatusBadge(
                status: excuse.excuseStatus,
                isPlayful: isPlayful,
              ),
            ],
          ),
          if (excuse.excuseNote?.isNotEmpty ?? false) ...[
            SizedBox(height: isPlayful ? 10 : 8),
            Container(
              padding: EdgeInsets.all(isPlayful ? 10 : 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    size: isPlayful ? 16 : 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      excuse.excuseNote ?? '',
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
