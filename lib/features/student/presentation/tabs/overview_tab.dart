import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/responsive_center.dart';
import '../providers/student_provider.dart';
import '../widgets/widgets.dart';

/// Overview tab for the student dashboard.
///
/// Displays a summary of:
/// - Welcome header
/// - Today's schedule
/// - Recent grades
/// - Attendance overview
class OverviewTab extends ConsumerWidget {
  const OverviewTab({
    super.key,
    required this.isPlayful,
  });

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todaysLessons = ref.watch(myTodaysLessonsProvider);
    final recentGrades = ref.watch(recentGradesProvider);
    final attendanceStats = ref.watch(myAttendanceStatsProvider());

    return ResponsiveCenterScrollView(
      maxWidth: 1000,
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Card
          DashboardHeader(isPlayful: isPlayful),
          SizedBox(height: isPlayful ? 24 : 20),

          // Today's Schedule
          Text(
            'Today\'s Schedule',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          todaysLessons.when(
            data: (lessons) => TodayScheduleSection(
              lessons: lessons,
              isPlayful: isPlayful,
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading schedule: $e'),
              ),
            ),
          ),
          SizedBox(height: isPlayful ? 24 : 20),

          // Recent Grades
          Text(
            'Recent Grades',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          recentGrades.when(
            data: (grades) => RecentGradesSection(
              grades: grades,
              isPlayful: isPlayful,
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading grades: $e'),
              ),
            ),
          ),
          SizedBox(height: isPlayful ? 24 : 20),

          // Attendance Summary
          Text(
            'Attendance Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          attendanceStats.when(
            data: (stats) => AttendanceSummaryCompact(
              stats: stats,
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error loading attendance: $e'),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
