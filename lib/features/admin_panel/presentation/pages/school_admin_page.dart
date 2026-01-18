import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/app_localizations.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/admin_providers.dart';

/// School Admin Page for bigadmin/admin roles.
///
/// Features:
/// - Tab 1 "Users": List of Teachers/Students in their school
/// - Tab 2 "Classes": List of Classes (e.g., 3.B)
/// - FAB for generating invite codes (Users tab) or creating classes (Classes tab)
class SchoolAdminPage extends ConsumerStatefulWidget {
  const SchoolAdminPage({super.key});

  @override
  ConsumerState<SchoolAdminPage> createState() => _SchoolAdminPageState();
}

class _SchoolAdminPageState extends ConsumerState<SchoolAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Trigger rebuild when tab changes to update FAB
      if (!_tabController.indexIsChanging) {
        setState(() {});
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
          title: Text(context.l10n.schoolAdmin),
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

    // Check if user has a school ID (superadmin might not have one)
    if (schoolId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.schoolAdmin),
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
        title: Text(context.l10n.schoolAdmin),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people_outline_rounded),
              text: context.l10n.users,
            ),
            Tab(
              icon: const Icon(Icons.class_outlined),
              text: context.l10n.classes,
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
            _UsersTab(schoolId: schoolId, isPlayful: isPlayful),
            _ClassesTab(schoolId: schoolId, isPlayful: isPlayful),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, schoolId, isPlayful),
    );
  }

  Widget? _buildFAB(BuildContext context, String schoolId, bool isPlayful) {
    final theme = Theme.of(context);

    if (_tabController.index == 0) {
      // Users tab - Generate Invite Code
      return FloatingActionButton.extended(
        onPressed: () => _showGenerateInviteCodeDialog(context, schoolId),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(context.l10n.generateInvite),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      );
    } else {
      // Classes tab - Create Class
      return FloatingActionButton.extended(
        onPressed: () => _showCreateClassDialog(context, schoolId),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.createClass),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      );
    }
  }

  void _showGenerateInviteCodeDialog(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => _GenerateInviteCodeDialog(schoolId: schoolId),
    );
  }

  void _showCreateClassDialog(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => _CreateClassDialog(schoolId: schoolId),
    );
  }
}

