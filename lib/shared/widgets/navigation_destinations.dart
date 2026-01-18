import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/chat/presentation/providers/chat_provider.dart';
import '../../features/chat/presentation/widgets/widgets.dart';
import 'navigation_labels.dart';

/// Builder class for creating NavigationDestination widgets based on user role.
///
/// This class handles all the icon selection, styling, and badge logic
/// for navigation destinations across different user roles.
class NavigationDestinationsBuilder {
  /// Builds navigation destinations for superadmin users.
  /// Tabs: Global Dashboard, Schools, Messages, Profile
  static List<NavigationDestination> buildForSuperAdmin(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return [
      _buildDashboardDestination(context, isPlayful, theme),
      _buildSchoolsDestination(context, isPlayful, theme),
      _buildMessagesDestination(context, isPlayful, theme, ref),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for bigadmin and admin users.
  /// Tabs: School Dashboard, Users/Classes, Messages, Profile
  static List<NavigationDestination> buildForAdmin(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return [
      _buildDashboardDestination(context, isPlayful, theme),
      _buildManageDestination(context, isPlayful, theme),
      _buildMessagesDestination(context, isPlayful, theme, ref),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for teacher users.
  /// Tabs: Schedule, My Subjects, Messages, Profile
  static List<NavigationDestination> buildForTeacher(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return [
      _buildScheduleDestination(context, isPlayful, theme),
      _buildSubjectsDestination(context, isPlayful, theme),
      _buildMessagesDestination(context, isPlayful, theme, ref),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for student users (default).
  /// Tabs: Home, Schedule, Grades, Messages, Profile
  static List<NavigationDestination> buildForStudent(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return [
      _buildHomeDestination(context, isPlayful, theme),
      _buildScheduleDestination(context, isPlayful, theme),
      _buildGradesDestination(context, isPlayful, theme),
      _buildMessagesDestination(context, isPlayful, theme, ref),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Builds navigation destinations for parent users.
  /// Tabs: Children, Grades, Messages, Profile
  static List<NavigationDestination> buildForParent(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    return [
      _buildChildrenDestination(context, isPlayful, theme),
      _buildGradesDestination(context, isPlayful, theme),
      _buildMessagesDestination(context, isPlayful, theme, ref),
      _buildProfileDestination(context, isPlayful, theme),
    ];
  }

  /// Returns the appropriate navigation destinations based on user role.
  static List<NavigationDestination> buildForRole(
    UserRole? role,
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    switch (role) {
      case UserRole.superadmin:
        return buildForSuperAdmin(context, isPlayful, theme, ref);
      case UserRole.bigadmin:
      case UserRole.admin:
        return buildForAdmin(context, isPlayful, theme, ref);
      case UserRole.teacher:
        return buildForTeacher(context, isPlayful, theme, ref);
      case UserRole.parent:
        return buildForParent(context, isPlayful, theme, ref);
      case UserRole.student:
      case null:
        return buildForStudent(context, isPlayful, theme, ref);
    }
  }

  // ============ Private Helper Methods for Building Destinations ============

  static NavigationDestination _buildHomeDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.home(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.home_rounded : Icons.home_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.home_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildScheduleDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.schedule(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.calendar_today_rounded : Icons.calendar_today_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.calendar_today_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildGradesDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.grades(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.assessment_rounded : Icons.assessment_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.assessment_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildDashboardDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.dashboard(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.dashboard_rounded : Icons.dashboard_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.dashboard_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildSchoolsDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.schools(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.school_rounded : Icons.school_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.school_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildManageDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.manage(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.people_rounded : Icons.people_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.people_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildSubjectsDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.subjects(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.book_rounded : Icons.book_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.book_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildChildrenDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.children(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.child_care_rounded : Icons.child_care_outlined,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.child_care_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildProfileDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
  ) {
    final label = NavigationLabels.profile(context);
    return NavigationDestination(
      icon: Icon(
        isPlayful ? Icons.person_rounded : Icons.person_outline,
        color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
      ),
      selectedIcon: Icon(
        Icons.person_rounded,
        color: theme.colorScheme.primary,
      ),
      label: label,
      tooltip: label,
    );
  }

  static NavigationDestination _buildMessagesDestination(
    BuildContext context,
    bool isPlayful,
    ThemeData theme,
    WidgetRef ref,
  ) {
    final label = NavigationLabels.messages(context);
    final unreadCount = ref.watch(unreadCountNotifierProvider);

    return NavigationDestination(
      icon: UnreadBadgeOverlay(
        count: unreadCount,
        badgeSize: 16,
        offset: const Offset(-2, -2),
        child: Icon(
          isPlayful ? Icons.chat_rounded : Icons.chat_outlined,
          color: isPlayful ? null : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      selectedIcon: UnreadBadgeOverlay(
        count: unreadCount,
        badgeSize: 16,
        offset: const Offset(-2, -2),
        child: Icon(
          Icons.chat_rounded,
          color: theme.colorScheme.primary,
        ),
      ),
      label: label,
      tooltip: label,
    );
  }
}
