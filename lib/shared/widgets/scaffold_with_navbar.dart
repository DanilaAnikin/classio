import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/theme_provider.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

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

  /// Calculates the selected index based on the current route and user role.
  ///
  /// This method maps the current route to the correct index for the current
  /// role's navigation destinations. This is necessary because when roles change,
  /// the navigation shell's current index may be out of bounds for the new
  /// destinations list.
  int _calculateSelectedIndex(BuildContext context, UserRole? role) {
    final location = GoRouterState.of(context).uri.path;
    final routes = getRoutesForRole(role);

    // Find the index of the current route in the role's routes
    for (int i = 0; i < routes.length; i++) {
      if (location == routes[i] || location.startsWith('${routes[i]}/')) {
        return i;
      }
    }

    // Default to first tab if route not found
    return 0;
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

    final destinations = _getNavigationDestinations(
      userRole,
      isPlayful,
      context,
      theme,
    );

    // Calculate index based on current route and role
    final calculatedIndex = _calculateSelectedIndex(context, userRole);

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
          final routes = getRoutesForRole(userRole);
          if (index >= 0 && index < routes.length) {
            // Use context.go instead of navigationShell.goBranch for role-aware navigation
            context.go(routes[index]);
          }
        },
        destinations: destinations,
      ),
    );
  }

  /// Returns the list of route paths for a given user role.
  ///
  /// The routes are returned in the same order as the navigation tabs.
  static List<String> getRoutesForRole(UserRole? role) {
    switch (role) {
      case UserRole.superadmin:
        return ['/', '/superadmin', '/profile'];
      case UserRole.bigadmin:
      case UserRole.admin:
        return ['/', '/school_admin', '/profile'];
      case UserRole.teacher:
        return ['/schedule', '/teacher_dashboard', '/profile'];
      case UserRole.parent:
        return ['/', '/grades', '/profile'];
      case UserRole.student:
      case null:
        return ['/', '/schedule', '/grades', '/profile'];
    }
  }

  /// Returns the appropriate navigation destinations based on user role.
  ///
  /// The destinations are styled differently based on [isPlayful] theme setting.
  List<NavigationDestination> _getNavigationDestinations(
    UserRole? role,
    bool isPlayful,
    BuildContext context,
    ThemeData theme,
  ) {
    switch (role) {
      case UserRole.superadmin:
        return _buildSuperAdminDestinations(context, isPlayful, theme);
      case UserRole.bigadmin:
      case UserRole.admin:
        return _buildAdminDestinations(context, isPlayful, theme);
      case UserRole.teacher:
        return _buildTeacherDestinations(context, isPlayful, theme);
      case UserRole.parent:
        return _buildParentDestinations(context, isPlayful, theme);
      case UserRole.student:
      case null:
        return _buildStudentDestinations(context, isPlayful, theme);
    }
  }

  /// Builds navigation destinations for superadmin users.
  /// Tabs: Global Dashboard, Schools, Profile
  List<NavigationDestination> _buildSuperAdminDestinations(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    return [
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.dashboard_rounded : Icons.dashboard_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.dashboard_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getGlobalDashboardLabel(context),
        tooltip: _getGlobalDashboardLabel(context),
      ),
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.school_rounded : Icons.school_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.school_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getSchoolsLabel(context),
        tooltip: _getSchoolsLabel(context),
      ),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for bigadmin and admin users.
  /// Tabs: School Dashboard, Users/Classes, Profile
  List<NavigationDestination> _buildAdminDestinations(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    return [
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.dashboard_rounded : Icons.dashboard_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.dashboard_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getSchoolDashboardLabel(context),
        tooltip: _getSchoolDashboardLabel(context),
      ),
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.people_rounded : Icons.people_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.people_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getUsersClassesLabel(context),
        tooltip: _getUsersClassesLabel(context),
      ),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for teacher users.
  /// Tabs: Schedule, My Subjects, Profile
  List<NavigationDestination> _buildTeacherDestinations(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    return [
      NavigationDestination(
        icon: Icon(
          isPlayful
              ? Icons.calendar_today_rounded
              : Icons.calendar_today_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.calendar_today_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getScheduleLabel(context),
        tooltip: _getScheduleLabel(context),
      ),
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.book_rounded : Icons.book_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.book_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getMySubjectsLabel(context),
        tooltip: _getMySubjectsLabel(context),
      ),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for student users (default).
  /// Tabs: Home, Schedule, Grades, Profile
  List<NavigationDestination> _buildStudentDestinations(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    return [
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.home_rounded : Icons.home_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.home_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getHomeLabel(context),
        tooltip: _getHomeLabel(context),
      ),
      NavigationDestination(
        icon: Icon(
          isPlayful
              ? Icons.calendar_today_rounded
              : Icons.calendar_today_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.calendar_today_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getScheduleLabel(context),
        tooltip: _getScheduleLabel(context),
      ),
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.assessment_rounded : Icons.assessment_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.assessment_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getGradesLabel(context),
        tooltip: _getGradesLabel(context),
      ),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for parent users.
  /// Tabs: Children, Grades, Profile
  List<NavigationDestination> _buildParentDestinations(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    return [
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.child_care_rounded : Icons.child_care_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.child_care_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getChildrenLabel(context),
        tooltip: _getChildrenLabel(context),
      ),
      NavigationDestination(
        icon: Icon(
          isPlayful ? Icons.assessment_rounded : Icons.assessment_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
        selectedIcon: Icon(
          Icons.assessment_rounded,
          color: theme.colorScheme.primary,
        ),
        label: _getGradesLabel(context),
        tooltip: _getGradesLabel(context),
      ),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds the Profile navigation destination (shared across all roles).
  NavigationDestination _buildProfileDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.person_rounded : Icons.person_outline,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.person_rounded,
        color: theme.colorScheme.primary,
      ),
      label: _getProfileLabel(context),
      tooltip: _getProfileLabel(context),
    );
  }

  // ============ Localized Label Methods ============

  /// Returns the localized label for the Home tab.
  String _getHomeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.home;
  }

  /// Returns the localized label for the Schedule tab.
  String _getScheduleLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Rozvrh';
      case 'de':
        return 'Stundenplan';
      case 'es':
        return 'Horario';
      case 'fr':
        return 'Emploi du temps';
      case 'it':
        return 'Orario';
      case 'pl':
        return 'Plan zajec';
      case 'ru':
        return 'Raspisanie';
      default:
        return 'Schedule';
    }
  }

  /// Returns the localized label for the Grades tab.
  String _getGradesLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Znamky';
      case 'de':
        return 'Noten';
      case 'es':
        return 'Notas';
      case 'fr':
        return 'Notes';
      case 'it':
        return 'Voti';
      case 'pl':
        return 'Oceny';
      case 'ru':
        return 'Ocenki';
      default:
        return 'Grades';
    }
  }

  /// Returns the localized label for the Profile tab.
  String _getProfileLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Profil';
      case 'de':
        return 'Profil';
      case 'es':
        return 'Perfil';
      case 'fr':
        return 'Profil';
      case 'it':
        return 'Profilo';
      case 'pl':
        return 'Profil';
      case 'ru':
        return 'Profil';
      default:
        return 'Profile';
    }
  }

  /// Returns the localized label for the Global Dashboard tab (superadmin).
  String _getGlobalDashboardLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Prehled';
      case 'de':
        return 'Dashboard';
      case 'es':
        return 'Panel';
      case 'fr':
        return 'Tableau de bord';
      case 'it':
        return 'Dashboard';
      case 'pl':
        return 'Panel';
      case 'ru':
        return 'Panel';
      default:
        return 'Dashboard';
    }
  }

  /// Returns the localized label for the Schools tab (superadmin).
  String _getSchoolsLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Skoly';
      case 'de':
        return 'Schulen';
      case 'es':
        return 'Escuelas';
      case 'fr':
        return 'Ecoles';
      case 'it':
        return 'Scuole';
      case 'pl':
        return 'Szkoly';
      case 'ru':
        return 'Shkoly';
      default:
        return 'Schools';
    }
  }

  /// Returns the localized label for the School Dashboard tab (admin).
  String _getSchoolDashboardLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Prehled';
      case 'de':
        return 'Dashboard';
      case 'es':
        return 'Panel';
      case 'fr':
        return 'Tableau de bord';
      case 'it':
        return 'Dashboard';
      case 'pl':
        return 'Panel';
      case 'ru':
        return 'Panel';
      default:
        return 'Dashboard';
    }
  }

  /// Returns the localized label for the Users/Classes tab (admin).
  String _getUsersClassesLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Sprava';
      case 'de':
        return 'Verwaltung';
      case 'es':
        return 'Gestion';
      case 'fr':
        return 'Gestion';
      case 'it':
        return 'Gestione';
      case 'pl':
        return 'Zarzadzanie';
      case 'ru':
        return 'Upravlenie';
      default:
        return 'Manage';
    }
  }

  /// Returns the localized label for the My Subjects tab (teacher).
  String _getMySubjectsLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Predmety';
      case 'de':
        return 'Facher';
      case 'es':
        return 'Materias';
      case 'fr':
        return 'Matieres';
      case 'it':
        return 'Materie';
      case 'pl':
        return 'Przedmioty';
      case 'ru':
        return 'Predmety';
      default:
        return 'Subjects';
    }
  }

  /// Returns the localized label for the Children tab (parent).
  String _getChildrenLabel(BuildContext context) {
    final locale = Localizations.localeOf(context);
    switch (locale.languageCode) {
      case 'cs':
        return 'Deti';
      case 'de':
        return 'Kinder';
      case 'es':
        return 'Hijos';
      case 'fr':
        return 'Enfants';
      case 'it':
        return 'Figli';
      case 'pl':
        return 'Dzieci';
      case 'ru':
        return 'Deti';
      default:
        return 'Children';
    }
  }
}
