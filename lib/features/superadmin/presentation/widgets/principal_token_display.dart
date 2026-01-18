import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that displays a generated principal token with copy functionality.
///
/// Shows the token in a prominent style with a copy button and expiration info.
class PrincipalTokenDisplay extends StatelessWidget {
  const PrincipalTokenDisplay({
    super.key,
    required this.token,
    this.expiresInDays = 30,
    this.onCopy,
  });

  /// The token to display.
  final String token;

  /// Number of days until the token expires.
  final int expiresInDays;

  /// Optional callback when the token is copied.
  final VoidCallback? onCopy;

  void _copyToken(BuildContext context) {
    Clipboard.setData(ClipboardData(text: token));
    onCopy?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Principal Invitation Token',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Share this with the school principal',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Token Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    token,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                      letterSpacing: 3,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  onPressed: () => _copyToken(context),
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: 'Copy token',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Expiration Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expires in $expiresInDays days',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact version of the token display for inline use.
class PrincipalTokenChip extends StatelessWidget {
  const PrincipalTokenChip({
    super.key,
    required this.token,
  });

  final String token;

  void _copyToken(BuildContext context) {
    Clipboard.setData(ClipboardData(text: token));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _copyToken(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.vpn_key_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              token,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                letterSpacing: 1,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.copy_rounded,
              size: 14,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
