import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget for composing and sending messages.
///
/// Includes a text field for message input and a send button.
/// The send button is only enabled when there is text to send.
class MessageInput extends ConsumerStatefulWidget {
  /// Creates a [MessageInput] widget.
  const MessageInput({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.hintText = 'Type a message...',
    this.isPlayful = false,
  });

  /// Callback when a message is sent.
  final Future<bool> Function(String message) onSend;

  /// Whether a message is currently being sent.
  final bool isLoading;

  /// Hint text for the input field.
  final String hintText;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  Future<void> _handleSend() async {
    if (!_hasText || _isSending || widget.isLoading) return;

    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      final success = await widget.onSend(message);
      if (success && mounted) {
        _controller.clear();
        // Keep focus on input for quick follow-up messages
        _focusNode.requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = widget.isLoading || _isSending;
    final canSend = _hasText && !isLoading;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isPlayful ? 16 : 12,
        vertical: widget.isPlayful ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 120, // Allow multiline but with max height
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(widget.isPlayful ? 24 : 20),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? theme.colorScheme.primary.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 1,
                  style: TextStyle(
                    fontSize: widget.isPlayful ? 16 : 15,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: widget.isPlayful ? 18 : 16,
                      vertical: widget.isPlayful ? 14 : 12,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            SizedBox(width: widget.isPlayful ? 12 : 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Material(
                color: canSend
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(widget.isPlayful ? 24 : 20),
                child: InkWell(
                  onTap: canSend ? _handleSend : null,
                  borderRadius: BorderRadius.circular(widget.isPlayful ? 24 : 20),
                  child: Container(
                    width: widget.isPlayful ? 50 : 46,
                    height: widget.isPlayful ? 50 : 46,
                    alignment: Alignment.center,
                    child: isLoading
                        ? SizedBox(
                            width: widget.isPlayful ? 24 : 22,
                            height: widget.isPlayful ? 24 : 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: canSend
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            size: widget.isPlayful ? 24 : 22,
                            color: canSend
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
