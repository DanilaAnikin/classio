import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/domain/entities/app_user.dart';

// =============================================================================
// STAFF CARD - Principal Dashboard Staff Display
// =============================================================================
// A premium card component for displaying staff member information with
// proper visual hierarchy, role-based coloring, and interactive actions.
//
// Features:
// - Uses AppCard.interactive for consistent card styling
// - AppAvatar for staff avatars with proper fallbacks
// - AppTypography for all text styles
// - AppSpacing for all margins/padding
// - Role-based color coding
// - Theme-aware styling (Clean vs Playful)
// =============================================================================

/// A card widget displaying a staff member's information.
///
/// Shows the staff member's name, email, role, and provides action buttons.
/// Uses design system tokens for consistent styling across themes.
class StaffCard extends StatelessWidget {
  /// Creates a [StaffCard].
  const StaffCard({
    super.key,
    required this.staff,
    this.onViewProfile,
    this.onRemove,
  });

  /// The staff member to display.
  final AppUser staff;

  /// Callback when the view profile action is triggered.
  final VoidCallback? onViewProfile;

  /// Callback when the remove action is triggered.
  final VoidCallback? onRemove;

  /// Detects if the current theme is playful.
  bool _isPlayful(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        (primaryColor.r * 255 > 100 && primaryColor.b * 255 > 200);
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful(context);
    final roleColor = _getRoleColor(isPlayful);

    return AppCard.interactive(
      onTap: onViewProfile,
      semanticLabel: 'Staff member ${staff.fullName}',
      child: Row(
        children: [
          // Avatar
          _StaffAvatar(
            staff: staff,
            roleColor: roleColor,
            isPlayful: isPlayful,
          ),
          SizedBox(width: AppSpacing.md),
          // Staff info
          Expanded(
            child: _StaffInfo(
              staff: staff,
              roleColor: roleColor,
              isPlayful: isPlayful,
            ),
          ),
          // Actions menu
          _ActionsMenu(
            isPlayful: isPlayful,
            onViewProfile: onViewProfile,
            onRemove: onRemove,
          ),
        ],
      ),
    );
  }

  /// Returns the appropriate color for the staff member's role.
  Color _getRoleColor(bool isPlayful) {
    switch (staff.role) {
      case UserRole.superadmin:
        return isPlayful
            ? PlayfulColors.superadminRole
            : CleanColors.superadminRole;
      case UserRole.bigadmin:
        return isPlayful
            ? PlayfulColors.principalRole
            : CleanColors.principalRole;
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
}

// =============================================================================
// SUBCOMPONENTS
// =============================================================================

/// Staff avatar with image or initials fallback.
class _StaffAvatar extends StatelessWidget {
  const _StaffAvatar({
    required this.staff,
    required this.roleColor,
    required this.isPlayful,
  });

  final AppUser staff;
  final Color roleColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = staff.avatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AppAvatar(
        imageUrl: avatarUrl,
        fallbackName: staff.fullName,
        size: isPlayful ? AvatarSize.lg : AvatarSize.md,
        showShadow: true,
      );
    }

    return AppAvatar.initials(
      name: staff.fullName,
      size: isPlayful ? AvatarSize.lg : AvatarSize.md,
      backgroundColor: roleColor.withValues(alpha: AppOpacity.medium),
      foregroundColor: roleColor,
      showShadow: true,
    );
  }
}

/// Staff information section showing name, email, and role badge.
class _StaffInfo extends StatelessWidget {
  const _StaffInfo({
    required this.staff,
    required this.roleColor,
    required this.isPlayful,
  });

  final AppUser staff;
  final Color roleColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Staff name
        Text(
          staff.fullName,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppSpacing.xxs),
        // Email
        Text(
          staff.email ?? '',
          style: AppTypography.secondaryText(isPlayful: isPlayful),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppSpacing.sm),
        // Role badge
        _RoleBadge(
          role: staff.role,
          roleColor: roleColor,
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

/// Role badge showing the staff member's role with icon.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.role,
    required this.roleColor,
    required this.isPlayful,
  });

  final UserRole role;
  final Color roleColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: AppOpacity.medium),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(),
            size: AppIconSize.xs,
            color: roleColor,
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            _getRoleDisplayName(),
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w600,
              color: roleColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon() {
    switch (role) {
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
    switch (role) {
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

/// Popup menu with staff actions.
class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.isPlayful,
    this.onViewProfile,
    this.onRemove,
  });

  final bool isPlayful;
  final VoidCallback? onViewProfile;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;
    final textColor =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: iconColor,
        size: AppIconSize.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card(isPlayful: isPlayful),
      ),
      elevation: isPlayful ? AppElevation.md : AppElevation.sm,
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.person_outline, size: AppIconSize.sm, color: textColor),
              SizedBox(width: AppSpacing.sm),
              Text(
                'View Profile',
                style: AppTypography.secondaryText(isPlayful: isPlayful)
                    .copyWith(color: textColor),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.person_remove_outlined,
                  size: AppIconSize.sm, color: errorColor),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Remove from School',
                style: AppTypography.secondaryText(isPlayful: isPlayful)
                    .copyWith(color: errorColor),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'view':
            onViewProfile?.call();
          case 'remove':
            onRemove?.call();
        }
      },
    );
  }
}
