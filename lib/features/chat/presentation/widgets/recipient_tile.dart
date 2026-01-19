import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../../auth/domain/entities/app_user.dart';

/// A tile widget for selecting a message recipient.
///
/// Displays the user's avatar, name, role, and optionally a selection
/// indicator. Used in the new conversation and create group pages.
class RecipientTile extends StatelessWidget {
  /// Creates a [RecipientTile] widget.
  const RecipientTile({
    super.key,
    required this.user,
    required this.onTap,
    this.isSelected = false,
    this.showCheckbox = false,
    this.isPlayful = false,
    this.isDisabled = false,
    this.displayNameOverride,
  });

  /// The user to display.
  final AppUser user;

  /// Callback when the tile is tapped.
  final VoidCallback onTap;

  /// Whether this recipient is selected.
  final bool isSelected;

  /// Whether to show a checkbox (for multi-select).
  final bool showCheckbox;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Whether this recipient is disabled (cannot be selected).
  final bool isDisabled;

  /// Optional override for the display name.
  final String? displayNameOverride;

  /// Gets a user-friendly role label.
  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  /// Gets the display name for the user.
  String get _displayName => displayNameOverride ?? user.displayName;

  /// Gets a color based on the user's role.
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

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(user.role);
    final cardRadius = AppRadius.card(isPlayful: isPlayful);

    // Theme-aware colors
    final selectedBackgroundColor = isPlayful
        ? PlayfulColors.primarySubtle.withValues(alpha: AppOpacity.soft)
        : CleanColors.primarySubtle.withValues(alpha: AppOpacity.soft);

    final selectedBorderColor = isPlayful
        ? PlayfulColors.primary.withValues(alpha: AppOpacity.semi)
        : CleanColors.primary.withValues(alpha: AppOpacity.semi);

    final primaryTextColor = isPlayful
        ? PlayfulColors.textPrimary
        : CleanColors.textPrimary;

    final tertiaryTextColor = isPlayful
        ? PlayfulColors.textTertiary
        : CleanColors.textTertiary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: cardRadius,
        splashColor: (isPlayful ? PlayfulColors.primary : CleanColors.primary)
            .withValues(alpha: AppOpacity.light),
        highlightColor: (isPlayful ? PlayfulColors.primary : CleanColors.primary)
            .withValues(alpha: AppOpacity.subtle),
        child: AnimatedOpacity(
          duration: AppDuration.fast,
          opacity: isDisabled ? AppOpacity.disabled : 1.0,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: AppCurves.standard,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? selectedBackgroundColor : Colors.transparent,
              borderRadius: cardRadius,
              border: isSelected
                  ? Border.all(
                      color: selectedBorderColor,
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Selection checkbox (if applicable)
                if (showCheckbox) ...[
                  _buildCheckbox(),
                  AppSpacing.gapH8,
                ],

                // Avatar
                _buildAvatar(),
                AppSpacing.gapH12,

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      Text(
                        _displayName,
                        style: AppTypography.listTileTitle(isPlayful: isPlayful).copyWith(
                          color: primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.gap4,
                      // Role badge and email
                      Row(
                        children: [
                          _buildRoleBadge(roleColor),
                          if (user.email?.isNotEmpty ?? false) ...[
                            AppSpacing.gapH8,
                            Expanded(
                              child: Text(
                                user.email ?? '',
                                style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                                  color: tertiaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Selection indicator (if not using checkbox)
                if (!showCheckbox && isSelected)
                  _buildSelectionIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    final checkboxColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;

    return SizedBox(
      width: AppSpacing.xl,
      height: AppSpacing.xl,
      child: Checkbox(
        value: isSelected,
        onChanged: isDisabled ? null : (_) => onTap(),
        activeColor: checkboxColor,
        checkColor: isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xsRadius,
        ),
        side: BorderSide(
          color: isSelected ? checkboxColor : borderColor,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = user.avatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return AppAvatar(
        imageUrl: avatarUrl,
        fallbackName: _displayName,
        size: AvatarSize.md,
      );
    }

    return AppAvatar.initials(
      name: _displayName,
      size: AvatarSize.md,
      backgroundColor: _getRoleColor(user.role).withValues(alpha: AppOpacity.soft),
      foregroundColor: _getRoleColor(user.role),
    );
  }

  Widget _buildRoleBadge(Color roleColor) {
    final badgeBackgroundColor = roleColor.withValues(alpha: AppOpacity.soft);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: badgeBackgroundColor,
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
      ),
      child: Text(
        _getRoleLabel(user.role),
        style: AppTypography.caption(isPlayful: isPlayful).copyWith(
          fontWeight: FontWeight.w600,
          color: roleColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    final indicatorColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppCurves.standard,
      child: Icon(
        Icons.check_circle_rounded,
        color: indicatorColor,
        size: AppIconSize.md,
      ),
    );
  }
}

/// A grouped section header for recipient lists.
class RecipientSectionHeader extends StatelessWidget {
  /// Creates a [RecipientSectionHeader] widget.
  const RecipientSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.isPlayful = false,
  });

  /// The section title.
  final String title;

  /// Optional count of items in this section.
  final int? count;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final primaryContainerColor = isPlayful
        ? PlayfulColors.primarySubtle
        : CleanColors.primarySubtle;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: AppTypography.overline(isPlayful: isPlayful).copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (count != null) ...[
            AppSpacing.gapH8,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: primaryContainerColor,
                borderRadius: AppRadius.badge(isPlayful: isPlayful),
              ),
              child: Text(
                count.toString(),
                style: AppTypography.badge(isPlayful: isPlayful).copyWith(
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// An empty state widget for when no recipients match a search query.
class NoRecipientsFound extends StatelessWidget {
  /// Creates a [NoRecipientsFound] widget.
  const NoRecipientsFound({
    super.key,
    this.searchQuery,
    this.isPlayful = false,
  });

  /// The search query that yielded no results.
  final String? searchQuery;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final tertiaryTextColor = isPlayful
        ? PlayfulColors.textTertiary
        : CleanColors.textTertiary;

    final iconColor = isPlayful
        ? PlayfulColors.textMuted
        : CleanColors.textMuted;

    return Center(
      child: Padding(
        padding: AppSpacing.insets24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: AppIconSize.hero,
              color: iconColor,
            ),
            AppSpacing.gap16,
            Text(
              searchQuery != null && searchQuery!.isNotEmpty
                  ? 'No recipients found for "$searchQuery"'
                  : 'No recipients available',
              style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
                color: tertiaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
