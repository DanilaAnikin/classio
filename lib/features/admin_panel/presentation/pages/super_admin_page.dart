import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/theme/spacing.dart';
import 'package:classio/core/theme/app_radius.dart';
import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/admin_providers.dart';

/// Super Admin page for managing all schools in the Classio app.
///
/// Displays a list of all schools with:
/// - School name
/// - Created date
/// - Tap to navigate to school details (optional)
///
/// Includes a FAB to add new schools via a dialog.
class SuperAdminPage extends ConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(schoolsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(schoolsProvider);
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
                  // Header Card
                  _HeaderCard(schoolCount: schools.length),
                  SizedBox(height: AppSpacing.lg),

                  // Schools List
                  ...schools.map((school) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SchoolCard(school: school),
                      )),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorState(context, theme, error, ref),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSchoolDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add School'),
      ),
    );
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
            SizedBox(height: AppSpacing.xl),
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
              'Add your first school by tapping the button below.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
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
              onPressed: () {
                ref.invalidate(schoolsProvider);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSchoolDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New School'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'School Name',
              hintText: 'Enter the school name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a school name';
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (formKey.currentState?.validate() ?? false) {
                _addSchool(context, ref, controller.text.trim());
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                _addSchool(context, ref, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addSchool(BuildContext context, WidgetRef ref, String name) async {
    // Close the dialog
    Navigator.of(context).pop();

    // Call the add school function from provider
    final school = await ref.read(adminNotifierProvider.notifier).createSchool(name);

    // Show success/error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(school != null
              ? 'School "$name" added successfully'
              : 'Failed to add school'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Header card showing the total school count.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.schoolCount});

  final int schoolCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.dialogInsets,
      decoration: BoxDecoration(
        borderRadius: AppRadius.dialogBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.dialogBorderRadius,
            ),
            child: Icon(
              Icons.account_balance_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Schools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schoolCount.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual school card displaying school information.
class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.school});

  final School school;

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.push(AppRoutes.getSuperadminSchoolDetail(school.id)),
      borderRadius: AppRadius.dialogBorderRadius,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: AppRadius.dialogBorderRadius,
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // School Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: AppRadius.cardBorderRadius,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 28,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // School Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (school.createdAt case final createdAt?)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        SizedBox(width: AppSpacing.xxs),
                        Text(
                          'Created ${_formatDate(createdAt)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
