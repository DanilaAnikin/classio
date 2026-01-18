import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../providers/student_provider.dart';
import '../widgets/widgets.dart';

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
            _OverviewTab(isPlayful: isPlayful),
            _ScheduleTab(isPlayful: isPlayful),
            _GradesTab(isPlayful: isPlayful),
            _AttendanceTab(isPlayful: isPlayful),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.isPlayful});

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
          Container(
            padding: EdgeInsets.all(isPlayful ? 24 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPlayful ? 24 : 16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: isPlayful ? 64 : 56,
                  height: isPlayful ? 64 : 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: isPlayful ? 36 : 32,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: isPlayful ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: isPlayful ? 24 : 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your learning journey continues',
                        style: TextStyle(
                          fontSize: isPlayful ? 15 : 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
            data: (lessons) => lessons.isEmpty
                ? Card(
                    elevation: isPlayful ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
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
                            Icons.event_note_outlined,
                            size: 48,
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No classes scheduled for today',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: lessons
                        .map((lesson) => _LessonCard(
                              lesson: lesson,
                              isPlayful: isPlayful,
                            ))
                        .toList(),
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
            data: (grades) => grades.isEmpty
                ? Card(
                    elevation: isPlayful ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
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
                            Icons.grade_outlined,
                            size: 48,
                            color:
                                theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No grades yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: grades
                        .map((grade) => _GradeCard(
                              grade: grade,
                              isPlayful: isPlayful,
                            ))
                        .toList(),
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

/// Card showing a single lesson in today's schedule.
class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.isPlayful,
  });

  final Lesson lesson;
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
              width: isPlayful ? 56 : 48,
              height: isPlayful ? 56 : 48,
              decoration: BoxDecoration(
                color: Color(lesson.subject.color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
              ),
              child: Center(
                child: Text(
                  lesson.subject.name.isNotEmpty
                      ? lesson.subject.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: isPlayful ? 22 : 18,
                    fontWeight: FontWeight.w700,
                    color: Color(lesson.subject.color),
                  ),
                ),
              ),
            ),
            SizedBox(width: isPlayful ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.subject.name,
                    style: TextStyle(
                      fontSize: isPlayful ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('HH:mm').format(lesson.startTime)} - ${DateFormat('HH:mm').format(lesson.endTime)}',
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.room,
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 11,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card showing a recent grade.
class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.grade,
    required this.isPlayful,
  });

  final Grade grade;
  final bool isPlayful;

  Color _getGradeColor(double value, ThemeData theme) {
    if (value >= 5) return Colors.green;
    if (value >= 4) return Colors.lightGreen;
    if (value >= 3) return Colors.orange;
    if (value >= 2) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeColor = _getGradeColor(grade.score, theme);

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
              width: isPlayful ? 48 : 42,
              height: isPlayful ? 48 : 42,
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
              ),
              child: Center(
                child: Text(
                  grade.score.toStringAsFixed(
                      grade.score.truncateToDouble() == grade.score ? 0 : 1),
                  style: TextStyle(
                    fontSize: isPlayful ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: gradeColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: isPlayful ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grade.description,
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(grade.date),
                    style: TextStyle(
                      fontSize: isPlayful ? 12 : 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTab extends ConsumerStatefulWidget {
  const _ScheduleTab({required this.isPlayful});

  final bool isPlayful;

  @override
  ConsumerState<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<_ScheduleTab> {
  int _selectedDayIndex = DateTime.now().weekday - 1; // 0-indexed, Monday = 0

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = widget.isPlayful;
    final weeklySchedule = ref.watch(myWeeklyScheduleProvider);

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Day selector
        Container(
          padding: EdgeInsets.symmetric(
            vertical: isPlayful ? 16 : 12,
            horizontal: isPlayful ? 8 : 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final isSelected = _selectedDayIndex == index;
              final isWeekend = index >= 5;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDayIndex = index),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: isPlayful ? 4 : 2),
                    padding: EdgeInsets.symmetric(
                      vertical: isPlayful ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isWeekend
                              ? theme.colorScheme.outline.withValues(alpha: 0.05)
                              : theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                      border: isSelected
                          ? null
                          : Border.all(
                              color:
                                  theme.colorScheme.outline.withValues(alpha: 0.2),
                            ),
                    ),
                    child: Center(
                      child: Text(
                        weekdays[index],
                        style: TextStyle(
                          fontSize: isPlayful ? 14 : 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isWeekend
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // Schedule content
        Expanded(
          child: weeklySchedule.when(
            data: (schedule) {
              final daySchedule = schedule[_selectedDayIndex] ?? [];
              if (daySchedule.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No classes on ${weekdays[_selectedDayIndex]}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(isPlayful ? 16 : 12),
                itemCount: daySchedule.length,
                itemBuilder: (context, index) {
                  final lesson = daySchedule[index];
                  return _ScheduleLessonCard(
                    lesson: lesson,
                    isPlayful: isPlayful,
                    isFirst: index == 0,
                    isLast: index == daySchedule.length - 1,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error loading schedule: $e'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Card for a lesson in the schedule view.
class _ScheduleLessonCard extends StatelessWidget {
  const _ScheduleLessonCard({
    required this.lesson,
    required this.isPlayful,
    required this.isFirst,
    required this.isLast,
  });

  final Lesson lesson;
  final bool isPlayful;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: isPlayful ? 60 : 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(lesson.startTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(lesson.endTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isPlayful ? 16 : 12),
          // Timeline indicator
          Column(
            children: [
              Container(
                width: isPlayful ? 14 : 12,
                height: isPlayful ? 14 : 12,
                decoration: BoxDecoration(
                  color: Color(lesson.subject.color),
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: isPlayful ? 60 : 50,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
            ],
          ),
          SizedBox(width: isPlayful ? 16 : 12),
          // Lesson content
          Expanded(
            child: Card(
              elevation: isPlayful ? 2 : 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                side: isPlayful
                    ? BorderSide.none
                    : BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Container(
                padding: EdgeInsets.all(isPlayful ? 16 : 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  border: Border(
                    left: BorderSide(
                      color: Color(lesson.subject.color),
                      width: isPlayful ? 4 : 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.subject.name,
                      style: TextStyle(
                        fontSize: isPlayful ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (lesson.subject.teacherName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: isPlayful ? 16 : 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lesson.subject.teacherName!,
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.room_outlined,
                          size: isPlayful ? 16 : 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.room,
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradesTab extends ConsumerWidget {
  const _GradesTab({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjectAverages = ref.watch(subjectAveragesProvider);
    final overallAverage = ref.watch(myOverallAverageProvider);

    return ResponsiveCenterScrollView(
      maxWidth: 800,
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall Average Card
          Container(
            padding: EdgeInsets.all(isPlayful ? 24 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getAverageColor(overallAverage),
                  _getAverageColor(overallAverage).withValues(alpha: 0.7),
                ],
              ),
              boxShadow: isPlayful
                  ? [
                      BoxShadow(
                        color: _getAverageColor(overallAverage).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: isPlayful ? 72 : 64,
                  height: isPlayful ? 72 : 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
                  ),
                  child: Center(
                    child: Text(
                      overallAverage.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: isPlayful ? 26 : 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isPlayful ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overall Average',
                        style: TextStyle(
                          fontSize: isPlayful ? 20 : 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getAverageDescription(overallAverage),
                        style: TextStyle(
                          fontSize: isPlayful ? 15 : 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isPlayful ? 24 : 20),

          // Subject Averages
          Text(
            'Grades by Subject',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          subjectAverages.when(
            data: (averages) {
              if (averages.isEmpty) {
                return Card(
                  elevation: isPlayful ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                    side: isPlayful
                        ? BorderSide.none
                        : BorderSide(
                            color:
                                theme.colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(isPlayful ? 24 : 16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.grade_outlined,
                          size: 48,
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No grades yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: averages.entries.map((entry) {
                  return _SubjectAverageCard(
                    subjectName: entry.key,
                    average: entry.value,
                    isPlayful: isPlayful,
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Text('Error loading grades: $e'),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Color _getAverageColor(double avg) {
    if (avg >= 5) return Colors.green.shade600;
    if (avg >= 4) return Colors.lightGreen.shade600;
    if (avg >= 3) return Colors.orange.shade600;
    if (avg >= 2) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  String _getAverageDescription(double avg) {
    if (avg >= 5) return 'Excellent performance!';
    if (avg >= 4) return 'Very good work!';
    if (avg >= 3) return 'Good progress';
    if (avg >= 2) return 'Needs improvement';
    return 'Keep working hard';
  }
}

/// Card showing a subject's average grade.
class _SubjectAverageCard extends StatelessWidget {
  const _SubjectAverageCard({
    required this.subjectName,
    required this.average,
    required this.isPlayful,
  });

  final String subjectName;
  final double average;
  final bool isPlayful;

  Color _getGradeColor(double value) {
    if (value >= 5) return Colors.green;
    if (value >= 4) return Colors.lightGreen;
    if (value >= 3) return Colors.orange;
    if (value >= 2) return Colors.deepOrange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeColor = _getGradeColor(average);

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
              width: isPlayful ? 56 : 48,
              height: isPlayful ? 56 : 48,
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
              ),
              child: Center(
                child: Text(
                  average.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: isPlayful ? 20 : 18,
                    fontWeight: FontWeight.w700,
                    color: gradeColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: isPlayful ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: TextStyle(
                      fontSize: isPlayful ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(isPlayful ? 6 : 4),
                    child: LinearProgressIndicator(
                      value: average / 6,
                      minHeight: isPlayful ? 8 : 6,
                      backgroundColor: gradeColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(gradeColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab({required this.isPlayful});

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
              padding: const EdgeInsets.all(16),
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
                    .read(selectedAttendanceMonthProvider.notifier)
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
              padding: const EdgeInsets.all(16),
              child: Text('Error loading calendar: $e'),
            ),
          ),
          SizedBox(height: isPlayful ? 24 : 20),

          // Recent Issues (absences/lates)
          Text(
            'Recent Issues',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          recentIssues.when(
            data: (issues) {
              if (issues.isEmpty) {
                return Card(
                  elevation: isPlayful ? 2 : 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                    side: isPlayful
                        ? BorderSide.none
                        : BorderSide(
                            color:
                                theme.colorScheme.outline.withValues(alpha: 0.2)),
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
              return Column(
                children: issues
                    .map((attendance) => Padding(
                          padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                          child: AttendanceListItem(
                            attendance: attendance,
                          ),
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
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
