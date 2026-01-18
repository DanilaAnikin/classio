import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../student/domain/entities/entities.dart';
import '../providers/parent_provider.dart';

/// Parent Dashboard Page.
///
/// Shows list of children with quick access to their information,
/// attendance summaries, and recent activity.
class ParentDashboardPage extends ConsumerStatefulWidget {
  const ParentDashboardPage({super.key});

  @override
  ConsumerState<ParentDashboardPage> createState() => _ParentDashboardPageState();
}

class _ParentDashboardPageState extends ConsumerState<ParentDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(myChildrenProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final childrenAsync = ref.watch(myChildrenProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parent Dashboard',
          style: TextStyle(
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myChildrenProvider);
        },
        child: ResponsiveCenterScrollView(
          maxWidth: 800,
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              _WelcomeCard(isPlayful: isPlayful),
              SizedBox(height: isPlayful ? 16 : 12),

              // Quick Actions Row
              _QuickAccessRow(isPlayful: isPlayful),
              SizedBox(height: isPlayful ? 24 : 20),

              // My Children Section
              Text(
                'My Children',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isPlayful ? 12 : 8),

              // Children List
              childrenAsync.when(
                data: (children) => children.isEmpty
                    ? _EmptyChildrenCard(isPlayful: isPlayful)
                    : Column(
                        children: children
                            .map((child) => _ChildCard(
                                  child: child,
                                  isPlayful: isPlayful,
                                ))
                            .toList(),
                      ),
                loading: () => _LoadingCard(isPlayful: isPlayful),
                error: (e, _) => _ErrorCard(
                  message: 'Failed to load children: $e',
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

/// Welcome card for parent dashboard.
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
              Icons.family_restroom_rounded,
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
                  'Monitor your children\'s progress',
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
    );
  }
}

/// Card displaying a child with quick actions and summary.
class _ChildCard extends ConsumerWidget {
  const _ChildCard({
    required this.child,
    required this.isPlayful,
  });

  final AppUser child;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final attendanceStats = ref.watch(childAttendanceStatsProvider(child.id));

    return Card(
      elevation: isPlayful ? 2 : 0,
      margin: EdgeInsets.only(bottom: isPlayful ? 16 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => context.push('/parent/child/${child.id}'),
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 16),
        child: Padding(
          padding: EdgeInsets.all(isPlayful ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Info Row
              Row(
                children: [
                  Container(
                    width: isPlayful ? 56 : 48,
                    height: isPlayful ? 56 : 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(child.fullName),
                        style: TextStyle(
                          fontSize: isPlayful ? 18 : 16,
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
                          style: TextStyle(
                            fontSize: isPlayful ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          child.email ?? '',
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: isPlayful ? 28 : 24,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ],
              ),
              SizedBox(height: isPlayful ? 16 : 12),

              // Attendance Summary
              attendanceStats.when(
                data: (stats) => _AttendanceSummaryRow(
                  stats: stats,
                  isPlayful: isPlayful,
                ),
                loading: () => _LoadingRow(isPlayful: isPlayful),
                error: (_, _) => const SizedBox.shrink(),
              ),
              SizedBox(height: isPlayful ? 16 : 12),

              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.grade_rounded,
                      label: 'Grades',
                      color: Colors.blue,
                      onTap: () => context.push('/parent/child/${child.id}/grades'),
                      isPlayful: isPlayful,
                    ),
                  ),
                  SizedBox(width: isPlayful ? 12 : 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.fact_check_rounded,
                      label: 'Attendance',
                      color: Colors.green,
                      onTap: () => context.push('/parent/child/${child.id}/attendance'),
                      isPlayful: isPlayful,
                    ),
                  ),
                  SizedBox(width: isPlayful ? 12 : 8),
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.calendar_month_rounded,
                      label: 'Schedule',
                      color: Colors.orange,
                      onTap: () => context.push('/parent/child/${child.id}/schedule'),
                      isPlayful: isPlayful,
                    ),
                  ),
                ],
              ),
            ],
          ),
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

/// Attendance summary row showing compact stats.
class _AttendanceSummaryRow extends StatelessWidget {
  const _AttendanceSummaryRow({
    required this.stats,
    required this.isPlayful,
  });

  final AttendanceStats stats;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 12 : 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pie_chart_rounded,
            size: isPlayful ? 20 : 18,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: isPlayful ? 10 : 8),
          Text(
            'Attendance: ',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            '${stats.attendancePercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              fontWeight: FontWeight.w700,
              color: stats.percentageColor,
            ),
          ),
          const Spacer(),
          _StatChip(
            value: stats.presentDays,
            color: AttendanceStatus.present.color,
            isPlayful: isPlayful,
          ),
          SizedBox(width: isPlayful ? 8 : 6),
          _StatChip(
            value: stats.absentDays,
            color: AttendanceStatus.absent.color,
            isPlayful: isPlayful,
          ),
          SizedBox(width: isPlayful ? 8 : 6),
          _StatChip(
            value: stats.lateDays,
            color: AttendanceStatus.late.color,
            isPlayful: isPlayful,
          ),
        ],
      ),
    );
  }
}

/// Small chip showing a stat value.
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final int value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 8 : 6,
        vertical: isPlayful ? 4 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          fontSize: isPlayful ? 12 : 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Quick action button for child card.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isPlayful ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: isPlayful ? 24 : 20,
              color: color,
            ),
            SizedBox(height: isPlayful ? 6 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isPlayful ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading row placeholder.
class _LoadingRow extends StatelessWidget {
  const _LoadingRow({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 12 : 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading stats...',
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty children card placeholder.
class _EmptyChildrenCard extends ConsumerWidget {
  const _EmptyChildrenCard({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Icons.child_care_outlined,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No children linked yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you just registered using a parent invite code, '
              'your child should appear here shortly. Try pulling down to refresh.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                ref.invalidate(myChildrenProvider);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: isPlayful ? 20 : 18),
                  const SizedBox(width: 8),
                  const Text('Refresh'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'If the issue persists, contact your school administrator.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
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

/// Quick access row for parent dashboard with navigation to timetable.
class _QuickAccessRow extends StatelessWidget {
  const _QuickAccessRow({required this.isPlayful});

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
      child: InkWell(
        onTap: () => context.push('/parent/timetable'),
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isPlayful ? 16 : 14),
          child: Row(
            children: [
              Container(
                width: isPlayful ? 48 : 40,
                height: isPlayful ? 48 : 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                ),
                child: Icon(
                  Icons.calendar_view_week_rounded,
                  size: isPlayful ? 26 : 22,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: isPlayful ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Timetable',
                      style: TextStyle(
                        fontSize: isPlayful ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'View your child\'s full weekly schedule',
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: isPlayful ? 18 : 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
