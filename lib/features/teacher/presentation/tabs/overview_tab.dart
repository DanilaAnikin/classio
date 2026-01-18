import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/attendance_entity.dart';
import '../providers/teacher_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/lesson_schedule_card.dart';
import '../widgets/excuse_card.dart';

/// Overview tab displaying today's lessons, quick stats, and pending actions.
class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teacherStatsProvider);
        ref.invalidate(todaysLessonsProvider);
        ref.invalidate(pendingExcusesProvider);
      },
      child: ResponsiveCenterScrollView(
        maxWidth: 1200,
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            _WelcomeHeader(isPlayful: isPlayful),
            SizedBox(height: isPlayful ? 24 : 20),

            // Stats Row
            _StatsSection(isPlayful: isPlayful),
            SizedBox(height: isPlayful ? 24 : 20),

            // Today's Lessons
            _TodaysLessonsSection(isPlayful: isPlayful),
            SizedBox(height: isPlayful ? 24 : 20),

            // Pending Excuses
            _PendingExcusesSection(isPlayful: isPlayful),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: isPlayful ? 28 : 24,
            fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.3 : -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMMM d, y').format(now),
          style: TextStyle(
            fontSize: isPlayful ? 16 : 15,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(teacherStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: TextStyle(
            fontSize: isPlayful ? 20 : 18,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isPlayful ? 12 : 10),
        statsAsync.when(
          data: (stats) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatCard(
                title: 'Students',
                value: stats.totalStudents.toString(),
                icon: Icons.groups_rounded,
                color: theme.colorScheme.primary,
                isPlayful: isPlayful,
              ),
              StatCard(
                title: 'Lessons Today',
                value: stats.todaysLessons.toString(),
                icon: Icons.schedule_rounded,
                color: theme.colorScheme.secondary,
                isPlayful: isPlayful,
              ),
              StatCard(
                title: 'Subjects',
                value: stats.totalSubjects.toString(),
                icon: Icons.menu_book_rounded,
                color: theme.colorScheme.tertiary,
                isPlayful: isPlayful,
              ),
              StatCard(
                title: 'Pending Excuses',
                value: stats.pendingExcuses.toString(),
                icon: Icons.note_alt_rounded,
                color: stats.pendingExcuses > 0
                    ? theme.colorScheme.error
                    : Colors.green,
                isPlayful: isPlayful,
              ),
            ],
          ),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _ErrorCard(
            message: 'Failed to load stats',
            onRetry: () => ref.invalidate(teacherStatsProvider),
            isPlayful: isPlayful,
          ),
        ),
      ],
    );
  }
}

class _TodaysLessonsSection extends ConsumerWidget {
  const _TodaysLessonsSection({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lessonsAsync = ref.watch(todaysLessonsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to full schedule
              },
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: const Text('View All'),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 12 : 10),
        lessonsAsync.when(
          data: (lessons) {
            if (lessons.isEmpty) {
              return _EmptyCard(
                icon: Icons.event_available_rounded,
                message: 'No lessons scheduled for today',
                isPlayful: isPlayful,
              );
            }

            return Column(
              children: lessons
                  .map((lesson) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LessonScheduleCard(
                          lesson: lesson,
                          isPlayful: isPlayful,
                          onTap: () {
                            // Navigate to attendance for this lesson
                          },
                        ),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _ErrorCard(
            message: 'Failed to load lessons',
            onRetry: () => ref.invalidate(todaysLessonsProvider),
            isPlayful: isPlayful,
          ),
        ),
      ],
    );
  }
}

class _PendingExcusesSection extends ConsumerWidget {
  const _PendingExcusesSection({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final excusesAsync = ref.watch(pendingExcusesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Excuses',
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 12 : 10),
        excusesAsync.when(
          data: (excuses) {
            if (excuses.isEmpty) {
              return _EmptyCard(
                icon: Icons.check_circle_outline_rounded,
                message: 'No pending excuses to review',
                isPlayful: isPlayful,
              );
            }

            return Column(
              children: excuses
                  .take(3)
                  .map((excuse) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ExcuseCard(
                          attendance: excuse,
                          isPlayful: isPlayful,
                          onApprove: () async {
                            await ref
                                .read(excuseNotifierProvider.notifier)
                                .reviewExcuse(
                                  excuse.id,
                                  ExcuseStatus.approved,
                                );
                          },
                          onReject: () async {
                            await ref
                                .read(excuseNotifierProvider.notifier)
                                .reviewExcuse(
                                  excuse.id,
                                  ExcuseStatus.rejected,
                                );
                          },
                        ),
                      ))
                  .toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _ErrorCard(
            message: 'Failed to load excuses',
            onRetry: () => ref.invalidate(pendingExcusesProvider),
            isPlayful: isPlayful,
          ),
        ),
      ],
    );
  }
}

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

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPlayful ? 32 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isPlayful ? 48 : 40,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: isPlayful ? 15 : 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
    required this.isPlayful,
  });

  final String message;
  final VoidCallback onRetry;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: isPlayful ? 40 : 36,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: isPlayful ? 15 : 14,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
