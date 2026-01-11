import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin/admin.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/grades/grades.dart';
import '../../features/profile/profile.dart';
import '../../features/schedule/schedule.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/subject_detail/subject_detail.dart';
import '../../shared/widgets/scaffold_with_navbar.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// A custom [Listenable] that notifies GoRouter when auth state changes.
///
/// This allows GoRouter to re-evaluate redirects when the user logs in or out.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Provides the [GoRouter] instance for the application.
///
/// This provider creates and configures the router with all routes,
/// transitions, and error handling. It can access other providers
/// if needed (e.g., for auth state-based redirects).
///
/// Usage in MaterialApp:
/// ```dart
/// MaterialApp.router(
///   routerConfig: ref.watch(goRouterProvider),
/// )
/// ```
@riverpod
GoRouter goRouter(Ref ref) {
  // Create a stream controller for auth state changes
  final streamController = StreamController<AuthState>();

  // Listen to auth state changes and add to stream
  ref.listen(authNotifierProvider, (previous, next) {
    streamController.add(next);
  });

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: kDebugMode,
    routes: _routes,
    errorBuilder: _errorBuilder,
    refreshListenable: GoRouterRefreshStream(streamController.stream),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      // After successful auth, redirect based on role
      if (isAuthenticated && state.matchedLocation == AppRoutes.auth) {
        final userRole = ref.read(currentUserRoleProvider);
        switch (userRole) {
          case UserRole.superadmin:
            return AppRoutes.superadmin;
          case UserRole.bigadmin:
          case UserRole.admin:
            return AppRoutes.schoolAdmin;
          case UserRole.teacher:
            return AppRoutes.teacherDashboard;
          default:
            return AppRoutes.home;
        }
      }

      // Role-based restrictions (only check if authenticated)
      if (isAuthenticated) {
        final userRole = ref.read(currentUserRoleProvider);

        // SuperAdmin route protection
        if (state.matchedLocation == AppRoutes.superadmin &&
            userRole != UserRole.superadmin) {
          return AppRoutes.home;
        }

        // Legacy: Superadmin restrictions - only superadmin can access /schools
        if (state.matchedLocation == AppRoutes.schools &&
            userRole != UserRole.superadmin) {
          return AppRoutes.home;
        }

        // School Admin route protection
        if (state.matchedLocation == AppRoutes.schoolAdmin &&
            userRole != UserRole.admin &&
            userRole != UserRole.bigadmin &&
            userRole != UserRole.superadmin) {
          return AppRoutes.home;
        }

        // Teacher Dashboard route protection
        if (state.matchedLocation == AppRoutes.teacherDashboard &&
            userRole != UserRole.teacher) {
          return AppRoutes.home;
        }

        // Legacy: Teacher restrictions - only teachers can access /teacher
        if (state.matchedLocation == AppRoutes.teacher &&
            userRole != UserRole.teacher) {
          return AppRoutes.home;
        }

        // Student trying to access admin routes
        if (userRole == UserRole.student &&
            (state.matchedLocation.startsWith('/admin') ||
                state.matchedLocation.startsWith('/school') ||
                state.matchedLocation.startsWith('/teacher') ||
                state.matchedLocation.startsWith('/superadmin'))) {
          return AppRoutes.home;
        }
      }

      return null; // No redirect needed
    },
  );
}

/// All application routes.
///
/// Uses [StatefulShellRoute.indexedStack] for bottom navigation to preserve
/// state across tabs. The auth route is kept outside the shell as it's a
/// separate full-screen page.
final List<RouteBase> _routes = [
  // Subject detail route - top-level route for viewing subject details
  GoRoute(
    path: AppRoutes.subject,
    name: AppRouteNames.subject,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return _buildPage(
        context: context,
        state: state,
        child: SubjectDetailPage(subjectId: id),
      );
    },
  ),
  // Teacher subject detail route - top-level route for teacher subject view
  GoRoute(
    path: AppRoutes.teacherSubjectDetail,
    name: AppRouteNames.teacherSubjectDetail,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return _buildPage(
        context: context,
        state: state,
        // TODO: Replace with TeacherSubjectDetailPage when created
        child: SubjectDetailPage(subjectId: id),
      );
    },
  ),
  // Main app shell with bottom navigation
  StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return ScaffoldWithNavBar(navigationShell: navigationShell);
    },
    branches: [
      // Branch 0: Home/Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRouteNames.home,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const DashboardPage(),
            ),
          ),
        ],
      ),
      // Branch 1: Schedule
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.schedule,
            name: AppRouteNames.schedule,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const SchedulePage(),
            ),
          ),
        ],
      ),
      // Branch 2: Grades
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.grades,
            name: AppRouteNames.grades,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const GradesPage(),
            ),
          ),
        ],
      ),
      // Branch 3: Profile
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            name: AppRouteNames.profile,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),
      // Branch 4: SuperAdmin Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.superadmin,
            name: AppRouteNames.superadmin,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const SuperAdminPage(),
            ),
          ),
        ],
      ),
      // Branch 5: School Admin (BigAdmin/Admin)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.schoolAdmin,
            name: AppRouteNames.schoolAdmin,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const SchoolAdminPage(),
            ),
          ),
        ],
      ),
      // Branch 6: Teacher Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.teacherDashboard,
            name: AppRouteNames.teacherDashboard,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const TeacherDashboardPage(),
            ),
          ),
        ],
      ),
    ],
  ),
  // Settings route - accessible from profile or other pages
  GoRoute(
    path: AppRoutes.settings,
    name: AppRouteNames.settings,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const SettingsScreen(),
    ),
  ),
  // Auth route - separate full-screen page outside the navigation shell
  GoRoute(
    path: AppRoutes.auth,
    name: AppRouteNames.auth,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const AuthScreen(),
    ),
  ),
];

