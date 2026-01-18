import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/app_localizations.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/shared/widgets/responsive_center.dart';

import '../../domain/entities/entities.dart';
import '../providers/deputy_provider.dart';
import '../widgets/widgets.dart';

/// Deputy Dashboard Page.
///
/// Features:
/// - Tab 1 "Overview": Stats and quick actions
/// - Tab 2 "Schedule Editor": Weekly schedule grid with class selector
/// - Tab 3 "Parent Onboarding": Students without parents, generate parent tokens
class DeputyDashboardPage extends ConsumerStatefulWidget {
  const DeputyDashboardPage({super.key});

  @override
  ConsumerState<DeputyDashboardPage> createState() =>
      _DeputyDashboardPageState();
}

class _DeputyDashboardPageState extends ConsumerState<DeputyDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schoolId = ref.read(authNotifierProvider).userSchoolId;
      if (schoolId != null) {
        ref.invalidate(deputyStatsProvider(schoolId));
        ref.invalidate(deputySchoolClassesProvider(schoolId));
        ref.invalidate(studentsWithoutParentsProvider(schoolId));
        ref.invalidate(pendingParentInvitesProvider(schoolId));
        ref.invalidate(schoolSubjectsProvider(schoolId));
      }
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
    final authState = ref.watch(authNotifierProvider);
    final schoolId = authState.userSchoolId;

    // Check if user has admin privileges
    if (!authState.hasAdminPrivileges) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.deputyPanel),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.accessDenied,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.noPermissionToAccessPage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Check if user has a school ID
    if (schoolId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.deputyPanel),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.noSchoolAssigned,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.notAssignedToSchool,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.deputyPanel),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard_outlined),
              text: context.l10n.overview,
            ),
            Tab(
              icon: const Icon(Icons.calendar_month_outlined),
              text: context.l10n.schedule,
            ),
            Tab(
              icon: const Icon(Icons.book_outlined),
              text: 'Subjects',
            ),
            Tab(
              icon: const Icon(Icons.family_restroom_outlined),
              text: context.l10n.parents,
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
            _OverviewTab(schoolId: schoolId, isPlayful: isPlayful, tabController: _tabController),
            ScheduleEditorTab(schoolId: schoolId, isPlayful: isPlayful),
            SubjectsManagementTab(schoolId: schoolId, isPlayful: isPlayful),
            ParentOnboardingTab(schoolId: schoolId, isPlayful: isPlayful),
          ],
        ),
      ),
    );
  }
}

/// Overview Tab - Stats and quick actions
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({
    required this.schoolId,
    required this.isPlayful,
    required this.tabController,
  });

  final String schoolId;
  final bool isPlayful;
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(deputyStatsProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(deputyStatsProvider(schoolId));
      },
      child: statsAsync.when(
        data: (stats) => ResponsiveCenterScrollView(
          maxWidth: 1000,
          padding: EdgeInsets.all(isPlayful ? 20 : 16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              _WelcomeCard(isPlayful: isPlayful),
              SizedBox(height: isPlayful ? 24 : 20),

              // Stats Grid
              Text(
                'Overview',
                style: TextStyle(
                  fontSize: isPlayful ? 20 : 18,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isPlayful ? 16 : 12),
              _StatsGrid(stats: stats, isPlayful: isPlayful),
              SizedBox(height: isPlayful ? 32 : 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: isPlayful ? 20 : 18,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: isPlayful ? 16 : 12),
              _QuickActionsGrid(isPlayful: isPlayful, tabController: tabController),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('Error loading stats: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(deputyStatsProvider(schoolId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: isPlayful ? 20 : 12,
            offset: Offset(0, isPlayful ? 8 : 4),
          ),
        ],
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
              Icons.admin_panel_settings_rounded,
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
                  'Deputy Panel',
                  style: TextStyle(
                    fontSize: isPlayful ? 24 : 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage schedules and parent onboarding',
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

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.stats,
    required this.isPlayful,
  });

  final DeputyStats stats;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: isPlayful ? 16 : 12,
      crossAxisSpacing: isPlayful ? 16 : 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          title: 'Total Lessons',
          value: stats.totalLessons.toString(),
          icon: Icons.calendar_today_rounded,
          color: Colors.blue,
          isPlayful: isPlayful,
        ),
        _StatCard(
          title: 'Classes',
          value: stats.totalClasses.toString(),
          icon: Icons.class_rounded,
          color: Colors.green,
          isPlayful: isPlayful,
        ),
        _StatCard(
          title: 'Without Parents',
          value: stats.studentsWithoutParents.toString(),
          icon: Icons.person_off_rounded,
          color: Colors.orange,
          isPlayful: isPlayful,
        ),
        _StatCard(
          title: 'Pending Invites',
          value: stats.pendingParentInvites.toString(),
          icon: Icons.mail_outline_rounded,
          color: Colors.purple,
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isPlayful,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 12 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: isPlayful ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: isPlayful ? 12 : 8,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
            ),
            child: Icon(icon, color: color, size: isPlayful ? 20 : 18),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isPlayful ? 24 : 20,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isPlayful ? 11 : 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends ConsumerWidget {
  const _QuickActionsGrid({
    required this.isPlayful,
    required this.tabController,
  });

  final bool isPlayful;
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: isPlayful ? 16 : 12,
      crossAxisSpacing: isPlayful ? 16 : 12,
      childAspectRatio: 2.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _QuickActionCard(
          title: 'Add Lesson',
          icon: Icons.add_circle_outline_rounded,
          color: Colors.blue,
          isPlayful: isPlayful,
          onTap: () {
            // Navigate to schedule editor
            tabController.animateTo(1);
          },
        ),
        _QuickActionCard(
          title: 'Add Subject',
          icon: Icons.book_outlined,
          color: Colors.purple,
          isPlayful: isPlayful,
          onTap: () {
            // Navigate to subjects management
            tabController.animateTo(2);
          },
        ),
        _QuickActionCard(
          title: 'Generate Invite',
          icon: Icons.person_add_alt_rounded,
          color: Colors.green,
          isPlayful: isPlayful,
          onTap: () {
            // Navigate to parent onboarding
            tabController.animateTo(3);
          },
        ),
        _QuickActionCard(
          title: 'Manage Classes',
          icon: Icons.group_rounded,
          color: Colors.orange,
          isPlayful: isPlayful,
          onTap: () {
            // Navigate to schedule editor (where class management is accessible)
            tabController.animateTo(1);
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isPlayful,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final bool isPlayful;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Container(
          padding: EdgeInsets.all(isPlayful ? 16 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            color: color.withValues(alpha: 0.1),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: isPlayful ? 28 : 24),
              SizedBox(width: isPlayful ? 12 : 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: color.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
