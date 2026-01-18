import 'package:flutter/material.dart';

/// Shows an error snackbar with a working dismiss button.
///
/// This utility function captures the ScaffoldMessenger before building
/// the SnackBar to prevent stale context issues with the dismiss button.
void showErrorSnackBar(BuildContext context, String message) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  // Clear any existing snackbars first
  scaffoldMessenger.clearSnackBars();

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          scaffoldMessenger.hideCurrentSnackBar();
        },
      ),
    ),
  );
}

/// Shows a success snackbar.
///
/// Uses the same pattern as [showErrorSnackBar] to ensure consistent behavior.
void showSuccessSnackBar(BuildContext context, String message) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  scaffoldMessenger.clearSnackBars();

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}
