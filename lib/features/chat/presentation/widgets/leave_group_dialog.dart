import 'package:flutter/material.dart';

/// A dialog that confirms leaving a group conversation.
///
/// Shows a warning message and provides cancel and leave options.
class LeaveGroupDialog extends StatelessWidget {
  /// Creates a [LeaveGroupDialog] widget.
  const LeaveGroupDialog({
    super.key,
    required this.onLeave,
  });

  /// Callback when the user confirms leaving the group.
  final VoidCallback onLeave;

  /// Shows the leave group confirmation dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLeave,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => LeaveGroupDialog(
        onLeave: () {
          Navigator.pop(dialogContext);
          onLeave();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Leave Group'),
      content: const Text(
        'Are you sure you want to leave this group? '
        'You will no longer receive messages from this group.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onLeave,
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Leave'),
        ),
      ],
    );
  }
}
