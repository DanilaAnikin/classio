import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/theme/app_colors.dart';
import '../../domain/entities/entities.dart';
import 'subscription_management_dialog.dart';

/// Subscription section widget displaying the school's subscription status.
///
/// Shows the current subscription tier, expiration date, and provides
/// a button to manage the subscription.
class SchoolSubscriptionSection extends StatelessWidget {
  const SchoolSubscriptionSection({
    super.key,
    required this.school,
    required this.isPlayful,
  });

  final SchoolWithStats school;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    // Get subscription status color and icon
    final (statusColor, statusIcon) = _getStatusColorAndIcon(theme);

    // Build subtitle text
    final subtitleText = _buildSubtitleText(dateFormat);

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
              onPressed: () => _openSubscriptionDialog(context),
              child: const Text('Manage'),
            ),
          ),
        ),
      ],
    );
  }

  (Color, IconData) _getStatusColorAndIcon(ThemeData theme) {
    switch (school.subscriptionStatus) {
      case SubscriptionStatus.trial:
        return (isPlayful ? PlayfulColors.subscriptionTrial : CleanColors.subscriptionTrial, Icons.hourglass_empty_rounded);
      case SubscriptionStatus.pro:
        return (isPlayful ? PlayfulColors.subscriptionBasic : CleanColors.subscriptionBasic, Icons.star_rounded);
      case SubscriptionStatus.max:
        return (isPlayful ? PlayfulColors.subscriptionPro : CleanColors.subscriptionPro, Icons.diamond_rounded);
      case SubscriptionStatus.expired:
        return (theme.colorScheme.error, Icons.warning_rounded);
      case SubscriptionStatus.suspended:
        return (isPlayful ? PlayfulColors.subscriptionExpired : CleanColors.subscriptionExpired, Icons.block_rounded);
    }
  }

  String _buildSubtitleText(DateFormat dateFormat) {
    final subscriptionExpiresAt = school.subscriptionExpiresAt;
    if (subscriptionExpiresAt != null) {
      final expiryDate = dateFormat.format(subscriptionExpiresAt);
      final isExpired = subscriptionExpiresAt.isBefore(DateTime.now());
      return isExpired ? 'Expired on $expiryDate' : 'Expires on $expiryDate';
    } else if (school.subscriptionStatus.isPaid) {
      return 'No expiry (perpetual)';
    } else {
      return 'Subscription status';
    }
  }

  Future<void> _openSubscriptionDialog(BuildContext context) async {
    await SubscriptionManagementDialog.show(
      context,
      schoolId: school.id,
      schoolName: school.name,
      currentStatus: school.subscriptionStatus,
      currentExpiresAt: school.subscriptionExpiresAt,
    );
  }
}
