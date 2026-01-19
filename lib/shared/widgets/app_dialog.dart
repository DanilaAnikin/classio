import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/theme_type.dart';

// =============================================================================
// APP DIALOG
// =============================================================================
// A premium, reusable dialog component that adapts to Clean and Playful themes.
//
// Features:
// - Multiple dialog variants (standard, alert, confirm, form, fullscreen)
// - Theme-aware styling with automatic detection
// - Animated entrance/exit transitions
// - Proper accessibility support (focus, escape key, screen reader)
// - Static show methods for easy invocation
// - Premium design with soft shadows and rounded corners
//
// Usage Examples:
// ```dart
// // Standard dialog with custom content
// AppDialog.show<String>(
//   context: context,
//   title: 'Edit Profile',
//   content: ProfileEditForm(),
//   actions: [
//     TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
//     ElevatedButton(onPressed: () => Navigator.pop(context, 'saved'), child: Text('Save')),
//   ],
// );
//
// // Simple alert dialog
// await AppDialog.showAlert(
//   context: context,
//   title: 'Success',
//   message: 'Your changes have been saved.',
// );
//
// // Confirmation dialog
// final confirmed = await AppDialog.showConfirm(
//   context: context,
//   title: 'Delete Item',
//   message: 'Are you sure you want to delete this item? This action cannot be undone.',
//   confirmText: 'Delete',
//   isDestructive: true,
// );
// if (confirmed == true) {
//   // Perform deletion
// }
//
// // Form dialog with validation
// final result = await AppDialog.showForm<Map<String, dynamic>>(
//   context: context,
//   title: 'Add Student',
//   content: StudentForm(
//     onSubmit: (data) => Navigator.pop(context, data),
//   ),
// );
//
// // Fullscreen dialog for complex content
// await AppDialog.show(
//   context: context,
//   title: 'Document Preview',
//   content: DocumentViewer(),
//   isFullscreen: true,
// );
// ```
// =============================================================================

/// Determines the variant/style of the dialog.
enum AppDialogVariant {
  /// Standard dialog with customizable content and actions.
  standard,

  /// Simple alert with a message and OK button.
  alert,

  /// Confirmation dialog with Confirm/Cancel actions.
  confirm,

  /// Form dialog optimized for input fields with validation.
  form,

  /// Fullscreen dialog for complex content.
  fullscreen,
}

