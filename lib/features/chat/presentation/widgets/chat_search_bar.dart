import 'package:flutter/material.dart';

/// A search bar widget for searching within chat messages.
///
/// Provides a text input field with clear and cancel functionality
/// for filtering messages in the chat.
class ChatSearchBar extends StatelessWidget {
  /// Creates a [ChatSearchBar] widget.
  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.onCancel,
    this.searchQuery = '',
    this.isPlayful = false,
  });

  /// The text editing controller for the search input.
  final TextEditingController controller;

  /// Callback when the cancel button is pressed.
  final VoidCallback onCancel;

  /// The current search query.
  final String searchQuery;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        onPressed: () {
                          controller.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isPlayful ? 16 : 12,
                  vertical: isPlayful ? 12 : 10,
                ),
              ),
            ),
          ),
          SizedBox(width: isPlayful ? 12 : 8),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
