/// Features barrel file
/// Exports feature modules for easy import.
///
/// IMPORTANT: Due to naming conflicts between some features,
/// this file uses selective exports. If you need classes
/// that are hidden here, import the specific feature directly:
///   import 'package:classio/features/admin_panel/admin_panel.dart';
///   import 'package:classio/features/teacher/teacher.dart';
library;

// Auth feature - main authentication
export 'auth/auth.dart';

// Chat feature
export 'chat/chat.dart';

// Dashboard feature - main user dashboard
export 'dashboard/dashboard.dart';

// Deputy feature - deputy/admin panel functionality
export 'deputy/deputy.dart';

// Grades feature
export 'grades/grades.dart';

// Invite feature
export 'invite/invite.dart';

// Parent feature
export 'parent/parent.dart';

// Principal feature
export 'principal/principal.dart';

// Profile feature
export 'profile/profile.dart';

// Schedule feature
export 'schedule/schedule.dart';

// Student feature (hide conflicts with teacher and principal)
export 'student/student.dart' hide AttendanceStatus, ExcuseStatus, AttendanceEntity, OverviewTab, ScheduleLessonCard;

// Subject detail feature
export 'subject_detail/subject_detail.dart';

// Superadmin feature
export 'superadmin/superadmin.dart';

// Note: The following features have naming conflicts and should be imported directly:
// - admin_panel/admin_panel.dart (admin panel implementation)
// - teacher/teacher.dart (has conflicts with student feature)