/// A premium, reusable dialog component for the Classio app.
///
/// Automatically adapts to Clean and Playful themes with appropriate styling.
/// Supports multiple variants for different use cases.
class AppDialog extends StatelessWidget {
  /// Creates a standard dialog.
  const AppDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.actions,
    this.icon,
    this.iconColor,
    this.isDismissible = true,
    this.showCloseButton = false,
    this.maxWidth = 400,
    this.padding,
    this.variant = AppDialogVariant.standard,
    this.themeType,
  });

  /// Creates an alert dialog with a message and OK button.
  factory AppDialog.alert({
    Key? key,
    required String title,
    required String message,
    String okText = 'OK',
    IconData? icon,
    Color? iconColor,
    ThemeType? themeType,
  }) {
    return AppDialog(
      key: key,
      title: title,
      content: _AlertContent(message: message),
      icon: icon,
      iconColor: iconColor,
      variant: AppDialogVariant.alert,
      showCloseButton: false,
      themeType: themeType,
      actions: [
        _DialogAction(
          text: okText,
          isPrimary: true,
          onPressed: null, // Will be handled in build
        ),
      ],
    );
  }

  /// Creates a confirmation dialog with Confirm/Cancel actions.
  factory AppDialog.confirm({
    Key? key,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
    ThemeType? themeType,
  }) {
    return AppDialog(
      key: key,
      title: title,
      content: _AlertContent(message: message),
      icon: icon ?? (isDestructive ? Icons.warning_amber_rounded : null),
      iconColor: iconColor,
      variant: AppDialogVariant.confirm,
      showCloseButton: false,
      themeType: themeType,
      actions: [
        _DialogAction(
          text: cancelText,
          isPrimary: false,
          onPressed: null,
        ),
        _DialogAction(
          text: confirmText,
          isPrimary: true,
          isDestructive: isDestructive,
          onPressed: null,
        ),
      ],
    );
  }

  /// Creates a form dialog optimized for input fields.
  factory AppDialog.form({
    Key? key,
    String? title,
    Widget? titleWidget,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = false,
    bool showCloseButton = true,
    double maxWidth = 480,
    ThemeType? themeType,
  }) {
    return AppDialog(
      key: key,
      title: title,
      titleWidget: titleWidget,
      content: content,
      actions: actions,
      isDismissible: isDismissible,
      showCloseButton: showCloseButton,
      maxWidth: maxWidth,
      variant: AppDialogVariant.form,
      themeType: themeType,
    );
  }

  /// Creates a fullscreen dialog.
  factory AppDialog.fullscreen({
    Key? key,
    String? title,
    Widget? titleWidget,
    required Widget content,
    List<Widget>? actions,
    bool showCloseButton = true,
    ThemeType? themeType,
  }) {
    return AppDialog(
      key: key,
      title: title,
      titleWidget: titleWidget,
      content: content,
      actions: actions,
      showCloseButton: showCloseButton,
      variant: AppDialogVariant.fullscreen,
      themeType: themeType,
    );
  }

  /// The title text for the dialog.
  final String? title;

  /// A custom widget for the title (takes precedence over [title]).
  final Widget? titleWidget;

  /// The main content of the dialog.
  final Widget? content;

  /// Action buttons at the bottom of the dialog.
  final List<Widget>? actions;

  /// An optional icon displayed above the title.
  final IconData? icon;

  /// Custom color for the icon.
  final Color? iconColor;

  /// Whether the dialog can be dismissed by tapping outside.
  final bool isDismissible;

  /// Whether to show a close button in the top-right corner.
  final bool showCloseButton;

  /// Maximum width of the dialog (default: 400).
  final double maxWidth;

  /// Custom padding for the dialog content.
  final EdgeInsets? padding;

  /// The variant/style of the dialog.
  final AppDialogVariant variant;

  /// Optional theme type override. If null, detects from context.
  final ThemeType? themeType;

  // ===========================================================================
  // STATIC SHOW METHODS
  // ===========================================================================

  /// Shows a custom dialog and returns the result.
  ///
  /// Example:
  /// ```dart
  /// final result = await AppDialog.show<String>(
  ///   context: context,
  ///   title: 'Select Option',
  ///   content: OptionsList(),
  ///   actions: [...],
  /// );
  /// ```
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    Widget? content,
    List<Widget>? actions,
    IconData? icon,
    Color? iconColor,
    bool isDismissible = true,
    bool showCloseButton = false,
    double maxWidth = 400,
    EdgeInsets? padding,
    bool isFullscreen = false,
    bool useRootNavigator = true,
  }) {
    if (isFullscreen) {
      return Navigator.of(context, rootNavigator: useRootNavigator).push<T>(
        _FullscreenDialogRoute<T>(
          builder: (context) => AppDialog.fullscreen(
            title: title,
            titleWidget: titleWidget,
            content: content!,
            actions: actions,
            showCloseButton: showCloseButton,
          ),
        ),
      );
    }

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: _getScrimColor(context),
      transitionDuration: AppDuration.medium,
      transitionBuilder: _buildTransition,
      useRootNavigator: useRootNavigator,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppDialog(
          title: title,
          titleWidget: titleWidget,
          content: content,
          actions: actions,
          icon: icon,
          iconColor: iconColor,
          isDismissible: isDismissible,
          showCloseButton: showCloseButton,
          maxWidth: maxWidth,
          padding: padding,
        );
      },
    );
  }

  /// Shows a simple alert dialog with a message and OK button.
  ///
  /// Example:
  /// ```dart
  /// await AppDialog.showAlert(
  ///   context: context,
  ///   title: 'Error',
  ///   message: 'An unexpected error occurred.',
  ///   icon: Icons.error_outline,
  /// );
  /// ```
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String okText = 'OK',
    IconData? icon,
    Color? iconColor,
    bool useRootNavigator = true,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: _getScrimColor(context),
      transitionDuration: AppDuration.medium,
      transitionBuilder: _buildTransition,
      useRootNavigator: useRootNavigator,
      pageBuilder: (context, animation, secondaryAnimation) {
        final isPlayful = _isPlayfulTheme(context);
        return _AlertDialog(
          title: title,
          message: message,
          okText: okText,
          icon: icon,
          iconColor: iconColor,
          isPlayful: isPlayful,
        );
      },
    );
  }

  /// Shows a confirmation dialog and returns true if confirmed.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await AppDialog.showConfirm(
  ///   context: context,
  ///   title: 'Delete Account',
  ///   message: 'This will permanently delete your account.',
  ///   confirmText: 'Delete',
  ///   isDestructive: true,
  /// );
  /// ```
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Color? iconColor,
    bool useRootNavigator = true,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: _getScrimColor(context),
      transitionDuration: AppDuration.medium,
      transitionBuilder: _buildTransition,
      useRootNavigator: useRootNavigator,
      pageBuilder: (context, animation, secondaryAnimation) {
        final isPlayful = _isPlayfulTheme(context);
        return _ConfirmDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          isDestructive: isDestructive,
          icon: icon,
          iconColor: iconColor,
          isPlayful: isPlayful,
        );
      },
    );
  }

  /// Shows a form dialog optimized for input fields.
  ///
  /// Example:
  /// ```dart
  /// final data = await AppDialog.showForm<Map<String, dynamic>>(
  ///   context: context,
  ///   title: 'Add Student',
  ///   content: StudentForm(
  ///     onSubmit: (data) => Navigator.pop(context, data),
  ///   ),
  /// );
  /// ```
  static Future<T?> showForm<T>({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    required Widget content,
    List<Widget>? actions,
    bool showCloseButton = true,
    double maxWidth = 480,
    bool useRootNavigator = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: _getScrimColor(context),
      transitionDuration: AppDuration.medium,
      transitionBuilder: _buildTransition,
      useRootNavigator: useRootNavigator,
      pageBuilder: (context, animation, secondaryAnimation) {
        return AppDialog.form(
          title: title,
          titleWidget: titleWidget,
          content: content,
          actions: actions,
          showCloseButton: showCloseButton,
          maxWidth: maxWidth,
        );
      },
    );
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  static Color _getScrimColor(BuildContext context) {
    final isPlayful = _isPlayfulTheme(context);
    return isPlayful
        ? PlayfulColors.surfaceOverlay
        : CleanColors.surfaceOverlay;
  }

  static bool _isPlayfulTheme(BuildContext context) {
    // Try to detect theme from the brightness and primary color
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    // Playful theme uses violet (0xFF7C3AED), Clean uses blue (0xFF0066FF)
    // Compare ARGB values using toARGB32() to avoid deprecation warning
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }

  static Widget _buildTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.modalEnter,
      reverseCurve: AppCurves.modalExit,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = themeType == ThemeType.playful ||
        (themeType == null && _isPlayfulTheme(context));

    if (variant == AppDialogVariant.fullscreen) {
      return _buildFullscreenDialog(context, isPlayful);
    }

    return _DialogWrapper(
      maxWidth: maxWidth,
      isDismissible: isDismissible,
      child: _buildDialogContent(context, isPlayful),
    );
  }

  Widget _buildDialogContent(BuildContext context, bool isPlayful) {
    final dialogPadding = padding ?? AppSpacing.dialogInsets;
    final borderRadius = AppRadius.dialog(isPlayful: isPlayful);

    // Colors
    final surfaceColor = isPlayful
        ? PlayfulColors.surfaceElevated
        : CleanColors.surfaceElevated;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;
    final iconBgColor = isPlayful
        ? PlayfulColors.primarySubtle
        : CleanColors.primarySubtle;
    final defaultIconColor = iconColor ??
        (isPlayful ? PlayfulColors.primary : CleanColors.primary);

    // Shadows
    final shadows = AppShadows.modal(isPlayful: isPlayful);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape &&
                isDismissible) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: borderRadius,
              border: Border.all(color: borderColor.withValues(alpha: 0.5)),
              boxShadow: shadows,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with close button
                    if (showCloseButton ||
                        title != null ||
                        titleWidget != null ||
                        icon != null)
                      _buildHeader(
                        context,
                        isPlayful,
                        dialogPadding,
                        iconBgColor,
                        defaultIconColor,
                      ),

                    // Content
                    if (content != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          dialogPadding.left,
                          (title != null || titleWidget != null || icon != null)
                              ? 0
                              : dialogPadding.top,
                          dialogPadding.right,
                          actions != null ? AppSpacing.md : dialogPadding.bottom,
                        ),
                        child: content,
                      ),

                    // Actions
                    if (actions != null && actions!.isNotEmpty)
                      _buildActions(context, isPlayful, dialogPadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isPlayful,
    EdgeInsets dialogPadding,
    Color iconBgColor,
    Color iconColor,
  ) {
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dialogPadding.left,
        dialogPadding.top,
        showCloseButton ? AppSpacing.sm : dialogPadding.right,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button row
          if (showCloseButton)
            Align(
              alignment: Alignment.topRight,
              child: _CloseButton(isPlayful: isPlayful),
            ),

          // Icon
          if (icon != null) ...[
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),
            ),
            AppSpacing.gap16,
          ],

          // Title
          if (titleWidget != null)
            titleWidget!
          else if (title != null)
            Center(
              child: Text(
                title!,
                style: AppTypography.sectionTitle(isPlayful: isPlayful)
                    .copyWith(color: textPrimary),
                textAlign: icon != null ? TextAlign.center : TextAlign.start,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    bool isPlayful,
    EdgeInsets dialogPadding,
  ) {
    final dividerColor =
        isPlayful ? PlayfulColors.divider : CleanColors.divider;

    // For alert and confirm variants, handle the action buttons specially
    if (variant == AppDialogVariant.alert ||
        variant == AppDialogVariant.confirm) {
      return _buildVariantActions(context, isPlayful, dialogPadding);
    }

    return Column(
      children: [
        Divider(height: 1, color: dividerColor),
        Padding(
          padding: EdgeInsets.all(dialogPadding.left),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (int i = 0; i < actions!.length; i++) ...[
                if (i > 0) AppSpacing.gapH8,
                actions![i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariantActions(
    BuildContext context,
    bool isPlayful,
    EdgeInsets dialogPadding,
  ) {
    final primaryColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;

    final actionWidgets = <Widget>[];

    for (final action in actions!) {
      if (action is _DialogAction) {
        final isDestructive = action.isDestructive;
        final isPrimary = action.isPrimary;

        Widget button;
        if (isPrimary) {
          button = ElevatedButton(
            onPressed: () {
              if (variant == AppDialogVariant.alert) {
                Navigator.of(context).pop();
              } else if (variant == AppDialogVariant.confirm) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? errorColor : primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.button(isPlayful: isPlayful),
              ),
              padding: AppSpacing.buttonInsetsMd,
            ),
            child: Text(action.text),
          );
        } else {
          button = TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.button(isPlayful: isPlayful),
              ),
              padding: AppSpacing.buttonInsetsMd,
            ),
            child: Text(action.text),
          );
        }
        actionWidgets.add(button);
      } else {
        actionWidgets.add(action);
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dialogPadding.left,
        AppSpacing.md,
        dialogPadding.right,
        dialogPadding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actionWidgets.length; i++) ...[
            if (i > 0) AppSpacing.gapH12,
            actionWidgets[i],
          ],
        ],
      ),
    );
  }

  Widget _buildFullscreenDialog(BuildContext context, bool isPlayful) {
    final surfaceColor =
        isPlayful ? PlayfulColors.background : CleanColors.background;
    final appBarColor = isPlayful ? PlayfulColors.appBar : CleanColors.appBar;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: showCloseButton
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close',
              )
            : null,
        title: titleWidget ??
            (title != null
                ? Text(
                    title!,
                    style: AppTypography.appBarTitle(isPlayful: isPlayful)
                        .copyWith(color: textPrimary),
                  )
                : null),
        actions: actions,
      ),
      body: content,
    );
  }
}

