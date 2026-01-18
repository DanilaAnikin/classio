import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/features/admin_panel/admin_panel.dart';
import 'package:classio/features/auth/auth.dart';
import 'package:classio/features/parent/presentation/pages/parent_dashboard_page.dart';
import 'package:classio/features/student/presentation/pages/student_dashboard_page.dart';

/// Main Dashboard page for the Classio app.
///
/// This is a routing widget that delegates to the appropriate dashboard
/// based on the user's role:
/// - SuperAdmin: SuperAdminPage
/// - BigAdmin/Admin: SchoolAdminPage
/// - Teacher: TeacherDashboardPage
/// - Parent: ParentDashboardPage
/// - Student: StudentDashboardPage
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = ref.watch(currentUserRoleProvider);

    // Role-based dispatch - each role gets their appropriate dashboard
    switch (userRole) {
      case UserRole.superadmin:
        return const SuperAdminPage();
      case UserRole.bigadmin:
      case UserRole.admin:
        return const SchoolAdminPage();
      case UserRole.teacher:
        return const TeacherDashboardPage();
      case UserRole.parent:
        return const ParentDashboardPage();
      case UserRole.student:
      case null:
        return const StudentDashboardPage();
    }
  }
}