/// Users Tab - Displays list of users in the school
class _UsersTab extends ConsumerWidget {
  const _UsersTab({
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(schoolUsersProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schoolUsersProvider(schoolId));
      },
      child: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Group users by role
          final teachers = users.where((u) => u.isTeacher).toList();
          final students = users.where((u) => u.isStudent).toList();
          final parents = users.where((u) => u.isParent).toList();
          final admins = users.where((u) => u.isAdmin || u.isBigAdmin).toList();

          return ResponsiveCenterScrollView(
            maxWidth: 1000,
            padding: EdgeInsets.all(isPlayful ? 16 : 12),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Card
                _UserStatsCard(
                  totalUsers: users.length,
                  teacherCount: teachers.length,
                  studentCount: students.length,
                  parentCount: parents.length,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Admins Section
                if (admins.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Administrators',
                    icon: Icons.admin_panel_settings_outlined,
                    count: admins.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...admins.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: _UserCard(user: user, isPlayful: isPlayful),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Teachers Section
                if (teachers.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Teachers',
                    icon: Icons.school_outlined,
                    count: teachers.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...teachers.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: _UserCard(user: user, isPlayful: isPlayful),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Students Section
                if (students.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Students',
                    icon: Icons.person_outline_rounded,
                    count: students.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...students.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: _UserCard(user: user, isPlayful: isPlayful),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Parents Section
                if (parents.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Parents',
                    icon: Icons.family_restroom_outlined,
                    count: parents.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...parents.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: _UserCard(user: user, isPlayful: isPlayful),
                      )),
                ],

                SizedBox(height: isPlayful ? 80 : 72), // Space for FAB
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 24 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Users Yet',
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate invite codes to add users to your school.',
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

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(schoolUsersProvider(schoolId));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Classes Tab - Displays list of classes in the school
class _ClassesTab extends ConsumerWidget {
  const _ClassesTab({
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(schoolClassesProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schoolClassesProvider(schoolId));
      },
      child: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Group classes by grade level
          final groupedClasses = <int, List<ClassInfo>>{};
          for (final schoolClass in classes) {
            final gradeLevel = schoolClass.gradeLevel ?? 0;
            groupedClasses.putIfAbsent(gradeLevel, () => []);
            groupedClasses[gradeLevel]!.add(schoolClass);
          }

          // Sort grade levels
          final sortedGrades = groupedClasses.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          return ResponsiveCenterScrollView(
            maxWidth: 1000,
            padding: EdgeInsets.all(isPlayful ? 16 : 12),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Card
                _ClassStatsCard(
                  totalClasses: classes.length,
                  gradeCount: groupedClasses.length,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Classes by Grade
                ...sortedGrades.expand((grade) => [
                      _SectionHeader(
                        title: 'Grade $grade',
                        icon: Icons.school_outlined,
                        count: groupedClasses[grade]!.length,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: isPlayful ? 12 : 8),
                      ...groupedClasses[grade]!.map((schoolClass) => Padding(
                            padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                            child: _ClassCard(
                              schoolClass: schoolClass,
                              isPlayful: isPlayful,
                            ),
                          )),
                      SizedBox(height: isPlayful ? 16 : 12),
                    ]),

                SizedBox(height: isPlayful ? 80 : 72), // Space for FAB
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 24 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.class_outlined,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Classes Yet',
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create classes to organize your students.',
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

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(schoolClassesProvider(schoolId));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.isPlayful,
  });

  final String title;
  final IconData icon;
  final int count;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: isPlayful ? 22 : 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.3 : -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 10 : 8,
            vertical: isPlayful ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// User stats card
class _UserStatsCard extends StatelessWidget {
  const _UserStatsCard({
    required this.totalUsers,
    required this.teacherCount,
    required this.studentCount,
    required this.parentCount,
    required this.isPlayful,
  });

  final int totalUsers;
  final int teacherCount;
  final int studentCount;
  final int parentCount;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.groups_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Users',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalUsers.toString(),
                  style: TextStyle(
                    fontSize: isPlayful ? 28 : 24,
                    fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatBadge(
                label: 'Teachers',
                count: teacherCount,
                color: Colors.blue,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              _StatBadge(
                label: 'Students',
                count: studentCount,
                color: Colors.green,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              _StatBadge(
                label: 'Parents',
                count: parentCount,
                color: Colors.orange,
                isPlayful: isPlayful,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small stat badge
class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final int count;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count ',
          style: TextStyle(
            fontSize: isPlayful ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 12 : 11,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Class stats card
class _ClassStatsCard extends StatelessWidget {
  const _ClassStatsCard({
    required this.totalClasses,
    required this.gradeCount,
    required this.isPlayful,
  });

  final int totalClasses;
  final int gradeCount;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.class_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Classes',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalClasses.toString(),
                  style: TextStyle(
                    fontSize: isPlayful ? 28 : 24,
                    fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 14 : 12,
              vertical: isPlayful ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
            child: Text(
              '$gradeCount Grades',
              style: TextStyle(
                fontSize: isPlayful ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// User card widget
class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.isPlayful,
  });

  final AppUser user;
  final bool isPlayful;

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return Colors.purple;
      case UserRole.bigadmin:
        return Colors.deepPurple;
      case UserRole.admin:
        return Colors.indigo;
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      case UserRole.parent:
        return Colors.orange;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Big Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String _getInitials(AppUser user) {
    if (user.firstName != null && user.lastName != null) {
      return '${user.firstName![0]}${user.lastName![0]}'.toUpperCase();
    } else if (user.firstName != null) {
      return user.firstName![0].toUpperCase();
    }
    return (user.email ?? 'U')[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(user.role);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? roleColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isPlayful ? 48 : 42,
            height: isPlayful ? 48 : 42,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(user),
                style: TextStyle(
                  fontSize: isPlayful ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? 14 : 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 15,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Role Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 12 : 10,
              vertical: isPlayful ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
            ),
            child: Text(
              _getRoleLabel(user.role),
              style: TextStyle(
                fontSize: isPlayful ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Class card widget
class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.schoolClass,
    required this.isPlayful,
  });

  final ClassInfo schoolClass;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Class Icon
          Container(
            width: isPlayful ? 48 : 42,
            height: isPlayful ? 48 : 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
            ),
            child: Center(
              child: Text(
                schoolClass.name,
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 14,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? 14 : 12),

          // Class Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Class ${schoolClass.name}',
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 15,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                if (schoolClass.gradeLevel != null)
                  Text(
                    'Grade ${schoolClass.gradeLevel}',
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),

          // Academic Year Badge
          if (schoolClass.academicYear != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 12 : 10,
                vertical: isPlayful ? 6 : 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
              ),
              child: Text(
                schoolClass.academicYear!,
                style: TextStyle(
                  fontSize: isPlayful ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog for generating invite codes
class _GenerateInviteCodeDialog extends ConsumerStatefulWidget {
  const _GenerateInviteCodeDialog({required this.schoolId});

  final String schoolId;

  @override
  ConsumerState<_GenerateInviteCodeDialog> createState() =>
      _GenerateInviteCodeDialogState();
}

class _GenerateInviteCodeDialogState
    extends ConsumerState<_GenerateInviteCodeDialog> {
  UserRole _selectedRole = UserRole.student;
  final _usageLimitController = TextEditingController(text: '1');
  String? _generatedCode;
  bool _isGenerating = false;

  @override
  void dispose() {
    _usageLimitController.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final usageLimit = int.tryParse(_usageLimitController.text) ?? 1;

      final inviteCode = await ref.read(adminNotifierProvider.notifier).generateInviteCode(
        schoolId: widget.schoolId,
        role: _selectedRole,
        usageLimit: usageLimit,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      if (mounted) {
        if (inviteCode != null) {
          setState(() {
            _generatedCode = inviteCode.code;
            _isGenerating = false;
          });
        } else {
          // Check for error in admin state
          final adminState = ref.read(adminNotifierProvider);
          setState(() {
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminState.errorMessage ?? 'Failed to generate invite code'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.vpn_key_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Generate Invite Code',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Role Dropdown
            Text(
              'Role',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UserRole>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              isExpanded: true,
              items: [UserRole.teacher, UserRole.student, UserRole.parent]
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.name[0].toUpperCase() +
                            role.name.substring(1)),
                      ))
                  .toList(),
              initialValue: _selectedRole,
              onChanged: _generatedCode == null
                  ? (value) {
                      if (value != null) {
                        setState(() {
                          _selectedRole = value;
                        });
                      }
                    }
                  : null,
            ),
            const SizedBox(height: 16),

            // Usage Limit Input
            Text(
              'Usage Limit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usageLimitController,
              enabled: _generatedCode == null,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Number of times this code can be used',
              ),
            ),
            const SizedBox(height: 24),

            // Generated Code Display
            if (_generatedCode != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Invite Code',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _generatedCode!,
                      style: TextStyle(
                        fontSize: isPlayful ? 24 : 22,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_generatedCode != null ? 'Done' : 'Cancel'),
        ),
        if (_generatedCode == null)
          FilledButton(
            onPressed: _isGenerating ? null : _generateCode,
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Generate'),
          ),
      ],
    );
  }
}

/// Dialog for creating a new class
class _CreateClassDialog extends ConsumerStatefulWidget {
  const _CreateClassDialog({required this.schoolId});

  final String schoolId;

  @override
  ConsumerState<_CreateClassDialog> createState() => _CreateClassDialogState();
}

class _CreateClassDialogState extends ConsumerState<_CreateClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  final _academicYearController = TextEditingController(
    text: '${DateTime.now().year}/${DateTime.now().year + 1}',
  );
  bool _isCreating = false;

  @override
  void dispose() {
    _classNameController.dispose();
    _gradeLevelController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  Future<void> _createClass() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final gradeLevel = int.tryParse(_gradeLevelController.text) ?? 1;

      final classInfo = await ref.read(adminNotifierProvider.notifier).createClass(
        schoolId: widget.schoolId,
        name: _classNameController.text.trim(),
        gradeLevel: gradeLevel,
        academicYear: _academicYearController.text.trim(),
      );

      if (mounted) {
        if (classInfo != null) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Class "${_classNameController.text}" created'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Check for error in admin state
          final adminState = ref.read(adminNotifierProvider);
          setState(() {
            _isCreating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adminState.errorMessage ?? 'Failed to create class'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.class_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          const Text('Create Class'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Class Name Input
              Text(
                'Class Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _classNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'e.g., 3.B, 4.A',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Grade Level Input
              Text(
                'Grade Level',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gradeLevelController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'e.g., 3, 4, 5',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a grade level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Academic Year Input
              Text(
                'Academic Year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _academicYearController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'e.g., 2025/2026',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an academic year';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isCreating ? null : _createClass,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}
