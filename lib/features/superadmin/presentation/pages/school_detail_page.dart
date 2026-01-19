import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classio/core/localization/app_localizations.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../providers/superadmin_provider.dart';
import '../widgets/principal_invite_section.dart';
import '../widgets/school_actions_section.dart';
import '../widgets/school_header_card.dart';
import '../widgets/school_stats_section.dart';
import '../widgets/school_subscription_section.dart';

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
                SchoolHeaderCard(
                  schoolName: school.name,
                  schoolId: schoolId,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Stats Section
                SchoolStatsSection(
                  totalStudents: school.totalStudents,
                  totalTeachers: school.totalTeachers,
                  totalClasses: school.totalClasses,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Subscription Section
                SchoolSubscriptionSection(
                  school: school,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Principal Invitation Code Section
                PrincipalInviteSection(
                  schoolId: schoolId,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Quick Actions
                SchoolActionsSection(
                  schoolId: schoolId,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 80 : 72),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorContent(
          theme: theme,
          error: error.toString(),
          onRetry: () => ref.invalidate(schoolDetailProvider(schoolId)),
        ),
      ),
    );
  }
}

/// Error content widget shown when loading the school fails.
class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.theme,
    required this.error,
    required this.onRetry,
  });

  final ThemeData theme;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
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
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
