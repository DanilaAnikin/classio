import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/app_localizations.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import '../dialogs/dialogs.dart';
import '../tabs/tabs.dart';

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
      return _buildAccessDeniedScaffold(context, theme);
    }

    // Check if user has a school ID (superadmin might not have one)
    if (schoolId == null) {
      return _buildNoSchoolScaffold(context, theme);
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
            UsersTab(schoolId: schoolId, isPlayful: isPlayful),
            ClassesTab(schoolId: schoolId, isPlayful: isPlayful),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, schoolId, isPlayful),
    );
  }

  Widget _buildAccessDeniedScaffold(BuildContext context, ThemeData theme) {
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

  Widget _buildNoSchoolScaffold(BuildContext context, ThemeData theme) {
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
      builder: (context) => GenerateInviteCodeDialog(schoolId: schoolId),
    );
  }

  void _showCreateClassDialog(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => CreateClassDialog(schoolId: schoolId),
    );
  }
}
