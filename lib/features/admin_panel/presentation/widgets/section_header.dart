import 'package:flutter/material.dart';

/// Section header widget for displaying grouped content headers.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.isPlayful,
  });

  final String title;
  final IconData icon;
  final int count;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: isPlayful ? 22 : 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.3 : -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 10 : 8,
            vertical: isPlayful ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
