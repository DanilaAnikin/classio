import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/app_localizations.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/superadmin_provider.dart';
import '../widgets/subscription_management_dialog.dart';

/// School detail page for SuperAdmin.
///
/// Shows detailed information about a specific school including:
/// - School statistics (students, teachers, classes)
/// - Subscription status
/// - Quick actions (manage subscription, view users, etc.)
class SchoolDetailPage extends ConsumerWidget {
  const SchoolDetailPage({
    super.key,
    required this.schoolId,
  });

  final String schoolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final schoolAsync = ref.watch(schoolDetailProvider(schoolId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.schoolDetails),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: schoolAsync.when(
        data: (school) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(schoolDetailProvider(schoolId));
          },
          child: ResponsiveCenterScrollView(
            maxWidth: 800,
            padding: EdgeInsets.all(isPlayful ? 16 : 12),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // School Header Card
                _buildHeaderCard(context, school, isPlayful),
                SizedBox(height: isPlayful ? 24 : 20),

                // Stats Section
                _buildStatsSection(context, school, isPlayful),
                SizedBox(height: isPlayful ? 24 : 20),

                // Subscription Section
                _buildSubscriptionSection(context, school, isPlayful),
                SizedBox(height: isPlayful ? 24 : 20),

                // Principal Invitation Code Section
                _PrincipalInviteSection(
                  schoolId: schoolId,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Quick Actions
                _buildActionsSection(context, school, isPlayful),
                SizedBox(height: isPlayful ? 80 : 72),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load school',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(schoolDetailProvider(schoolId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, dynamic school, bool isPlayful) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 24 : 16),
        child: Column(
          children: [
            Container(
              width: isPlayful ? 80 : 64,
              height: isPlayful ? 80 : 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: isPlayful ? 40 : 32,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 16 : 12),
            Text(
              school.name ?? 'Unknown School',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'ID: $schoolId',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, dynamic school, bool isPlayful) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.people_outline,
                label: 'Students',
                value: school.totalStudents?.toString() ?? '0',
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.person_outline,
                label: 'Teachers',
                value: school.totalTeachers?.toString() ?? '0',
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.class_outlined,
                label: 'Classes',
                value: school.totalClasses?.toString() ?? '0',
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isPlayful,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        child: Column(
          children: [
            Icon(
              icon,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: isPlayful ? 8 : 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(
    BuildContext context,
    SchoolWithStats school,
    bool isPlayful,
  ) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    // Get subscription status color and icon
    Color statusColor;
    IconData statusIcon;
    switch (school.subscriptionStatus) {
      case SubscriptionStatus.trial:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty_rounded;
      case SubscriptionStatus.pro:
        statusColor = Colors.blue;
        statusIcon = Icons.star_rounded;
      case SubscriptionStatus.max:
        statusColor = Colors.purple;
        statusIcon = Icons.diamond_rounded;
      case SubscriptionStatus.expired:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.warning_rounded;
      case SubscriptionStatus.suspended:
        statusColor = Colors.red;
        statusIcon = Icons.block_rounded;
    }

    // Build subtitle text
    String subtitleText;
    if (school.subscriptionExpiresAt != null) {
      final expiryDate = dateFormat.format(school.subscriptionExpiresAt!);
      final isExpired = school.subscriptionExpiresAt!.isBefore(DateTime.now());
      subtitleText = isExpired ? 'Expired on $expiryDate' : 'Expires on $expiryDate';
    } else if (school.subscriptionStatus.isPaid) {
      subtitleText = 'No expiry (perpetual)';
    } else {
      subtitleText = 'Subscription status';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        Card(
          elevation: isPlayful ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            side: isPlayful
                ? BorderSide.none
                : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 16 : 12,
              vertical: isPlayful ? 8 : 4,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
            ),
            title: Text(
              school.subscriptionStatus.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
            subtitle: Text(subtitleText),
            trailing: FilledButton.tonal(
              onPressed: () => _openSubscriptionDialog(context, school),
              child: const Text('Manage'),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openSubscriptionDialog(
    BuildContext context,
    SchoolWithStats school,
  ) async {
    await SubscriptionManagementDialog.show(
      context,
      schoolId: school.id,
      schoolName: school.name,
      currentStatus: school.subscriptionStatus,
      currentExpiresAt: school.subscriptionExpiresAt,
    );
  }

  Widget _buildActionsSection(BuildContext context, dynamic school, bool isPlayful) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        Wrap(
          spacing: isPlayful ? 12 : 8,
          runSpacing: isPlayful ? 12 : 8,
          children: [
            _buildActionChip(
              context,
              icon: Icons.people_outline,
              label: 'View Users',
              onTap: () {
                context.pushSuperadminSchoolUsers(schoolId);
              },
              isPlayful: isPlayful,
            ),
            _buildActionChip(
              context,
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                context.pushSuperadminSchoolSettings(schoolId);
              },
              isPlayful: isPlayful,
            ),
            _buildActionChip(
              context,
              icon: Icons.analytics_outlined,
              label: 'Analytics',
              onTap: () {
                _showAnalyticsDialog(context, schoolId, isPlayful);
              },
              isPlayful: isPlayful,
            ),
          ],
        ),
      ],
    );
  }

  void _showAnalyticsDialog(BuildContext context, String schoolId, bool isPlayful) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isPlayful ? 24 : 16),
        ),
      ),
      builder: (context) => _SchoolAnalyticsSheet(
        schoolId: schoolId,
        isPlayful: isPlayful,
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPlayful,
  }) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 8),
      ),
    );
  }
}

