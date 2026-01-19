import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../providers/superadmin_provider.dart';

/// Helper class for token generation operations.
class _TokenOperations {
  static Future<void> generateToken({
    required BuildContext context,
    required WidgetRef ref,
    required String schoolId,
  }) async {
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

    final newToken = await ref
        .read(superAdminNotifierProvider.notifier)
        .generatePrincipalToken(schoolId);

    if (context.mounted) {
      if (newToken != null) {
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

  static void copyToClipboard(BuildContext context, String token) {
    Clipboard.setData(ClipboardData(text: token));

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
}

/// Card displaying the invitation token with copy and regenerate actions.
class InviteTokenCard extends ConsumerWidget {
  const InviteTokenCard({
    super.key,
    required this.schoolId,
    required this.token,
    required this.isLoading,
    required this.isPlayful,
  });

  final String schoolId;
  final String? token;
  final bool isLoading;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Card(
      elevation: isPlayful ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium + 0.04)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          children: [
            if (token != null) ...[
              _TokenDisplay(token: token!, isPlayful: isPlayful),
              SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
              _TokenActionButtons(
                schoolId: schoolId,
                token: token!,
                isLoading: isLoading,
                isPlayful: isPlayful,
              ),
            ] else ...[
              _NoTokenDisplay(isPlayful: isPlayful),
              SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
              _GenerateTokenButton(
                schoolId: schoolId,
                isLoading: isLoading,
                isPlayful: isPlayful,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Displays the token value.
class _TokenDisplay extends StatelessWidget {
  const _TokenDisplay({required this.token, required this.isPlayful});

  final String token;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.lg : AppSpacing.md,
        vertical: isPlayful ? AppSpacing.md : AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: AppOpacity.heavy),
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: AppOpacity.medium + 0.14),
        ),
      ),
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
    );
  }
}

/// Action buttons for copying and regenerating the token.
class _TokenActionButtons extends ConsumerWidget {
  const _TokenActionButtons({
    required this.schoolId,
    required this.token,
    required this.isLoading,
    required this.isPlayful,
  });

  final String schoolId;
  final String token;
  final bool isLoading;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => _TokenOperations.copyToClipboard(context, token),
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy Code'),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs),
              ),
            ),
          ),
        ),
        SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => _TokenOperations.generateToken(
                      context: context,
                      ref: ref,
                      schoolId: schoolId,
                    ),
            icon: isLoading
                ? SizedBox(
                    width: AppIconSize.sm - 2,
                    height: AppIconSize.sm - 2,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            label: const Text('Regenerate'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Display shown when no token is available.
class _NoTokenDisplay extends StatelessWidget {
  const _NoTokenDisplay({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.lg : AppSpacing.md,
        vertical: isPlayful ? AppSpacing.xl : AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: AppOpacity.heavy),
        borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium + 0.04),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.key_off_rounded,
            size: isPlayful ? AppIconSize.xxl : AppIconSize.xl + 8,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.dominant),
          ),
          SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
          Text(
            'No Active Invitation Code',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: isPlayful ? AppSpacing.xxs : 2),
          Text(
            'Generate a new code for the principal to register.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.dominant + 0.16),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button to generate a new token.
class _GenerateTokenButton extends ConsumerWidget {
  const _GenerateTokenButton({
    required this.schoolId,
    required this.isLoading,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isLoading;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading
            ? null
            : () => _TokenOperations.generateToken(
                  context: context,
                  ref: ref,
                  schoolId: schoolId,
                ),
        icon: isLoading
            ? SizedBox(
                width: AppIconSize.sm - 2,
                height: AppIconSize.sm - 2,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : const Icon(Icons.add_rounded),
        label: const Text('Generate Invitation Code'),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: isPlayful ? AppSpacing.md - 2 : AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isPlayful ? AppRadius.sm : AppRadius.xs),
          ),
        ),
      ),
    );
  }
}

/// Loading card shown while fetching the invitation token.
class InviteTokenLoadingCard extends StatelessWidget {
  const InviteTokenLoadingCard({super.key, required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Card(
      elevation: isPlayful ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: AppOpacity.medium + 0.04)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.xxl : AppSpacing.xl),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

/// Error card shown when loading the invitation token fails.
class InviteTokenErrorCard extends ConsumerWidget {
  const InviteTokenErrorCard({
    super.key,
    required this.schoolId,
    required this.error,
    required this.isPlayful,
  });

  final String schoolId;
  final String error;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Card(
      elevation: isPlayful ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: cardRadius,
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.error.withValues(alpha: AppOpacity.medium + 0.14)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.lg : AppSpacing.md),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? AppIconSize.xl + 8 : AppIconSize.xl,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
            Text(
              'Failed to load invitation code',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: isPlayful ? AppSpacing.xs : AppSpacing.xxs + 2),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(schoolPrincipalTokenProvider(schoolId)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
