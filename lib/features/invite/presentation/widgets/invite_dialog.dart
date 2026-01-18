import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/features/auth/domain/entities/app_user.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/core/theme/app_colors.dart';
import '../providers/invite_provider.dart';
import '../../domain/entities/invite_token.dart';

/// A dialog widget for generating and managing invite tokens.
///
/// This dialog allows users to:
/// - Select a role to invite (based on their permissions)
/// - Select a class (required for teachers inviting students)
/// - Set an optional expiration date
/// - Generate and copy invite tokens
/// - View and manage existing tokens
class InviteDialog extends ConsumerStatefulWidget {
  const InviteDialog({super.key});

  /// Shows the invite dialog.
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const InviteDialog(),
    );
  }

  @override
  ConsumerState<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<InviteDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserRole? _selectedRole;
  String? _selectedClassId;
  DateTime? _expiresAt;
  bool _hasExpiration = false;

  // Mock class data - in real implementation, this would come from a provider
  final List<Map<String, String>> _availableClasses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final invitableRoles = ref.read(invitableRolesProvider);
      if (invitableRoles.isNotEmpty) {
        setState(() {
          _selectedRole = invitableRoles.first;
        });
      }
      ref.read(inviteNotifierProvider.notifier).loadMyTokens();
      _loadClasses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    // In real implementation, load classes from a provider
    // For now, we'll load classes the teacher teaches
    // This should be replaced with actual class loading logic
  }

  Future<void> _generateToken() async {
    if (_selectedRole == null) return;

    final currentUser = ref.read(currentUserProvider);
    final currentRole = currentUser?.role;

    // Validate class selection for teachers inviting students
    if (currentRole == UserRole.teacher && _selectedRole == UserRole.student) {
      if (_selectedClassId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a class for student invitations'),
            backgroundColor: CleanColors.error,
          ),
        );
        return;
      }
    }

    final token = await ref.read(inviteNotifierProvider.notifier).generateInvite(
          targetRole: _selectedRole!,
          classId: _selectedClassId,
          expiresAt: _hasExpiration ? _expiresAt : null,
        );

    if (token != null && mounted) {
      // Show success with copy option
      _showTokenGeneratedDialog(token);
    }
  }

  void _showTokenGeneratedDialog(String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: CleanColors.success),
            SizedBox(width: 8),
            Text('Token Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share this token with the person you want to invite:',
              style: TextStyle(color: CleanColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CleanColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CleanColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      token,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Token copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Role: ${_selectedRole?.name.toUpperCase() ?? "Unknown"}',
              style: const TextStyle(color: CleanColors.textSecondary),
            ),
            if (_hasExpiration && _expiresAt != null)
              Text(
                'Expires: ${_formatDateTime(_expiresAt!)}',
                style: const TextStyle(color: CleanColors.textSecondary),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectExpirationDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _expiresAt ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_expiresAt ?? now),
      );

      if (time != null) {
        setState(() {
          _expiresAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitableRoles = ref.watch(invitableRolesProvider);
    final inviteState = ref.watch(inviteNotifierProvider);
    final canInviteAny = ref.watch(canInviteProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (!canInviteAny) {
      return AlertDialog(
        title: const Text('Invite Users'),
        content: const Text(
          'You do not have permission to invite users.',
          style: TextStyle(color: CleanColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: CleanColors.divider),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: CleanColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Invite Users',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Create Invite'),
                Tab(text: 'My Invites'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Create Invite Tab
                  _buildCreateInviteTab(
                    invitableRoles,
                    inviteState,
                    currentUser,
                  ),

                  // My Invites Tab
                  _buildMyInvitesTab(inviteState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateInviteTab(
    List<UserRole> invitableRoles,
    InviteState inviteState,
    AppUser? currentUser,
  ) {
    final isTeacherInvitingStudent = currentUser?.role == UserRole.teacher &&
        _selectedRole == UserRole.student;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role selection
          const Text(
            'Select Role',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CleanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<UserRole>(
            initialValue: _selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            isExpanded: true,
            items: invitableRoles.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(role),
                      size: 20,
                      color: CleanColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_getRoleDisplayName(role)),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
                // Clear class selection if not needed
                if (currentUser?.role != UserRole.teacher ||
                    value != UserRole.student) {
                  _selectedClassId = null;
                }
              });
            },
          ),

          // Class selection (for teachers inviting students)
          if (isTeacherInvitingStudent) ...[
            const SizedBox(height: 16),
            const Text(
              'Select Class',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: CleanColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Students will be enrolled in this class upon registration',
              style: TextStyle(
                fontSize: 12,
                color: CleanColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedClassId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Select a class you teach',
              ),
              isExpanded: true,
              items: _availableClasses.map((classData) {
                return DropdownMenuItem(
                  value: classData['id'],
                  child: Text(
                    classData['name'] ?? 'Unknown Class',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
            ),
            if (_availableClasses.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No classes available. Please contact an administrator.',
                  style: TextStyle(
                    fontSize: 12,
                    color: CleanColors.warning,
                  ),
                ),
              ),
          ],

          // Expiration toggle
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Set Expiration'),
            subtitle: const Text(
              'Token will become invalid after this date',
              style: TextStyle(fontSize: 12),
            ),
            value: _hasExpiration,
            onChanged: (value) {
              setState(() {
                _hasExpiration = value;
                if (value && _expiresAt == null) {
                  _expiresAt = DateTime.now().add(const Duration(days: 7));
                }
              });
            },
          ),

          // Expiration date picker
          if (_hasExpiration) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectExpirationDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: CleanColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _expiresAt != null
                            ? _formatDateTime(_expiresAt!)
                            : 'Select date and time',
                        style: TextStyle(
                          color: _expiresAt != null
                              ? CleanColors.textPrimary
                              : CleanColors.hint,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
          ],

          // Error message
          if (inviteState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CleanColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: CleanColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      inviteState.error!,
                      style: const TextStyle(color: CleanColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Generate button
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: inviteState.isLoading ||
                      _selectedRole == null ||
                      (isTeacherInvitingStudent && _selectedClassId == null)
                  ? null
                  : _generateToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: CleanColors.primary,
                foregroundColor: CleanColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: inviteState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CleanColors.onPrimary,
                      ),
                    )
                  : const Text('Generate Invite Token'),
            ),
          ),

          // Permission info
          const SizedBox(height: 16),
          _buildPermissionInfo(currentUser?.role),
        ],
      ),
    );
  }

  Widget _buildMyInvitesTab(InviteState inviteState) {
    final validTokens = inviteState.myTokens.where((t) => t.isValid).toList();
    final usedTokens = inviteState.myTokens.where((t) => !t.isValid).toList();

    if (inviteState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (inviteState.myTokens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: CleanColors.disabled,
            ),
            SizedBox(height: 16),
            Text(
              'No invite tokens yet',
              style: TextStyle(
                color: CleanColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first invite token to get started',
              style: TextStyle(
                color: CleanColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (validTokens.isNotEmpty) ...[
          const Text(
            'Active Tokens',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CleanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...validTokens.map((token) => _buildTokenCard(token)),
        ],
        if (usedTokens.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Used/Expired Tokens',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: CleanColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...usedTokens.map((token) => _buildTokenCard(token, isInactive: true)),
        ],
      ],
    );
  }

  Widget _buildTokenCard(InviteToken token, {bool isInactive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: isInactive ? 0.6 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Role icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isInactive
                      ? CleanColors.disabled.withValues(alpha: 0.1)
                      : CleanColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getRoleIcon(token.role),
                  color: isInactive ? CleanColors.disabled : CleanColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Token info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      token.token,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For: ${_getRoleDisplayName(token.role)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CleanColors.textSecondary,
                      ),
                    ),
                    if (token.expiresAt != null)
                      Text(
                        token.isExpired
                            ? 'Expired: ${_formatDateTime(token.expiresAt!)}'
                            : 'Expires: ${_formatDateTime(token.expiresAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: token.isExpired
                              ? CleanColors.error
                              : CleanColors.textSecondary,
                        ),
                      ),
                    if (token.isUsed)
                      const Text(
                        'Used',
                        style: TextStyle(
                          fontSize: 12,
                          color: CleanColors.success,
                        ),
                      ),
                  ],
                ),
              ),

              // Actions
              if (!isInactive) ...[
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy token',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: token.token));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Token copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, size: 20),
                  tooltip: 'Revoke token',
                  onPressed: () => _confirmRevokeToken(token),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRevokeToken(InviteToken token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Token'),
        content: Text(
          'Are you sure you want to revoke the token "${token.token}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: CleanColors.error,
              foregroundColor: CleanColors.onError,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success =
          await ref.read(inviteNotifierProvider.notifier).revokeToken(token.token);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token revoked successfully'),
            backgroundColor: CleanColors.success,
          ),
        );
      }
    }
  }

  Widget _buildPermissionInfo(UserRole? role) {
    if (role == null) return const SizedBox.shrink();

    String info;
    switch (role) {
      case UserRole.superadmin:
        info = 'As a Super Admin, you can invite Big Admins.';
        break;
      case UserRole.bigadmin:
        info = 'As a Big Admin, you can invite Admins and Teachers.';
        break;
      case UserRole.admin:
        info = 'As an Admin, you can invite Teachers and Parents.';
        break;
      case UserRole.teacher:
        info =
            'As a Teacher, you can invite Students to classes you teach.';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CleanColors.infoLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: CleanColors.info, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(
                fontSize: 12,
                color: CleanColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
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

  String _getRoleDisplayName(UserRole role) {
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
}

/// A compact button widget for triggering the invite dialog.
///
/// Can be placed in app bars or floating action buttons.
class InviteButton extends ConsumerWidget {
  const InviteButton({
    super.key,
    this.showLabel = true,
  });

  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canInviteAny = ref.watch(canInviteProvider);

    if (!canInviteAny) {
      return const SizedBox.shrink();
    }

    if (showLabel) {
      return TextButton.icon(
        onPressed: () => InviteDialog.show(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Invite'),
      );
    }

    return IconButton(
      icon: const Icon(Icons.person_add),
      tooltip: 'Invite Users',
      onPressed: () => InviteDialog.show(context),
    );
  }
}

/// A floating action button for the invite dialog.
class InviteFAB extends ConsumerWidget {
  const InviteFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canInviteAny = ref.watch(canInviteProvider);

    if (!canInviteAny) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => InviteDialog.show(context),
      icon: const Icon(Icons.person_add),
      label: const Text('Invite'),
    );
  }
}
