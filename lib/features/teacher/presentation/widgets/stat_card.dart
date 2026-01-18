import 'package:flutter/material.dart';

/// A card widget displaying a single statistic.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isPlayful,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPlayful;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Container(
          constraints: const BoxConstraints(minWidth: 140),
          padding: EdgeInsets.all(isPlayful ? 16 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            gradient: isPlayful
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.04),
                    ],
                  )
                : null,
            color: isPlayful ? null : theme.colorScheme.surface,
            border: isPlayful
                ? null
                : Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: isPlayful
                    ? color.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isPlayful ? 12 : 6,
                offset: Offset(0, isPlayful ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(isPlayful ? 10 : 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isPlayful ? 22 : 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isPlayful ? 12 : 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: isPlayful ? 28 : 24,
                  fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: isPlayful ? 0.3 : -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: isPlayful ? 13 : 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
