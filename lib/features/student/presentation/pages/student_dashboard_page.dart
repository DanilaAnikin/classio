import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../providers/student_provider.dart';
import '../tabs/tabs.dart';

/// Student Dashboard Page with tabbed navigation.
///
/// Provides a comprehensive dashboard for students with:
/// - Overview: Today's schedule, recent grades, attendance summary
/// - Schedule: Weekly timetable view
/// - Grades: All grades by subject
/// - Attendance: Attendance history with calendar
class StudentDashboardPage extends ConsumerStatefulWidget {
  const StudentDashboardPage({super.key});

  @override
  ConsumerState<StudentDashboardPage> createState() =>
      _StudentDashboardPageState();
}

class _StudentDashboardPageState extends ConsumerState<StudentDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(myTodaysLessonsProvider);
      ref.invalidate(recentGradesProvider);
      ref.invalidate(myAttendanceStatsProvider());
      ref.invalidate(myWeeklyScheduleProvider);
      ref.invalidate(subjectAveragesProvider);
      ref.invalidate(recentAttendanceIssuesProvider);
    });
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Dashboard',
          style: TextStyle(
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_rounded),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.calendar_month_rounded),
              text: 'Schedule',
            ),
            Tab(
              icon: Icon(Icons.grade_rounded),
              text: 'Grades',
            ),
            Tab(
              icon: Icon(Icons.fact_check_rounded),
              text: 'Attendance',
            ),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: isPlayful ? 3 : 2,
        ),
      ),
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.03),
                    theme.colorScheme.secondary.withValues(alpha: 0.03),
                    theme.colorScheme.tertiary.withValues(alpha: 0.03),
                  ],
                ),
              )
            : null,
        child: TabBarView(
          controller: _tabController,
          children: [
            OverviewTab(isPlayful: isPlayful),
            ScheduleTab(isPlayful: isPlayful),
            GradesTab(isPlayful: isPlayful),
            AttendanceTab(isPlayful: isPlayful),
          ],
        ),
      ),
    );
  }
}
