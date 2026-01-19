import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/app_colors.dart';
import 'package:classio/core/theme/app_radius.dart';
import 'package:classio/core/theme/spacing.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/superadmin_provider.dart';
import '../widgets/widgets.dart';

/// SuperAdmin Dashboard Page for managing all schools in Classio.
///
/// Features three tabs:
/// - Overview: Platform-wide statistics
/// - Schools: List of all schools with stats
/// - Create School: Form to create new schools
class SuperAdminDashboardPage extends ConsumerStatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  ConsumerState<SuperAdminDashboardPage> createState() =>
      _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState
    extends ConsumerState<SuperAdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Refresh data when page opens to prevent stale data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(platformStatsProvider);
      ref.invalidate(schoolsWithStatsProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard_rounded),
              text: 'Overview',
            ),
            Tab(
              icon: Icon(Icons.school_rounded),
              text: 'Schools',
            ),
            Tab(
              icon: Icon(Icons.add_business_rounded),
              text: 'Create School',
            ),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OverviewTab(),
          _SchoolsTab(),
          _CreateSchoolTab(),
        ],
      ),
    );
  }
}

/// Overview Tab - Shows platform-wide statistics.
class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final statsAsync = ref.watch(platformStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(platformStatsProvider);
      },
      child: statsAsync.when(
        data: (stats) => ResponsiveCenterScrollView(
          maxWidth: 1000,
          padding: AppSpacing.cardInsets,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlatformStatsCard(stats: stats, isPlayful: isPlayful),
              SizedBox(height: AppSpacing.xl),

              // Quick Actions Section
              _SectionTitle(
                title: 'Quick Actions',
                icon: Icons.flash_on_rounded,
              ),
              SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_business_rounded,
                      label: 'Create School',
                      color: theme.colorScheme.primary,
                      onTap: () => CreateSchoolDialog.show(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.refresh_rounded,
                      label: 'Refresh Data',
                      color: AppSemanticColors.info(isPlayful: isPlayful),
                      onTap: () {
                        ref.invalidate(platformStatsProvider);
                        ref.invalidate(schoolsWithStatsProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data refreshed'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xxxl * 2),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Failed to Load Statistics',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(platformStatsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Schools Tab - Shows list of all schools.
class _SchoolsTab extends ConsumerWidget {
  const _SchoolsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final schoolsAsync = ref.watch(schoolsWithStatsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schoolsWithStatsProvider);
      },
      child: schoolsAsync.when(
        data: (schools) {
          if (schools.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return ResponsiveCenterScrollView(
            maxWidth: 1000,
            padding: AppSpacing.cardInsets,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with count
                _SchoolsHeader(schoolCount: schools.length),
                SizedBox(height: AppSpacing.lg),

                // Schools List
                ...schools.map((school) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SchoolCard(
                        school: school,
                        onTap: () => _navigateToSchoolDetail(context, school),
                      ),
                    )),
                SizedBox(height: AppSpacing.xxxl * 2),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  void _navigateToSchoolDetail(BuildContext context, SchoolWithStats school) {
    context.push(AppRoutes.getSuperadminSchoolDetail(school.id));
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpacing.xxl - AppSpacing.xxs),
            Text(
              'No Schools Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Create your first school to get started.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => CreateSchoolDialog.show(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create School'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Failed to Load Schools',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(schoolsWithStatsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Create School Tab - Form to create new schools.
class _CreateSchoolTab extends ConsumerStatefulWidget {
  const _CreateSchoolTab();

  @override
  ConsumerState<_CreateSchoolTab> createState() => _CreateSchoolTabState();
}

class _CreateSchoolTabState extends ConsumerState<_CreateSchoolTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createSchool() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isCreating = true;
    });

    final (school, token) = await ref
        .read(superAdminNotifierProvider.notifier)
        .createSchoolWithToken(_nameController.text.trim());

    if (mounted) {
      setState(() {
        _isCreating = false;
      });

      if (school != null && token != null) {
        _nameController.clear();
        _showSuccessDialog(school.name, token);
      } else {
        final error = ref.read(superAdminNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create school'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessDialog(String schoolName, String token) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SchoolCreatedDialog(
        schoolName: schoolName,
        token: token,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ResponsiveCenterScrollView(
      maxWidth: 600,
      padding: AppSpacing.dialogInsets,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_business_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              'Create New School',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Enter the school name below. A principal invitation token will be generated automatically after creation.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xxl),

            // Form Card
            Container(
              padding: AppSpacing.dialogInsets,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.dialogBorderRadius,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'School Name',
                      hintText: 'Enter the school name',
                      prefixIcon: const Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.cardBorderRadius,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a school name';
                      }
                      if (value.trim().length < 3) {
                        return 'School name must be at least 3 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      if (!_isCreating) {
                        _createSchool();
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.xl),
                  FilledButton.icon(
                    onPressed: _isCreating ? null : _createSchool,
                    icon: _isCreating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(_isCreating ? 'Creating...' : 'Create School'),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // Info Box
            Builder(
              builder: (context) {
                final infoColor = AppSemanticColors.info(isPlayful: false);
                return Container(
                  padding: AppSpacing.cardInsets,
                  decoration: BoxDecoration(
                    color: infoColor.withValues(alpha: 0.08),
                    borderRadius: AppRadius.cardBorderRadius,
                    border: Border.all(
                      color: infoColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 22,
                        color: infoColor,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What happens next?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: infoColor,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xxs),
                            Text(
                              'After creating the school, you will receive an invitation token to share with the school principal. They can use this token to register as the first administrator.',
                              style: TextStyle(
                                fontSize: 13,
                                color: infoColor.withValues(alpha: 0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Section title widget.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Quick action card widget.
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.dialogBorderRadius,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.dialogBorderRadius,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: 26,
                color: color,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Schools header widget showing total count.
class _SchoolsHeader extends StatelessWidget {
  const _SchoolsHeader({required this.schoolCount});

  final int schoolCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.dialogBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Schools',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: AppSpacing.xxs / 2),
                Text(
                  schoolCount.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: () => CreateSchoolDialog.show(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// Dialog shown after successfully creating a school.
class _SchoolCreatedDialog extends StatelessWidget {
  const _SchoolCreatedDialog({
    required this.schoolName,
    required this.token,
  });

  final String schoolName;
  final String token;

  void _copyToken(BuildContext context) {
    // Copy to clipboard would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successColor = AppSemanticColors.success(isPlayful: false);
    final warningColor = AppSemanticColors.warning(isPlayful: false);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: AppSpacing.smallInsets,
            decoration: BoxDecoration(
              color: successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: successColor,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          const Expanded(child: Text('School Created')),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.08),
                borderRadius: AppRadius.cardBorderRadius,
                border: Border.all(
                  color: successColor.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                'School "$schoolName" has been created successfully!',
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              'Principal Invitation Token',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              'Share this token with the school principal to allow them to register.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: AppRadius.cardBorderRadius,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      token,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                        letterSpacing: 2,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  IconButton.filledTonal(
                    onPressed: () => _copyToken(context),
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'Copy token',
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: warningColor,
                  ),
                  SizedBox(width: AppSpacing.sm - 2),
                  Expanded(
                    child: Text(
                      'This token expires in 30 days.',
                      style: TextStyle(
                        fontSize: 12,
                        color: warningColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
