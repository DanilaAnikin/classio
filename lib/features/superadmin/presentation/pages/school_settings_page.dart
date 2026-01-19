import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classio/core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/superadmin_provider.dart';

/// Page for managing school settings.
///
/// Allows superadmins to:
/// - Update school name
/// - Manage subscription status
/// - Generate/view principal invitation tokens
/// - Delete school
class SchoolSettingsPage extends ConsumerStatefulWidget {
  const SchoolSettingsPage({
    super.key,
    required this.schoolId,
  });

  final String schoolId;

  @override
  ConsumerState<SchoolSettingsPage> createState() => _SchoolSettingsPageState();
}

class _SchoolSettingsPageState extends ConsumerState<SchoolSettingsPage> {
  late TextEditingController _nameController;
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateSchoolName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('School name cannot be empty')),
      );
      return;
    }

    final success = await ref
        .read(superAdminNotifierProvider.notifier)
        .updateSchoolName(widget.schoolId, _nameController.text.trim());

    if (mounted) {
      if (success != null) {
        setState(() {
          _isEditingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('School name updated')),
        );
      } else {
        final error = ref.read(superAdminNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to update school name')),
        );
      }
    }
  }

  Future<void> _generateNewToken() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate New Token'),
        content: const Text(
          'This will generate a new principal invitation token. '
          'Any existing unused tokens will still be valid until they expire.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final token = await ref
          .read(superAdminNotifierProvider.notifier)
          .generatePrincipalToken(widget.schoolId);

      if (mounted && token != null) {
        ref.invalidate(schoolPrincipalTokenProvider(widget.schoolId));
        _showTokenDialog(token);
      }
    }
  }

  void _showTokenDialog(String token) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Principal Token Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share this token with the school principal to allow them to register:',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    token,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token copied to clipboard')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Valid for 30 days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSubscriptionStatus(SubscriptionStatus status) async {
    final success = await ref
        .read(superAdminNotifierProvider.notifier)
        .updateSubscriptionStatus(widget.schoolId, status);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription updated to ${status.displayName}')),
        );
      } else {
        final error = ref.read(superAdminNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to update subscription')),
        );
      }
    }
  }

  Future<void> _deleteSchool() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete School'),
        content: const Text(
          'Are you sure you want to delete this school? '
          'This action cannot be undone and will delete all associated data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(superAdminNotifierProvider.notifier)
          .deleteSchool(widget.schoolId);

      if (mounted) {
        if (success) {
          context.pop();
          context.pop(); // Go back twice to exit school detail
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('School deleted')),
          );
        } else {
          final error = ref.read(superAdminNotifierProvider).errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error ?? 'Failed to delete school')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final schoolAsync = ref.watch(schoolDetailProvider(widget.schoolId));
    final tokenAsync = ref.watch(schoolPrincipalTokenProvider(widget.schoolId));
    final adminState = ref.watch(superAdminNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: schoolAsync.when(
        data: (school) {
          if (!_isEditingName && _nameController.text.isEmpty) {
            _nameController.text = school.name;
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(schoolDetailProvider(widget.schoolId));
              ref.invalidate(schoolPrincipalTokenProvider(widget.schoolId));
            },
            child: ResponsiveCenterScrollView(
              maxWidth: 600,
              padding: EdgeInsets.all(isPlayful ? 16 : 12),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // School Name Section
                  _buildSection(
                    context,
                    title: 'School Information',
                    isPlayful: isPlayful,
                    child: Column(
                      children: [
                        if (_isEditingName)
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'School Name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          isPlayful ? 16 : 8),
                                    ),
                                  ),
                                  onSubmitted: (_) => _updateSchoolName(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed:
                                    adminState.isLoading ? null : _updateSchoolName,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _isEditingName = false;
                                    _nameController.text = school.name;
                                  });
                                },
                              ),
                            ],
                          )
                        else
                          ListTile(
                            title: const Text('School Name'),
                            subtitle: Text(school.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _isEditingName = true;
                                });
                              },
                            ),
                          ),
                        const Divider(),
                        ListTile(
                          title: const Text('School ID'),
                          subtitle: Text(
                            school.id,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: school.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('School ID copied')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isPlayful ? 24 : 16),

                  // Subscription Section
                  _buildSection(
                    context,
                    title: 'Subscription',
                    isPlayful: isPlayful,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.verified,
                            color: _getSubscriptionColor(school.subscriptionStatus),
                          ),
                          title: const Text('Current Status'),
                          subtitle: Text(school.subscriptionStatus.displayName),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: SubscriptionStatus.values.map((status) {
                              final isSelected =
                                  school.subscriptionStatus == status;
                              return ChoiceChip(
                                label: Text(status.displayName),
                                selected: isSelected,
                                onSelected: adminState.isLoading
                                    ? null
                                    : (_) => _updateSubscriptionStatus(status),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isPlayful ? 24 : 16),

                  // Principal Token Section
                  _buildSection(
                    context,
                    title: 'Principal Invitation',
                    isPlayful: isPlayful,
                    child: Column(
                      children: [
                        tokenAsync.when(
                          data: (token) {
                            if (token != null) {
                              return ListTile(
                                leading: const Icon(Icons.key),
                                title: const Text('Active Token'),
                                subtitle: Text(
                                  token,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: token));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Token copied')),
                                    );
                                  },
                                ),
                              );
                            }
                            return const ListTile(
                              leading: Icon(Icons.key_off),
                              title: Text('No Active Token'),
                              subtitle: Text(
                                  'Generate a token to invite a principal'),
                            );
                          },
                          loading: () => const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Loading token...'),
                          ),
                          error: (_, _) => const ListTile(
                            leading: Icon(Icons.error_outline),
                            title: Text('Failed to load token'),
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: FilledButton.icon(
                            onPressed:
                                adminState.isLoading ? null : _generateNewToken,
                            icon: const Icon(Icons.add),
                            label: const Text('Generate New Token'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isPlayful ? 24 : 16),

                  // Danger Zone
                  _buildSection(
                    context,
                    title: 'Danger Zone',
                    isPlayful: isPlayful,
                    isDanger: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deleting a school will permanently remove all associated data including users, classes, and grades.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed:
                                adminState.isLoading ? null : _deleteSchool,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Delete School'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(color: theme.colorScheme.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isPlayful ? 80 : 72),
                ],
              ),
            ),
          );
        },
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
                onPressed: () =>
                    ref.invalidate(schoolDetailProvider(widget.schoolId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
    required bool isPlayful,
    bool isDanger = false,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isDanger
            ? BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5))
            : isPlayful
                ? BorderSide.none
                : BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDanger ? theme.colorScheme.error : null,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Color _getSubscriptionColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.trial:
        return CleanColors.subscriptionTrial;
      case SubscriptionStatus.pro:
        return CleanColors.subscriptionBasic;
      case SubscriptionStatus.max:
        return CleanColors.subscriptionPro;
      case SubscriptionStatus.suspended:
        return CleanColors.subscriptionExpired;
      case SubscriptionStatus.expired:
        return CleanColors.subscriptionInactive;
    }
  }
}
