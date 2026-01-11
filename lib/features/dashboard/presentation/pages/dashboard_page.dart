import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/router/routes.dart';
import 'package:classio/features/admin/admin.dart';
import 'package:classio/features/auth/auth.dart';
import 'package:classio/features/dashboard/dashboard.dart';
import 'package:classio/shared/widgets/widgets.dart';

/// Main Dashboard page for the Classio app.
///
/// Displays a merged timeline of schedule and assignments with:
/// - Time-based greeting header
/// - "Up Next" card showing current/next lesson
/// - Today's schedule timeline
/// - Upcoming assignments grouped by urgency
///
/// Supports two theme modes: Clean (minimal/professional) and Playful (colorful/fun).
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);

    // Role-based dispatch - redirect non-students to their appropriate dashboard
    switch (userRole) {
      case UserRole.superadmin:
        return const SuperAdminPage();
      case UserRole.bigadmin:
      case UserRole.admin:
        return const SchoolAdminPage();
      case UserRole.teacher:
        return const TeacherDashboardPage();
      case UserRole.parent:
        // Parents see a simplified version - for now show student view
        // TODO: Create ParentDashboardPage
        break;
      case UserRole.student:
      case null:
        // Continue with student dashboard below
        break;
    }

    final dashboardState = ref.watch(dashboardNotifierProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Scaffold(
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
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardNotifierProvider.notifier).refreshDashboard();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: isPlayful
                    ? theme.colorScheme.surface.withValues(alpha: 0.95)
                    : theme.colorScheme.surface,
                elevation: isPlayful ? 0 : 1,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  title: const _GreetingHeader(),
                  background: isPlayful
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary.withValues(alpha: 0.08),
                                theme.colorScheme.surface.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ),

              // Content
              if (dashboardState.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (dashboardState.hasError)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: dashboardState.error ?? 'An error occurred',
                    onRetry: () {
                      ref.read(dashboardNotifierProvider.notifier).loadDashboard();
                    },
                  ),
                )
              else if (dashboardState.hasData)
                SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    maxWidth: 1200,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Up Next Card
                        const _UpNextCard(),
                        const SizedBox(height: 24),

                        // Today's Schedule Section
                        const _TodayScheduleSection(),
                        const SizedBox(height: 24),

                        // Due Soon Section
                        const _DueSoonSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                )
              else
                SliverFillRemaining(
                  child: Center(
                    child: Text(context.l10n.dashboardNoData),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Greeting header that displays time-based greeting with user name.
class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  String _getGreeting(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.dashboardGreetingMorning;
    } else if (hour < 17) {
      return l10n.dashboardGreetingAfternoon;
    } else {
      return l10n.dashboardGreetingEvening;
    }
  }

  String _getUserDisplayName(String? email, BuildContext context) {
    if (email == null || email.isEmpty) {
      return context.l10n.dashboardStudent;
    }
    // Extract name from email (before @)
    final name = email.split('@').first;
    // Capitalize first letter
    return name.isNotEmpty
        ? '${name[0].toUpperCase()}${name.substring(1)}'
        : context.l10n.dashboardStudent;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final displayName = _getUserDisplayName(user?.email, context);

    return Text(
      '${_getGreeting(context)}, $displayName',
      style: TextStyle(
        fontSize: isPlayful ? 20 : 18,
        fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
        color: theme.colorScheme.onSurface,
        letterSpacing: isPlayful ? 0.3 : -0.3,
      ),
    );
  }
}

/// Card showing the current or next upcoming lesson.
class _UpNextCard extends ConsumerWidget {
  const _UpNextCard();

  String _formatTime(DateTime time) {
    return DateFormat('H:mm').format(time);
  }

  String _getCountdownText(DateTime startTime, BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.isNegative) {
      return l10n.dashboardStarted;
    }