/// Widget for displaying and managing the principal invitation code.
class _PrincipalInviteSection extends ConsumerWidget {
  const _PrincipalInviteSection({
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenAsync = ref.watch(schoolPrincipalTokenProvider(schoolId));
    final superAdminState = ref.watch(superAdminNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.key_rounded,
              size: isPlayful ? 24 : 20,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: isPlayful ? 8 : 6),
            Text(
              'Principal Invitation Code',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 8 : 6),
        Text(
          'Share this code with the school principal to allow them to register.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        tokenAsync.when(
          data: (token) => _buildTokenCard(
            context,
            ref,
            token: token,
            isLoading: superAdminState.isLoading,
          ),
          loading: () => _buildLoadingCard(context),
          error: (error, _) => _buildErrorCard(context, ref, error.toString()),
        ),
      ],
    );
  }

  Widget _buildTokenCard(
    BuildContext context,
    WidgetRef ref, {
    required String? token,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: Column(
          children: [
            if (token != null) ...[
              // Token Display
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isPlayful ? 20 : 16,
                  vertical: isPlayful ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SelectableText(
                        token,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 3,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isPlayful ? 16 : 12),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : () => _copyToClipboard(context, token),
                      icon: const Icon(Icons.copy_rounded),
                      label: const Text('Copy Code'),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isPlayful ? 12 : 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isPlayful ? 12 : 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => _regenerateToken(context, ref),
                      icon: isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isPlayful ? 12 : 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // No token available
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isPlayful ? 20 : 16,
                  vertical: isPlayful ? 24 : 20,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.key_off_rounded,
                      size: isPlayful ? 48 : 40,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    SizedBox(height: isPlayful ? 12 : 8),
                    Text(
                      'No Active Invitation Code',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: isPlayful ? 4 : 2),
                    Text(
                      'Generate a new code for the principal to register.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isPlayful ? 16 : 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _regenerateToken(context, ref),
                  icon: isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.add_rounded),
                  label: const Text('Generate Invitation Code'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isPlayful ? 14 : 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 32 : 24),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 40 : 32,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            Text(
              'Failed to load invitation code',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: isPlayful ? 8 : 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: isPlayful ? 16 : 12),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(schoolPrincipalTokenProvider(schoolId)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String token) {
    Clipboard.setData(ClipboardData(text: token));

    // Capture ScaffoldMessenger before building the SnackBar
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Invitation code copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _regenerateToken(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Code?'),
        content: const Text(
          'This will create a new invitation code for the principal. '
          'Any existing unused code will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Generate new token
    final newToken = await ref
        .read(superAdminNotifierProvider.notifier)
        .generatePrincipalToken(schoolId);

    if (context.mounted) {
      if (newToken != null) {
        // Refresh the token provider to show the new token
        ref.invalidate(schoolPrincipalTokenProvider(schoolId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New invitation code generated successfully'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final errorMessage = ref.read(superAdminNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to generate new code'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Bottom sheet widget for displaying school analytics.
class _SchoolAnalyticsSheet extends ConsumerWidget {
  const _SchoolAnalyticsSheet({
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final analyticsAsync = ref.watch(schoolAnalyticsProvider(schoolId));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isPlayful ? 24 : 16),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.all(isPlayful ? 20 : 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: theme.colorScheme.primary,
                      size: isPlayful ? 28 : 24,
                    ),
                    SizedBox(width: isPlayful ? 12 : 8),
                    Expanded(
                      child: Text(
                        'School Analytics',
                        style: theme.textTheme.headlineSmall?.copyWith(
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
              const Divider(height: 1),
              // Content
              Expanded(
                child: analyticsAsync.when(
                  data: (analytics) => _buildAnalyticsContent(
                    context,
                    scrollController,
                    analytics,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => _buildErrorContent(
                    context,
                    ref,
                    error.toString(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    ScrollController scrollController,
    SchoolAnalytics analytics,
  ) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      children: [
        // School name header
        Text(
          analytics.schoolName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isPlayful ? 24 : 16),

        // User Statistics
        _buildSectionTitle(context, 'User Statistics'),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.people_rounded,
                label: 'Total Users',
                value: analytics.totalUsers.toString(),
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.school_rounded,
                label: 'Students',
                value: analytics.totalStudents.toString(),
                color: Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.person_rounded,
                label: 'Teachers',
                value: analytics.totalTeachers.toString(),
                color: Colors.green,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admins',
                value: analytics.totalAdmins.toString(),
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.family_restroom_rounded,
                label: 'Parents',
                value: analytics.totalParents.toString(),
                color: Colors.pink,
              ),
            ),
            const Expanded(child: SizedBox()), // Placeholder for alignment
          ],
        ),
        SizedBox(height: isPlayful ? 24 : 16),

        // School Structure
        _buildSectionTitle(context, 'School Structure'),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.class_rounded,
                label: 'Classes',
                value: analytics.totalClasses.toString(),
                color: Colors.purple,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: _buildAnalyticCard(
                context,
                icon: Icons.menu_book_rounded,
                label: 'Subjects',
                value: analytics.totalSubjects.toString(),
                color: Colors.teal,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 24 : 16),

        // Quick Stats Summary
        _buildSectionTitle(context, 'Quick Stats'),
        SizedBox(height: isPlayful ? 12 : 8),
        Card(
          elevation: isPlayful ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            side: isPlayful
                ? BorderSide.none
                : BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: EdgeInsets.all(isPlayful ? 16 : 12),
            child: Column(
              children: [
                _buildQuickStatRow(
                  context,
                  label: 'Student to Teacher Ratio',
                  value: analytics.totalTeachers > 0
                      ? '${(analytics.totalStudents / analytics.totalTeachers).toStringAsFixed(1)} : 1'
                      : 'N/A',
                ),
                const Divider(),
                _buildQuickStatRow(
                  context,
                  label: 'Average Students per Class',
                  value: analytics.totalClasses > 0
                      ? (analytics.totalStudents / analytics.totalClasses)
                          .toStringAsFixed(1)
                      : 'N/A',
                ),
                const Divider(),
                _buildQuickStatRow(
                  context,
                  label: 'Subjects per Teacher',
                  value: analytics.totalTeachers > 0
                      ? (analytics.totalSubjects / analytics.totalTeachers)
                          .toStringAsFixed(1)
                      : 'N/A',
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isPlayful ? 32 : 24),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAnalyticCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isPlayful ? 28 : 24,
              ),
            ),
            SizedBox(height: isPlayful ? 12 : 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: isPlayful ? 4 : 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isPlayful ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load analytics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(schoolAnalyticsProvider(schoolId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
