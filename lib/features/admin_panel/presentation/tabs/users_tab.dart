import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/theme/spacing.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../providers/admin_providers.dart';
import '../widgets/widgets.dart';

/// Users Tab - Displays list of users in the school.
class UsersTab extends ConsumerWidget {
  const UsersTab({
    super.key,
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
                UserStatsCard(
                  totalUsers: users.length,
                  teacherCount: teachers.length,
                  studentCount: students.length,
                  parentCount: parents.length,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Admins Section
                if (admins.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Administrators',
                    icon: Icons.admin_panel_settings_outlined,
                    count: admins.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...admins.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: UserCard(user: user, isPlayful: isPlayful),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Teachers Section
                if (teachers.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Teachers',
                    icon: Icons.school_outlined,
                    count: teachers.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...teachers.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: UserCard(user: user, isPlayful: isPlayful),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Students Section
                if (students.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Students',
                    icon: Icons.person_outline_rounded,
                    count: students.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...students.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: UserCard(user: user, isPlayful: isPlayful),
                      )),
                  SizedBox(height: isPlayful ? 16 : 12),
                ],

                // Parents Section
                if (parents.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Parents',
                    icon: Icons.family_restroom_outlined,
                    count: parents.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 12 : 8),
                  ...parents.map((user) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                        child: UserCard(user: user, isPlayful: isPlayful),
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
        padding: EdgeInsets.all(AppSpacing.xxl),
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
            SizedBox(height: AppSpacing.xl),
            Text(
              'No Users Yet',
              style: TextStyle(
                fontSize: isPlayful ? 22 : 20,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
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
        padding: AppSpacing.dialogInsets,
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
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
