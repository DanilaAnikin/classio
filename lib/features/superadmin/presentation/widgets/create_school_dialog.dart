import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_input.dart';
import '../providers/superadmin_provider.dart';

/// A premium dialog for creating a new school.
///
/// After creating the school, displays the generated principal token
/// that can be used to invite the first school administrator.
/// Uses design system tokens and shared components for consistent styling.
class CreateSchoolDialog extends ConsumerStatefulWidget {
  const CreateSchoolDialog({super.key});

  /// Shows the create school dialog using the AppDialog system.
  static Future<void> show(BuildContext context) {
    return AppDialog.showForm<void>(
      context: context,
      title: 'Create New School',
      titleWidget: null,
      showCloseButton: false,
      maxWidth: 480,
      content: const CreateSchoolDialog(),
    );
  }

  @override
  ConsumerState<CreateSchoolDialog> createState() => _CreateSchoolDialogState();
}

class _CreateSchoolDialogState extends ConsumerState<CreateSchoolDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isCreating = false;
  String? _generatedToken;
  String? _createdSchoolName;

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
        if (school != null && token != null) {
          _generatedToken = token;
          _createdSchoolName = school.name;
        }
      });

      if (school == null) {
        final error = ref.read(superAdminNotifierProvider).errorMessage;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to create school'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _copyToken() {
    final token = _generatedToken;
    if (token != null) {
      Clipboard.setData(ClipboardData(text: token));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Principal token copied to clipboard'),
          duration: AppDuration.snackbar,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _detectIsPlayful(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _detectIsPlayful(context);

    // Show success state with token
    final generatedToken = _generatedToken;
    if (generatedToken != null) {
      return _SuccessContent(
        schoolName: _createdSchoolName ?? '',
        token: generatedToken,
        isPlayful: isPlayful,
        onCopyToken: _copyToken,
        onDone: () => Navigator.of(context).pop(),
      );
    }

    // Show creation form
    return _CreationForm(
      formKey: _formKey,
      nameController: _nameController,
      isCreating: _isCreating,
      isPlayful: isPlayful,
      onCancel: () => Navigator.of(context).pop(),
      onCreateSchool: _createSchool,
    );
  }
}

/// Success content showing the generated token.
class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    required this.schoolName,
    required this.token,
    required this.isPlayful,
    required this.onCopyToken,
    required this.onDone,
  });

  final String schoolName;
  final String token;
  final bool isPlayful;
  final VoidCallback onCopyToken;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final successColor = AppSemanticColors.success(isPlayful: isPlayful);
    final warningColor = AppSemanticColors.warning(isPlayful: isPlayful);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success Header
          _SuccessHeader(
            successColor: successColor,
            isPlayful: isPlayful,
          ),
          SizedBox(height: AppSpacing.lg),

          // Success Message
          _SuccessMessage(
            schoolName: schoolName,
            successColor: successColor,
            isPlayful: isPlayful,
          ),
          SizedBox(height: AppSpacing.lg),

          // Token Section
          _TokenSection(
            token: token,
            theme: theme,
            isPlayful: isPlayful,
            onCopyToken: onCopyToken,
          ),
          SizedBox(height: AppSpacing.md),

          // Warning Notice
          _WarningNotice(
            warningColor: warningColor,
            isPlayful: isPlayful,
          ),
          SizedBox(height: AppSpacing.lg),

          // Done Button
          AppButton.primary(
            label: 'Done',
            onPressed: onDone,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}

/// Success header with icon.
class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({
    required this.successColor,
    required this.isPlayful,
  });

  final Color successColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: AppSpacing.smallInsets,
          decoration: BoxDecoration(
            color: successColor.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.button(isPlayful: isPlayful),
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: successColor,
            size: AppIconSize.md,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'School Created',
            style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Success message container.
class _SuccessMessage extends StatelessWidget {
  const _SuccessMessage({
    required this.schoolName,
    required this.successColor,
    required this.isPlayful,
  });

  final String schoolName;
  final Color successColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: successColor.withValues(alpha: AppOpacity.subtle),
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        border: Border.all(
          color: successColor.withValues(alpha: AppOpacity.medium),
        ),
      ),
      child: Text(
        'School "$schoolName" has been created successfully!',
        style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.dominant),
        ),
      ),
    );
  }
}

/// Token display section with copy button.
class _TokenSection extends StatelessWidget {
  const _TokenSection({
    required this.token,
    required this.theme,
    required this.isPlayful,
    required this.onCopyToken,
  });

  final String token;
  final ThemeData theme;
  final bool isPlayful;
  final VoidCallback onCopyToken;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Principal Invitation Token',
          style: AppTypography.inputLabel(isPlayful: isPlayful).copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        Text(
          'Share this token with the school principal to allow them to register.',
          style: AppTypography.tertiaryText(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium),
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.card(isPlayful: isPlayful),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: AppOpacity.soft),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  token,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    letterSpacing: 2,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              IconButton.filledTonal(
                onPressed: onCopyToken,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy token',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Warning notice about token expiration.
class _WarningNotice extends StatelessWidget {
  const _WarningNotice({
    required this.warningColor,
    required this.isPlayful,
  });

  final Color warningColor;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.smallInsets,
      decoration: BoxDecoration(
        color: warningColor.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
        border: Border.all(
          color: warningColor.withValues(alpha: AppOpacity.soft),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppIconSize.sm,
            color: warningColor,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This token expires in 30 days. Generate a new one if needed.',
              style: AppTypography.caption(isPlayful: isPlayful).copyWith(
                color: warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Creation form widget.
class _CreationForm extends StatelessWidget {
  const _CreationForm({
    required this.formKey,
    required this.nameController,
    required this.isCreating,
    required this.isPlayful,
    required this.onCancel,
    required this.onCreateSchool,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final bool isCreating;
  final bool isPlayful;
  final VoidCallback onCancel;
  final VoidCallback onCreateSchool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form Header
          _FormHeader(isPlayful: isPlayful),
          SizedBox(height: AppSpacing.lg),

          // Description
          Text(
            'Enter the name of the new school. A principal invitation token will be generated automatically.',
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.heavy),
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // School Name Input
          AppInput(
            controller: nameController,
            label: 'School Name',
            hint: 'Enter the school name',
            prefixIcon: Icons.school_outlined,
            autofocus: true,
            enabled: !isCreating,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a school name';
              }
              if (value.trim().length < 3) {
                return 'School name must be at least 3 characters';
              }
              return null;
            },
            onSubmitted: (_) {
              if (!isCreating) {
                onCreateSchool();
              }
            },
          ),
          SizedBox(height: AppSpacing.xl),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton.secondary(
                label: 'Cancel',
                onPressed: isCreating ? null : onCancel,
              ),
              SizedBox(width: AppSpacing.sm),
              AppButton.primary(
                label: 'Create School',
                onPressed: isCreating ? null : onCreateSchool,
                isLoading: isCreating,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Form header with icon.
class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.add_business_rounded,
          color: theme.colorScheme.primary,
          size: AppIconSize.lg,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Create New School',
            style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
