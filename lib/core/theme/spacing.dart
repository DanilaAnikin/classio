import 'package:flutter/material.dart';

// =============================================================================
// CLASSIO SPACING SYSTEM
// =============================================================================
//
// Enterprise-grade spacing system based on a 4-point grid.
// Provides consistent spacing, layout constraints, and responsive helpers
// for a premium, polished UI across all device sizes.
//
// Design Philosophy:
// - 4px base unit ensures pixel-perfect alignment
// - Semantic tokens for meaningful, maintainable code
// - Responsive helpers for adaptive layouts
// - Pre-computed EdgeInsets for performance
// - Theme-aware variants (Clean vs Playful)
//
// =============================================================================

/// Primary spacing constants based on a 4-point grid system.
///
/// This system provides:
/// - A complete numeric scale from 0-96px
/// - Semantic spacing tokens for common patterns
/// - Component-specific spacing values
/// - Layout constraints for responsive design
/// - Pre-computed EdgeInsets for performance
/// - Helper methods for responsive spacing
///
/// Usage:
/// ```dart
/// // Direct values
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
/// SizedBox(height: AppSpacing.sectionGap)
///
/// // Pre-computed insets
/// Container(padding: AppSpacing.cardInsets)
///
/// // Gap helpers
/// Column(children: [widget1, AppSpacing.gapMd, widget2])
///
/// // Responsive helpers
/// Padding(
///   padding: EdgeInsets.symmetric(
///     horizontal: AppSpacing.responsive(
///       context,
///       mobile: AppSpacing.pageHorizontalMobile,
///       tablet: AppSpacing.pageHorizontalTablet,
///       desktop: AppSpacing.pageHorizontalDesktop,
///     ),
///   ),
/// )
/// ```
abstract final class AppSpacing {
  // ===========================================================================
  // BASE UNIT
  // ===========================================================================

  /// Base spacing unit (4 pixels).
  /// All spacing values are derived from this unit for consistent rhythm.
  static const double unit = 4.0;

  // ===========================================================================
  // NUMERIC SCALE
  // ===========================================================================
  // Complete spacing scale from 0 to 96 pixels.
  // Use these for fine-grained control when semantic tokens don't fit.

  /// 0px - No spacing
  static const double space0 = 0.0;

  /// 2px - Hairline spacing (half unit)
  static const double space2 = 2.0;

  /// 4px - Extra extra small (1 unit)
  static const double space4 = unit; // 4

  /// 8px - Extra small (2 units)
  static const double space8 = unit * 2; // 8

  /// 12px - Small (3 units)
  static const double space12 = unit * 3; // 12

  /// 16px - Medium/Default (4 units)
  static const double space16 = unit * 4; // 16

  /// 20px - Medium-large (5 units)
  static const double space20 = unit * 5; // 20

  /// 24px - Large (6 units)
  static const double space24 = unit * 6; // 24

  /// 32px - Extra large (8 units)
  static const double space32 = unit * 8; // 32

  /// 40px - 2x large (10 units)
  static const double space40 = unit * 10; // 40

  /// 48px - 3x large (12 units)
  static const double space48 = unit * 12; // 48

  /// 64px - 4x large (16 units)
  static const double space64 = unit * 16; // 64

  /// 80px - 5x large (20 units)
  static const double space80 = unit * 20; // 80

  /// 96px - 6x large (24 units)
  static const double space96 = unit * 24; // 96

  // ===========================================================================
  // NAMED SIZE ALIASES (T-Shirt Sizes)
  // ===========================================================================
  // For developers who prefer semantic naming over numeric values.

  /// Extra extra small spacing (4 pixels)
  static const double xxs = space4;

  /// Extra small spacing (8 pixels)
  static const double xs = space8;

  /// Small spacing (12 pixels)
  static const double sm = space12;

  /// Medium spacing (16 pixels) - default padding
  static const double md = space16;

  /// Large spacing (20 pixels)
  static const double lg = space20;

  /// Extra large spacing (24 pixels)
  static const double xl = space24;

