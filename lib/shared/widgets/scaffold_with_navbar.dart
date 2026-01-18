import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/theme_provider.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'navigation_config.dart';
import 'navigation_destinations.dart';

/// A scaffold widget that wraps the main app content with a bottom navigation bar.
///
/// This widget is designed to be used with go_router's StatefulNavigationShell
/// to manage navigation between the main app sections.
///
/// The appearance adapts based on the current theme:
/// - **Clean Mode**: Subtle, professional styling with outlined icons
/// - **Playful Mode**: Colorful, engaging styling with filled icons
///
/// Navigation tabs are dynamic based on user role:
/// - **superadmin**: Global Dashboard, Schools, Profile
/// - **bigadmin/admin**: School Dashboard, Users/Classes, Profile
/// - **teacher**: Schedule, My Subjects, Profile
/// - **student**: Home, Schedule, Grades, Profile
/// - **parent**: Children, Grades, Profile
class ScaffoldWithNavBar extends ConsumerWidget {
  /// Creates a scaffold with navigation bar.
  ///
  /// The [navigationShell] parameter is required and comes from go_router's
  /// StatefulShellRoute configuration.
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  /// The navigation shell from go_router that manages the current route state.
  final StatefulNavigationShell navigationShell;

  /// Calculates the selected index based on the current branch and user role.
  ///
  /// This method maps the navigation shell's current branch index to the correct
  /// index for the current role's navigation destinations. This is necessary
  /// because the shell has many branches but each role only uses a subset.
  int _calculateSelectedIndex(UserRole? role) {
    // Get the current branch index from the navigation shell
    final currentBranch = navigationShell.currentIndex;
    final branchIndices = NavigationConfig.getBranchIndicesForRole(role);

    // Find which tab index corresponds to the current branch
    final tabIndex = branchIndices.indexOf(currentBranch);

    // If current branch is found in role's branches, return its tab index
    // Otherwise default to first tab
    return tabIndex >= 0 ? tabIndex : 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlayful = ref.watch(isPlayfulThemeProvider);
    final userRole = ref.watch(currentUserRoleProvider);
    final theme = Theme.of(context);

    // Add loading state check - if auth is still loading, show loading indicator
    final authState = ref.watch(authNotifierProvider);
    if (authState.isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final destinations = NavigationDestinationsBuilder.buildForRole(
      userRole,
      context,
      isPlayful,
      theme,
      ref,
    );

    // Calculate index based on current branch and role
    final calculatedIndex = _calculateSelectedIndex(userRole);

    // Clamp the index to be safe - prevent out of bounds
    final safeIndex =
        (calculatedIndex >= 0 && calculatedIndex < destinations.length)
            ? calculatedIndex
            : 0;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex, // Use safe index instead of navigationShell.currentIndex
        onDestinationSelected: (index) {
          final branchIndices = NavigationConfig.getBranchIndicesForRole(userRole);
          if (index >= 0 && index < branchIndices.length) {
            // Use navigationShell.goBranch for proper shell state synchronization
            // This ensures the IndexedStack shows the correct child widget
            navigationShell.goBranch(
              branchIndices[index],
              initialLocation: true,
            );
          }
        },
        destinations: destinations,
      ),
    );
  }

  /// Returns the list of route paths for a given user role.
  ///
  /// The routes are returned in the same order as the navigation tabs.
  /// This is a convenience wrapper around NavigationConfig.getRoutesForRole().
  static List<String> getRoutesForRole(UserRole? role) {
    return NavigationConfig.getRoutesForRole(role);
  }

  /// Returns the list of branch indices for a given user role.
  ///
  /// These indices correspond to the branches in StatefulShellRoute.indexedStack
  /// defined in app_router.dart. The order matches getRoutesForRole().
  /// This is a convenience wrapper around NavigationConfig.getBranchIndicesForRole().
  static List<int> getBranchIndicesForRole(UserRole? role) {
    return NavigationConfig.getBranchIndicesForRole(role);
  }
}
