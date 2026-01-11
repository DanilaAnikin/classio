import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/admin_providers.dart';

/// Super Admin page for system-wide administration.
///
/// Displays a list of all schools in the system with:
/// - School name and creation date
/// - Pull-to-refresh functionality
/// - FloatingActionButton to add new schools
///
/// Supports two theme modes: Clean (minimal/professional) and Playful (colorful/fun).
class SuperAdminPage extends ConsumerWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolsAsync = ref.watch(schoolsNotifierProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Administration'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(schoolsNotifierProvider.notifier).refreshSchools();
        },
        child: schoolsAsync.when(
          data: (schools) {
            if (schools.isEmpty) {
              return _buildEmptyState(context, theme, isPlayful);
            }

            return ResponsiveCenterScrollView(
              maxWidth: 1000,
              padding: EdgeInsets.all(isPlayful ? 16 : 12),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _SectionHeader(
                    title: 'Schools',
                    count: schools.length,
                    isPlayful: isPlayful,
                  ),
                  SizedBox(height: isPlayful ? 16 : 12),

                  // School Cards
                  ...schools.map((school) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                        child: _SchoolCard(
                          school: school,
                          isPlayful: isPlayful,
                        ),
                      )),
                  SizedBox(height: isPlayful ? 80 : 72),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => _buildErrorState(context, theme, isPlayful, error, ref),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSchoolDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add School'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isPlayful) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isPlayful ? 120 : 100,
                height: isPlayful ? 120 : 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: isPlayful ? 56 : 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: isPlayful ? 28 : 24),
              Text(
                'No Schools Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: isPlayful ? 0.3 : -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Add your first school to get started',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    bool isPlayful,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: isPlayful ? 72 : 64,
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
              SizedBox(height: isPlayful ? 24 : 20),
              Text(
                'Failed to Load Schools',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(schoolsNotifierProvider.notifier).refreshSchools();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSchoolDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddSchoolDialog(
        onAdd: (name) async {
          await ref.read(schoolsNotifierProvider.notifier).createSchool(name);
        },
      ),
    );
  }
}

/// Section header displaying title and count.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isPlayful,
  });

  final String title;
  final int count;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.business_rounded,
          size: isPlayful ? 24 : 22,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: isPlayful ? 10 : 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 22 : 20,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.3 : -0.3,
          ),
        ),
        SizedBox(width: isPlayful ? 10 : 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 10 : 8,
            vertical: isPlayful ? 4 : 3,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

/// Card displaying school information.
class _SchoolCard extends StatelessWidget {
  const _SchoolCard({
    required this.school,
    required this.isPlayful,
  });

  final SchoolEntity school;
  final bool isPlayful;

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.15),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 12 : 6,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to school detail page
          },
          borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
          child: Padding(
            padding: EdgeInsets.all(isPlayful ? 18 : 14),
            child: Row(
              children: [
                // School Icon
                Container(
                  width: isPlayful ? 52 : 44,
                  height: isPlayful ? 52 : 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: isPlayful ? 28 : 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: isPlayful ? 16 : 12),

                // School Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: TextStyle(
                          fontSize: isPlayful ? 18 : 16,
                          fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: isPlayful ? 0.3 : -0.3,
                        ),
                      ),
                      SizedBox(height: isPlayful ? 6 : 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: isPlayful ? 14 : 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: isPlayful ? 6 : 4),
                          Text(
                            'Created ${_formatDate(school.createdAt)}',
                            style: TextStyle(
                              fontSize: isPlayful ? 13 : 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontWeight: isPlayful ? FontWeight.w500 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.chevron_right_rounded,
                  size: isPlayful ? 28 : 24,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding a new school.
class _AddSchoolDialog extends StatefulWidget {
  const _AddSchoolDialog({required this.onAdd});

  final Future<void> Function(String name) onAdd;

  @override
  State<_AddSchoolDialog> createState() => _AddSchoolDialogState();
}

class _AddSchoolDialogState extends State<_AddSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await widget.onAdd(_nameController.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create school: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add School'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'School Name',
            hintText: 'Enter the school name',
            prefixIcon: Icon(Icons.school_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a school name';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleAdd(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleAdd,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