  /// Extra extra large spacing (32 pixels)
  static const double xxl = space32;

  /// Extra extra extra large spacing (40 pixels)
  static const double xxxl = space40;

  /// 4x extra large spacing (48 pixels)
  static const double xxxxl = space48;

  // ===========================================================================
  // SEMANTIC SPACING - Page Layout
  // ===========================================================================

  /// Horizontal page padding for mobile screens (24px)
  static const double pageHorizontalMobile = space24;

  /// Horizontal page padding for tablet screens (32px)
  static const double pageHorizontalTablet = space32;

  /// Horizontal page padding for desktop screens (48px)
  static const double pageHorizontalDesktop = space48;

  /// Gap between major sections on a page (32px)
  /// Use between distinct content areas like header, body, footer
  static const double sectionGap = space32;

  /// Gap between cards in a list or grid (16px)
  /// Use for spacing between cards, tiles, or similar components
  static const double cardGap = space16;

  /// Gap between content blocks within a section (24px)
  /// Use for spacing between paragraphs, form groups, etc.
  static const double contentGap = space24;

  /// Standard page margin (16px) - legacy support
  static const double pageMargin = space16;

  /// Large page margin for tablet/desktop (24px) - legacy support
  static const double pageMarginLg = space24;

  // ===========================================================================
  // SEMANTIC SPACING - Components
  // ===========================================================================

  /// Internal padding for cards (20px)
  /// Generous padding for comfortable content presentation
  static const double cardPadding = space20;

  /// Comfortable card padding (legacy alias)
  static const double cardPaddingLg = space20;

  /// Internal padding for dialogs (24px)
  static const double dialogPadding = space24;

  /// Horizontal padding for input fields (16px)
  static const double inputPaddingHorizontal = space16;

  /// Vertical padding for input fields (12px)
  static const double inputPaddingVertical = space12;

  /// Input field content padding (legacy - uses horizontal)
  static const double inputPadding = space16;

  /// Horizontal padding for list items (16px)
  static const double listItemPaddingHorizontal = space16;

  /// Vertical padding for list items (12px)
  static const double listItemPaddingVertical = space12;

  /// Chip internal padding (12 pixels)
  static const double chipPadding = sm;

  /// Toolbar/AppBar padding (16 pixels)
  static const double toolbarPadding = md;

  /// Bottom sheet handle margin (12 pixels)
  static const double bottomSheetHandle = sm;

  // ===========================================================================
  // BUTTON PADDING BY SIZE
  // ===========================================================================

  /// Small button horizontal padding (12px)
  static const double buttonPaddingSmHorizontal = space12;

  /// Small button vertical padding (8px)
  static const double buttonPaddingSmVertical = space8;

  /// Medium button horizontal padding (16px)
  static const double buttonPaddingMdHorizontal = space16;

  /// Medium button vertical padding (12px)
  static const double buttonPaddingMdVertical = space12;

  /// Large button horizontal padding (24px)
  static const double buttonPaddingLgHorizontal = space24;

  /// Large button vertical padding (16px)
  static const double buttonPaddingLgVertical = space16;

  /// Standard button internal padding (legacy - 16px)
  static const double buttonPadding = space16;

  // ===========================================================================
  // GAP SPACING (Between Elements)
  // ===========================================================================

  /// Gap between icon and text (8 pixels)
  static const double iconTextGap = space8;

  /// Inline spacing between elements (4 pixels)
  static const double inlineGap = space4;

  /// Stack spacing for vertically stacked elements (8 pixels)
  static const double stackGap = space8;

  /// Gap between subsections (16 pixels)
  static const double subsectionGap = space16;

  /// Spacing between list items (12 pixels)
  static const double listItemSpacing = space12;

  /// Spacing between grid items (16 pixels)
  static const double gridGap = space16;

  // ===========================================================================
  // LAYOUT CONSTRAINTS
  // ===========================================================================

  /// Maximum content width for centered layouts (1200px)
  /// Use for main content containers on wide screens
  static const double maxContentWidth = 1200.0;

