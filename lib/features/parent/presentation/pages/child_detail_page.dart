import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../../../student/domain/entities/entities.dart';
import '../providers/parent_provider.dart';

/// Child Detail Page for Parent.
///
/// Shows detailed information about a specific child including
/// grades, attendance, schedule, and recent activity.
class ChildDetailPage extends ConsumerStatefulWidget {
  const ChildDetailPage({
    super.key,
    required this.childId,
  });

  final String childId;

  @override
  ConsumerState<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends ConsumerState<ChildDetailPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(myChildrenProvider);
      ref.invalidate(childAttendanceStatsProvider(widget.childId));
      ref.invalidate(childTodaysLessonsProvider(widget.childId));
      ref.invalidate(childGradesProvider(widget.childId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final childrenAsync = ref.watch(myChildrenProvider);
    final attendanceStats = ref.watch(childAttendanceStatsProvider(widget.childId));
    final todaysLessons = ref.watch(childTodaysLessonsProvider(widget.childId));
    final grades = ref.watch(childGradesProvider(widget.childId));

    // Find the child from the list
    final child = childrenAsync.whenData((children) {
      return children.firstWhere(
        (c) => c.id == widget.childId,
        orElse: () => AppUser(
          id: widget.childId,
          email: 'unknown@example.com',
          role: UserRole.student,
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(child.valueOrNull?.fullName ?? 'Child Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(childAttendanceStatsProvider(widget.childId));
          ref.invalidate(childTodaysLessonsProvider(widget.childId));
          ref.invalidate(childGradesProvider(widget.childId));
        },
        child: ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Child Info Card
              child.when(
                data: (childData) => _ChildInfoCard(
                  child: childData,
                  isPlayful: isPlayful,
                ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (_, _) => _ErrorCard(
                  message: 'Failed to load child info',
                  isPlayful: isPlayful,
                ),
              ),
              SizedBox(height: isPlayful ? 24 : 20),

              // Quick Actions
              Text(
                'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.grade_rounded,
                      label: 'Grades',
                      color: Colors.blue,
                      onTap: () {
                        context.push('/parent/child/${widget.childId}/grades');
                      },
                      isPlayful: isPlayful,
                    ),
                  ),
                  SizedBox(width: isPlayful ? 12 : 8),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.fact_check_rounded,
                      label: 'Attendance',
                      color: Colors.green,
                      onTap: () {
                        context.push('/parent/child/${widget.childId}/attendance');
                      },
                      isPlayful: isPlayful,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isPlayful ? 12 : 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.calendar_month_rounded,
                      label: 'Schedule',
                      color: Colors.orange,
                      onTap: () => context.push('/parent/child/${widget.childId}/schedule'),
                      isPlayful: isPlayful,
                    ),
                  ),
                  SizedBox(width: isPlayful ? 12 : 8),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.message_rounded,
                      label: 'Messages',
                      color: Colors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Messages coming soon')),
                        );
                      },
                      isPlayful: isPlayful,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isPlayful ? 24 : 20),

              // Attendance Overview
              Text(
                'Attendance Overview',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
              attendanceStats.when(
                data: (stats) => _AttendanceOverviewCard(
                  stats: stats,
                  isPlayful: isPlayful,
                  onViewAll: () => context.push('/parent/child/${widget.childId}/attendance'),
                ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load attendance',
                  isPlayful: isPlayful,
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
                    ? _EmptyCard(
                        icon: Icons.event_available_outlined,
                        message: 'No classes scheduled for today',
                        isPlayful: isPlayful,
                      )
                    : Column(
                        children: lessons
                            .take(3)
                            .map((lesson) => _LessonCard(
                                  lesson: lesson,
                                  isPlayful: isPlayful,
                                ))
                            .toList(),
                      ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load schedule',
                  isPlayful: isPlayful,
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
              grades.when(
                data: (gradesList) => gradesList.isEmpty
                    ? _EmptyCard(
                        icon: Icons.grade_outlined,
                        message: 'No grades recorded yet',
                        isPlayful: isPlayful,
                      )
                    : Column(
                        children: [
                          ...gradesList.take(3).map((subjectStats) => _SubjectGradeCard(
                                stats: subjectStats,
                                isPlayful: isPlayful,
                              )),
                          if (gradesList.length > 3)
                            Padding(
                              padding: EdgeInsets.only(top: isPlayful ? 8 : 6),
                              child: TextButton(
                                onPressed: () =>
                                    context.push('/parent/child/${widget.childId}/grades'),
                                child: const Text('View all grades'),
                              ),
                            ),
                        ],
                      ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load grades',
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
}

/// Child info card showing avatar and basic info.
class _ChildInfoCard extends StatelessWidget {
  const _ChildInfoCard({
    required this.child,
    required this.isPlayful,
  });

  final AppUser child;
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
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: Row(
          children: [
            Container(
              width: isPlayful ? 72 : 64,
              height: isPlayful ? 72 : 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getInitials(child.fullName),
                  style: TextStyle(
                    fontSize: isPlayful ? 24 : 20,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
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
                    child.fullName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    child.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

/// Action card for quick navigation.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
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
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isPlayful ? 20 : 16),
          child: Column(
            children: [
              Container(
                width: isPlayful ? 56 : 48,
                height: isPlayful ? 56 : 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                ),
                child: Icon(
                  icon,
                  size: isPlayful ? 28 : 24,
                  color: color,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Attendance overview card.
class _AttendanceOverviewCard extends StatelessWidget {
  const _AttendanceOverviewCard({
    required this.stats,
    required this.isPlayful,
    required this.onViewAll,
  });

  final AttendanceStats stats;
  final bool isPlayful;
  final VoidCallback onViewAll;

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
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: Column(
          children: [
            Row(
              children: [
                // Percentage indicator
                Container(
                  width: isPlayful ? 72 : 64,
                  height: isPlayful ? 72 : 64,
                  decoration: BoxDecoration(
                    color: stats.percentageColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  ),
                  child: Center(
                    child: Text(
                      '${stats.attendancePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: isPlayful ? 20 : 18,
                        fontWeight: FontWeight.w800,
                        color: stats.percentageColor,
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
                        'Attendance Rate',
                        style: TextStyle(
                          fontSize: isPlayful ? 16 : 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StatItem(
                            label: 'Present',
                            value: stats.presentDays,
                            color: AttendanceStatus.present.color,
                            isPlayful: isPlayful,
                          ),
                          SizedBox(width: isPlayful ? 16 : 12),
                          _StatItem(
                            label: 'Absent',
                            value: stats.absentDays,
                            color: AttendanceStatus.absent.color,
                            isPlayful: isPlayful,
                          ),
                          SizedBox(width: isPlayful ? 16 : 12),
                          _StatItem(
                            label: 'Late',
                            value: stats.lateDays,
                            color: AttendanceStatus.late.color,
                            isPlayful: isPlayful,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewAll,
                child: const Text('View Full Attendance'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stat item.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final int value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: isPlayful ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 11 : 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Lesson card.
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
      margin: EdgeInsets.only(bottom: isPlayful ? 8 : 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 14 : 12),
        child: Row(
          children: [
            Container(
              width: isPlayful ? 48 : 40,
              height: isPlayful ? 48 : 40,
              decoration: BoxDecoration(
                color: Color(lesson.subject.color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
              ),
              child: Center(
                child: Text(
                  lesson.subject.name.isNotEmpty ? lesson.subject.name[0] : '?',
                  style: TextStyle(
                    fontSize: isPlayful ? 18 : 16,
                    fontWeight: FontWeight.w700,
                    color: Color(lesson.subject.color),
                  ),
                ),
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.subject.name,
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(lesson.startTime)} - ${DateFormat('HH:mm').format(lesson.endTime)}',
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 10 : 8,
                vertical: isPlayful ? 5 : 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
              ),
              child: Text(
                lesson.room,
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Subject grade card.
class _SubjectGradeCard extends StatelessWidget {
  const _SubjectGradeCard({
    required this.stats,
    required this.isPlayful,
  });

  final SubjectGradeStats stats;
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
    final gradeColor = _getGradeColor(stats.average);

    return Card(
      elevation: isPlayful ? 2 : 0,
      margin: EdgeInsets.only(bottom: isPlayful ? 8 : 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 14 : 12),
        child: Row(
          children: [
            Container(
              width: isPlayful ? 48 : 40,
              height: isPlayful ? 48 : 40,
              decoration: BoxDecoration(
                color: gradeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
              ),
              child: Center(
                child: Text(
                  stats.average.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 14,
                    fontWeight: FontWeight.w700,
                    color: gradeColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stats.subjectName,
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: stats.average / 6,
                      minHeight: isPlayful ? 6 : 5,
                      backgroundColor: gradeColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(gradeColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 10),
            Text(
              '${stats.gradeCount} grades',
              style: TextStyle(
                fontSize: isPlayful ? 12 : 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
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
