import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/deputy_provider.dart';
import 'link_parent_dialog.dart';

/// Parent Onboarding Tab for the Deputy Dashboard.
///
/// Shows:
/// - List of students without parents
/// - Button to generate parent invites
/// - List of pending parent invites with copy/revoke actions
class ParentOnboardingTab extends ConsumerWidget {
  const ParentOnboardingTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(studentsWithoutParentsProvider(schoolId));
    final invitesAsync = ref.watch(pendingParentInvitesProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(studentsWithoutParentsProvider(schoolId));
        ref.invalidate(pendingParentInvitesProvider(schoolId));
      },
      child: ResponsiveCenterScrollView(
        maxWidth: 1000,
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Card
            _OnboardingStatsCard(
              studentsAsync: studentsAsync,
              invitesAsync: invitesAsync,
              isPlayful: isPlayful,
            ),
            SizedBox(height: isPlayful ? 24 : 20),

            // Students Without Parents Section
            _SectionHeader(
              title: 'Students Without Parents',
              icon: Icons.person_outline_rounded,
              isPlayful: isPlayful,
              actionLabel: 'Link Parent',
              onActionTap: () => _showLinkParentDialog(context, ref),
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            studentsAsync.when(
              data: (students) {
                if (students.isEmpty) {
                  return _EmptyStateCard(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'All Students Have Parents',
                    message: 'Every student has at least one parent linked.',
                    isPlayful: isPlayful,
                    isPositive: true,
                  );
                }
                return Column(
                  children: students.take(5).map((student) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                      child: _StudentCard(
                        student: student,
                        isPlayful: isPlayful,
                        onLinkParent: () => _showLinkParentDialog(
                          context,
                          ref,
                          preselectedStudent: student,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => _LoadingCard(isPlayful: isPlayful),
              error: (error, stack) => _ErrorCard(
                error: error.toString(),
                onRetry: () => ref.invalidate(studentsWithoutParentsProvider(schoolId)),
                isPlayful: isPlayful,
              ),
            ),
            if (studentsAsync.hasValue && studentsAsync.value!.length > 5) ...[
              TextButton(
                onPressed: () => _showAllStudentsWithoutParents(
                  context,
                  ref,
                  studentsAsync.value!,
                ),
                child: Text(
                  'View all ${studentsAsync.value!.length} students',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            SizedBox(height: isPlayful ? 24 : 20),

            // Pending Invites Section
            _SectionHeader(
              title: 'Pending Parent Invites',
              icon: Icons.mail_outline_rounded,
              isPlayful: isPlayful,
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            invitesAsync.when(
              data: (invites) {
                if (invites.isEmpty) {
                  return _EmptyStateCard(
                    icon: Icons.inbox_outlined,
                    title: 'No Pending Invites',
                    message: 'Generate invites to link parents with students.',
                    isPlayful: isPlayful,
                  );
                }
                return Column(
                  children: invites.map((invite) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                      child: _InviteCard(
                        invite: invite,
                        isPlayful: isPlayful,
                        onCopy: () => _copyInviteCode(context, invite.code),
                        onRevoke: () => _revokeInvite(context, ref, invite),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => _LoadingCard(isPlayful: isPlayful),
              error: (error, stack) => _ErrorCard(
                error: error.toString(),
                onRetry: () => ref.invalidate(pendingParentInvitesProvider(schoolId)),
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(height: isPlayful ? 80 : 72), // Space for FAB
          ],
        ),
      ),
    );
  }

  void _showLinkParentDialog(
    BuildContext context,
    WidgetRef ref, {
    StudentWithoutParent? preselectedStudent,
  }) {
    showDialog(
      context: context,
      builder: (context) => LinkParentDialog(
        schoolId: schoolId,
        preselectedStudent: preselectedStudent,
      ),
    );
  }

  void _copyInviteCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _revokeInvite(BuildContext context, WidgetRef ref, ParentInvite invite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Invite'),
        content: Text(
          'Are you sure you want to revoke the invite for ${invite.studentName ?? "this student"}?\n\n'
          'The code "${invite.code}" will no longer be usable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final notifier = ref.read(deputyNotifierProvider.notifier);
                await notifier.revokeParentInvite(invite.id, schoolId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invite revoked'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to revoke invite: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  void _showAllStudentsWithoutParents(
    BuildContext context,
    WidgetRef ref,
    List<StudentWithoutParent> students,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Students Without Parents (${students.length})',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
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
                const Divider(height: 1),
                // List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _StudentCard(
                          student: student,
                          isPlayful: isPlayful,
                          onLinkParent: () {
                            Navigator.pop(context);
                            _showLinkParentDialog(
                              context,
                              ref,
                              preselectedStudent: student,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Stats card for parent onboarding.
class _OnboardingStatsCard extends StatelessWidget {
  const _OnboardingStatsCard({
    required this.studentsAsync,
    required this.invitesAsync,
    required this.isPlayful,
  });

  final AsyncValue<List<StudentWithoutParent>> studentsAsync;
  final AsyncValue<List<ParentInvite>> invitesAsync;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.tertiary.withValues(alpha: 0.15),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.tertiary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.family_restroom_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.tertiary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent Onboarding',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Link parents with their children',
                  style: TextStyle(
                    fontSize: isPlayful ? 12 : 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatItem(
                label: 'Need Parents',
                value: studentsAsync.when(
                  data: (s) => s.length.toString(),
                  loading: () => '...',
                  error: (_, _) => '-',
                ),
                color: Colors.orange,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              _StatItem(
                label: 'Pending',
                value: invitesAsync.when(
                  data: (i) => i.length.toString(),
                  loading: () => '...',
                  error: (_, _) => '-',
                ),
                color: Colors.blue,
                isPlayful: isPlayful,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small stat item widget.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final String value;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value ',
          style: TextStyle(
            fontSize: isPlayful ? 16 : 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 12 : 11,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isPlayful,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final IconData icon;
  final bool isPlayful;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: isPlayful ? 22 : 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isPlayful ? 18 : 16,
              fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: isPlayful ? 0.3 : -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onActionTap != null)
          TextButton.icon(
            onPressed: onActionTap,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(actionLabel!),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }
}

/// Student card widget.
class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.isPlayful,
    required this.onLinkParent,
  });

  final StudentWithoutParent student;
  final bool isPlayful;
  final VoidCallback onLinkParent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 14 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isPlayful ? 44 : 40,
            height: isPlayful ? 44 : 40,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.initials,
                style: TextStyle(
                  fontSize: isPlayful ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? 14 : 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (student.className != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Class ${student.className}',
                    style: TextStyle(
                      fontSize: isPlayful ? 13 : 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Link button
          OutlinedButton.icon(
            onPressed: onLinkParent,
            icon: const Icon(Icons.link_rounded, size: 16),
            label: const Text('Link'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Invite card widget.
class _InviteCard extends StatelessWidget {
  const _InviteCard({
    required this.invite,
    required this.isPlayful,
    required this.onCopy,
    required this.onRevoke,
  });

  final ParentInvite invite;
  final bool isPlayful;
  final VoidCallback onCopy;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpired = invite.isExpired;

    return Container(
      padding: EdgeInsets.all(isPlayful ? 14 : 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: isExpired
              ? theme.colorScheme.error.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: isPlayful ? 44 : 40,
                height: isPlayful ? 44 : 40,
                decoration: BoxDecoration(
                  color: isExpired
                      ? theme.colorScheme.error.withValues(alpha: 0.1)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                child: Icon(
                  isExpired ? Icons.timer_off_outlined : Icons.vpn_key_rounded,
                  size: isPlayful ? 24 : 20,
                  color: isExpired
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: isPlayful ? 14 : 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invite.studentName ?? 'Unknown Student',
                          style: TextStyle(
                            fontSize: isPlayful ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (isExpired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'EXPIRED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Code
                    SelectableText(
                      invite.code,
                      style: TextStyle(
                        fontSize: isPlayful ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                        color: theme.colorScheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'Copy code',
                    onPressed: onCopy,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: 'Revoke invite',
                    onPressed: onRevoke,
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty state card.
class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.isPlayful,
    this.isPositive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool isPlayful;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isPositive ? Colors.green : theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: (isPositive ? Colors.green : theme.colorScheme.primary)
            .withValues(alpha: 0.05),
        border: Border.all(
          color: (isPositive ? Colors.green : theme.colorScheme.outline)
              .withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isPlayful ? 40 : 36,
            color: color.withValues(alpha: 0.6),
          ),
          SizedBox(height: isPlayful ? 12 : 10),
          Text(
            title,
            style: TextStyle(
              fontSize: isPlayful ? 16 : 15,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              fontSize: isPlayful ? 13 : 12,
              color: color.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Loading card.
class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isPlayful ? 32 : 24),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Error card with retry button.
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.error,
    required this.onRetry,
    required this.isPlayful,
  });

  final String error;
  final VoidCallback onRetry;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.error.withValues(alpha: 0.05),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 36,
            color: theme.colorScheme.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          Text(
            error,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.error.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
