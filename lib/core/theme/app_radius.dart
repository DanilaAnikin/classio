import 'package:flutter/material.dart';

/// Comprehensive border radius system for consistent, premium corner rounding.
///
/// This system provides:
/// - Named radius scale (none, xs, sm, md, lg, xl, xxl, full)
/// - Theme-aware semantic radius (card, button, input, dialog, etc.)
/// - Pre-computed BorderRadius and Radius objects
/// - Partial radius helpers (topOnly, bottomOnly, etc.)
/// - Special shapes for chat bubbles and other UI elements
///
/// ## Design Philosophy
/// - Clean theme: Subtle, professional rounding (8px buttons, 12px cards)
/// - Playful theme: Friendlier, more rounded (12px buttons, 16px cards)
/// - Both themes share certain constants (pill chips, circular avatars)
///
/// ## Usage Examples
/// ```dart
/// // Basic usage with named sizes
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.md.borderRadius,
///   ),
/// )
///
/// // Theme-aware semantic usage
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.card(isPlayful: isPlayfulTheme),
///   ),
/// )
///
/// // Pre-computed radius objects
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.cardRadius,
///   ),
/// )
///
/// // Partial radius helpers
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.topOnly(AppRadius.xl),
///   ),
/// )
///
/// // Chat bubble radius
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.messageRadius(isFromMe: true),
///   ),
/// )
/// ```
abstract final class AppRadius {
  // ============================================================================
  // RADIUS SCALE - Raw double values
  // ============================================================================

  /// No radius (0px) - Sharp corners
  static const double none = 0.0;

  /// Extra small radius (4px) - Tiny elements, badges, tooltips
  static const double xs = 4.0;

  /// Small radius (6px) - Chips, small buttons
  static const double sm = 6.0;

  /// Medium radius (8px) - Buttons/inputs (Clean theme)
  static const double md = 8.0;

  /// Large radius (12px) - Cards (Clean), buttons (Playful)
  static const double lg = 12.0;

  /// Extra large radius (16px) - Cards (Playful), dialogs (Clean)
  static const double xl = 16.0;

  /// Extra extra large radius (20px) - Large dialogs, sheets
  static const double xxl = 20.0;

  /// Full/pill radius (9999px) - Creates fully rounded ends for pills, avatars
  static const double full = 9999.0;

  // ============================================================================
  // SEMANTIC RADIUS - Theme-aware methods returning BorderRadius
  // ============================================================================

  /// Card corner radius based on theme.
  /// - Clean: 12px (subtle, professional)
  /// - Playful: 16px (friendlier, more rounded)
  static BorderRadius card({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? xl : lg);
  }

  /// Button corner radius based on theme.
  /// - Clean: 8px (subtle)
  /// - Playful: 12px (more rounded)
  static BorderRadius button({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? lg : md);
  }

  /// Small button corner radius based on theme.
  /// - Clean: 6px
  /// - Playful: 8px
  static BorderRadius buttonSmall({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? md : sm);
  }

  /// Input field corner radius based on theme.
  /// - Clean: 8px (subtle)
  /// - Playful: 12px (more rounded)
  static BorderRadius input({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? lg : md);
  }

  /// Dialog corner radius based on theme.
  /// - Clean: 16px
  /// - Playful: 20px
  static BorderRadius dialog({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? xxl : xl);
  }

  /// Bottom sheet corner radius (top corners only).
  /// Always 20px for both themes.
  static BorderRadius bottomSheet() {
    return const BorderRadius.vertical(
      top: Radius.circular(xxl),
    );
  }

  /// Chip corner radius - always pill-shaped (fully rounded).
  /// Consistent across both themes.
  static BorderRadius chip({bool isPlayful = false}) {
    return BorderRadius.circular(full);
  }

  /// Avatar corner radius - always circular.
  /// Consistent across both themes.
  static BorderRadius avatar({bool isPlayful = false}) {
    return BorderRadius.circular(full);
  }

  /// Badge corner radius based on theme.
  /// - Clean: 4px
  /// - Playful: 6px
  static BorderRadius badge({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? sm : xs);
  }

  /// Tooltip corner radius - always 6px.
  /// Consistent across both themes.
  static BorderRadius tooltip() {
    return BorderRadius.circular(sm);
  }

  /// Snackbar corner radius based on theme.
  /// - Clean: 8px
  /// - Playful: 12px
  static BorderRadius snackbar({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? lg : md);
  }

