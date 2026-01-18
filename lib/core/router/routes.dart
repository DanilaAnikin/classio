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

  /// SuperAdmin school detail screen with dynamic ID parameter.
  static const String superadminSchoolDetail = '/superadmin/school/:id';

  /// Helper method to generate superadmin school detail route with ID.
  static String getSuperadminSchoolDetail(String id) => '/superadmin/school/$id';

  /// SuperAdmin school users page with dynamic ID parameter.
  static const String superadminSchoolUsers = '/superadmin/school/:id/users';

  /// Helper method to generate superadmin school users route with ID.
  static String getSuperadminSchoolUsers(String id) => '/superadmin/school/$id/users';

  /// SuperAdmin school settings page with dynamic ID parameter.
  static const String superadminSchoolSettings = '/superadmin/school/:id/settings';

  /// Helper method to generate superadmin school settings route with ID.
  static String getSuperadminSchoolSettings(String id) => '/superadmin/school/$id/settings';

  /// BigAdmin/Admin panel screen.
  static const String schoolAdmin = '/school_admin';

  /// Principal dashboard screen (for BigAdmin role).
  static const String principal = '/principal';

  /// Teacher dashboard screen.
  static const String teacherDashboard = '/teacher_dashboard';

  /// Teacher subject detail screen with dynamic ID parameter.
  static const String teacherSubjectDetail = '/teacher_dashboard/subject/:id';

  /// Helper method to generate teacher subject detail route with ID.
  static String getTeacherSubjectDetail(String id) =>
      '/teacher_dashboard/subject/$id';

  /// Deputy panel screen (for school admins/deputies).
  static const String deputy = '/deputy';

  /// Deputy schedule editor with optional class ID parameter.
  static const String deputySchedule = '/deputy/schedule/:classId';

  /// Helper method to generate deputy schedule route with class ID.
  static String getDeputySchedule(String classId) => '/deputy/schedule/$classId';

  // Legacy routes for backwards compatibility
  /// @deprecated Use [superadmin] instead.
  static const String schools = '/schools';

  /// @deprecated Use [teacherDashboard] instead.
  static const String teacher = '/teacher';

  /// @deprecated Use [teacherSubjectDetail] instead.
  static const String teacherSubject = '/teacher/subject/:id';

  /// @deprecated Use [getTeacherSubjectDetail] instead.
  static String legacyTeacherSubjectDetail(String id) => '/teacher/subject/$id';

  // ============ Teacher Routes ============

  /// Teacher gradebook for specific subject.
  static const String teacherGradebook = '/teacher/gradebook/:subjectId';

  /// Helper method to generate gradebook route with subject ID.
  static String getTeacherGradebook(String subjectId) =>
      '/teacher/gradebook/$subjectId';

  /// Teacher attendance marking for specific lesson.
  static const String teacherAttendance = '/teacher/attendance/:lessonId';

  /// Helper method to generate attendance marking route with lesson ID.
  static String getTeacherAttendance(String lessonId) =>
      '/teacher/attendance/$lessonId';

  /// Teacher assignments for specific subject.
  static const String teacherAssignments = '/teacher/assignments/:subjectId';

  /// Helper method to generate assignments route with subject ID.
  static String getTeacherAssignments(String subjectId) =>
      '/teacher/assignments/$subjectId';

  /// Teacher absence excuses review page.
  static const String teacherAbsenceExcuses = '/teacher/absence-excuses';

  // ============ Student Routes ============

  /// Student dashboard screen (main student panel).
  static const String student = '/student';

  /// Student attendance page.
  static const String studentAttendance = '/student/attendance';

  /// Student grades page.
  static const String studentGrades = '/student/grades';

  /// Student schedule page.
  static const String studentSchedule = '/student/schedule';

  // ============ Parent Routes ============

  /// Parent dashboard screen (main parent panel).
  static const String parent = '/parent';

  /// Parent child detail page.
  static const String parentChildDetail = '/parent/child/:childId';

  /// Helper method to generate child detail route with child ID.
  static String getParentChildDetail(String childId) =>
      '/parent/child/$childId';

  /// Parent child attendance page.
  static const String parentChildAttendance = '/parent/child/:childId/attendance';

  /// Helper method to generate child attendance route with child ID.
  static String getParentChildAttendance(String childId) =>
      '/parent/child/$childId/attendance';

  /// Parent child grades page.
  static const String parentChildGrades = '/parent/child/:childId/grades';

  /// Helper method to generate child grades route with child ID.
  static String getParentChildGrades(String childId) =>
      '/parent/child/$childId/grades';

  /// Parent child schedule page.
  static const String parentChildSchedule = '/parent/child/:childId/schedule';

  /// Helper method to generate child schedule route with child ID.
  static String getParentChildSchedule(String childId) =>
      '/parent/child/$childId/schedule';

  /// Parent child timetable page (full weekly view with week navigation).
  static const String parentChildTimetable = '/parent/timetable';

  /// Parent submit absence excuse page.
  static const String parentSubmitExcuse =
      '/parent/child/:childId/attendance/:attendanceId/excuse';

  /// Helper method to generate submit excuse route.
  static String getParentSubmitExcuse(String childId, String attendanceId) =>
      '/parent/child/$childId/attendance/$attendanceId/excuse';

  /// Parent absence excuses list page.
  static const String parentAbsenceExcuses = '/parent/absence-excuses';

  /// Parent absence excuses list page for specific child.
  static const String parentChildAbsenceExcuses =
      '/parent/child/:childId/absence-excuses';

  /// Helper method to generate child absence excuses route.
  static String getParentChildAbsenceExcuses(String childId) =>
      '/parent/child/$childId/absence-excuses';

  // ============ Chat/Messages Routes ============

  /// Messages/conversations list screen.
  static const String messages = '/messages';

  /// Individual chat/conversation screen with dynamic ID.
  static const String chat = '/chat/:id';

  /// Helper method to generate chat route with ID and group flag.
  static String getChat(String id, {bool isGroup = false}) =>
      '/chat/$id?isGroup=$isGroup';

  /// New conversation page.
  static const String newConversation = '/chat/new';

  /// Create group page.
  static const String createGroup = '/chat/create-group';

  // ============ User Profile Routes ============

  /// User profile page for viewing other users' profiles.
  static const String userProfile = '/user/:userId';

  /// Helper method to generate user profile route with user ID.
  static String getUserProfile(String userId) => '/user/$userId';
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
  static const String superadminSchoolDetail = 'superadmin_school_detail';
  static const String superadminSchoolUsers = 'superadmin_school_users';
  static const String superadminSchoolSettings = 'superadmin_school_settings';
  static const String schoolAdmin = 'school_admin';
  static const String principal = 'principal';
  static const String teacherDashboard = 'teacher_dashboard';
  static const String teacherSubjectDetail = 'teacher_subject_detail';
  static const String deputy = 'deputy';
  static const String deputySchedule = 'deputy_schedule';

  // Legacy route names for backwards compatibility
  /// @deprecated Use [superadmin] instead.
  static const String schools = 'schools';

  /// @deprecated Use [teacherDashboard] instead.
  static const String teacher = 'teacher';

  /// @deprecated Use [teacherSubjectDetail] instead.
  static const String teacherSubject = 'teacher-subject';

  // ============ Teacher Route Names ============

  /// Route name for teacher gradebook.
  static const String teacherGradebook = 'teacher_gradebook';

  /// Route name for teacher attendance marking.
  static const String teacherAttendance = 'teacher_attendance';

  /// Route name for teacher assignments.
  static const String teacherAssignments = 'teacher_assignments';

  /// Route name for teacher absence excuses review.
  static const String teacherAbsenceExcuses = 'teacher_absence_excuses';

  // ============ Student Route Names ============

  /// Route name for student dashboard.
  static const String student = 'student';

  /// Route name for student attendance.
  static const String studentAttendance = 'student_attendance';

  /// Route name for student grades.
  static const String studentGrades = 'student_grades';

  /// Route name for student schedule.
  static const String studentSchedule = 'student_schedule';

  // ============ Parent Route Names ============

  /// Route name for parent dashboard.
  static const String parent = 'parent';

  /// Route name for parent child detail.
  static const String parentChildDetail = 'parent_child_detail';

  /// Route name for parent child attendance.
  static const String parentChildAttendance = 'parent_child_attendance';

  /// Route name for parent child grades.
  static const String parentChildGrades = 'parent_child_grades';

  /// Route name for parent child schedule.
  static const String parentChildSchedule = 'parent_child_schedule';

  /// Route name for parent child timetable (full weekly view).
  static const String parentChildTimetable = 'parent_child_timetable';

  /// Route name for parent submit absence excuse.
  static const String parentSubmitExcuse = 'parent_submit_excuse';

  /// Route name for parent absence excuses list.
  static const String parentAbsenceExcuses = 'parent_absence_excuses';

  /// Route name for parent child absence excuses list.
  static const String parentChildAbsenceExcuses = 'parent_child_absence_excuses';

  // ============ Chat/Messages Route Names ============

  /// Route name for messages list.
  static const String messages = 'messages';

  /// Route name for individual chat.
  static const String chat = 'chat';

  /// Route name for new conversation.
  static const String newConversation = 'new_conversation';

  /// Route name for create group.
  static const String createGroup = 'create_group';

  // ============ User Profile Route Names ============

  /// Route name for user profile.
  static const String userProfile = 'user_profile';
}
