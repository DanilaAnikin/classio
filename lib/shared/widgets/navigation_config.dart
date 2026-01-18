import '../../features/auth/domain/entities/app_user.dart';

/// Configuration class that defines navigation structure for different user roles.
///
/// This class contains static methods to retrieve:
/// - Route paths for each role
/// - Branch indices for StatefulShellRoute navigation
class NavigationConfig {
  /// Returns the list of route paths for a given user role.
  ///
  /// The routes are returned in the same order as the navigation tabs.
  static List<String> getRoutesForRole(UserRole? role) {
    switch (role) {
      case UserRole.superadmin:
        return ['/', '/superadmin', '/messages', '/profile'];
      case UserRole.bigadmin:
        return ['/principal', '/school_admin', '/messages', '/profile'];
      case UserRole.admin:
        return ['/deputy', '/school_admin', '/messages', '/profile'];
      case UserRole.teacher:
        return ['/schedule', '/teacher_dashboard', '/messages', '/profile'];
      case UserRole.parent:
        return ['/', '/grades', '/messages', '/profile'];
      case UserRole.student:
      case null:
        return ['/', '/schedule', '/grades', '/messages', '/profile'];
    }
  }

  /// Returns the list of branch indices for a given user role.
  ///
  /// These indices correspond to the branches in StatefulShellRoute.indexedStack
  /// defined in app_router.dart. The order matches getRoutesForRole().
  ///
  /// Branch mapping from app_router.dart:
  /// - Branch 0: / (home/dashboard)
  /// - Branch 1: /schedule
  /// - Branch 2: /grades
  /// - Branch 3: /profile
  /// - Branch 4: /superadmin
  /// - Branch 5: /school_admin
  /// - Branch 6: /teacher_dashboard
  /// - Branch 7: /deputy
  /// - Branch 8: /principal
  /// - Branch 9: /messages
  /// - Branch 10: /teacher
  /// - Branch 11: /student
  /// - Branch 12: /parent
  static List<int> getBranchIndicesForRole(UserRole? role) {
    switch (role) {
      case UserRole.superadmin:
        return [0, 4, 9, 3]; // /, /superadmin, /messages, /profile
      case UserRole.bigadmin:
        return [8, 5, 9, 3]; // /principal, /school_admin, /messages, /profile
      case UserRole.admin:
        return [7, 5, 9, 3]; // /deputy, /school_admin, /messages, /profile
      case UserRole.teacher:
        return [1, 6, 9, 3]; // /schedule, /teacher_dashboard, /messages, /profile
      case UserRole.parent:
        return [0, 2, 9, 3]; // /, /grades, /messages, /profile
      case UserRole.student:
      case null:
        return [0, 1, 2, 9, 3]; // /, /schedule, /grades, /messages, /profile
    }
  }
}
