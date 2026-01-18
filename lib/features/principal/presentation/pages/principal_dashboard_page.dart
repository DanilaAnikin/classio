import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/localization/app_localizations.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import '../providers/principal_providers.dart';
import '../widgets/widgets.dart';
import 'overview_tab.dart';
import 'staff_management_tab.dart';
import 'class_management_tab.dart';
import 'invite_management_tab.dart';

/// Principal Dashboard Page for BigAdmin role.
///
/// Features:
/// - Tab 1 "Overview": School stats and quick actions
/// - Tab 2 "Staff Management": List admins/teachers, add button with invite
/// - Tab 3 "Class Management": List/create classes, assign head teachers
/// - Tab 4 "Invites": Generate/view tokens
///
/// Beautiful Material 3 design with pull to refresh support.
class PrincipalDashboardPage extends ConsumerStatefulWidget {
  const PrincipalDashboardPage({super.key});

  @override
  ConsumerState<PrincipalDashboardPage> createState() =>
      _PrincipalDashboardPageState();
}

class _PrincipalDashboardPageState extends ConsumerState<PrincipalDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      // Trigger rebuild when tab changes to update FAB
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final schoolId = ref.read(authNotifierProvider).userSchoolId;
      if (schoolId != null) {
        ref.invalidate(schoolStatsProvider(schoolId));
        ref.invalidate(schoolStaffProvider(schoolId));
        ref.invalidate(principalSchoolClassesProvider(schoolId));
        ref.invalidate(principalInviteCodesProvider(schoolId));
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

    // Check if user is a bigadmin
    if (!authState.isBigAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.principalDashboard),
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
          title: Text(context.l10n.principalDashboard),
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
        title: Text(context.l10n.principalDashboard),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard_outlined),
              text: context.l10n.overview,
            ),
            Tab(
              icon: const Icon(Icons.people_outline_rounded),
              text: context.l10n.staff,
            ),
            Tab(
              icon: const Icon(Icons.class_outlined),
              text: context.l10n.classes,
            ),
            Tab(
              icon: const Icon(Icons.vpn_key_outlined),
              text: context.l10n.invites,
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
            OverviewTab(
              schoolId: schoolId,
              isPlayful: isPlayful,
              onNavigateToTab: (index) => _tabController.animateTo(index),
            ),
            StaffManagementTab(schoolId: schoolId, isPlayful: isPlayful),
            ClassManagementTab(schoolId: schoolId, isPlayful: isPlayful),
            InviteManagementTab(schoolId: schoolId, isPlayful: isPlayful),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context, schoolId, isPlayful),
    );
  }

  Widget? _buildFAB(BuildContext context, String schoolId, bool isPlayful) {
    final theme = Theme.of(context);

    switch (_tabController.index) {
      case 1: // Staff tab - Invite Staff
        return FloatingActionButton.extended(
          heroTag: 'invite_staff_fab',
          onPressed: () => _showInviteStaffDialog(context, schoolId),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Invite Staff'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      case 2: // Classes tab - Create Class
        return FloatingActionButton.extended(
          heroTag: 'create_class_fab',
          onPressed: () => _showCreateClassDialog(context, schoolId),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Create Class'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      case 3: // Invites tab - Generate Invite
        return FloatingActionButton.extended(
          heroTag: 'generate_invite_fab',
          onPressed: () => _showGenerateInviteDialog(context, schoolId),
          icon: const Icon(Icons.vpn_key_rounded),
          label: const Text('Generate Invite'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        );
      default:
        return null;
    }
  }

  void _showInviteStaffDialog(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => GenerateStaffInviteDialog(schoolId: schoolId),
    );
  }

  void _showCreateClassDialog(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => CreateClassDialog(schoolId: schoolId),
    );
  }

  void _showGenerateInviteDialog(BuildContext context, String schoolId) {
    showDialog(
      context: context,
      builder: (context) => GenerateStaffInviteDialog(schoolId: schoolId),
    );
  }
}
