import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';

/// A premium message input widget for composing and sending messages.
///
/// Features:
/// - Clean, modern input field with proper focus states
/// - Attachment button on the left side
/// - Auto-resizing text input for multiline messages
/// - Animated send button that activates when there's text
/// - Smooth animations and transitions
/// - Full theme awareness (Clean vs Playful)
class MessageInput extends ConsumerStatefulWidget {
  /// Creates a [MessageInput] widget.
  const MessageInput({
    super.key,
    required this.onSend,
    this.onAttachmentPressed,
    this.isLoading = false,
    this.hintText = 'Type a message...',
    this.isPlayful = false,
    this.maxLines = 6,
  });

  /// Callback when a message is sent.
  final Future<bool> Function(String message) onSend;

  /// Callback when the attachment button is pressed.
  final VoidCallback? onAttachmentPressed;

  /// Whether a message is currently being sent.
  final bool isLoading;

  /// Hint text for the input field.
  final String hintText;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Maximum number of lines before scrolling.
  final int maxLines;

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isSending = false;
  bool _isFocused = false;

  late final AnimationController _sendButtonController;
  late final Animation<double> _sendButtonScale;
  late final Animation<double> _sendButtonOpacity;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    // Initialize send button animation controller
    _sendButtonController = AnimationController(
      duration: AppDuration.normal,
      vsync: this,
    );

    _sendButtonScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: AppCurves.emphasized,
    ));

    _sendButtonOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: AppCurves.decelerate,
    ));
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      // Animate send button
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
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
    final isLoading = widget.isLoading || _isSending;
    final canSend = _hasText && !isLoading;
    final isPlayful = widget.isPlayful;

    // Get theme-aware colors
    final backgroundColor = isPlayful
        ? PlayfulColors.surface
        : CleanColors.surface;
    final inputBackgroundColor = isPlayful
        ? PlayfulColors.surfaceSubtle
        : CleanColors.surfaceSubtle;
    final borderColor = _isFocused
        ? (isPlayful ? PlayfulColors.primary : CleanColors.primary)
        : Colors.transparent;
    final hintColor = isPlayful
        ? PlayfulColors.textMuted
        : CleanColors.textMuted;
    final textColor = isPlayful
        ? PlayfulColors.textPrimary
        : CleanColors.textPrimary;
    final primaryColor = isPlayful
        ? PlayfulColors.primary
        : CleanColors.primary;
    final onPrimaryColor = isPlayful
        ? PlayfulColors.onPrimary
        : CleanColors.onPrimary;
    final iconInactiveColor = isPlayful
        ? PlayfulColors.textTertiary
        : CleanColors.textTertiary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.md : AppSpacing.sm,
        vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: AppShadows.navigation(isPlayful: isPlayful),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            _AttachmentButton(
              onPressed: widget.onAttachmentPressed,
              isPlayful: isPlayful,
              iconColor: iconInactiveColor,
            ),
            SizedBox(width: isPlayful ? AppSpacing.xs : AppSpacing.xxs),

            // Text input field
            Expanded(
              child: AnimatedContainer(
                duration: AppDuration.fast,
                curve: AppCurves.standard,
                constraints: BoxConstraints(
                  maxHeight: _calculateMaxHeight(),
                ),
                decoration: BoxDecoration(
                  color: inputBackgroundColor,
                  borderRadius: AppRadius.input(isPlayful: isPlayful),
                  border: Border.all(
                    color: borderColor.withValues(
                      alpha: _isFocused ? AppOpacity.heavy : 0.0,
                    ),
                    width: _isFocused ? 1.5 : 1.0,
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
                  style: AppTypography.inputText(isPlayful: isPlayful).copyWith(
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppTypography.inputHint(isPlayful: isPlayful).copyWith(
                      color: hintColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isPlayful ? AppSpacing.md : AppSpacing.sm,
                      vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            SizedBox(width: isPlayful ? AppSpacing.xs : AppSpacing.xxs),

            // Send button with animation
            _SendButton(
              onPressed: canSend ? _handleSend : null,
              isLoading: isLoading,
              isPlayful: isPlayful,
              canSend: canSend,
              scaleAnimation: _sendButtonScale,
              opacityAnimation: _sendButtonOpacity,
              primaryColor: primaryColor,
              onPrimaryColor: onPrimaryColor,
              inactiveBackgroundColor: inputBackgroundColor,
              inactiveIconColor: iconInactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxHeight() {
    // Calculate max height based on line height and max lines
    // Using bodyLarge line height (1.5) and font size (16)
    const lineHeight = AppFontSize.bodyLarge * AppLineHeight.body;
    // Add vertical padding
    final verticalPadding = widget.isPlayful ? AppSpacing.sm * 2 : AppSpacing.xs * 2;
    return (lineHeight * widget.maxLines) + verticalPadding;
  }
}

/// Attachment button widget for the message input.
class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.onPressed,
    required this.isPlayful,
    required this.iconColor,
  });

  final VoidCallback? onPressed;
  final bool isPlayful;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final size = isPlayful ? AppIconSize.xxl : AppIconSize.xl;
    final iconSize = isPlayful ? AppIconSize.md : AppIconSize.sm;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.avatar(),
          child: Center(
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Send button widget with animations.
class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.onPressed,
    required this.isLoading,
    required this.isPlayful,
    required this.canSend,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.inactiveBackgroundColor,
    required this.inactiveIconColor,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPlayful;
  final bool canSend;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color inactiveBackgroundColor;
  final Color inactiveIconColor;

  @override
  Widget build(BuildContext context) {
    final size = isPlayful ? AppIconSize.xxl : AppIconSize.xl;
    final iconSize = isPlayful ? AppIconSize.md : AppIconSize.sm;
    final loadingSize = isPlayful ? AppIconSize.sm : AppIconSize.xs;

    return AnimatedBuilder(
      animation: Listenable.merge([scaleAnimation, opacityAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: canSend ? scaleAnimation.value : 0.9,
          child: AnimatedContainer(
            duration: AppDuration.fast,
            curve: AppCurves.standard,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: canSend ? primaryColor : inactiveBackgroundColor,
              borderRadius: AppRadius.button(isPlayful: isPlayful),
              boxShadow: canSend
                  ? AppShadows.button(isPlayful: isPlayful)
                  : AppShadows.none,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: AppRadius.button(isPlayful: isPlayful),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: loadingSize,
                          height: loadingSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            color: canSend ? onPrimaryColor : inactiveIconColor,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: iconSize,
                          color: canSend ? onPrimaryColor : inactiveIconColor,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
