import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';

/// A card widget displaying a staff member's information.
///
/// Shows the staff member's name, email, role, and provides action buttons.
class StaffCard extends StatelessWidget {
  /// Creates a [StaffCard].
  const StaffCard({
    super.key,
    required this.staff,
    this.onViewProfile,
    this.onRemove,
    this.isPlayful = false,
  });

  /// The staff member to display.
  final AppUser staff;

  /// Callback when the view profile action is triggered.
  final VoidCallback? onViewProfile;

  /// Callback when the remove action is triggered.
  final VoidCallback? onRemove;

  /// Whether to use playful styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(theme);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? roleColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: InkWell(
          onTap: onViewProfile,
          borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
          child: Padding(
            padding: EdgeInsets.all(isPlayful ? 16 : 14),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(theme, roleColor),
                SizedBox(width: isPlayful ? 16 : 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName,
                        style: TextStyle(
                          fontSize: isPlayful ? 17 : 16,
                          fontWeight:
                              isPlayful ? FontWeight.w700 : FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        staff.email ?? '',
                        style: TextStyle(
                          fontSize: isPlayful ? 14 : 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isPlayful ? 10 : 8),
                      _buildRoleBadge(theme, roleColor),
                    ],
                  ),
                ),
                // Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 20, color: theme.colorScheme.onSurface),
                          const SizedBox(width: 12),
                          const Text('View Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_outlined,
                              size: 20, color: theme.colorScheme.error),
                          const SizedBox(width: 12),
                          Text('Remove from School',
                              style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onViewProfile?.call();
                        break;
                      case 'remove':
                        onRemove?.call();
                        break;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, Color roleColor) {
    if (staff.avatarUrl != null && staff.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: isPlayful ? 28 : 26,
        backgroundImage: NetworkImage(staff.avatarUrl!),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
      );
    }

    return CircleAvatar(
      radius: isPlayful ? 28 : 26,
      backgroundColor: roleColor.withValues(alpha: 0.15),
      child: Text(
        _getInitials(),
        style: TextStyle(
          fontSize: isPlayful ? 18 : 16,
          fontWeight: FontWeight.w700,
          color: roleColor,
        ),
      ),
    );
  }

  String _getInitials() {
    if (staff.firstName != null && staff.lastName != null) {
      return '${staff.firstName![0]}${staff.lastName![0]}'.toUpperCase();
    } else if (staff.firstName != null) {
      return staff.firstName![0].toUpperCase();
    }
    return (staff.email ?? 'U')[0].toUpperCase();
  }

  Widget _buildRoleBadge(ThemeData theme, Color roleColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 12 : 10,
        vertical: isPlayful ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(),
            size: isPlayful ? 15 : 14,
            color: roleColor,
          ),
          SizedBox(width: isPlayful ? 6 : 4),
          Text(
            _getRoleDisplayName(),
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: roleColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(ThemeData theme) {
    switch (staff.role) {
      case UserRole.superadmin:
        return Colors.purple;
      case UserRole.bigadmin:
        return theme.colorScheme.primary;
      case UserRole.admin:
        return Colors.indigo;
      case UserRole.teacher:
        return Colors.blue;
      case UserRole.student:
        return Colors.green;
      case UserRole.parent:
        return Colors.orange;
    }
  }

  IconData _getRoleIcon() {
    switch (staff.role) {
      case UserRole.superadmin:
        return Icons.admin_panel_settings;
      case UserRole.bigadmin:
        return Icons.supervisor_account;
      case UserRole.admin:
        return Icons.manage_accounts;
      case UserRole.teacher:
        return Icons.school;
      case UserRole.student:
        return Icons.person;
      case UserRole.parent:
        return Icons.family_restroom;
    }
  }

  String _getRoleDisplayName() {
    switch (staff.role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
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
}
