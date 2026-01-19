import 'package:flutter/material.dart';

/// Small stat badge widget for displaying counts with labels.
class StatBadge extends StatelessWidget {
  const StatBadge({
    super.key,
    required this.label,
    required this.count,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final int count;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count ',
          style: TextStyle(
            fontSize: isPlayful ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 12 : 11,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
