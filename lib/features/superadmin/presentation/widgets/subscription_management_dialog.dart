import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/subscription_status.dart';
import '../providers/superadmin_provider.dart';

/// A dialog for managing a school's subscription.
///
/// Allows selecting subscription tier (Trial, Pro, Max) and setting
/// expiry dates. Trial subscriptions automatically set expiry to school year end.
class SubscriptionManagementDialog extends ConsumerStatefulWidget {
  const SubscriptionManagementDialog({
    super.key,
    required this.schoolId,
    required this.schoolName,
    required this.currentStatus,
    this.currentExpiresAt,
  });

  final String schoolId;
  final String schoolName;
  final SubscriptionStatus currentStatus;
  final DateTime? currentExpiresAt;

  /// Shows the subscription management dialog.
  static Future<bool?> show(
    BuildContext context, {
    required String schoolId,
    required String schoolName,
    required SubscriptionStatus currentStatus,
    DateTime? currentExpiresAt,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SubscriptionManagementDialog(
        schoolId: schoolId,
        schoolName: schoolName,
        currentStatus: currentStatus,
        currentExpiresAt: currentExpiresAt,
      ),
    );
  }

  @override
  ConsumerState<SubscriptionManagementDialog> createState() =>
      _SubscriptionManagementDialogState();
}

class _SubscriptionManagementDialogState
    extends ConsumerState<SubscriptionManagementDialog> {
  late SubscriptionStatus _selectedStatus;
  DateTime? _expiryDate;
  bool _noExpiry = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;

    // For trial, calculate default expiry; for paid tiers, use current or none
    if (_selectedStatus == SubscriptionStatus.trial) {
      _expiryDate = widget.currentExpiresAt ?? _calculateTrialExpiry();
      _noExpiry = false;
    } else if (_selectedStatus.isPaid) {
      _expiryDate = widget.currentExpiresAt;
      _noExpiry = widget.currentExpiresAt == null;
    } else {
      _expiryDate = widget.currentExpiresAt;
      _noExpiry = widget.currentExpiresAt == null;
    }
  }

  /// Calculates the trial expiry date based on school year.
  /// School year runs from Sept 1 to July 1 (10 months).
  /// If current month is >= September, expiry is July 1 of next year.
  /// If current month is < September, expiry is July 1 of current year.
  DateTime _calculateTrialExpiry() {
    final now = DateTime.now();
    final currentYear = now.year;

    // School year: Sept 1 to July 1
    if (now.month >= 9) {
      // After September, expiry is July 1 of next year
      return DateTime(currentYear + 1, 7, 1);
    } else {
      // Before September, expiry is July 1 of current year
      return DateTime(currentYear, 7, 1);
    }
  }

  void _onStatusChanged(SubscriptionStatus? status) {
    if (status == null) return;

    setState(() {
      _selectedStatus = status;

      // Auto-set expiry for trial subscriptions
      if (status == SubscriptionStatus.trial) {
        _expiryDate = _calculateTrialExpiry();
        _noExpiry = false;
      } else if (status.isPaid) {
        // For paid tiers, default to no expiry (perpetual)
        _noExpiry = true;
        _expiryDate = null;
      }
    });
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      helpText: 'Select subscription expiry date',
    );

    if (picked != null && mounted) {
      setState(() {
        _expiryDate = picked;
        _noExpiry = false;
      });
    }
  }

  Future<void> _saveSubscription() async {
    setState(() {
      _isSaving = true;
    });

    final expiresAt = _noExpiry ? null : _expiryDate;

    final success = await ref
        .read(superAdminNotifierProvider.notifier)
        .updateSubscription(widget.schoolId, _selectedStatus, expiresAt);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription updated to ${_selectedStatus.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(superAdminNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update subscription'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.credit_card_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Manage Subscription'),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // School name
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.schoolName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subscription tier selection
            Text(
              'Subscription Tier',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),

            // Tier options
            _buildTierOption(
              context,
              status: SubscriptionStatus.trial,
              icon: Icons.hourglass_empty_rounded,
              description: 'Free trial for school year (Sept 1 - July 1)',
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildTierOption(
              context,
              status: SubscriptionStatus.pro,
              icon: Icons.star_rounded,
              description: 'Standard features with full access',
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildTierOption(
              context,
              status: SubscriptionStatus.max,
              icon: Icons.diamond_rounded,
              description: 'Premium features with priority support',
              color: Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildTierOption(
              context,
              status: SubscriptionStatus.expired,
              icon: Icons.timer_off_rounded,
              description: 'Subscription has expired',
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildTierOption(
              context,
              status: SubscriptionStatus.suspended,
              icon: Icons.block_rounded,
              description: 'School access suspended by administrator',
              color: Colors.red,
            ),

            const SizedBox(height: 24),

            // Expiry date section
            Text(
              'Subscription Expiry',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),

            // Expiry options based on tier
            if (_selectedStatus == SubscriptionStatus.trial) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 20,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trial expires on ${_expiryDate != null ? dateFormat.format(_expiryDate!) : "N/A"}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Automatically set to end of school year',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_selectedStatus.isPaid) ...[
              // No expiry checkbox
              CheckboxListTile(
                value: _noExpiry,
                onChanged: (value) {
                  setState(() {
                    _noExpiry = value ?? false;
                    if (_noExpiry) {
                      _expiryDate = null;
                    }
                  });
                },
                title: const Text('No expiry (perpetual subscription)'),
                subtitle: const Text('Subscription will not expire automatically'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Custom date picker (only if not perpetual)
              if (!_noExpiry) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _selectExpiryDate,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(
                    _expiryDate != null
                        ? 'Expires: ${dateFormat.format(_expiryDate!)}'
                        : 'Select expiry date',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ] else ...[
              // For expired/suspended status
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This status cannot have an expiry date.',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveSubscription,
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Widget _buildTierOption(
    BuildContext context, {
    required SubscriptionStatus status,
    required IconData icon,
    required String description,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedStatus == status;

    return InkWell(
      onTap: () => _onStatusChanged(status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withValues(alpha: 0.5)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<SubscriptionStatus>(
              value: status,
              groupValue: _selectedStatus,
              onChanged: _onStatusChanged,
              activeColor: color,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
