/// Route path constants for the application.
///
/// This file defines all route paths used throughout the app.
/// Using constants prevents typos and enables easy refactoring.
library;

/// Application route paths.
///
/// Usage:
/// ```dart
/// context.go(AppRoutes.settings);
/// context.push(AppRoutes.auth);
/// ```
abstract final class AppRoutes {
  /// Home/Dashboard screen - the main entry point of the app.
  static const String home = '/';

  /// Schedule screen for viewing timetable/classes.
  static const String schedule = '/schedule';

  /// Grades screen for viewing academic grades.
  static const String grades = '/grades';

  /// Profile screen for user profile and settings.
  static const String profile = '/profile';

  /// Settings screen for app configuration.
  static const String settings = '/settings';

  /// Authentication screen for login/signup.
  static const String auth = '/auth';

  /// Login route (alias for auth).
  static const String login = '/auth';

  /// Subject detail screen with dynamic ID parameter.
  static const String subject = '/subject/:id';

  /// Helper method to generate subject detail route with ID.
  static String subjectDetail(String id) => '/subject/$id';

  /// SuperAdmin dashboard screen.
  static const String superadmin = '/superadmin';

  /// BigAdmin/Admin panel screen.
  static const String schoolAdmin = '/school_admin';

  /// Teacher dashboard screen.
  static const String teacherDashboard = '/teacher_dashboard';

  /// Teacher subject detail screen with dynamic ID parameter.
  static const String teacherSubjectDetail = '/teacher_dashboard/subject/:id';

  /// Helper method to generate teacher subject detail route with ID.
  static String getTeacherSubjectDetail(String id) =>
      '/teacher_dashboard/subject/$id';

  // Legacy routes for backwards compatibility
  /// @deprecated Use [superadmin] instead.
  static const String schools = '/schools';

  /// @deprecated Use [teacherDashboard] instead.
  static const String teacher = '/teacher';

  /// @deprecated Use [teacherSubjectDetail] instead.
  static const String teacherSubject = '/teacher/subject/:id';

  /// @deprecated Use [getTeacherSubjectDetail] instead.
  static String legacyTeacherSubjectDetail(String id) => '/teacher/subject/$id';
}

/// Route names for named navigation (optional, for go_router's named routes).
///
/// Usage with named routes:
/// ```dart
/// context.goNamed(AppRouteNames.settings);
/// ```
abstract final class AppRouteNames {
  static const String home = 'home';
  static const String schedule = 'schedule';
  static const String grades = 'grades';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String auth = 'auth';
  static const String subject = 'subject';
  static const String superadmin = 'superadmin';
  static const String schoolAdmin = 'school_admin';
  static const String teacherDashboard = 'teacher_dashboard';
  static const String teacherSubjectDetail = 'teacher_subject_detail';

  // Legacy route names for backwards compatibility
  /// @deprecated Use [superadmin] instead.
  static const String schools = 'schools';

  /// @deprecated Use [teacherDashboard] instead.
  static const String teacher = 'teacher';

  /// @deprecated Use [teacherSubjectDetail] instead.
  static const String teacherSubject = 'teacher-subject';
}
