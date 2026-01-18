import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/admin_panel/admin_panel.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/chat/presentation/pages/pages.dart';
import '../../features/deputy/deputy.dart';
import '../../features/parent/presentation/pages/pages.dart' as parent_pages;
import '../../features/principal/principal.dart';
import '../../features/student/presentation/pages/pages.dart' as student_pages;
import '../../features/superadmin/superadmin.dart';
import '../../features/teacher/teacher.dart' as teacher;
import '../../features/teacher/presentation/pages/pages.dart' as teacher_pages;
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

  // Dispose the stream controller when the provider is disposed
  ref.onDispose(() {
    streamController.close();
  });

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
            return AppRoutes.principal;
          case UserRole.admin:
            return AppRoutes.deputy;
          case UserRole.teacher:
            return AppRoutes.teacher;
          case UserRole.student:
            return AppRoutes.student;
          case UserRole.parent:
            return AppRoutes.parent;
          case null:
            return AppRoutes.home;
        }
      }

      // Role-based restrictions (only check if authenticated)
      if (isAuthenticated) {
        final userRole = ref.read(currentUserRoleProvider);

        // SuperAdmin route protection
        if ((state.matchedLocation == AppRoutes.superadmin ||
                state.matchedLocation.startsWith('/superadmin/')) &&
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

        // Principal route protection - only bigadmin and superadmin
        if (state.matchedLocation == AppRoutes.principal &&
            userRole != UserRole.bigadmin &&
            userRole != UserRole.superadmin) {
          return AppRoutes.home;
        }

        // Deputy route protection - admin privileges required
        if (state.matchedLocation.startsWith('/deputy') &&
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

        // Teacher routes protection - only teachers can access /teacher/*
        if (state.matchedLocation.startsWith('/teacher') &&
            userRole != UserRole.teacher) {
          return AppRoutes.home;
        }

        // Student routes protection - only students can access /student/*
        if (state.matchedLocation.startsWith('/student') &&
            userRole != UserRole.student) {
          return AppRoutes.home;
        }

        // Parent routes protection - only parents can access /parent/*
        if (state.matchedLocation.startsWith('/parent') &&
            userRole != UserRole.parent) {
          return AppRoutes.home;
        }

        // General role-based restrictions for admin routes
        if ((state.matchedLocation.startsWith('/admin') ||
                state.matchedLocation.startsWith('/school_admin')) &&
            userRole != UserRole.admin &&
            userRole != UserRole.bigadmin &&
            userRole != UserRole.superadmin) {
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
  // Uses the shared SubjectDetailPage which displays subject information
  // for all roles including teachers
  GoRoute(
    path: AppRoutes.teacherSubjectDetail,
    name: AppRouteNames.teacherSubjectDetail,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return _buildPage(
        context: context,
        state: state,
        child: SubjectDetailPage(subjectId: id),
      );
    },
  ),
  // SuperAdmin school detail route - top-level route for viewing school details
  GoRoute(
    path: AppRoutes.superadminSchoolDetail,
    name: AppRouteNames.superadminSchoolDetail,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return _buildPage(
        context: context,
        state: state,
        child: SchoolDetailPage(schoolId: id),
      );
    },
  ),
  // SuperAdmin school users route - view all users in a school
  GoRoute(
    path: AppRoutes.superadminSchoolUsers,
    name: AppRouteNames.superadminSchoolUsers,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return _buildPage(
        context: context,
        state: state,
        child: SchoolUsersPage(schoolId: id),
      );
    },
  ),
  // SuperAdmin school settings route - manage school settings
  GoRoute(
    path: AppRoutes.superadminSchoolSettings,
    name: AppRouteNames.superadminSchoolSettings,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      return _buildPage(
        context: context,
        state: state,
        child: SchoolSettingsPage(schoolId: id),
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
              child: const SuperAdminDashboardPage(),
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
              child: const teacher.TeacherDashboardPage(),
            ),
          ),
        ],
      ),
      // Branch 7: Deputy Panel
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.deputy,
            name: AppRouteNames.deputy,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const DeputyDashboardPage(),
            ),
          ),
        ],
      ),
      // Branch 8: Principal Dashboard (BigAdmin)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.principal,
            name: AppRouteNames.principal,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const PrincipalDashboardPage(),
            ),
          ),
        ],
      ),
      // Branch 9: Messages (all authenticated users)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.messages,
            name: AppRouteNames.messages,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const ConversationsPage(),
            ),
          ),
        ],
      ),
      // Branch 10: Teacher Panel (new teacher routes)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.teacher,
            name: AppRouteNames.teacher,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const teacher_pages.TeacherDashboardPage(),
            ),
          ),
        ],
      ),
      // Branch 11: Student Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.student,
            name: AppRouteNames.student,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const student_pages.StudentDashboardPage(),
            ),
          ),
        ],
      ),
      // Branch 12: Parent Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: AppRoutes.parent,
            name: AppRouteNames.parent,
            pageBuilder: (context, state) => _buildPage(
              context: context,
              state: state,
              child: const parent_pages.ParentDashboardPage(),
            ),
          ),
        ],
      ),
    ],
  ),
  // Chat routes - outside the shell for proper navigation
  GoRoute(
    path: AppRoutes.newConversation,
    name: AppRouteNames.newConversation,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const NewConversationPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.createGroup,
    name: AppRouteNames.createGroup,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const CreateGroupPage(),
    ),
  ),
  GoRoute(
    path: AppRoutes.chat,
    name: AppRouteNames.chat,
    pageBuilder: (context, state) {
      final id = state.pathParameters['id']!;
      final isGroup = state.uri.queryParameters['isGroup'] == 'true';
      return _buildPage(
        context: context,
        state: state,
        child: ChatPage(conversationId: id, isGroup: isGroup),
      );
    },
  ),
  // Deputy Schedule Editor with class ID parameter
  GoRoute(
    path: AppRoutes.deputySchedule,
    name: AppRouteNames.deputySchedule,
    pageBuilder: (context, state) {
      final classId = state.pathParameters['classId']!;
      return _buildPage(
        context: context,
        state: state,
        child: ScheduleEditorPage(initialClassId: classId),
      );
    },
  ),

  // ============ Teacher Sub-Routes ============

  // Teacher gradebook for specific subject
  GoRoute(
    path: AppRoutes.teacherGradebook,
    name: AppRouteNames.teacherGradebook,
    pageBuilder: (context, state) {
      final subjectId = state.pathParameters['subjectId']!;
      return _buildPage(
        context: context,
        state: state,
        child: teacher_pages.GradebookPage(subjectId: subjectId),
      );
    },
  ),
  // Teacher attendance marking for specific lesson
  GoRoute(
    path: AppRoutes.teacherAttendance,
    name: AppRouteNames.teacherAttendance,
    pageBuilder: (context, state) {
      final lessonId = state.pathParameters['lessonId']!;
      return _buildPage(
        context: context,
        state: state,
        child: teacher_pages.AttendanceMarkingPage(lessonId: lessonId),
      );
    },
  ),
  // Teacher assignments for specific subject
  GoRoute(
    path: AppRoutes.teacherAssignments,
    name: AppRouteNames.teacherAssignments,
    pageBuilder: (context, state) {
      final subjectId = state.pathParameters['subjectId']!;
      return _buildPage(
        context: context,
        state: state,
        child: teacher_pages.AssignmentsPage(subjectId: subjectId),
      );
    },
  ),

  // ============ Student Sub-Routes ============

  // Student attendance page
  GoRoute(
    path: AppRoutes.studentAttendance,
    name: AppRouteNames.studentAttendance,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const student_pages.StudentAttendancePage(),
    ),
  ),
  // Student grades page
  GoRoute(
    path: AppRoutes.studentGrades,
    name: AppRouteNames.studentGrades,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const student_pages.StudentGradesPage(),
    ),
  ),
  // Student schedule page
  GoRoute(
    path: AppRoutes.studentSchedule,
    name: AppRouteNames.studentSchedule,
    pageBuilder: (context, state) => _buildPage(
      context: context,
      state: state,
      child: const student_pages.StudentSchedulePage(),
    ),
  ),

  // ============ Parent Sub-Routes ============

  // Parent child detail page
  GoRoute(
    path: AppRoutes.parentChildDetail,
    name: AppRouteNames.parentChildDetail,
    pageBuilder: (context, state) {
      final childId = state.pathParameters['childId']!;
      return _buildPage(
        context: context,
        state: state,
        child: parent_pages.ChildDetailPage(childId: childId),
      );
    },
  ),
  // Parent child attendance page
  GoRoute(
    path: AppRoutes.parentChildAttendance,
    name: AppRouteNames.parentChildAttendance,
    pageBuilder: (context, state) {
      final childId = state.pathParameters['childId']!;
      return _buildPage(
        context: context,
        state: state,
        child: parent_pages.ChildAttendancePage(childId: childId),
      );
    },
  ),
  // Parent child grades page
  GoRoute(
    path: AppRoutes.parentChildGrades,
    name: AppRouteNames.parentChildGrades,
    pageBuilder: (context, state) {
      final childId = state.pathParameters['childId']!;
      return _buildPage(
        context: context,
        state: state,
        child: parent_pages.ChildGradesPage(childId: childId),
      );
    },
  ),
  // Parent child schedule page
  GoRoute(
    path: AppRoutes.parentChildSchedule,
    name: AppRouteNames.parentChildSchedule,
    pageBuilder: (context, state) {
      final childId = state.pathParameters['childId']!;
      return _buildPage(
        context: context,
        state: state,
        child: parent_pages.ChildSchedulePage(childId: childId),
      );
    },
  ),
  // Parent child timetable page (full weekly view with week navigation)
  GoRoute(
    path: AppRoutes.parentChildTimetable,
    name: AppRouteNames.parentChildTimetable,
    pageBuilder: (context, state) {
      return _buildPage(
        context: context,
        state: state,
        child: const parent_pages.ChildTimetablePage(),
      );
    },
  ),
  // Parent submit absence excuse page
  GoRoute(
    path: AppRoutes.parentSubmitExcuse,
    name: AppRouteNames.parentSubmitExcuse,
    pageBuilder: (context, state) {
      final childId = state.pathParameters['childId']!;
      final attendanceId = state.pathParameters['attendanceId']!;
      return _buildPage(
        context: context,
        state: state,
        child: parent_pages.SubmitAbsenceExcusePage(
          childId: childId,
          attendanceId: attendanceId,
        ),
      );
    },
  ),
  // Parent absence excuses list page (all children)
  GoRoute(
    path: AppRoutes.parentAbsenceExcuses,
    name: AppRouteNames.parentAbsenceExcuses,
    pageBuilder: (context, state) {
      return _buildPage(
        context: context,
        state: state,
        child: const parent_pages.AbsenceExcusesListPage(),
      );
    },
  ),
  // Parent child-specific absence excuses list page
  GoRoute(
    path: AppRoutes.parentChildAbsenceExcuses,
    name: AppRouteNames.parentChildAbsenceExcuses,
    pageBuilder: (context, state) {
      final childId = state.pathParameters['childId']!;
      return _buildPage(
        context: context,
        state: state,
        child: parent_pages.AbsenceExcusesListPage(childId: childId),
      );
    },
  ),

  // ============ Teacher Absence Excuses Route ============

  // Teacher absence excuses review page
  GoRoute(
    path: AppRoutes.teacherAbsenceExcuses,
    name: AppRouteNames.teacherAbsenceExcuses,
    pageBuilder: (context, state) {
      return _buildPage(
        context: context,
        state: state,
        child: const teacher_pages.AbsenceExcusesPage(),
      );
    },
  ),

  // ============ User Profile Route ============

  // User profile page for viewing other users' profiles
  GoRoute(
    path: AppRoutes.userProfile,
    name: AppRouteNames.userProfile,
    pageBuilder: (context, state) {
      final userId = state.pathParameters['userId']!;
      return _buildPage(
        context: context,
        state: state,
        child: UserProfilePage(userId: userId),
      );
    },
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

  /// Push the superadmin school detail screen onto the navigation stack.
  void pushSuperadminSchoolDetail(String id) =>
      push(AppRoutes.getSuperadminSchoolDetail(id));

  /// Push the superadmin school users screen onto the navigation stack.
  void pushSuperadminSchoolUsers(String id) =>
      push(AppRoutes.getSuperadminSchoolUsers(id));

  /// Push the superadmin school settings screen onto the navigation stack.
  void pushSuperadminSchoolSettings(String id) =>
      push(AppRoutes.getSuperadminSchoolSettings(id));

  /// Navigate to the school admin screen, replacing the current route stack.
  void goToSchoolAdmin() => go(AppRoutes.schoolAdmin);

  /// Navigate to the teacher dashboard screen, replacing the current route stack.
  void goToTeacherDashboard() => go(AppRoutes.teacherDashboard);

  /// Push the teacher subject detail screen onto the navigation stack.
  void pushTeacherSubjectDetail(String id) =>
      push(AppRoutes.getTeacherSubjectDetail(id));

  /// Navigate to the deputy panel screen, replacing the current route stack.
  void goToDeputy() => go(AppRoutes.deputy);

  /// Push the deputy schedule editor screen onto the navigation stack.
  void pushDeputySchedule(String classId) =>
      push(AppRoutes.getDeputySchedule(classId));

  /// Navigate to the principal dashboard screen, replacing the current route stack.
  void goToPrincipal() => go(AppRoutes.principal);

  // Legacy navigation helpers for backwards compatibility
  /// @deprecated Use [goToSuperAdmin] instead.
  void goToSchools() => go(AppRoutes.schools);

  // ============ Teacher Navigation ============

  /// Navigate to the teacher panel, replacing the current route stack.
  void goToTeacher() => go(AppRoutes.teacher);

  /// Push the teacher gradebook screen onto the navigation stack.
  void pushTeacherGradebook(String subjectId) =>
      push(AppRoutes.getTeacherGradebook(subjectId));

  /// Push the teacher attendance marking screen onto the navigation stack.
  void pushTeacherAttendance(String lessonId) =>
      push(AppRoutes.getTeacherAttendance(lessonId));

  /// Push the teacher assignments screen onto the navigation stack.
  void pushTeacherAssignments(String subjectId) =>
      push(AppRoutes.getTeacherAssignments(subjectId));

  // ============ Student Navigation ============

  /// Navigate to the student dashboard, replacing the current route stack.
  void goToStudent() => go(AppRoutes.student);

  /// Navigate to the student attendance screen, replacing the current route stack.
  void goToStudentAttendance() => go(AppRoutes.studentAttendance);

  /// Push the student attendance screen onto the navigation stack.
  void pushStudentAttendance() => push(AppRoutes.studentAttendance);

  /// Navigate to the student grades screen, replacing the current route stack.
  void goToStudentGrades() => go(AppRoutes.studentGrades);

  /// Push the student grades screen onto the navigation stack.
  void pushStudentGrades() => push(AppRoutes.studentGrades);

  /// Navigate to the student schedule screen, replacing the current route stack.
  void goToStudentSchedule() => go(AppRoutes.studentSchedule);

  /// Push the student schedule screen onto the navigation stack.
  void pushStudentSchedule() => push(AppRoutes.studentSchedule);

  // ============ Parent Navigation ============

  /// Navigate to the parent dashboard, replacing the current route stack.
  void goToParent() => go(AppRoutes.parent);

  /// Push the parent child detail screen onto the navigation stack.
  void pushParentChildDetail(String childId) =>
      push(AppRoutes.getParentChildDetail(childId));

  /// Push the parent child attendance screen onto the navigation stack.
  void pushParentChildAttendance(String childId) =>
      push(AppRoutes.getParentChildAttendance(childId));

  /// Push the parent child grades screen onto the navigation stack.
  void pushParentChildGrades(String childId) =>
      push(AppRoutes.getParentChildGrades(childId));

  /// Push the parent child schedule screen onto the navigation stack.
  void pushParentChildSchedule(String childId) =>
      push(AppRoutes.getParentChildSchedule(childId));

  /// Navigate to the parent child timetable screen, replacing the current route stack.
  void goToParentTimetable() => go(AppRoutes.parentChildTimetable);

  /// Push the parent child timetable screen onto the navigation stack.
  void pushParentTimetable() => push(AppRoutes.parentChildTimetable);

  /// Push the parent submit absence excuse screen onto the navigation stack.
  void pushParentSubmitExcuse(String childId, String attendanceId) =>
      push(AppRoutes.getParentSubmitExcuse(childId, attendanceId));

  /// Navigate to the parent absence excuses list screen.
  void goToParentAbsenceExcuses() => go(AppRoutes.parentAbsenceExcuses);

  /// Push the parent absence excuses list screen onto the navigation stack.
  void pushParentAbsenceExcuses() => push(AppRoutes.parentAbsenceExcuses);

  /// Push the parent child-specific absence excuses screen onto the navigation stack.
  void pushParentChildAbsenceExcuses(String childId) =>
      push(AppRoutes.getParentChildAbsenceExcuses(childId));

  // ============ Teacher Absence Excuses Navigation ============

  /// Navigate to the teacher absence excuses review screen.
  void goToTeacherAbsenceExcuses() => go(AppRoutes.teacherAbsenceExcuses);

  /// Push the teacher absence excuses review screen onto the navigation stack.
  void pushTeacherAbsenceExcuses() => push(AppRoutes.teacherAbsenceExcuses);

  // ============ Chat/Messages Navigation ============

  /// Navigate to the messages/conversations list screen.
  void goToMessages() => go(AppRoutes.messages);

  /// Push the messages/conversations list screen onto the navigation stack.
  void pushMessages() => push(AppRoutes.messages);

  /// Navigate to a specific chat/conversation.
  void goToChat(String id, {bool isGroup = false}) =>
      go(AppRoutes.getChat(id, isGroup: isGroup));

  /// Push a specific chat/conversation onto the navigation stack.
  void pushChat(String id, {bool isGroup = false}) =>
      push(AppRoutes.getChat(id, isGroup: isGroup));

  /// Push the new conversation page onto the navigation stack.
  void pushNewConversation() => push(AppRoutes.newConversation);

  /// Push the create group page onto the navigation stack.
  void pushCreateGroup() => push(AppRoutes.createGroup);

  // ============ User Profile Navigation ============

  /// Navigate to a user's profile page.
  void goToUserProfile(String userId) => go(AppRoutes.getUserProfile(userId));

  /// Push a user's profile page onto the navigation stack.
  void pushUserProfile(String userId) => push(AppRoutes.getUserProfile(userId));
}
