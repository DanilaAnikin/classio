import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

// =============================================================================
// APP INPUT - Premium Reusable Text Field Component
// =============================================================================
//
// A premium, enterprise-grade text input component that supports:
// - Multiple variants (standard, password, search, multiline)
// - Theme-aware styling (Clean vs Playful)
// - Smooth animations for focus states and floating labels
// - Comprehensive state handling (default, focused, error, disabled)
// - Focus glow effects using shadow system
//
// Usage Examples:
// ```dart
// // Standard text field
// AppInput(
//   controller: _controller,
//   label: 'Email',
//   hint: 'Enter your email address',
//   prefixIcon: Icons.email_outlined,
//   keyboardType: TextInputType.emailAddress,
//   validator: (value) => value?.isEmpty == true ? 'Required' : null,
// )
//
// // Password field with visibility toggle
// AppInput.password(
//   controller: _passwordController,
//   label: 'Password',
//   hint: 'Enter your password',
// )
//
// // Search field with clear button
// AppInput.search(
//   controller: _searchController,
//   hint: 'Search students...',
//   onChanged: (value) => _filterStudents(value),
// )
//
// // Multiline text area
// AppInput.multiline(
//   controller: _bioController,
//   label: 'Bio',
//   hint: 'Tell us about yourself',
//   maxLines: 5,
//   maxLength: 500,
// )
// ```
// =============================================================================

/// Input variant types
enum AppInputVariant {
  /// Standard single-line text input
  standard,

  /// Password input with visibility toggle
  password,

  /// Search input with search icon and clear button
  search,

  /// Multi-line text area
  multiline,
}

