import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
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
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
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
              SizedBox(height: isPlayful ? 24 : 20),

              // Calendar Section
              Text(
                'Calendar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
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
              SizedBox(height: isPlayful ? 24 : 20),

              // Recent Issues Section
              Text(
                'Recent Issues',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
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
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
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
                const SizedBox(width: 12),
                Text(
                  status.label,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
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
      margin: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        child: Row(
          children: [
            Container(
              width: isPlayful ? 48 : 40,
              height: isPlayful ? 48 : 40,
              decoration: BoxDecoration(
                color: attendance.status.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
              ),
              child: Icon(
                _getStatusIcon(attendance.status),
                size: isPlayful ? 24 : 20,
                color: attendance.status.color,
              ),
            ),
            SizedBox(width: isPlayful ? 16 : 12),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPlayful ? 8 : 6,
                          vertical: isPlayful ? 3 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: attendance.status.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
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
                      SizedBox(width: isPlayful ? 8 : 6),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: isPlayful ? 14 : 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
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
              SizedBox(width: isPlayful ? 12 : 8),
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
        color = Colors.grey;
        icon = Icons.remove_circle_outline;
        break;
      case ExcuseStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case ExcuseStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case ExcuseStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.all(isPlayful ? 8 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
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
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
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
