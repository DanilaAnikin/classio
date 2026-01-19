import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/theme/app_colors.dart';
import 'package:classio/core/theme/app_radius.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/student_provider.dart';
import '../widgets/widgets.dart';

/// Student Attendance Page.
///
/// Shows the student's attendance history with statistics, calendar view,
/// and recent attendance issues.
class StudentAttendancePage extends ConsumerWidget {
  const StudentAttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final attendanceStats = ref.watch(myAttendanceStatsProvider());
    final selectedMonth = ref.watch(selectedAttendanceMonthProvider);
    final attendanceCalendar = ref.watch(
      attendanceCalendarProvider(selectedMonth.month, selectedMonth.year),
    );
    final recentIssues = ref.watch(recentAttendanceIssuesProvider);

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
          ref.invalidate(myAttendanceStatsProvider());
          ref.invalidate(
            attendanceCalendarProvider(selectedMonth.month, selectedMonth.year),
          );
          ref.invalidate(recentAttendanceIssuesProvider);
        },
        child: ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Card
              attendanceStats.when(
                data: (stats) => AttendanceSummaryCard(
                  stats: stats,
                  title: 'Attendance Overview',
                ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load attendance stats',
                  isPlayful: isPlayful,
                ),
              ),
              SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),

              // Calendar Section
              Text(
                'Calendar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
              attendanceCalendar.when(
                data: (calendarData) => AttendanceCalendarWidget(
                  month: selectedMonth.month,
                  year: selectedMonth.year,
                  attendanceData: calendarData,
                  onMonthChanged: (month, year) {
                    ref
                        .read(selectedAttendanceMonthProvider.notifier)
                        .setMonth(DateTime(year, month));
                  },
                  onDayTap: (date) => _showDayDetails(context, date, calendarData[date]),
                ),
                loading: () => _CalendarLoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load calendar',
                  isPlayful: isPlayful,
                ),
              ),
              SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),

              // Recent Issues Section
              Text(
                'Recent Issues',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
              recentIssues.when(
                data: (issues) => issues.isEmpty
                    ? _EmptyCard(
                        icon: Icons.check_circle_outline,
                        message: 'No attendance issues',
                        isPlayful: isPlayful,
                      )
                    : Column(
                        children: issues
                            .map((issue) => _AttendanceIssueCard(
                                  attendance: issue,
                                  isPlayful: isPlayful,
                                ))
                            .toList(),
                      ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load issues',
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

  void _showDayDetails(
    BuildContext context,
    DateTime date,
    DailyAttendanceStatus? status,
  ) {
    if (status == null) return;

    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.dialogInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, y').format(date),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  status.label,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing a single attendance issue.
class _AttendanceIssueCard extends StatelessWidget {
  const _AttendanceIssueCard({
    required this.attendance,
    required this.isPlayful,
  });

  final AttendanceEntity attendance;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      margin: EdgeInsets.only(bottom: isPlayful ? AppSpacing.sm : AppSpacing.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
        child: Row(
          children: [
            Container(
              width: isPlayful ? 48 : 40,
              height: isPlayful ? 48 : 40,
              decoration: BoxDecoration(
                color: attendance.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.md : AppRadius.sm + 2),
              ),
              child: Icon(
                _getStatusIcon(attendance.status),
                size: isPlayful ? 24 : 20,
                color: attendance.status.color,
              ),
            ),
            SizedBox(width: isPlayful ? AppSpacing.md : AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.subjectName ?? 'Unknown Subject',
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPlayful ? AppSpacing.xs : AppSpacing.xs - 2,
                          vertical: isPlayful ? 3 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: attendance.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs + 2),
                        ),
                        child: Text(
                          attendance.status.label,
                          style: TextStyle(
                            fontSize: isPlayful ? 12 : 11,
                            fontWeight: FontWeight.w600,
                            color: attendance.status.color,
                          ),
                        ),
                      ),
                      SizedBox(width: isPlayful ? AppSpacing.xs : AppSpacing.xs - 2),
                      Text(
                        DateFormat('MMM d, y').format(attendance.date),
                        style: TextStyle(
                          fontSize: isPlayful ? 12 : 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  if (attendance.excuseNote != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: isPlayful ? 14 : 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            attendance.excuseNote!,
                            style: TextStyle(
                              fontSize: isPlayful ? 12 : 11,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (attendance.excuseStatus != ExcuseStatus.none) ...[
              SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),
              _ExcuseStatusBadge(
                status: attendance.excuseStatus,
                isPlayful: isPlayful,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.late:
        return Icons.schedule;
      case AttendanceStatus.excused:
        return Icons.verified_outlined;
      case AttendanceStatus.leftEarly:
        return Icons.exit_to_app;
    }
  }
}

/// Badge showing excuse status.
class _ExcuseStatusBadge extends StatelessWidget {
  const _ExcuseStatusBadge({
    required this.status,
    required this.isPlayful,
  });

  final ExcuseStatus status;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case ExcuseStatus.none:
        color = isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
        icon = Icons.remove_circle_outline;
        break;
      case ExcuseStatus.pending:
        color = isPlayful ? PlayfulColors.attendanceLate : CleanColors.attendanceLate;
        icon = Icons.hourglass_empty;
        break;
      case ExcuseStatus.approved:
        color = isPlayful ? PlayfulColors.attendancePresent : CleanColors.attendancePresent;
        icon = Icons.check_circle;
        break;
      case ExcuseStatus.rejected:
        color = isPlayful ? PlayfulColors.attendanceAbsent : CleanColors.attendanceAbsent;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.xs : AppSpacing.xs - 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm + 2 : AppRadius.sm),
      ),
      child: Icon(
        icon,
        size: isPlayful ? 20 : 18,
        color: color,
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

/// Calendar loading placeholder.
class _CalendarLoadingCard extends StatelessWidget {
  const _CalendarLoadingCard({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: isPlayful ? 400 : 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg + AppRadius.xs : AppRadius.md),
        color: theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
      ),
      child: const Center(child: CircularProgressIndicator()),
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