  /// Maximum width for text-heavy content (680px)
  /// Optimal line length for readability (~65-75 characters)
  static const double maxReadingWidth = 680.0;

  /// Maximum card width (400px)
  /// Prevents cards from becoming too wide on large screens
  static const double maxCardWidth = 400.0;

  /// Minimum touch target size - iOS standard (44px)
  static const double minTouchTargetIOS = 44.0;

  /// Minimum touch target size - Material standard (48px)
  static const double minTouchTarget = 48.0;

  /// Standard navigation bar height (64px)
  static const double navBarHeight = 64.0;

  /// Standard app bar height (56px)
  static const double appBarHeight = 56.0;

  /// Standard input height (48 pixels)
  static const double inputHeight = 48.0;

  /// Compact input height (40 pixels)
  static const double inputHeightCompact = 40.0;

  /// Standard button height (48 pixels)
  static const double buttonHeight = 48.0;

  /// Compact button height (40 pixels)
  static const double buttonHeightCompact = 40.0;

  /// Small button height (36 pixels)
  static const double buttonHeightSmall = 36.0;

  // ===========================================================================
  // RESPONSIVE HELPER METHODS
  // ===========================================================================

  /// Returns responsive spacing value based on screen width.
  ///
  /// Breakpoints:
  /// - Mobile: < 600px
  /// - Tablet: 600-1024px
  /// - Desktop: > 1024px
  ///
  /// Example:
  /// ```dart
  /// final horizontalPadding = AppSpacing.responsive(
  ///   context,
  ///   mobile: 24,
  ///   tablet: 32,
  ///   desktop: 48,
  /// );
  /// ```
  static double responsive(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 1024) {
      return desktop ?? tablet ?? mobile;
    } else if (width >= 600) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }

  /// Returns responsive page horizontal padding based on screen width.
  ///
  /// - Mobile: 24px
  /// - Tablet: 32px
  /// - Desktop: 48px
  static double pageHorizontal(BuildContext context) {
    return responsive(
      context,
      mobile: pageHorizontalMobile,
      tablet: pageHorizontalTablet,
      desktop: pageHorizontalDesktop,
    );
  }

  /// Returns a SizedBox with the specified height for vertical spacing.
  ///
  /// Example:
  /// ```dart
  /// Column(children: [
  ///   Text('Title'),
  ///   AppSpacing.gap(16),
  ///   Text('Body'),
  /// ])
  /// ```
  static SizedBox gap(double size) => SizedBox(height: size);

  /// Returns a SizedBox with the specified width for horizontal spacing.
  static SizedBox gapH(double size) => SizedBox(width: size);

  /// Creates EdgeInsets with horizontal-only padding.
  static EdgeInsets horizontal(double size) =>
      EdgeInsets.symmetric(horizontal: size);

  /// Creates EdgeInsets with vertical-only padding.
  static EdgeInsets vertical(double size) =>
      EdgeInsets.symmetric(vertical: size);

  /// Creates EdgeInsets with all sides equal.
  static EdgeInsets all(double size) => EdgeInsets.all(size);

  /// Creates EdgeInsets with symmetric horizontal and vertical values.
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  // ===========================================================================
  // PRE-COMPUTED SIZEDBOX GAPS
  // ===========================================================================
  // Use these in Column/Row children for efficient spacing.

  /// No vertical gap
  static const SizedBox gap0 = SizedBox.shrink();

  /// 2px vertical gap
  static const SizedBox gap2 = SizedBox(height: space2);

  /// 4px vertical gap
  static const SizedBox gap4 = SizedBox(height: space4);

  /// 8px vertical gap
  static const SizedBox gap8 = SizedBox(height: space8);

  /// 12px vertical gap
  static const SizedBox gap12 = SizedBox(height: space12);

  /// 16px vertical gap
  static const SizedBox gap16 = SizedBox(height: space16);

  /// 20px vertical gap
  static const SizedBox gap20 = SizedBox(height: space20);

  /// 24px vertical gap
  static const SizedBox gap24 = SizedBox(height: space24);

  /// 32px vertical gap
  static const SizedBox gap32 = SizedBox(height: space32);

  /// 40px vertical gap
  static const SizedBox gap40 = SizedBox(height: space40);

  /// 48px vertical gap
  static const SizedBox gap48 = SizedBox(height: space48);

  /// 64px vertical gap
  static const SizedBox gap64 = SizedBox(height: space64);

  /// 80px vertical gap
  static const SizedBox gap80 = SizedBox(height: space80);

  /// 96px vertical gap
  static const SizedBox gap96 = SizedBox(height: space96);

  // Horizontal gap variants
  /// 4px horizontal gap
  static const SizedBox gapH4 = SizedBox(width: space4);

  /// 8px horizontal gap
  static const SizedBox gapH8 = SizedBox(width: space8);

  /// 12px horizontal gap
  static const SizedBox gapH12 = SizedBox(width: space12);

  /// 16px horizontal gap
  static const SizedBox gapH16 = SizedBox(width: space16);

  /// 20px horizontal gap
  static const SizedBox gapH20 = SizedBox(width: space20);

  /// 24px horizontal gap
  static const SizedBox gapH24 = SizedBox(width: space24);

  /// 32px horizontal gap
  static const SizedBox gapH32 = SizedBox(width: space32);

  // Named aliases for common gaps
  /// Extra small vertical gap (8px)
  static const SizedBox gapXs = gap8;

  /// Small vertical gap (12px)
  static const SizedBox gapSm = gap12;

  /// Medium vertical gap (16px)
  static const SizedBox gapMd = gap16;

  /// Large vertical gap (20px)
  static const SizedBox gapLg = gap20;

  /// Extra large vertical gap (24px)
  static const SizedBox gapXl = gap24;

  /// 2x extra large vertical gap (32px)
  static const SizedBox gapXxl = gap32;

  // ===========================================================================
  // PRE-COMPUTED EDGEINSETS - Standard
  // ===========================================================================

  /// No padding
  static const EdgeInsets insetsNone = EdgeInsets.zero;

  /// 4px all sides
  static const EdgeInsets insets4 = EdgeInsets.all(space4);

  /// 8px all sides
  static const EdgeInsets insets8 = EdgeInsets.all(space8);

  /// 12px all sides
  static const EdgeInsets insets12 = EdgeInsets.all(space12);

  /// 16px all sides
  static const EdgeInsets insets16 = EdgeInsets.all(space16);

  /// 20px all sides
  static const EdgeInsets insets20 = EdgeInsets.all(space20);

  /// 24px all sides
  static const EdgeInsets insets24 = EdgeInsets.all(space24);

  /// 32px all sides
  static const EdgeInsets insets32 = EdgeInsets.all(space32);

  // ===========================================================================
  // PRE-COMPUTED EDGEINSETS - Horizontal
  // ===========================================================================

  /// 8px horizontal
  static const EdgeInsets insetsH8 = EdgeInsets.symmetric(horizontal: space8);

  /// 12px horizontal
  static const EdgeInsets insetsH12 =
      EdgeInsets.symmetric(horizontal: space12);

  /// 16px horizontal
  static const EdgeInsets insetsH16 =
      EdgeInsets.symmetric(horizontal: space16);

  /// 20px horizontal
  static const EdgeInsets insetsH20 =
      EdgeInsets.symmetric(horizontal: space20);

  /// 24px horizontal
  static const EdgeInsets insetsH24 =
      EdgeInsets.symmetric(horizontal: space24);

  /// 32px horizontal
  static const EdgeInsets insetsH32 =
      EdgeInsets.symmetric(horizontal: space32);

  // ===========================================================================
  // PRE-COMPUTED EDGEINSETS - Vertical
  // ===========================================================================

  /// 8px vertical
  static const EdgeInsets insetsV8 = EdgeInsets.symmetric(vertical: space8);

  /// 12px vertical
  static const EdgeInsets insetsV12 = EdgeInsets.symmetric(vertical: space12);

  /// 16px vertical
  static const EdgeInsets insetsV16 = EdgeInsets.symmetric(vertical: space16);

  /// 20px vertical
  static const EdgeInsets insetsV20 = EdgeInsets.symmetric(vertical: space20);

  /// 24px vertical
  static const EdgeInsets insetsV24 = EdgeInsets.symmetric(vertical: space24);

  // ===========================================================================
  // PRE-COMPUTED EDGEINSETS - Semantic/Component
  // ===========================================================================

  /// Card padding - generous internal spacing (20px all sides)
  static const EdgeInsets cardInsets = EdgeInsets.all(space20);

  /// Legacy card insets (16px) - for backward compatibility
  static const EdgeInsets cardInsetsCompact = EdgeInsets.all(space16);

  /// Comfortable card padding (legacy alias)
  static const EdgeInsets cardInsetsLg = EdgeInsets.all(space20);

  /// Dialog content padding (24px all sides)
  static const EdgeInsets dialogInsets = EdgeInsets.all(space24);

  /// Page padding for mobile (24px horizontal, 16px vertical)
  static const EdgeInsets pagePaddingMobile = EdgeInsets.symmetric(
    horizontal: pageHorizontalMobile,
    vertical: space16,
  );

  /// Page padding for tablet (32px horizontal, 24px vertical)
  static const EdgeInsets pagePaddingTablet = EdgeInsets.symmetric(
    horizontal: pageHorizontalTablet,
    vertical: space24,
  );

  /// Page padding for desktop (48px horizontal, 32px vertical)
  static const EdgeInsets pagePaddingDesktop = EdgeInsets.symmetric(
    horizontal: pageHorizontalDesktop,
    vertical: space32,
  );

  /// Standard page insets (16px all sides) - legacy
  static const EdgeInsets pageInsets = EdgeInsets.all(space16);

  /// Large page insets (24px all sides) - legacy
  static const EdgeInsets pageInsetsLg = EdgeInsets.all(space24);

  /// List item padding (16px horizontal, 12px vertical)
  static const EdgeInsets listItemInsets = EdgeInsets.symmetric(
    horizontal: listItemPaddingHorizontal,
    vertical: listItemPaddingVertical,
  );

  /// Compact list item padding (12px horizontal, 8px vertical)
  static const EdgeInsets listItemInsetsCompact = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: space8,
  );

  /// Input field content padding (16px horizontal, 12px vertical)
  static const EdgeInsets inputInsets = EdgeInsets.symmetric(
    horizontal: inputPaddingHorizontal,
    vertical: inputPaddingVertical,
  );

  /// Input field legacy insets (16px horizontal, 14px vertical)
  static const EdgeInsets inputInsetsLegacy = EdgeInsets.symmetric(
    horizontal: space16,
    vertical: 14,
  );

  /// Bottom sheet content padding (16px horizontal, 12px top, 24px bottom)
  static const EdgeInsets bottomSheetInsets = EdgeInsets.fromLTRB(
    space16,
    space12,
    space16,
    space24,
  );

  // ===========================================================================
  // PRE-COMPUTED EDGEINSETS - Buttons
  // ===========================================================================

  /// Small button padding (12px horizontal, 8px vertical)
  static const EdgeInsets buttonInsetsSm = EdgeInsets.symmetric(
    horizontal: buttonPaddingSmHorizontal,
    vertical: buttonPaddingSmVertical,
  );

  /// Medium button padding (16px horizontal, 12px vertical)
  static const EdgeInsets buttonInsetsMd = EdgeInsets.symmetric(
    horizontal: buttonPaddingMdHorizontal,
    vertical: buttonPaddingMdVertical,
  );

  /// Large button padding (24px horizontal, 16px vertical)
  static const EdgeInsets buttonInsetsLg = EdgeInsets.symmetric(
    horizontal: buttonPaddingLgHorizontal,
    vertical: buttonPaddingLgVertical,
  );

  /// Standard button padding (legacy - 20px horizontal, 12px vertical)
  static const EdgeInsets buttonInsets = EdgeInsets.symmetric(
    horizontal: space20,
    vertical: space12,
  );

  // ===========================================================================
  // PRE-COMPUTED EDGEINSETS - Other Components
  // ===========================================================================

  /// Chip padding (12px horizontal, 6px vertical)
  static const EdgeInsets chipInsets = EdgeInsets.symmetric(
    horizontal: space12,
    vertical: 6,
  );

  /// Badge padding (8px horizontal, 4px vertical)
  static const EdgeInsets badgeInsets = EdgeInsets.symmetric(
    horizontal: space8,
    vertical: space4,
  );

  /// Horizontal-only padding (left/right 16) - legacy
  static const EdgeInsets horizontalInsets =
      EdgeInsets.symmetric(horizontal: space16);

  /// Large horizontal padding (left/right 24) - legacy
  static const EdgeInsets horizontalInsetsLg =
      EdgeInsets.symmetric(horizontal: space24);

  /// Vertical-only padding (top/bottom 16) - legacy
  static const EdgeInsets verticalInsets =
      EdgeInsets.symmetric(vertical: space16);

  /// Small insets for compact areas (8px all sides) - legacy
  static const EdgeInsets smallInsets = EdgeInsets.all(space8);

  /// Extra small insets (4px all sides) - legacy
  static const EdgeInsets xsInsets = EdgeInsets.all(space4);

  // ===========================================================================
  // THEME-AWARE SPACING
  // ===========================================================================

  /// Returns page padding appropriate for current screen size and theme.
  ///
  /// - Playful theme has slightly more generous padding for a friendlier feel
  /// - Clean theme uses standard values for a professional look
  static EdgeInsets getPagePadding(
    BuildContext context, {
    bool isPlayful = false,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final playfulBonus = isPlayful ? 4.0 : 0.0;

    if (width >= 1024) {
      return EdgeInsets.symmetric(
        horizontal: pageHorizontalDesktop + playfulBonus,
        vertical: space32 + playfulBonus,
      );
    } else if (width >= 600) {
      return EdgeInsets.symmetric(
        horizontal: pageHorizontalTablet + playfulBonus,
        vertical: space24 + playfulBonus,
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: pageHorizontalMobile + playfulBonus,
        vertical: space16 + playfulBonus,
      );
    }
  }

  /// Returns card padding based on theme.
  /// - Clean: 20px (standard generous)
  /// - Playful: 24px (extra generous for friendlier feel)
  static EdgeInsets getCardPadding({bool isPlayful = false}) {
    return EdgeInsets.all(isPlayful ? space24 : space20);
  }

  /// Returns section gap based on theme.
  /// - Clean: 32px
  /// - Playful: 40px (more breathing room)
  static double getSectionGap({bool isPlayful = false}) {
    return isPlayful ? space40 : space32;
  }
}

