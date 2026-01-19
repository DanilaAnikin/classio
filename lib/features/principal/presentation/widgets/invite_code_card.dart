import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../admin_panel/domain/entities/invite_code.dart';
import '../../../auth/domain/entities/app_user.dart';

// =============================================================================
// INVITE CODE CARD - Principal Dashboard Invite Management
// =============================================================================
// A premium card component for displaying invite codes with proper
// visual hierarchy, status indicators, and interactive actions.
//
// Features:
// - Uses AppCard for consistent card styling
// - AppButton for actions
// - AppTypography for all text styles
// - AppSpacing for all margins/padding
// - Status-based color coding
// - Theme-aware styling (Clean vs Playful)
// =============================================================================

/// A card widget displaying an invite code.
class InviteCodeCard extends StatelessWidget {
  /// Creates an [InviteCodeCard].
  const InviteCodeCard({
    super.key,
    required this.inviteCode,
    this.onDeactivate,
  });

  /// The invite code to display.
  final InviteCode inviteCode;

  /// Callback when deactivate is triggered.
  final VoidCallback? onDeactivate;

  /// Detects if the current theme is playful.
  bool _isPlayful(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        (primaryColor.r * 255 > 100 && primaryColor.b * 255 > 200);
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful(context);
    final isActive = inviteCode.canBeUsed;

    return AnimatedOpacity(
      duration: AppDuration.fast,
      opacity: isActive ? 1.0 : AppOpacity.disabled,
      child: AppCard(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with role badge and status
            _HeaderRow(
              inviteCode: inviteCode,
              isPlayful: isPlayful,
              isActive: isActive,
            ),
            SizedBox(height: AppSpacing.md),
            // Code display with copy button
            _CodeDisplay(
              code: inviteCode.code,
              isActive: isActive,
              isPlayful: isPlayful,
            ),
            SizedBox(height: AppSpacing.md),
            // Stats row with usage and expiry
            _StatsRow(
              inviteCode: inviteCode,
              isPlayful: isPlayful,
              isActive: isActive,
              onDeactivate: onDeactivate,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUBCOMPONENTS
// =============================================================================

/// Header row with role badge and status indicator.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.inviteCode,
    required this.isPlayful,
    required this.isActive,
  });

  final InviteCode inviteCode;
  final bool isPlayful;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Role badge
        _RoleBadge(
          role: inviteCode.role,
          isPlayful: isPlayful,
        ),
        const Spacer(),
        // Status badge
        _StatusBadge(
          isActive: isActive,
          isPlayful: isPlayful,
        ),
      ],
    );
  }
}

/// Role badge showing the target role for the invite.
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.role,
    required this.isPlayful,
  });

  final UserRole role;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(),
            size: AppIconSize.xs,
            color: roleColor,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            _getRoleDisplayName(),
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
              color: roleColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor() {
    switch (role) {
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

/// Status badge showing active/inactive state.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isActive,
    required this.isPlayful,
  });

  final bool isActive;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final statusColor = isActive
        ? (isPlayful ? PlayfulColors.success : CleanColors.success)
        : (isPlayful ? PlayfulColors.error : CleanColors.error);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: AppTypography.caption(isPlayful: isPlayful).copyWith(
          fontWeight: FontWeight.w500,
          color: statusColor,
        ),
      ),
    );
  }
}

/// Code display with copy functionality.
class _CodeDisplay extends StatelessWidget {
  const _CodeDisplay({
    required this.code,
    required this.isActive,
    required this.isPlayful,
  });

  final String code;
  final bool isActive;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final surfaceColor =
        isPlayful ? PlayfulColors.surfaceSubtle : CleanColors.surfaceSubtle;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;

    return Row(
      children: [
        // Code container
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: AppRadius.badge(isPlayful: isPlayful),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              code,
              style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        // Copy button
        AppButton.icon(
          icon: Icons.copy,
          tooltip: 'Copy code',
          size: ButtonSize.medium,
          onPressed: isActive
              ? () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Code copied to clipboard',
                        style: AppTypography.secondaryText(isPlayful: isPlayful)
                            .copyWith(color: Colors.white),
                      ),
                      duration: const Duration(seconds: 2),
                      backgroundColor: isPlayful
                          ? PlayfulColors.success
                          : CleanColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.badge(isPlayful: isPlayful),
                      ),
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }
}

/// Stats row showing usage, expiry, and deactivate action.
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.inviteCode,
    required this.isPlayful,
    required this.isActive,
    this.onDeactivate,
  });

  final InviteCode inviteCode;
  final bool isPlayful;
  final bool isActive;
  final VoidCallback? onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Usage stat
        _StatItem(
          icon: Icons.repeat,
          label: 'Uses',
          value: '${inviteCode.timesUsed}/${inviteCode.usageLimit}',
          isPlayful: isPlayful,
        ),
        SizedBox(width: AppSpacing.md),
        // Expiry stat (if applicable)
        if (inviteCode.expiresAt case final expiresAt?)
          _StatItem(
            icon: Icons.schedule,
            label: 'Expires',
            value: _formatDate(expiresAt),
            isPlayful: isPlayful,
            isWarning: DateTime.now().isAfter(expiresAt),
          ),
        const Spacer(),
        // Deactivate button
        if (isActive)
          AppButton.tertiary(
            label: 'Deactivate',
            icon: Icons.cancel_outlined,
            size: ButtonSize.small,
            foregroundColor:
                isPlayful ? PlayfulColors.error : CleanColors.error,
            onPressed: onDeactivate,
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Individual stat item showing icon, value, and label.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPlayful,
    this.isWarning = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPlayful;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final warningColor = isPlayful ? PlayfulColors.error : CleanColors.error;
    final normalColor =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final color = isWarning ? warningColor : normalColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppIconSize.xs,
          color: color,
        ),
        SizedBox(width: AppSpacing.xxs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.tertiaryText(isPlayful: isPlayful).copyWith(
                fontWeight: FontWeight.w500,
                color: isWarning
                    ? warningColor
                    : (isPlayful
                        ? PlayfulColors.textPrimary
                        : CleanColors.textPrimary),
              ),
            ),
            Text(
              label,
              style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
