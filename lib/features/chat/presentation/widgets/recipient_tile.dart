import 'package:flutter/material.dart';

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
  /// Uses the AppUser.displayName which handles special display for superadmins.
  String get _displayName => displayNameOverride ?? user.displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledOpacity = isDisabled ? 0.4 : 1.0;

    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
      child: Opacity(
        opacity: disabledOpacity,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 16 : 12,
            vertical: isPlayful ? 14 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Selection checkbox (if applicable)
              if (showCheckbox) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: isDisabled ? null : (_) => onTap(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: isPlayful ? 8 : 4),
              ],

              // Avatar
              _buildAvatar(theme),
              SizedBox(width: isPlayful ? 14 : 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: isPlayful ? 17 : 16,
                        fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: isPlayful ? 0.2 : 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isPlayful ? 4 : 2),
                    Row(
                      children: [
                        Flexible(
                          flex: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isPlayful ? 10 : 8,
                              vertical: isPlayful ? 4 : 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role, theme).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(isPlayful ? 10 : 8),
                            ),
                            child: Text(
                              _getRoleLabel(user.role),
                              style: TextStyle(
                                fontSize: isPlayful ? 12 : 11,
                                fontWeight: FontWeight.w600,
                                color: _getRoleColor(user.role, theme),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (user.email?.isNotEmpty ?? false) ...[
                          SizedBox(width: isPlayful ? 10 : 8),
                          Expanded(
                            child: Text(
                              user.email ?? '',
                              style: TextStyle(
                                fontSize: isPlayful ? 13 : 12,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                Icon(
                  Icons.check_circle_rounded,
                  color: theme.colorScheme.primary,
                  size: isPlayful ? 26 : 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the avatar for the user.
  Widget _buildAvatar(ThemeData theme) {
    final size = isPlayful ? 52.0 : 48.0;

    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(user.avatarUrl!),
        onBackgroundImageError: (_, _) {},
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getRoleColor(user.role, theme).withValues(alpha: 0.2),
      child: Text(
        _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: isPlayful ? 22 : 20,
          fontWeight: FontWeight.w600,
          color: _getRoleColor(user.role, theme),
        ),
      ),
    );
  }

  /// Gets a color based on the user's role.
  Color _getRoleColor(UserRole role, ThemeData theme) {
    switch (role) {
      case UserRole.superadmin:
        return Colors.purple;
      case UserRole.bigadmin:
        return Colors.indigo;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.teacher:
        return Colors.teal;
      case UserRole.student:
        return Colors.green;
      case UserRole.parent:
        return Colors.orange;
    }
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
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 16 : 12,
        vertical: isPlayful ? 12 : 8,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
              letterSpacing: isPlayful ? 0.5 : 0.3,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 8 : 6,
                vertical: isPlayful ? 3 : 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: isPlayful ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