// NOTE: Border radius constants have been moved to app_radius.dart
// Import 'package:classio/core/theme/app_radius.dart' for AppRadius
// or use the barrel file: 'package:classio/core/theme/theme.dart'

// =============================================================================
// ELEVATION SYSTEM
// =============================================================================

/// Standardized elevation (shadow) constants for consistent depth perception.
///
/// These values align with Material Design elevation guidelines.
abstract final class AppElevation {
  /// No elevation (0)
  static const double none = 0.0;

  /// Subtle elevation (1) - for cards at rest
  static const double xs = 1.0;

  /// Small elevation (2) - for raised buttons, cards
  static const double sm = 2.0;

  /// Medium elevation (4) - for floating action buttons, dialogs
  static const double md = 4.0;

  /// Large elevation (8) - for bottom sheets, navigation drawers
  static const double lg = 8.0;

  /// Extra large elevation (12) - for modal bottom sheets
  static const double xl = 12.0;
}

// =============================================================================
// ICON SIZE SYSTEM
// =============================================================================

/// Standardized icon sizes for consistent iconography.
abstract final class AppIconSize {
  /// Extra small icon (16 pixels)
  static const double xs = 16.0;

  /// Small icon (20 pixels)
  static const double sm = 20.0;

  /// Medium/default icon (24 pixels)
  static const double md = 24.0;

