import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/entities.dart';
import '../providers/superadmin_provider.dart';
import 'analytics_components.dart';

/// Bottom sheet widget for displaying school analytics.
///
/// Shows detailed analytics including:
/// - User statistics (total users, students, teachers, admins, parents)
/// - School structure (classes, subjects)
/// - Quick stats (ratios and averages)
class SchoolAnalyticsSheet extends ConsumerWidget {
  const SchoolAnalyticsSheet({
    super.key,
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
              _buildHandleBar(theme),
              _buildTitle(context, theme),
              const Divider(height: 1),
              Expanded(
                child: analyticsAsync.when(
                  data: (analytics) => _AnalyticsContent(
                    scrollController: scrollController,
                    analytics: analytics,
                    isPlayful: isPlayful,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => _ErrorContent(
                    schoolId: schoolId,
                    error: error.toString(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandleBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Padding(
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
    );
  }
}

/// Content widget displaying the analytics data.
class _AnalyticsContent extends StatelessWidget {
  const _AnalyticsContent({
    required this.scrollController,
    required this.analytics,
    required this.isPlayful,
  });

  final ScrollController scrollController;
  final SchoolAnalytics analytics;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      children: [
        Text(
          analytics.schoolName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isPlayful ? 24 : 16),

        // User Statistics
        AnalyticsSectionTitle(title: 'User Statistics', isPlayful: isPlayful),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: AnalyticCard(
                icon: Icons.people_rounded,
                label: 'Total Users',
                value: analytics.totalUsers.toString(),
                color: theme.colorScheme.primary,
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: AnalyticCard(
                icon: Icons.school_rounded,
                label: 'Students',
                value: analytics.totalStudents.toString(),
                color: Colors.orange,
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: AnalyticCard(
                icon: Icons.person_rounded,
                label: 'Teachers',
                value: analytics.totalTeachers.toString(),
                color: Colors.green,
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: AnalyticCard(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admins',
                value: analytics.totalAdmins.toString(),
                color: Colors.blue,
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: AnalyticCard(
                icon: Icons.family_restroom_rounded,
                label: 'Parents',
                value: analytics.totalParents.toString(),
                color: Colors.pink,
                isPlayful: isPlayful,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
        SizedBox(height: isPlayful ? 24 : 16),

        // School Structure
        AnalyticsSectionTitle(title: 'School Structure', isPlayful: isPlayful),
        SizedBox(height: isPlayful ? 12 : 8),
        Row(
          children: [
            Expanded(
              child: AnalyticCard(
                icon: Icons.class_rounded,
                label: 'Classes',
                value: analytics.totalClasses.toString(),
                color: Colors.purple,
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: isPlayful ? 12 : 8),
            Expanded(
              child: AnalyticCard(
                icon: Icons.menu_book_rounded,
                label: 'Subjects',
                value: analytics.totalSubjects.toString(),
                color: Colors.teal,
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 24 : 16),

        // Quick Stats Summary
        AnalyticsSectionTitle(title: 'Quick Stats', isPlayful: isPlayful),
        SizedBox(height: isPlayful ? 12 : 8),
        QuickStatsCard(analytics: analytics, isPlayful: isPlayful),
        SizedBox(height: isPlayful ? 32 : 24),
      ],
    );
  }
}

/// Error content widget shown when loading analytics fails.
class _ErrorContent extends ConsumerWidget {
  const _ErrorContent({
    required this.schoolId,
    required this.error,
  });

  final String schoolId;
  final String error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
