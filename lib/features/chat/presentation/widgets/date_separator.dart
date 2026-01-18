import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A separator widget displaying a date between messages.
///
/// Features:
/// - Shows "Today", "Yesterday", or formatted date
/// - Centered with horizontal lines on either side
/// - Theme-aware styling
class DateSeparator extends StatelessWidget {
  /// Creates a [DateSeparator] widget.
  const DateSeparator({
    super.key,
    required this.date,
    this.isPlayful = false,
  });

  /// The date to display.
  final DateTime date;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEEE').format(date); // "Monday", "Tuesday", etc.
    } else if (date.year == now.year) {
      return DateFormat('MMMM d').format(date); // "January 15"
    } else {
      return DateFormat('MMMM d, y').format(date); // "January 15, 2024"
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _formatDate(date);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isPlayful ? 16 : 12,
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: isPlayful
                    ? LinearGradient(
                        colors: [
                          Colors.transparent,
                          theme.colorScheme.outline.withValues(alpha: 0.3),
                        ],
                      )
                    : null,
                color: isPlayful
                    ? null
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isPlayful ? 16 : 12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isPlayful ? 12 : 10,
                vertical: isPlayful ? 6 : 4,
              ),
              decoration: isPlayful
                  ? BoxDecoration(
                      color:
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Text(
                dateText,
                style: TextStyle(
                  fontSize: isPlayful ? 13 : 12,
                  fontWeight: isPlayful ? FontWeight.w600 : FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: isPlayful ? 0.3 : 0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: isPlayful
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.outline.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      )
                    : null,
                color: isPlayful
                    ? null
                    : theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