  /// Large icon (28 pixels)
  static const double lg = 28.0;

  /// Extra large icon (32 pixels)
  static const double xl = 32.0;

  /// Extra extra large icon (48 pixels)
  static const double xxl = 48.0;

  /// Hero/display icon (64 pixels)
  static const double hero = 64.0;

  // Semantic sizes
  /// Navigation bar icon size (24 pixels)
  static const double navigation = md; // 24

  /// App bar action icon size (24 pixels)
  static const double appBar = md; // 24

  /// List tile leading icon size (24 pixels)
  static const double listTile = md; // 24

  /// Button icon size (20 pixels)
  static const double button = sm; // 20

  /// Badge/indicator icon size (16 pixels)
  static const double badge = xs; // 16

  /// Avatar icon size (40 pixels)
  static const double avatar = 40.0;

  /// Large avatar size (56 pixels)
  static const double avatarLg = 56.0;
}

// =============================================================================
// ANIMATION DURATION SYSTEM
// =============================================================================

/// Standardized animation durations for consistent motion.
///
/// Based on Material Design motion guidelines. Shorter durations
/// feel more responsive; longer durations feel more deliberate.
abstract final class AppDuration {
  /// Instant - no animation (0ms)
  static const Duration instant = Duration.zero;

  /// Extra fast (100ms) - micro-interactions, hover states
  static const Duration fastest = Duration(milliseconds: 100);