/// A premium, theme-aware text input component.
///
/// Supports multiple variants and comprehensive customization options
/// while maintaining consistent styling from the design system.
class AppInput extends StatefulWidget {
  /// Creates a standard text input.
  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.obscureText = false,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onTap,
    this.onEditingComplete,
    this.contentPadding,
    this.fillColor,
    this.showClearButton = false,
    this.onClear,
  })  : _variant = AppInputVariant.standard,
        _initialObscureText = obscureText;

  /// Creates a password input with visibility toggle.
  const AppInput.password({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.inputFormatters,
    this.onTap,
    this.onEditingComplete,
    this.contentPadding,
    this.fillColor,
  })  : _variant = AppInputVariant.password,
        obscureText = true,
        _initialObscureText = true,
        suffixIcon = null,
        keyboardType = TextInputType.visiblePassword,
        maxLines = 1,
        minLines = null,
        textCapitalization = TextCapitalization.none,
        autocorrect = false,
        enableSuggestions = false,
        showClearButton = false,
        onClear = null;

  /// Creates a search input with search icon and clear button.
  const AppInput.search({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.textInputAction = TextInputAction.search,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.inputFormatters,
    this.onTap,
    this.onEditingComplete,
    this.contentPadding,
    this.fillColor,
    this.onClear,
  })  : _variant = AppInputVariant.search,
        label = null,
        helperText = null,
        errorText = null,
        prefixIcon = Icons.search_rounded,
        suffixIcon = null,
        obscureText = false,
        _initialObscureText = false,
        keyboardType = TextInputType.text,
        maxLines = 1,
        minLines = null,
        textCapitalization = TextCapitalization.none,
        autocorrect = true,
        enableSuggestions = true,
        showClearButton = true;

  /// Creates a multiline text area input.
  const AppInput.multiline({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.multiline,
    this.maxLines = 5,
    this.minLines = 3,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.sentences,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onTap,
    this.onEditingComplete,
    this.contentPadding,
    this.fillColor,
    this.showClearButton = false,
    this.onClear,
  })  : _variant = AppInputVariant.multiline,
        obscureText = false,
        _initialObscureText = false,
        textInputAction = TextInputAction.newline,
        onSubmitted = null;

  // ===========================================================================
  // PROPERTIES
  // ===========================================================================

  /// The variant of the input (standard, password, search, multiline).
  final AppInputVariant _variant;

  /// Initial obscure text value (for internal state management).
  final bool _initialObscureText;

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Floating label text displayed above the input when focused or filled.
  final String? label;

  /// Placeholder text displayed when the input is empty.
  final String? hint;

  /// Helper text displayed below the input.
  final String? helperText;

  /// Error text displayed below the input (overrides helperText when present).
  final String? errorText;

  /// Icon displayed at the start of the input.
  final IconData? prefixIcon;

  /// Icon or widget displayed at the end of the input.
  final IconData? suffixIcon;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the text (e.g., presses Enter).
  final ValueChanged<String>? onSubmitted;

  /// Validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// The action button to display on the keyboard.
  final TextInputAction? textInputAction;

  /// Maximum number of lines for the input.
  final int maxLines;

  /// Minimum number of lines for the input (multiline only).
  final int? minLines;

  /// Maximum length of the input text.
  final int? maxLength;

  /// Whether the input is enabled.
  final bool enabled;

  /// Whether the input is read-only.
  final bool readOnly;

  /// Whether to autofocus the input when it's displayed.
  final bool autofocus;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// Focus node for controlling focus programmatically.
  final FocusNode? focusNode;

  /// Input formatters to apply to the input.
  final List<TextInputFormatter>? inputFormatters;

  /// Text capitalization behavior.
  final TextCapitalization textCapitalization;

  /// Whether to enable autocorrect.
  final bool autocorrect;

  /// Whether to enable suggestions.
  final bool enableSuggestions;

  /// Callback when the input is tapped.
  final VoidCallback? onTap;

  /// Callback when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Custom content padding for the input.
  final EdgeInsetsGeometry? contentPadding;

  /// Custom fill color for the input background.
  final Color? fillColor;

  /// Whether to show a clear button when the input has content.
  final bool showClearButton;

  /// Callback when the clear button is pressed.
  final VoidCallback? onClear;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late bool _obscureText;
  bool _isFocused = false;
  bool _hasContent = false;

  // Animation controller for smooth transitions
  late final AnimationController _animationController;
  late final Animation<double> _focusAnimation;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget._initialObscureText;
    _hasContent = _controller.text.isNotEmpty;

    // Set up focus listener
    _focusNode.addListener(_handleFocusChange);

    // Set up text change listener
    _controller.addListener(_handleTextChange);

    // Set up animation
    _animationController = AnimationController(
      duration: AppDuration.normal,
      vsync: this,
    );

    _focusAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.standard,
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _controller.removeListener(_handleTextChange);

    // Only dispose if we created them
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();

    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleTextChange() {
    final hasContent = _controller.text.isNotEmpty;
    if (hasContent != _hasContent) {
      setState(() {
        _hasContent = hasContent;
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = theme.brightness == Brightness.light &&
        theme.colorScheme.primary == PlayfulColors.primary;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main input container with animated decoration
        AnimatedBuilder(
          animation: _focusAnimation,
          builder: (context, child) {
            return Container(
              decoration: _buildDecoration(
                isPlayful: isPlayful,
                hasError: hasError,
              ),
              child: child,
            );
          },
          child: _buildTextField(isPlayful: isPlayful, hasError: hasError),
        ),

        // Helper/Error text and counter
        if (widget.helperText != null ||
            widget.errorText != null ||
            widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppSpacing.space4,
              left: AppSpacing.space4,
              right: AppSpacing.space4,
            ),
            child: _buildBottomRow(isPlayful: isPlayful, hasError: hasError),
          ),
      ],
    );
  }

  BoxDecoration _buildDecoration({
    required bool isPlayful,
    required bool hasError,
  }) {
    final borderRadius = AppRadius.input(isPlayful: isPlayful);

    // Determine border color based on state
    Color borderColor;
    if (!widget.enabled) {
      borderColor =
          isPlayful ? PlayfulColors.inputBorder : CleanColors.inputBorder;
    } else if (hasError) {
      borderColor = isPlayful
          ? PlayfulColors.inputBorderError
          : CleanColors.inputBorderError;
    } else if (_isFocused) {
      borderColor = isPlayful
          ? PlayfulColors.inputBorderFocus
          : CleanColors.inputBorderFocus;
    } else {
      borderColor =
          isPlayful ? PlayfulColors.inputBorder : CleanColors.inputBorder;
    }

    // Determine background color
    Color backgroundColor;
    if (!widget.enabled) {
      backgroundColor = isPlayful
          ? PlayfulColors.inputBackgroundDisabled
          : CleanColors.inputBackgroundDisabled;
    } else if (_isFocused) {
      backgroundColor = isPlayful
          ? PlayfulColors.inputBackgroundFocus
          : CleanColors.inputBackgroundFocus;
    } else {
      backgroundColor = widget.fillColor ??
          (isPlayful
              ? PlayfulColors.inputBackground
              : CleanColors.inputBackground);
    }

    // Build shadow based on state
    List<BoxShadow> shadows = [];
    if (widget.enabled && _isFocused) {
      if (hasError) {
        shadows = AppShadows.inputFocusError(isPlayful: isPlayful);
      } else {
        shadows = AppShadows.inputFocus(isPlayful: isPlayful);
      }
    }

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: Border.all(
        color: borderColor,
        width: _isFocused ? 2.0 : 1.0,
      ),
      boxShadow: shadows,
    );
  }

  Widget _buildTextField({
    required bool isPlayful,
    required bool hasError,
  }) {
    final textStyle = AppTypography.inputText(isPlayful: isPlayful);
    final hintStyle = AppTypography.inputHint(isPlayful: isPlayful);
    final labelStyle = AppTypography.inputLabel(isPlayful: isPlayful);

    // Determine label color based on state
    Color labelColor;
    if (!widget.enabled) {
      labelColor =
          isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled;
    } else if (hasError) {
      labelColor = isPlayful ? PlayfulColors.error : CleanColors.error;
    } else if (_isFocused) {
      labelColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    } else {
      labelColor =
          isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    }

    // Determine icon color
    Color iconColor;
    if (!widget.enabled) {
      iconColor =
          isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled;
    } else if (_isFocused) {
      iconColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    } else {
      iconColor =
          isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;
    }

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: _obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      onTap: widget.onTap,
      onEditingComplete: widget.onEditingComplete,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: textStyle.copyWith(
        color: widget.enabled
            ? (isPlayful
                ? PlayfulColors.textPrimary
                : CleanColors.textPrimary)
            : (isPlayful
                ? PlayfulColors.textDisabled
                : CleanColors.textDisabled),
      ),
      cursorColor: isPlayful ? PlayfulColors.primary : CleanColors.primary,
      cursorWidth: 2.0,
      cursorRadius: const Radius.circular(1),
      decoration: InputDecoration(
        // Remove default decoration as we handle it in the container
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,

        // Content padding
        contentPadding: widget.contentPadding ?? AppSpacing.inputInsets,

        // Label (floating)
        labelText: widget.label,
        labelStyle: labelStyle.copyWith(color: labelColor),
        floatingLabelStyle: labelStyle.copyWith(
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,

        // Hint
        hintText: widget.hint,
        hintStyle: hintStyle,

        // Counter (hidden, we render our own)
        counterText: '',

        // Prefix icon
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  widget.prefixIcon,
                  size: AppIconSize.md,
                  color: iconColor,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),

        // Suffix icon/widget
        suffixIcon: _buildSuffixWidget(isPlayful: isPlayful, hasError: hasError),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),

        // Alignment
        alignLabelWithHint:
            widget._variant == AppInputVariant.multiline ? true : false,
      ),
    );
  }

  Widget? _buildSuffixWidget({
    required bool isPlayful,
    required bool hasError,
  }) {
    final List<Widget> suffixWidgets = [];

    // Determine icon color
    Color iconColor;
    if (!widget.enabled) {
      iconColor =
          isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled;
    } else {
      iconColor =
          isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;
    }

    // Clear button (for search variant or when showClearButton is true)
    if ((widget._variant == AppInputVariant.search || widget.showClearButton) &&
        _hasContent &&
        widget.enabled) {
      suffixWidgets.add(
        _SuffixIconButton(
          icon: Icons.close_rounded,
          onPressed: _clearText,
          color: iconColor,
          tooltip: 'Clear',
        ),
      );
    }

    // Password visibility toggle
    if (widget._variant == AppInputVariant.password && widget.enabled) {
      suffixWidgets.add(
        _SuffixIconButton(
          icon: _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onPressed: _toggleObscureText,
          color: iconColor,
          tooltip: _obscureText ? 'Show password' : 'Hide password',
        ),
      );
    }

    // Custom suffix icon
    if (widget.suffixIcon != null) {
      suffixWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            widget.suffixIcon,
            size: AppIconSize.md,
            color: iconColor,
          ),
        ),
      );
    }

    if (suffixWidgets.isEmpty) return null;

    if (suffixWidgets.length == 1) {
      return suffixWidgets.first;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: suffixWidgets,
    );
  }

  Widget _buildBottomRow({
    required bool isPlayful,
    required bool hasError,
  }) {
    final errorStyle = AppTypography.inputError(isPlayful: isPlayful);
    final helperStyle = AppTypography.tertiaryText(isPlayful: isPlayful);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Helper or error text
        Expanded(
          child: AnimatedSwitcher(
            duration: AppDuration.fast,
            switchInCurve: AppCurves.decelerate,
            switchOutCurve: AppCurves.accelerate,
            child: hasError
                ? Text(
                    widget.errorText!,
                    key: const ValueKey('error'),
                    style: errorStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                : widget.helperText != null
                    ? Text(
                        widget.helperText!,
                        key: const ValueKey('helper'),
                        style: helperStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ),

        // Character counter
        if (widget.maxLength != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.space8),
            child: Text(
              '${_controller.text.length}/${widget.maxLength}',
              style: helperStyle.copyWith(
                color: _controller.text.length > (widget.maxLength! * 0.9)
                    ? (isPlayful ? PlayfulColors.warning : CleanColors.warning)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// Internal suffix icon button widget
class _SuffixIconButton extends StatelessWidget {
  const _SuffixIconButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Icon(
          icon,
          size: AppIconSize.md,
          color: color,
        ),
        onPressed: onPressed,
        splashRadius: 20,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}

// =============================================================================
// ANIMATED BUILDER HELPER
// =============================================================================

/// A simplified AnimatedBuilder that rebuilds on animation changes.
class AnimatedBuilder extends AnimatedWidget {
  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
