import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../admin_panel/domain/entities/invite_code.dart';
import '../../../auth/domain/entities/app_user.dart';

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

  @override
  Widget build(BuildContext context) {
    final isActive = inviteCode.canBeUsed;

    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? CleanColors.border : CleanColors.disabled,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRoleIcon(),
                          size: 14,
                          color: _getRoleColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRoleDisplayName(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getRoleColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? CleanColors.successLight
                          : CleanColors.errorLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? CleanColors.success
                            : CleanColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Code
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: CleanColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CleanColors.border),
                      ),
                      child: Text(
                        inviteCode.code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: CleanColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy code',
                    onPressed: isActive
                        ? () {
                            Clipboard.setData(
                                ClipboardData(text: inviteCode.code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.repeat,
                    label: 'Uses',
                    value: '${inviteCode.timesUsed}/${inviteCode.usageLimit}',
                  ),
                  const SizedBox(width: 16),
                  if (inviteCode.expiresAt != null)
                    _buildStatItem(
                      icon: Icons.schedule,
                      label: 'Expires',
                      value: _formatDate(inviteCode.expiresAt!),
                      isExpired: DateTime.now().isAfter(inviteCode.expiresAt!),
                    ),
                  const Spacer(),
                  if (isActive)
                    TextButton.icon(
                      onPressed: onDeactivate,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 18,
                        color: CleanColors.error,
                      ),
                      label: const Text(
                        'Deactivate',
                        style: TextStyle(color: CleanColors.error),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    bool isExpired = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: isExpired ? CleanColors.error : CleanColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isExpired
                    ? CleanColors.error
                    : CleanColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: CleanColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getRoleColor() {
    switch (inviteCode.role) {
      case UserRole.superadmin:
        return CleanColors.error;
      case UserRole.bigadmin:
        return CleanColors.primary;
      case UserRole.admin:
        return CleanColors.secondary;
      case UserRole.teacher:
        return CleanColors.info;
      case UserRole.student:
        return CleanColors.success;
      case UserRole.parent:
        return CleanColors.warning;
    }
  }

  IconData _getRoleIcon() {
    switch (inviteCode.role) {
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
    switch (inviteCode.role) {
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