  /// Fast (150ms) - button presses, small state changes
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal (200ms) - standard transitions
  static const Duration normal = Duration(milliseconds: 200);

  /// Medium (300ms) - page transitions, larger state changes
  static const Duration medium = Duration(milliseconds: 300);

  /// Slow (400ms) - complex animations, emphasis
  static const Duration slow = Duration(milliseconds: 400);

  /// Slower (500ms) - deliberate animations
  static const Duration slower = Duration(milliseconds: 500);

  /// Slowest (600ms) - dramatic entrance/exit
  static const Duration slowest = Duration(milliseconds: 600);

  // Semantic durations
  /// Button press feedback
  static const Duration buttonPress = fast;

  /// Hover state change
  static const Duration hover = fastest;

  /// Card expansion/collapse
  static const Duration cardExpand = medium;

  /// Page transition
  static const Duration pageTransition = medium;

  /// Modal entrance
  static const Duration modalEnter = medium;

  /// Modal exit
  static const Duration modalExit = normal;

  /// Fade in/out
  static const Duration fade = normal;

  /// Tooltip show/hide
  static const Duration tooltip = fast;

  /// Snackbar entrance
  static const Duration snackbar = medium;
}

// =============================================================================
// ANIMATION CURVES SYSTEM
// =============================================================================

/// Standardized animation curves for consistent motion feel.
abstract final class AppCurves {
  /// Standard easing - use for most animations
  static const Curve standard = Curves.easeInOut;

  /// Decelerate - use for entering elements
  static const Curve decelerate = Curves.easeOut;

  /// Accelerate - use for exiting elements
  static const Curve accelerate = Curves.easeIn;

  /// Emphasized - use for important state changes
  static const Curve emphasized = Curves.easeInOutCubic;

  /// Spring - use for playful, bouncy animations
  static const Curve spring = Curves.elasticOut;

  /// Linear - use sparingly, mainly for continuous animations
  static const Curve linear = Curves.linear;

  // Semantic curves
  /// Modal entrance curve
  static const Curve modalEnter = decelerate;

  /// Modal exit curve
  static const Curve modalExit = accelerate;

  /// Page transition curve
  static const Curve pageTransition = emphasized;

  /// Card expansion curve
  static const Curve cardExpand = standard;

  /// Button press curve
  static const Curve buttonPress = decelerate;
}
