import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/responsive_center.dart';
import '../providers/student_provider.dart';
import '../widgets/widgets.dart';

/// Attendance tab displaying attendance history and calendar.
///
/// Shows:
/// - Attendance summary card with statistics
/// - Calendar view with month navigation
/// - Recent attendance issues (absences/lates)
class AttendanceTab extends ConsumerWidget {
  const AttendanceTab({
    super.key,
    required this.isPlayful,
  });

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final attendanceStats = ref.watch(myAttendanceStatsProvider());
    final selectedMonth = ref.watch(selectedAttendanceMonthProvider);
    final calendarData = ref.watch(
      attendanceCalendarProvider(
        selectedMonth.month,
        selectedMonth.year,
      ),
    );
    final recentIssues = ref.watch(recentAttendanceIssuesProvider);

    return ResponsiveCenterScrollView(
      maxWidth: 800,
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Attendance Summary Card
          _AttendanceSummarySection(
            attendanceStats: attendanceStats,
            isPlayful: isPlayful,
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
          _AttendanceCalendarSection(
            calendarData: calendarData,
            selectedMonth: selectedMonth,
            isPlayful: isPlayful,
            onMonthChanged: (month, year) {
              ref
                  .read(selectedAttendanceMonthProvider.notifier)
                  .setMonth(DateTime(year, month));
            },
          ),
          SizedBox(height: isPlayful ? 24 : 20),

          // Recent Issues
          Text(
            'Recent Issues',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          _RecentIssuesSection(
            recentIssues: recentIssues,
            isPlayful: isPlayful,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Section displaying the attendance summary card.
class _AttendanceSummarySection extends StatelessWidget {
  const _AttendanceSummarySection({
    required this.attendanceStats,
    required this.isPlayful,
  });

  final AsyncValue attendanceStats;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return attendanceStats.when(
      data: (stats) => AttendanceSummaryCard(stats: stats),
      loading: () => Container(
        height: isPlayful ? 180 : 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading stats: $e'),
      ),
    );
  }
}

/// Section displaying the attendance calendar.
class _AttendanceCalendarSection extends StatelessWidget {
  const _AttendanceCalendarSection({
    required this.calendarData,
    required this.selectedMonth,
    required this.isPlayful,
    required this.onMonthChanged,
  });

  final AsyncValue calendarData;
  final DateTime selectedMonth;
  final bool isPlayful;
  final void Function(int month, int year) onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return calendarData.when(
      data: (data) => AttendanceCalendarWidget(
        month: selectedMonth.month,
        year: selectedMonth.year,
        attendanceData: data,
        onMonthChanged: onMonthChanged,
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
        padding: const EdgeInsets.all(16),
        child: Text('Error loading calendar: $e'),
      ),
    );
  }
}

/// Section displaying recent attendance issues.
class _RecentIssuesSection extends StatelessWidget {
  const _RecentIssuesSection({
    required this.recentIssues,
    required this.isPlayful,
  });

  final AsyncValue recentIssues;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return recentIssues.when(
      data: (issues) {
        if (issues.isEmpty) {
          return _NoIssuesCard(isPlayful: isPlayful);
        }
        return Column(
          children: issues
              .map((attendance) => Padding(
                    padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                    child: AttendanceListItem(attendance: attendance),
                  ))
              .toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Text('Error loading attendance issues: $e'),
      ),
    );
  }
}

/// Card shown when there are no attendance issues.
class _NoIssuesCard extends StatelessWidget {
  const _NoIssuesCard({required this.isPlayful});

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
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No attendance issues',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Great job maintaining your attendance!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