/// Builds a page with platform-appropriate transitions.
///
/// - Web: Uses fade transition for smoother UX
/// - Mobile: Uses native platform transitions (Cupertino for iOS, Material for Android)
CustomTransitionPage<T> _buildPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  // Use fade transition for web, native transitions for mobile
  if (kIsWeb) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  // For mobile platforms, use Material page transitions
  // This respects the platform (Cupertino on iOS, Material on Android)
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Slide transition from right for a native feel
      final tween = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

/// Error/404 page builder.
///
/// Shown when navigation fails or route is not found.
Widget _errorBuilder(BuildContext context, GoRouterState state) {
  return _NotFoundScreen(error: state.error);
}

/// 404 Not Found screen.
///
/// Displays a user-friendly error message with option to return home.
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen({this.error});

  final GoException? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 80,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  '404',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Page Not Found',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The page you are looking for does not exist or has been moved.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (kDebugMode && error != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension on [BuildContext] for type-safe navigation helpers.
///
/// These helpers provide a cleaner API for common navigation patterns.
///
/// Usage:
/// ```dart
/// context.goHome();
/// context.goToSchedule();
/// context.goToGrades();
/// context.goToProfile();
/// context.goToSettings();
/// context.goToAuth();
/// context.goToLogin();
/// ```
extension AppNavigationExtension on BuildContext {
  /// Navigate to the home/dashboard screen, replacing the current route stack.
  void goHome() => go(AppRoutes.home);

  /// Navigate to the schedule screen, replacing the current route stack.
  void goToSchedule() => go(AppRoutes.schedule);

  /// Navigate to the grades screen, replacing the current route stack.
  void goToGrades() => go(AppRoutes.grades);

  /// Navigate to the profile screen, replacing the current route stack.
  void goToProfile() => go(AppRoutes.profile);

  /// Navigate to the settings screen, replacing the current route stack.
  void goToSettings() => go(AppRoutes.settings);

  /// Navigate to the auth screen, replacing the current route stack.
  void goToAuth() => go(AppRoutes.auth);

  /// Navigate to the login screen, replacing the current route stack.
  void goToLogin() => go(AppRoutes.login);

  /// Push the schedule screen onto the navigation stack.
  void pushSchedule() => push(AppRoutes.schedule);

  /// Push the grades screen onto the navigation stack.
  void pushGrades() => push(AppRoutes.grades);

  /// Push the profile screen onto the navigation stack.
  void pushProfile() => push(AppRoutes.profile);

  /// Push the settings screen onto the navigation stack.
  void pushSettings() => push(AppRoutes.settings);

  /// Push the auth screen onto the navigation stack.
  void pushAuth() => push(AppRoutes.auth);

  /// Push the login screen onto the navigation stack.
  void pushLogin() => push(AppRoutes.login);

  /// Push the subject detail screen onto the navigation stack.
  void pushSubjectDetail(String id) => push(AppRoutes.subjectDetail(id));

  /// Navigate to the super admin screen, replacing the current route stack.
  void goToSuperAdmin() => go(AppRoutes.superadmin);

  /// Navigate to the school admin screen, replacing the current route stack.
  void goToSchoolAdmin() => go(AppRoutes.schoolAdmin);

  /// Navigate to the teacher dashboard screen, replacing the current route stack.
  void goToTeacherDashboard() => go(AppRoutes.teacherDashboard);

  /// Push the teacher subject detail screen onto the navigation stack.
  void pushTeacherSubjectDetail(String id) =>
      push(AppRoutes.getTeacherSubjectDetail(id));

  // Legacy navigation helpers for backwards compatibility
  /// @deprecated Use [goToSuperAdmin] instead.
  void goToSchools() => go(AppRoutes.schools);
}
