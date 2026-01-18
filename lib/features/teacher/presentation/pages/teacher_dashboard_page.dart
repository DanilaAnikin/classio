import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../auth/auth.dart';
import '../providers/teacher_provider.dart';
import '../tabs/overview_tab.dart';
import '../tabs/gradebook_tab.dart';
import '../tabs/attendance_tab.dart';
import '../tabs/my_students_tab.dart';
import '../tabs/assignments_tab.dart';

/// Main Teacher Dashboard page with tabbed navigation.
///
/// Provides a comprehensive dashboard for teachers with:
/// - Overview: Today's lessons, quick stats, recent activity
/// - Gradebook: Full gradebook grid for managing grades
/// - Attendance: Mark attendance for lessons
/// - My Students: View students and add new ones
/// - Assignments: Create and manage assignments
class TeacherDashboardPage extends ConsumerStatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  ConsumerState<TeacherDashboardPage> createState() =>
      _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends ConsumerState<TeacherDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(teacherStatsProvider);
      ref.invalidate(todaysLessonsProvider);
      ref.invalidate(pendingExcusesProvider);
      ref.invalidate(mySubjectsProvider);
      ref.invalidate(myClassesProvider);
      ref.invalidate(myAssignmentsProvider);
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
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Teacher Dashboard'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Please log in to access the Teacher Dashboard',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Teacher Dashboard',
          style: TextStyle(
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isPlayful ? 0.3 : -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: isPlayful
            ? theme.colorScheme.surface.withValues(alpha: 0.95)
            : theme.colorScheme.surface,
        elevation: isPlayful ? 0 : 1,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isPlayful ? 14 : 13,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isPlayful ? 14 : 13,
          ),
          indicatorWeight: isPlayful ? 3 : 2,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_rounded, size: 20),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.grade_rounded, size: 20),
              text: 'Gradebook',
            ),
            Tab(
              icon: Icon(Icons.how_to_reg_rounded, size: 20),
              text: 'Attendance',
            ),
            Tab(
              icon: Icon(Icons.groups_rounded, size: 20),
              text: 'My Students',
            ),
            Tab(
              icon: Icon(Icons.assignment_rounded, size: 20),
              text: 'Assignments',
            ),
          ],
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
          children: const [
            OverviewTab(),
            GradebookTab(),
            AttendanceTab(),
            MyStudentsTab(),
            AssignmentsTab(),
          ],
        ),
      ),
    );
  }
}
