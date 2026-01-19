import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/spacing.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../providers/schedule_provider.dart';
import '../widgets/widgets.dart';

/// Schedule page displaying the weekly timetable.
///
/// Features:
/// - Day selector for switching between weekdays (Mon-Fri)
/// - ListView of lessons for the selected day
/// - Theme-aware styling (clean vs playful)
/// - Loading, error, and empty states
class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  /// Get localized day labels
  List<String> _getDayLabels(BuildContext context) {
    final l10n = context.l10n;
    return [
      l10n.scheduleMondayFull,
      l10n.scheduleTuesdayFull,
      l10n.scheduleWednesdayFull,
      l10n.scheduleThursdayFull,
      l10n.scheduleFridayFull,
      l10n.scheduleSaturday,
      l10n.scheduleSunday,
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final selectedDay = ref.watch(selectedDayProvider);
    final isLoading = ref.watch(isScheduleLoadingProvider);
    final error = ref.watch(scheduleErrorProvider);
    final lessons = ref.watch(selectedDayLessonsProvider);
    final l10n = context.l10n;
    final dayLabels = _getDayLabels(context);

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
            ref.invalidate(weekLessonsProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 80,
                floating: false,
                pinned: true,
                backgroundColor: isPlayful
                    ? theme.colorScheme.surface.withValues(alpha: 0.95)
                    : theme.colorScheme.surface,
                elevation: isPlayful ? 0 : 1,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: AppSpacing.md, bottom: AppSpacing.md),
                  title: Text(
                    l10n.navSchedule,
                    style: TextStyle(
                      fontSize: isPlayful ? 22 : 20,
                      fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: isPlayful ? 0.3 : -0.3,
                    ),
                  ),
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

              // Week Selector
              SliverToBoxAdapter(
                child: ResponsiveCenter(
                  maxWidth: 1200,
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.xs),
                  child: const WeekSelector(),
                ),
              ),

              // Day Selector
              SliverToBoxAdapter(
                child: ResponsiveCenter(
                  maxWidth: 1200,
                  padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DaySelector(),
                      SizedBox(height: AppSpacing.md),
                      // Selected day header
                      Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: isPlayful ? AppIconSize.sm : 18,
                            color: theme.colorScheme.primary,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            selectedDay >= 1 && selectedDay <= 7
                                ? dayLabels[selectedDay - 1]
                                : l10n.scheduleUnknown,
                            style: TextStyle(
                              fontSize: isPlayful ? 18 : 16,
                              fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: isPlayful ? 0.3 : 0,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            lessons.length == 1
                                ? l10n.scheduleLessonCount(lessons.length)
                                : l10n.scheduleLessonsCount(lessons.length),
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 13,
                              fontWeight: FontWeight.w400,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: error,
                    onRetry: () {
                      ref.invalidate(weekLessonsProvider);
                    },
                  ),
                )
              else if (lessons.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(
                    isWeekend: selectedDay > 5,
                    isPlayful: isPlayful,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: ResponsiveCenter(
                    maxWidth: 1200,
                    padding: AppSpacing.horizontalInsets,
                    child: Column(
                      children: List.generate(
                        lessons.length,
                        (index) {
                          final lesson = lessons[index];
                          return ScheduleLessonCard(
                            lesson: lesson,
                            isFirst: index == 0,
                            isLast: index == lessons.length - 1,
                            onTap: () {
                              showLessonDetailDialog(
                                context: context,
                                lesson: lesson,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

              // Bottom spacing
              SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget when no lessons are scheduled.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isWeekend,
    required this.isPlayful,
  });

  final bool isWeekend;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                isWeekend ? Icons.weekend_rounded : Icons.beach_access_rounded,
                size: isPlayful ? 56 : AppIconSize.xxl,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              isWeekend ? l10n.scheduleWeekend : l10n.scheduleNoLessons,
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              isWeekend
                  ? l10n.scheduleEnjoyTimeOff
                  : l10n.scheduleFreeDay,
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
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
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              l10n.dashboardSomethingWrong,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
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
