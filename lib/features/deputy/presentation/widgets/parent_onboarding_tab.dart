import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/theme/theme.dart';
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
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
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
            SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),

            // Students Without Parents Section
            _SectionHeader(
              title: 'Students Without Parents',
              icon: Icons.person_outline_rounded,
              isPlayful: isPlayful,
              actionLabel: 'Link Parent',
              onActionTap: () => _showLinkParentDialog(context, ref),
            ),
            SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
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
                      padding: EdgeInsets.only(bottom: isPlayful ? 10 : AppSpacing.xs),
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
            if (studentsAsync.hasValue && (studentsAsync.value?.length ?? 0) > 5) ...[
              TextButton(
                onPressed: () => _showAllStudentsWithoutParents(
                  context,
                  ref,
                  studentsAsync.value ?? [],
                ),
                child: Text(
                  'View all ${studentsAsync.value?.length ?? 0} students',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg),

            // Pending Invites Section
            _SectionHeader(
              title: 'Pending Parent Invites',
              icon: Icons.mail_outline_rounded,
              isPlayful: isPlayful,
            ),
            SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
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
                      padding: EdgeInsets.only(bottom: isPlayful ? 10 : AppSpacing.xs),
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
            SizedBox(height: isPlayful ? 80 : 72), // Space for FAB (non-standard size for FAB clearance)
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: AppSpacing.sm),
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
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);
    final warningColor = isPlayful ? PlayfulColors.warning : CleanColors.warning;
    final infoColor = isPlayful ? PlayfulColors.info : CleanColors.info;

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.tertiary.withValues(alpha: AppOpacity.soft),
                  theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
                width: 1,
              ),
        boxShadow: AppShadows.card(isPlayful: isPlayful),
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? AppIconSize.hero - 8 : AppIconSize.xxl,
            height: isPlayful ? AppIconSize.hero - 8 : AppIconSize.xxl,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withValues(alpha: AppOpacity.soft),
              borderRadius: BorderRadius.circular(isPlayful ? AppRadius.lg : AppRadius.md),
            ),
            child: Icon(
              Icons.family_restroom_rounded,
              size: isPlayful ? AppIconSize.xl : AppIconSize.lg,
              color: theme.colorScheme.tertiary,
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.lg : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent Onboarding',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Link parents with their children',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
                color: warningColor,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? AppSpacing.xxs + 2 : AppSpacing.xxs),
              _StatItem(
                label: 'Pending',
                value: invitesAsync.when(
                  data: (i) => i.length.toString(),
                  loading: () => '...',
                  error: (_, _) => '-',
                ),
                color: infoColor,
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
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value ',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color.withValues(alpha: AppOpacity.heavy),
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
          size: isPlayful ? AppIconSize.md - 2 : AppIconSize.sm,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: isPlayful ? 0.3 : -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onActionTap != null)
          TextButton.icon(
            onPressed: onActionTap,
            icon: Icon(Icons.add_rounded, size: AppIconSize.xs + 2),
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);
    final warningColor = isPlayful ? PlayfulColors.warning : CleanColors.warning;

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md - 2 : AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
          width: 1,
        ),
        boxShadow: AppShadows.button(isPlayful: isPlayful),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: isPlayful ? 44 : 40,
            height: isPlayful ? 44 : 40,
            decoration: BoxDecoration(
              color: warningColor.withValues(alpha: AppOpacity.soft),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student.initials,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: warningColor,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? AppSpacing.md - 2 : AppSpacing.sm),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (student.className != null) ...[
                  SizedBox(height: AppSpacing.xxs - 2),
                  Text(
                    'Class ${student.className}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Link button
          OutlinedButton.icon(
            onPressed: onLinkParent,
            icon: Icon(Icons.link_rounded, size: AppIconSize.xs),
            label: const Text('Link'),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);
    final isExpired = invite.isExpired;

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md - 2 : AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: theme.colorScheme.surface,
        border: Border.all(
          color: isExpired
              ? theme.colorScheme.error.withValues(alpha: AppOpacity.medium)
              : theme.colorScheme.outline.withValues(alpha: AppOpacity.soft),
          width: 1,
        ),
        boxShadow: AppShadows.button(isPlayful: isPlayful),
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
                      ? theme.colorScheme.error.withValues(alpha: AppOpacity.soft)
                      : theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
                  borderRadius: BorderRadius.circular(isPlayful ? AppRadius.md : AppRadius.sm),
                ),
                child: Icon(
                  isExpired ? Icons.timer_off_outlined : Icons.vpn_key_rounded,
                  size: isPlayful ? AppIconSize.md : AppIconSize.sm,
                  color: isExpired
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: isPlayful ? AppSpacing.md - 2 : AppSpacing.sm),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invite.studentName ?? 'Unknown Student',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isExpired) ...[
                          SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxs + 2,
                              vertical: AppSpacing.xxs - 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              'EXPIRED',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    // Code
                    SelectableText(
                      invite.code,
                      style: theme.textTheme.bodySmall?.copyWith(
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
                    iconSize: AppIconSize.sm,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: 'Revoke invite',
                    onPressed: onRevoke,
                    iconSize: AppIconSize.sm,
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);
    final successColor = isPlayful ? PlayfulColors.success : CleanColors.success;
    final color = isPositive ? successColor : theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: (isPositive ? successColor : theme.colorScheme.primary)
            .withValues(alpha: AppOpacity.subtle),
        border: Border.all(
          color: (isPositive ? successColor : theme.colorScheme.outline)
              .withValues(alpha: AppOpacity.soft),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: isPlayful ? AppIconSize.xl + 8 : AppIconSize.xl + 4,
            color: color.withValues(alpha: AppOpacity.medium),
          ),
          SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.sm),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: AppOpacity.heavy),
            ),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: AppOpacity.medium),
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
      padding: EdgeInsets.all(isPlayful ? AppSpacing.xxl : AppSpacing.xl),
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
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: cardRadius,
        color: theme.colorScheme.error.withValues(alpha: AppOpacity.subtle),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: AppOpacity.soft),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: AppIconSize.xl + 4,
            color: theme.colorScheme.error.withValues(alpha: AppOpacity.medium),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error.withValues(alpha: AppOpacity.heavy),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: AppIconSize.xs + 2),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
