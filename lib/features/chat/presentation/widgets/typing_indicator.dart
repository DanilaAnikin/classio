import 'package:flutter/material.dart';

/// A widget that shows a typing indicator animation.
///
/// Displays three animated dots to indicate that someone is typing.
class TypingIndicator extends StatefulWidget {
  /// Creates a [TypingIndicator] widget.
  const TypingIndicator({
    super.key,
    this.isPlayful = false,
  });

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isPlayful ? 16 : 14,
        vertical: widget.isPlayful ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: widget.isPlayful
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.isPlayful ? 20 : 16),
          topRight: Radius.circular(widget.isPlayful ? 20 : 16),
          bottomRight: Radius.circular(widget.isPlayful ? 20 : 16),
          bottomLeft: const Radius.circular(4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = (_controller.value + index * 0.2) % 1.0;
              final scale = 0.5 + (0.5 * _bounce(progress));

              return Container(
                margin: EdgeInsets.symmetric(
                  horizontal: widget.isPlayful ? 3 : 2,
                ),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.isPlayful ? 10 : 8,
                    height: widget.isPlayful ? 10 : 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// Creates a bounce effect for the animation.
  double _bounce(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      final f = (2 * t) - 2;
      return 0.5 * f * f * f + 1;
    }
  }
}

/// A widget that shows the typing indicator with a user's name.
class TypingIndicatorWithName extends StatelessWidget {
  /// Creates a [TypingIndicatorWithName] widget.
  const TypingIndicatorWithName({
    super.key,
    required this.userName,
    this.isPlayful = false,
  });

  /// Name of the user who is typing.
  final String userName;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: Text(
              '$userName is typing...',
              style: TextStyle(
                fontSize: isPlayful ? 13 : 12,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          TypingIndicator(isPlayful: isPlayful),
        ],
      ),
    );
  }
}