// =============================================================================
// INTERNAL WIDGETS
// =============================================================================

/// Wrapper widget that handles dialog positioning and constraints.
class _DialogWrapper extends StatelessWidget {
  const _DialogWrapper({
    required this.maxWidth,
    required this.isDismissible,
    required this.child,
  });

  final double maxWidth;
  final bool isDismissible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.pagePaddingMobile,
        child: child,
      ),
    );
  }
}

/// Close button for the dialog header.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;
    final hoverColor =
        isPlayful ? PlayfulColors.surfaceHover : CleanColors.surfaceHover;

    return Semantics(
      button: true,
      label: 'Close dialog',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: AppRadius.fullRadius,
          hoverColor: hoverColor,
          child: Padding(
            padding: AppSpacing.insets8,
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal widget for alert content.
class _AlertContent extends StatelessWidget {
  const _AlertContent({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message);
  }
}

/// Internal action button definition.
class _DialogAction extends StatelessWidget {
  const _DialogAction({
    required this.text,
    required this.isPrimary,
    this.isDestructive = false,
    this.onPressed,
  });

  final String text;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // This widget is used as a data holder and isn't directly rendered
    return const SizedBox.shrink();
  }
}

/// Internal alert dialog implementation.
class _AlertDialog extends StatelessWidget {
  const _AlertDialog({
    required this.title,
    required this.message,
    required this.okText,
    required this.isPlayful,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String message;
  final String okText;
  final bool isPlayful;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isPlayful
        ? PlayfulColors.surfaceElevated
        : CleanColors.surfaceElevated;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final iconBgColor = isPlayful
        ? PlayfulColors.primarySubtle
        : CleanColors.primarySubtle;

    final shadows = AppShadows.modal(isPlayful: isPlayful);
    final borderRadius = AppRadius.dialog(isPlayful: isPlayful);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePaddingMobile,
          child: Center(
            child: KeyboardListener(
              focusNode: FocusNode()..requestFocus(),
              autofocus: true,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: borderRadius,
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                  boxShadow: shadows,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Padding(
                    padding: AppSpacing.dialogInsets,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        if (icon != null) ...[
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 28,
                              color: iconColor ?? primaryColor,
                            ),
                          ),
                          AppSpacing.gap16,
                        ],

                        // Title
                        Text(
                          title,
                          style: AppTypography.sectionTitle(isPlayful: isPlayful)
                              .copyWith(color: textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gap12,

                        // Message
                        Text(
                          message,
                          style: AppTypography.secondaryText(isPlayful: isPlayful)
                              .copyWith(color: textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gap24,

                        // OK Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    AppRadius.button(isPlayful: isPlayful),
                              ),
                              padding: AppSpacing.buttonInsetsMd,
                            ),
                            child: Text(okText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal confirm dialog implementation.
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDestructive,
    required this.isPlayful,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final bool isPlayful;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isPlayful
        ? PlayfulColors.surfaceElevated
        : CleanColors.surfaceElevated;
    final borderColor = isPlayful ? PlayfulColors.border : CleanColors.border;
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;
    final textPrimary =
        isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;
    final textSecondary =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;
    final iconBgColor = isDestructive
        ? (isPlayful ? PlayfulColors.errorMuted : CleanColors.errorMuted)
        : (isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle);

    final shadows = AppShadows.modal(isPlayful: isPlayful);
    final borderRadius = AppRadius.dialog(isPlayful: isPlayful);

    final effectiveIcon =
        icon ?? (isDestructive ? Icons.warning_amber_rounded : null);
    final effectiveIconColor = iconColor ??
        (isDestructive
            ? errorColor
            : (isPlayful ? PlayfulColors.primary : CleanColors.primary));

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePaddingMobile,
          child: Center(
            child: KeyboardListener(
              focusNode: FocusNode()..requestFocus(),
              autofocus: true,
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  Navigator.of(context).pop(false);
                }
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: borderRadius,
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                  boxShadow: shadows,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Padding(
                    padding: AppSpacing.dialogInsets,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        if (effectiveIcon != null) ...[
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              effectiveIcon,
                              size: 28,
                              color: effectiveIconColor,
                            ),
                          ),
                          AppSpacing.gap16,
                        ],

                        // Title
                        Text(
                          title,
                          style: AppTypography.sectionTitle(isPlayful: isPlayful)
                              .copyWith(color: textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gap12,

                        // Message
                        Text(
                          message,
                          style: AppTypography.secondaryText(isPlayful: isPlayful)
                              .copyWith(color: textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.gap24,

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textSecondary,
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        AppRadius.button(isPlayful: isPlayful),
                                  ),
                                  padding: AppSpacing.buttonInsetsMd,
                                ),
                                child: Text(cancelText),
                              ),
                            ),
                            AppSpacing.gapH12,
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isDestructive ? errorColor : primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        AppRadius.button(isPlayful: isPlayful),
                                  ),
                                  padding: AppSpacing.buttonInsetsMd,
                                ),
                                child: Text(confirmText),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom route for fullscreen dialogs with proper transitions.
class _FullscreenDialogRoute<T> extends PageRoute<T> {
  _FullscreenDialogRoute({required this.builder});

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => AppDuration.medium;

  @override
  bool get opaque => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.modalEnter,
      reverseCurve: AppCurves.modalExit,
    );

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    );
  }
}
