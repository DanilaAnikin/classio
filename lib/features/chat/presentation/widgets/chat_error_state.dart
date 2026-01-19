import 'package:flutter/material.dart';

/// A widget that displays an error state for the chat.
///
/// Shows an error message and a retry button when messages
/// fail to load.
class ChatErrorState extends StatelessWidget {
  /// Creates a [ChatErrorState] widget.
  const ChatErrorState({
    super.key,
    required this.error,
    required this.onRetry,
    this.isPlayful = false,
  });

  /// The error message to display.
  final String error;

  /// Callback when the retry button is pressed.
  final VoidCallback onRetry;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 64 : 56,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: isPlayful ? 20 : 16),
            Text(
              'Failed to load messages',
              style: TextStyle(
                fontSize: isPlayful ? 18 : 16,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