  /// Popup menu corner radius based on theme.
  /// - Clean: 8px
  /// - Playful: 12px
  static BorderRadius popupMenu({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? lg : md);
  }

  /// Search bar corner radius based on theme.
  /// - Clean: 8px (subtle)
  /// - Playful: 9999px (pill-shaped)
  static BorderRadius searchBar({required bool isPlayful}) {
    return BorderRadius.circular(isPlayful ? full : md);
  }

  /// Navigation indicator corner radius.
  /// Always 16px for both themes.
  static BorderRadius indicator() {
    return BorderRadius.circular(xl);
  }

  // ============================================================================
  // PRE-COMPUTED BORDERRADIUS OBJECTS - Default (Clean theme) values
  // ============================================================================

  /// No border radius
  static const BorderRadius noneRadius = BorderRadius.zero;

  /// Extra small border radius (4px) - for badges, tiny elements
  static const BorderRadius xsRadius = BorderRadius.all(Radius.circular(xs));

  /// Small border radius (6px) - for chips, small buttons
  static const BorderRadius smRadius = BorderRadius.all(Radius.circular(sm));

  /// Medium border radius (8px) - for buttons, inputs (Clean theme)
  static const BorderRadius mdRadius = BorderRadius.all(Radius.circular(md));

  /// Large border radius (12px) - for cards (Clean theme)
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));

  /// Extra large border radius (16px) - for dialogs, cards (Playful)
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));

  /// Extra extra large border radius (20px) - for large dialogs, sheets
  static const BorderRadius xxlRadius = BorderRadius.all(Radius.circular(xxl));

  /// Full/pill border radius (9999px) - for pills, avatars
  static const BorderRadius fullRadius = BorderRadius.all(Radius.circular(full));

  // ============================================================================
  // SEMANTIC PRE-COMPUTED BORDERRADIUS - Default (Clean theme) values
  // ============================================================================

  /// Default card radius (Clean theme - 12px)
  static const BorderRadius cardRadius = lgRadius;

  /// Default button radius (Clean theme - 8px)
  static const BorderRadius buttonRadius = mdRadius;

  /// Default small button radius (Clean theme - 6px)
  static const BorderRadius buttonSmallRadius = smRadius;

  /// Default input radius (Clean theme - 8px)
  static const BorderRadius inputRadius = mdRadius;

  /// Default dialog radius (Clean theme - 16px)
  static const BorderRadius dialogRadius = xlRadius;

  /// Default bottom sheet radius (top only - 20px)
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Default chip radius (pill - 9999px)
  static const BorderRadius chipRadius = fullRadius;

  /// Default avatar radius (circular - 9999px)
  static const BorderRadius avatarRadius = fullRadius;

  /// Default badge radius (Clean theme - 4px)
  static const BorderRadius badgeRadius = xsRadius;

  /// Default tooltip radius (6px)
  static const BorderRadius tooltipRadius = smRadius;

  /// Default snackbar radius (Clean theme - 8px)
  static const BorderRadius snackbarRadius = mdRadius;

  /// Default popup menu radius (Clean theme - 8px)
  static const BorderRadius popupMenuRadius = mdRadius;

  /// Default indicator radius (16px)
  static const BorderRadius indicatorRadius = xlRadius;

  // ============================================================================
  // THEME-SPECIFIC PRE-COMPUTED BORDERRADIUS
  // ============================================================================

  /// Clean theme card radius (12px)
  static const BorderRadius cleanCardRadius = lgRadius;

  /// Playful theme card radius (16px)
  static const BorderRadius playfulCardRadius = xlRadius;

  /// Clean theme button radius (8px)
  static const BorderRadius cleanButtonRadius = mdRadius;

  /// Playful theme button radius (12px)
  static const BorderRadius playfulButtonRadius = lgRadius;

  /// Clean theme input radius (8px)
  static const BorderRadius cleanInputRadius = mdRadius;

  /// Playful theme input radius (12px)
  static const BorderRadius playfulInputRadius = lgRadius;

  /// Clean theme dialog radius (16px)
  static const BorderRadius cleanDialogRadius = xlRadius;

  /// Playful theme dialog radius (20px)
  static const BorderRadius playfulDialogRadius = xxlRadius;

  /// Clean theme badge radius (4px)
  static const BorderRadius cleanBadgeRadius = xsRadius;

  /// Playful theme badge radius (6px)
  static const BorderRadius playfulBadgeRadius = smRadius;

  /// Clean theme snackbar radius (8px)
  static const BorderRadius cleanSnackbarRadius = mdRadius;

  /// Playful theme snackbar radius (12px)
  static const BorderRadius playfulSnackbarRadius = lgRadius;

  /// Clean theme snackbar shape (8px) - pre-computed RoundedRectangleBorder
  static const RoundedRectangleBorder cleanSnackbarShape = RoundedRectangleBorder(
    borderRadius: cleanSnackbarRadius,
  );

  // ============================================================================
  // PRE-COMPUTED RADIUS OBJECTS
  // ============================================================================

  /// No radius
  static const Radius noneCircular = Radius.zero;

  /// Extra small circular radius (4px)
  static const Radius xsCircular = Radius.circular(xs);

  /// Small circular radius (6px)
  static const Radius smCircular = Radius.circular(sm);

  /// Medium circular radius (8px)
  static const Radius mdCircular = Radius.circular(md);

  /// Large circular radius (12px)
  static const Radius lgCircular = Radius.circular(lg);

  /// Extra large circular radius (16px)
  static const Radius xlCircular = Radius.circular(xl);

  /// Extra extra large circular radius (20px)
  static const Radius xxlCircular = Radius.circular(xxl);

  /// Full circular radius (9999px)
  static const Radius fullCircular = Radius.circular(full);

  // ============================================================================
  // PARTIAL RADIUS HELPERS
  // ============================================================================

  /// Creates a BorderRadius with only the top corners rounded.
  /// Useful for bottom sheets, app bars, modal headers.
  ///
  /// ```dart
  /// AppRadius.topOnly(AppRadius.xl) // 16px top corners
  /// ```
  static BorderRadius topOnly(double radius) {
    return BorderRadius.vertical(
      top: Radius.circular(radius),
    );
  }

  /// Creates a BorderRadius with only the bottom corners rounded.
  /// Useful for tabs, footers, bottom navigation.
  ///
  /// ```dart
  /// AppRadius.bottomOnly(AppRadius.md) // 8px bottom corners
  /// ```
  static BorderRadius bottomOnly(double radius) {
    return BorderRadius.vertical(
      bottom: Radius.circular(radius),
    );
  }

  /// Creates a BorderRadius with only the left corners rounded.
  /// Useful for left-aligned elements, drawer edges.
  ///
  /// ```dart
  /// AppRadius.leftOnly(AppRadius.lg) // 12px left corners
  /// ```
  static BorderRadius leftOnly(double radius) {
    return BorderRadius.horizontal(
      left: Radius.circular(radius),
    );
  }

  /// Creates a BorderRadius with only the right corners rounded.
  /// Useful for right-aligned elements, drawer edges.
  ///
  /// ```dart
  /// AppRadius.rightOnly(AppRadius.lg) // 12px right corners
  /// ```
  static BorderRadius rightOnly(double radius) {
    return BorderRadius.horizontal(
      right: Radius.circular(radius),
    );
  }

  /// Creates a BorderRadius with horizontal (left and right) corners rounded.
  /// Useful for horizontal pills, elongated buttons.
  ///
  /// ```dart
  /// AppRadius.horizontal(AppRadius.full) // Pill shape
  /// ```
  static BorderRadius horizontal(double radius) {
    return BorderRadius.horizontal(
      left: Radius.circular(radius),
      right: Radius.circular(radius),
    );
  }

  /// Creates a BorderRadius with vertical (top and bottom) corners rounded.
  /// Useful for vertical pills.
  ///
  /// ```dart
  /// AppRadius.vertical(AppRadius.lg) // 12px top and bottom
  /// ```
  static BorderRadius vertical(double radius) {
    return BorderRadius.vertical(
      top: Radius.circular(radius),
      bottom: Radius.circular(radius),
    );
  }

  /// Creates a BorderRadius with custom values for each corner.
  ///
  /// ```dart
  /// AppRadius.only(
  ///   topLeft: AppRadius.lg,
  ///   topRight: AppRadius.lg,
  ///   bottomLeft: AppRadius.none,
  ///   bottomRight: AppRadius.md,
  /// )
  /// ```
  static BorderRadius only({
    double topLeft = 0,
    double topRight = 0,
    double bottomLeft = 0,
    double bottomRight = 0,
  }) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  // ============================================================================
  // PRE-COMPUTED PARTIAL BORDERRADIUS OBJECTS
  // ============================================================================

  /// Top-only radius with xxl (20px) - for bottom sheets
  static const BorderRadius topXxl = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Top-only radius with xl (16px) - for modals
  static const BorderRadius topXl = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  /// Top-only radius with lg (12px) - for cards with flat bottoms
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(lg),
  );

  /// Top-only radius with md (8px) - for app bars
  static const BorderRadius topMd = BorderRadius.vertical(
    top: Radius.circular(md),
  );

  /// Bottom-only radius with lg (12px) - for footers
  static const BorderRadius bottomLg = BorderRadius.vertical(
    bottom: Radius.circular(lg),
  );

  /// Bottom-only radius with md (8px) - for tabs
  static const BorderRadius bottomMd = BorderRadius.vertical(
    bottom: Radius.circular(md),
  );

  /// Left-only radius with xl (16px) - for right drawers
  static const BorderRadius leftXl = BorderRadius.horizontal(
    left: Radius.circular(xl),
  );

  /// Right-only radius with xl (16px) - for left drawers
  static const BorderRadius rightXl = BorderRadius.horizontal(
    right: Radius.circular(xl),
  );

  // ============================================================================
  // SPECIAL SHAPES - Chat Bubbles
  // ============================================================================

  /// Chat message bubble radius.
  /// Creates rounded corners with one corner less rounded for directional indication.
  ///
  /// - `isFromMe: true` - Bottom-right corner is less rounded (sent message)
  /// - `isFromMe: false` - Bottom-left corner is less rounded (received message)
  ///
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppRadius.messageRadius(isFromMe: true),
  ///     color: Colors.blue,
  ///   ),
  ///   child: Text('Hello!'),
  /// )
  /// ```
  static BorderRadius messageRadius({required bool isFromMe}) {
    const double large = 18.0;
    const double small = 4.0;

    if (isFromMe) {
      // Sent message - bottom-right corner is sharp
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(large),
        bottomRight: Radius.circular(small),
      );
    } else {
      // Received message - bottom-left corner is sharp
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(small),
        bottomRight: Radius.circular(large),
      );
    }
  }

  /// First message in a group (from same sender).
  /// Top corners are fully rounded, bottom corner on sender side is sharp.
  static BorderRadius messageFirstInGroup({required bool isFromMe}) {
    const double large = 18.0;
    const double medium = 8.0;

    if (isFromMe) {
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(large),
        bottomRight: Radius.circular(medium),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(medium),
        bottomRight: Radius.circular(large),
      );
    }
  }

  /// Middle message in a group (from same sender).
  /// Both corners on sender side are less rounded.
  static BorderRadius messageMiddleInGroup({required bool isFromMe}) {
    const double large = 18.0;
    const double medium = 8.0;

    if (isFromMe) {
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(medium),
        bottomLeft: Radius.circular(large),
        bottomRight: Radius.circular(medium),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(medium),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(medium),
        bottomRight: Radius.circular(large),
      );
    }
  }

  /// Last message in a group (from same sender).
  /// Top corner on sender side is less rounded, bottom is sharp.
  static BorderRadius messageLastInGroup({required bool isFromMe}) {
    const double large = 18.0;
    const double medium = 8.0;
    const double small = 4.0;

    if (isFromMe) {
      return const BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(medium),
        bottomLeft: Radius.circular(large),
        bottomRight: Radius.circular(small),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(medium),
        topRight: Radius.circular(large),
        bottomLeft: Radius.circular(small),
        bottomRight: Radius.circular(large),
      );
    }
  }

  // ============================================================================
  // ROUNDEDRECTANGLEBORDER OBJECTS - For shape properties
  // ============================================================================

  /// Card shape with default (Clean theme) radius
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: cardRadius,
  );

  /// Button shape with default (Clean theme) radius
  static const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: buttonRadius,
  );

  /// Small button shape with default radius
  static const RoundedRectangleBorder buttonSmallShape = RoundedRectangleBorder(
    borderRadius: buttonSmallRadius,
  );

  /// Dialog shape with default (Clean theme) radius
  static const RoundedRectangleBorder dialogShape = RoundedRectangleBorder(
    borderRadius: dialogRadius,
  );

  /// Bottom sheet shape with top-only radius
  static const RoundedRectangleBorder bottomSheetShape = RoundedRectangleBorder(
    borderRadius: bottomSheetRadius,
  );

  /// Chip shape with pill radius
  static const RoundedRectangleBorder chipShape = RoundedRectangleBorder(
    borderRadius: chipRadius,
  );

  /// Input shape with default (Clean theme) radius
  static const RoundedRectangleBorder inputShape = RoundedRectangleBorder(
    borderRadius: inputRadius,
  );

  /// Tooltip shape with default radius
  static const RoundedRectangleBorder tooltipShape = RoundedRectangleBorder(
    borderRadius: tooltipRadius,
  );

  /// Snackbar shape with default (Clean theme) radius
  static const RoundedRectangleBorder snackbarShape = RoundedRectangleBorder(
    borderRadius: snackbarRadius,
  );

  /// Popup menu shape with default (Clean theme) radius
  static const RoundedRectangleBorder popupMenuShape = RoundedRectangleBorder(
    borderRadius: popupMenuRadius,
  );

  // ============================================================================
  // THEME-SPECIFIC ROUNDEDRECTANGLEBORDER OBJECTS
  // ============================================================================

  /// Clean theme card shape (12px)
  static const RoundedRectangleBorder cleanCardShape = RoundedRectangleBorder(
    borderRadius: cleanCardRadius,
  );

  /// Playful theme card shape (16px)
  static const RoundedRectangleBorder playfulCardShape = RoundedRectangleBorder(
    borderRadius: playfulCardRadius,
  );

  /// Clean theme button shape (8px)
  static const RoundedRectangleBorder cleanButtonShape = RoundedRectangleBorder(
    borderRadius: cleanButtonRadius,
  );

  /// Playful theme button shape (12px)
  static const RoundedRectangleBorder playfulButtonShape = RoundedRectangleBorder(
    borderRadius: playfulButtonRadius,
  );

  /// Clean theme dialog shape (16px)
  static const RoundedRectangleBorder cleanDialogShape = RoundedRectangleBorder(
    borderRadius: cleanDialogRadius,
  );

  /// Playful theme dialog shape (20px)
  static const RoundedRectangleBorder playfulDialogShape = RoundedRectangleBorder(
    borderRadius: playfulDialogRadius,
  );

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Creates a BorderRadius from a double value.
  /// Convenience method for inline usage.
  ///
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: AppRadius.circular(16),
  ///   ),
  /// )
  /// ```
  static BorderRadius circular(double radius) {
    return BorderRadius.circular(radius);
  }

  /// Returns the appropriate card shape based on theme.
  static RoundedRectangleBorder cardShapeFor({required bool isPlayful}) {
    return RoundedRectangleBorder(
      borderRadius: card(isPlayful: isPlayful),
    );
  }

  /// Returns the appropriate button shape based on theme.
  static RoundedRectangleBorder buttonShapeFor({required bool isPlayful}) {
    return RoundedRectangleBorder(
      borderRadius: button(isPlayful: isPlayful),
    );
  }

  /// Returns the appropriate dialog shape based on theme.
  static RoundedRectangleBorder dialogShapeFor({required bool isPlayful}) {
    return RoundedRectangleBorder(
      borderRadius: dialog(isPlayful: isPlayful),
    );
  }

  /// Returns the appropriate input shape based on theme.
  static RoundedRectangleBorder inputShapeFor({required bool isPlayful}) {
    return RoundedRectangleBorder(
      borderRadius: input(isPlayful: isPlayful),
    );
  }

  // ============================================================================
  // DEPRECATED ALIASES - For backward compatibility with spacing.dart
  // ============================================================================

  /// @deprecated Use [xs] instead
  @Deprecated('Use AppRadius.xs instead')
  static const double xxs = 2.0;

  /// @deprecated Use [cardRadius] instead
  @Deprecated('Use AppRadius.cardRadius instead')
  static const BorderRadius cardBorderRadius = cardRadius;

  /// @deprecated Use [buttonRadius] instead
  @Deprecated('Use AppRadius.buttonRadius instead')
  static const BorderRadius buttonBorderRadius = buttonRadius;

  /// @deprecated Use [dialogRadius] instead
  @Deprecated('Use AppRadius.dialogRadius instead')
  static const BorderRadius dialogBorderRadius = dialogRadius;

  /// @deprecated Use [bottomSheetRadius] instead
  @Deprecated('Use AppRadius.bottomSheetRadius instead')
  static const BorderRadius bottomSheetBorderRadius = bottomSheetRadius;

  /// @deprecated Use [inputRadius] instead
  @Deprecated('Use AppRadius.inputRadius instead')
  static const BorderRadius inputBorderRadius = inputRadius;

  /// @deprecated Use [xsRadius] instead
  @Deprecated('Use AppRadius.xsRadius instead')
  static const BorderRadius xxsBorderRadius = BorderRadius.all(Radius.circular(2.0));

  /// @deprecated Use [xsRadius] instead
  @Deprecated('Use AppRadius.xsRadius instead')
  static const BorderRadius xsBorderRadius = xsRadius;

  /// @deprecated Use [mdRadius] instead
  @Deprecated('Use AppRadius.mdRadius instead')
  static const BorderRadius smBorderRadius = mdRadius;

  /// @deprecated Use [xsRadius] instead
  @Deprecated('Use AppRadius.xsRadius instead')
  static const BorderRadius smallBorderRadius = xsRadius;

  /// @deprecated Use [lgRadius] instead
  @Deprecated('Use AppRadius.lgRadius instead')
  static const BorderRadius mediumBorderRadius = lgRadius;

  /// @deprecated Use [xlRadius] instead
  @Deprecated('Use AppRadius.xlRadius instead')
  static const BorderRadius largeBorderRadius = xlRadius;

  /// @deprecated Use [xxlRadius] instead
  @Deprecated('Use AppRadius.xxlRadius instead')
  static const BorderRadius xlBorderRadius = xxlRadius;

  /// @deprecated Use [fullRadius] instead
  @Deprecated('Use AppRadius.fullRadius instead')
  static const BorderRadius fullBorderRadius = fullRadius;

  /// @deprecated Use [xsCircular] instead
  @Deprecated('Use AppRadius.xsCircular instead')
  static const Radius circularXxs = Radius.circular(2.0);

  /// @deprecated Use [xsCircular] instead
  @Deprecated('Use AppRadius.xsCircular instead')
  static const Radius circularXs = xsCircular;

  /// @deprecated Use [mdCircular] instead
  @Deprecated('Use AppRadius.mdCircular instead')
  static const Radius circularSm = mdCircular;

  /// @deprecated Use [lgCircular] instead
  @Deprecated('Use AppRadius.lgCircular instead')
  static const Radius circularMd = lgCircular;

  /// @deprecated Use [xlCircular] instead
  @Deprecated('Use AppRadius.xlCircular instead')
  static const Radius circularLg = xlCircular;

  /// @deprecated Use [xxlCircular] instead
  @Deprecated('Use AppRadius.xxlCircular instead')
  static const Radius circularXl = xxlCircular;

  /// @deprecated Use [fullCircular] instead
  @Deprecated('Use AppRadius.fullCircular instead')
  static const Radius circularXxl = fullCircular;

  /// @deprecated Use [card] instead
  @Deprecated('Use AppRadius.card() instead')
  static BorderRadius getCardRadius({required bool isPlayful}) {
    return card(isPlayful: isPlayful);
  }

  /// @deprecated Use [button] instead
  @Deprecated('Use AppRadius.button() instead')
  static BorderRadius getButtonRadius({required bool isPlayful}) {
    return button(isPlayful: isPlayful);
  }

  /// @deprecated Use [input] instead
  @Deprecated('Use AppRadius.input() instead')
  static BorderRadius getInputRadius({required bool isPlayful}) {
    return input(isPlayful: isPlayful);
  }

  /// @deprecated Use [dialog] instead
  @Deprecated('Use AppRadius.dialog() instead')
  static BorderRadius getDialogRadius({required bool isPlayful}) {
    return dialog(isPlayful: isPlayful);
  }

  /// @deprecated Use [chip] instead
  @Deprecated('Use AppRadius.chip() instead')
  static BorderRadius getChipRadius({required bool isPlayful}) {
    return chip(isPlayful: isPlayful);
  }

  /// @deprecated Use [badge] instead
  @Deprecated('Use AppRadius.badge() instead')
  static BorderRadius getBadgeRadius({required bool isPlayful}) {
    return badge(isPlayful: isPlayful);
  }
}
