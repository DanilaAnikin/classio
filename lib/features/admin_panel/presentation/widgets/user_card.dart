import 'package:flutter/material.dart';

import 'package:classio/core/theme/app_colors.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';

/// User card widget displaying user information with role badge.
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.isPlayful,
  });

  final AppUser user;
  final bool isPlayful;

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return isPlayful ? PlayfulColors.superadminRole : CleanColors.superadminRole;
      case UserRole.bigadmin:
        return isPlayful ? PlayfulColors.principalRole : CleanColors.principalRole;
      case UserRole.admin:
        return isPlayful ? PlayfulColors.deputyRole : CleanColors.deputyRole;
      case UserRole.teacher:
        return isPlayful ? PlayfulColors.teacherRole : CleanColors.teacherRole;
      case UserRole.student:
        return isPlayful ? PlayfulColors.studentRole : CleanColors.studentRole;
      case UserRole.parent:
        return isPlayful ? PlayfulColors.parentRole : CleanColors.parentRole;
    }
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Big Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String _getInitials(AppUser user) {
    if (user.firstName != null && user.lastName != null) {
      return '${user.firstName![0]}${user.lastName![0]}'.toUpperCase();
    } else if (user.firstName != null) {
      return user.firstName![0].toUpperCase();
    }
    return (user.email ?? 'U')[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(user.role);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? roleColor.withValues(alpha: 0.1)
                : CleanColors.shadow,
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isPlayful ? 48 : 42,
            height: isPlayful ? 48 : 42,
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getInitials(user),
                style: TextStyle(
                  fontSize: isPlayful ? 18 : 16,
                  fontWeight: FontWeight.w700,
                  color: roleColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? 14 : 12),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 15,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email ?? '',
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Role Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 12 : 10,
              vertical: isPlayful ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
            ),
            child: Text(
              _getRoleLabel(user.role),
              style: TextStyle(
                fontSize: isPlayful ? 12 : 11,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