    if (difference.inHours > 0) {
      return l10n.dashboardInHoursMinutes(difference.inHours, difference.inMinutes % 60);
    } else if (difference.inMinutes > 0) {
      return l10n.dashboardInMinutes(difference.inMinutes);
    } else {
      return l10n.dashboardStartingNow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLesson = ref.watch(currentLessonProvider);
    final nextLesson = ref.watch(nextLessonProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    // Determine which lesson to show
    final lesson = currentLesson ?? nextLesson;
    final isInProgress = currentLesson != null;

    final borderRadius = BorderRadius.circular(isPlayful ? 20 : 12);

    final containerContent = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: isPlayful && lesson != null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  lesson.subject.color.withValues(alpha: 0.15),
                  lesson.subject.color.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? (lesson?.subject.color ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 20 : 8,
            offset: Offset(0, isPlayful ? 8 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: lesson != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_filled_rounded,
                            color: isInProgress
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            size: isPlayful ? 24 : 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isInProgress ? context.l10n.dashboardInProgress : context.l10n.dashboardUpNextLabel,
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 13,
                              fontWeight: FontWeight.w600,
                              color: isInProgress
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                              letterSpacing: isPlayful ? 0.5 : 0,
                            ),
                          ),
                        ],
                      ),
                      if (!isInProgress)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isPlayful ? 12 : 10,
                            vertical: isPlayful ? 6 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(isPlayful ? 12 : 8),
                          ),
                          child: Text(
                            _getCountdownText(lesson.startTime, context),
                            style: TextStyle(
                              fontSize: isPlayful ? 13 : 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subject Name
                  Text(
                    lesson.subject.name,
                    style: TextStyle(
                      fontSize: isPlayful ? 26 : 22,
                      fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: isPlayful ? 0.3 : -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Details Row
                  Row(
                    children: [
                      // Room
                      _InfoChip(
                        icon: Icons.room_outlined,
                        label: lesson.room,
                        isPlayful: isPlayful,
                      ),
                      const SizedBox(width: 12),
                      // Time
                      _InfoChip(
                        icon: Icons.access_time_rounded,
                        label:
                            '${_formatTime(lesson.startTime)} - ${_formatTime(lesson.endTime)}',
                        isPlayful: isPlayful,
                      ),
                    ],
                  ),

                  // Status indicator for substitution/cancelled
                  if (lesson.status != LessonStatus.normal) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isPlayful ? 12 : 10,
                        vertical: isPlayful ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: lesson.status == LessonStatus.cancelled
                            ? theme.colorScheme.error.withValues(alpha: 0.1)
                            : theme.colorScheme.tertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                      ),
                      child: Text(
                        lesson.status == LessonStatus.cancelled
                            ? context.l10n.dashboardCancelled
                            : context.l10n.dashboardSubstitution(lesson.substituteTeacher ?? "TBA"),
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          fontWeight: FontWeight.w600,
                          color: lesson.status == LessonStatus.cancelled
                              ? theme.colorScheme.error
                              : theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : _buildEmptyState(context, theme, isPlayful),
      ),
    );

    // Wrap with InkWell for navigation if lesson is available
    if (lesson != null) {
      return InkWell(
        onTap: () => context.push(AppRoutes.subjectDetail(lesson.subject.id)),
        borderRadius: borderRadius,
        child: containerContent,
      );
    }

    return containerContent;
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isPlayful) {
    final l10n = context.l10n;
    return Column(
      children: [
        Icon(
          Icons.celebration_rounded,
          size: isPlayful ? 48 : 40,
          color: theme.colorScheme.primary.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.dashboardAllDone,
          style: TextStyle(
            fontSize: isPlayful ? 20 : 18,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.dashboardNoMoreLessons,
          style: TextStyle(
            fontSize: isPlayful ? 14 : 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Small info chip for displaying room/time info.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isPlayful,
  });

  final IconData icon;
  final String label;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: isPlayful ? 18 : 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 14 : 13,
            fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Section displaying today's schedule as a vertical timeline.
class _TodayScheduleSection extends ConsumerWidget {
  const _TodayScheduleSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(todayLessonsProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: isPlayful ? 22 : 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.dashboardTodaySchedule,
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Timeline
        if (lessons.isEmpty)
          _buildEmptySchedule(context, theme, isPlayful)
        else
          ...List.generate(
            lessons.length,
            (index) => _LessonTimelineItem(
              lesson: lessons[index],
              isFirst: index == 0,
              isLast: index == lessons.length - 1,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySchedule(BuildContext context, ThemeData theme, bool isPlayful) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.beach_access_rounded,
            size: isPlayful ? 32 : 28,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardNoClassesToday,
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                l10n.dashboardEnjoyFreeDay,
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual lesson item in the timeline.
class _LessonTimelineItem extends ConsumerWidget {
  const _LessonTimelineItem({
    required this.lesson,
    required this.isFirst,
    required this.isLast,
  });

  final Lesson lesson;
  final bool isFirst;
  final bool isLast;

  String _formatTime(DateTime time) {
    return DateFormat('H:mm').format(time);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final isCurrentLesson = lesson.isInProgress;
    final isPast = lesson.hasEnded;
    final isCancelled = lesson.status == LessonStatus.cancelled;
    final isSubstitution = lesson.status == LessonStatus.substitution;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  _formatTime(lesson.startTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 13,
                    fontWeight: isCurrentLesson ? FontWeight.w700 : FontWeight.w500,
                    color: isCancelled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : isCurrentLesson
                            ? theme.colorScheme.primary
                            : isPast
                                ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                                : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  _formatTime(lesson.endTime),
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 11,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),

          // Timeline line with dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Dot
                Container(
                  width: isCurrentLesson ? 14 : 10,
                  height: isCurrentLesson ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCancelled
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                        : isCurrentLesson
                            ? theme.colorScheme.primary
                            : isSubstitution
                                ? theme.colorScheme.tertiary
                                : isPast
                                    ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                                    : lesson.subject.color,
                    border: isCurrentLesson
                        ? Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 3,
                          )
                        : null,
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),

          // Lesson Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: InkWell(
                onTap: () => context.push(AppRoutes.subjectDetail(lesson.subject.id)),
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 10),
                child: Container(
                  padding: EdgeInsets.all(isPlayful ? 16 : 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isPlayful ? 16 : 10),
                    gradient: isPlayful && !isCancelled
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              lesson.subject.color.withValues(alpha: 0.15),
                              lesson.subject.color.withValues(alpha: 0.05),
                            ],
                          )
                        : null,
                    color: isPlayful
                        ? null
                        : isCancelled
                            ? theme.colorScheme.surface.withValues(alpha: 0.5)
                            : theme.colorScheme.surface,
                    border: isPlayful
                        ? null
                        : Border.all(
                            color: isCurrentLesson
                                ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                : theme.colorScheme.outline.withValues(alpha: 0.15),
                            width: isCurrentLesson ? 2 : 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isPlayful
                            ? lesson.subject.color.withValues(alpha: isCancelled ? 0.05 : 0.15)
                            : Colors.black.withValues(alpha: 0.03),
                        blurRadius: isPlayful ? 12 : 6,
                        offset: Offset(0, isPlayful ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.subject.name,
                            style: TextStyle(
                              fontSize: isPlayful ? 16 : 15,
                              fontWeight:
                                  isPlayful ? FontWeight.w700 : FontWeight.w600,
                              color: isCancelled
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                  : theme.colorScheme.onSurface,
                              decoration:
                                  isCancelled ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (isSubstitution)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.l10n.dashboardSub,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ),
                        if (isCancelled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              context.l10n.dashboardCancelled.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.room_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lesson.room,
                          style: TextStyle(
                            fontSize: isPlayful ? 13 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        if (lesson.subject.teacherName != null ||
                            lesson.substituteTeacher != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lesson.substituteTeacher ??
                                lesson.subject.teacherName ??
                                '',
                            style: TextStyle(
                              fontSize: isPlayful ? 13 : 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontStyle: lesson.substituteTeacher != null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section displaying assignments due soon, grouped by urgency.
class _DueSoonSection extends ConsumerWidget {
  const _DueSoonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(upcomingAssignmentsProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final l10n = context.l10n;

    // Group assignments by urgency
    final todayAssignments = assignments.where((a) => a.isDueToday).toList();
    final tomorrowAssignments =
        assignments.where((a) => a.isDueTomorrow).toList();
    final laterAssignments = assignments
        .where((a) => !a.isDueToday && !a.isDueTomorrow && !a.isOverdue)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: isPlayful ? 22 : 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.dashboardDueSoon,
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (assignments.isEmpty)
          _buildEmptyAssignments(context, theme, isPlayful)
        else ...[
          // Today's assignments
          if (todayAssignments.isNotEmpty) ...[
            _buildGroupHeader(l10n.dashboardToday, theme, isPlayful, isUrgent: true),
            const SizedBox(height: 8),
            ...todayAssignments.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AssignmentItem(assignment: a),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tomorrow's assignments
          if (tomorrowAssignments.isNotEmpty) ...[
            _buildGroupHeader(l10n.dashboardTomorrow, theme, isPlayful),
            const SizedBox(height: 8),
            ...tomorrowAssignments.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AssignmentItem(assignment: a),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Later assignments
          if (laterAssignments.isNotEmpty) ...[
            _buildGroupHeader(l10n.dashboardLater, theme, isPlayful),
            const SizedBox(height: 8),
            ...laterAssignments.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _AssignmentItem(assignment: a),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildGroupHeader(
    String title,
    ThemeData theme,
    bool isPlayful, {
    bool isUrgent = false,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: isUrgent
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        if (isUrgent) ...[
          const SizedBox(width: 6),
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: theme.colorScheme.error,
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyAssignments(BuildContext context, ThemeData theme, bool isPlayful) {
    final l10n = context.l10n;
    return Container(
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: isPlayful ? 32 : 28,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardAllCaughtUp,
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 15,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                l10n.dashboardNoAssignmentsDue,
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual assignment card.
class _AssignmentItem extends ConsumerWidget {
  const _AssignmentItem({required this.assignment});

  final Assignment assignment;

  String _formatDueDate(DateTime dueDate, BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final assignmentDate =
        DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (assignmentDate == today) {
      return l10n.dashboardToday;
    } else if (assignmentDate == tomorrow) {
      return l10n.dashboardTomorrow;
    } else {
      return DateFormat('EEE, MMM d').format(dueDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final isCompleted = assignment.isCompleted;
    final isOverdue = assignment.isOverdue;

    return InkWell(
      onTap: () => context.push(AppRoutes.subjectDetail(assignment.subject.id)),
      borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
      child: Container(
        padding: EdgeInsets.all(isPlayful ? 14 : 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
          gradient: isPlayful && !isCompleted
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    assignment.subject.color.withValues(alpha: 0.1),
                    assignment.subject.color.withValues(alpha: 0.02),
                  ],
                )
              : null,
          color: isPlayful
              ? null
              : isCompleted
                  ? theme.colorScheme.surface.withValues(alpha: 0.5)
                  : theme.colorScheme.surface,
          border: isPlayful
              ? null
              : Border.all(
                  color: isOverdue && !isCompleted
                      ? theme.colorScheme.error.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.15),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isPlayful
                  ? assignment.subject.color.withValues(alpha: isCompleted ? 0.03 : 0.1)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isPlayful ? 10 : 4,
              offset: Offset(0, isPlayful ? 3 : 2),
            ),
          ],
        ),
        child: Row(
        children: [
          // Subject color indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.2)
                  : assignment.subject.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
                    color: isCompleted
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                        : theme.colorScheme.onSurface,
                    decoration:
                        isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      assignment.subject.name,
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                            : assignment.subject.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDueDate(assignment.dueDate, context),
                      style: TextStyle(
                        fontSize: isPlayful ? 12 : 11,
                        color: isOverdue && !isCompleted
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight:
                            isOverdue && !isCompleted ? FontWeight.w600 : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Completion indicator
          if (isCompleted)
            Icon(
              Icons.check_circle_rounded,
              color: theme.colorScheme.primary,
              size: isPlayful ? 24 : 22,
            )
          else if (isOverdue)
            Icon(
              Icons.error_outline_rounded,
              color: theme.colorScheme.error,
              size: isPlayful ? 24 : 22,
            ),
        ],
        ),
      ),
    );
  }
}

/// Error view with retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dashboardSomethingWrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.dashboardRetry),
            ),
          ],
        ),
      ),
    );
  }
}
