import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Premium enterprise-grade shadow system for consistent elevation and depth.
///
/// This system provides subtle, diffused shadows that create a polished SaaS look.
/// All shadows use multi-layer composition for natural depth perception:
/// - Layer 1: Close shadow (sharp, low blur) for definition
/// - Layer 2: Far shadow (soft, high blur) for ambient occlusion
///
/// Shadow Scale:
/// - xs: Very subtle hover states, chips
/// - sm: Cards at rest (default)
/// - md: Elevated cards, dropdowns
/// - lg: Modals, dialogs
/// - xl: Floating elements, popovers
///
/// Usage:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     boxShadow: AppShadows.card(context),
///   ),
/// )
/// ```
abstract final class AppShadows {
  // ============ No Shadow ============

  /// No shadow - flat appearance
  static const List<BoxShadow> none = [];

  // ============================================================================
  // CLEAN THEME SHADOWS
  // ============================================================================
  // Professional, subtle shadows using pure black with very low opacity.
  // Creates a refined, enterprise SaaS aesthetic.

  /// Extra small shadow - very subtle for hover states and chips
  /// Total perceived opacity: ~5%
  static const List<BoxShadow> cleanXs = [
    BoxShadow(
      color: Color(0x07000000), // 3% opacity
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2% opacity
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Small shadow - cards at rest, default card shadow
  /// Multi-layer for natural depth: close definition + ambient softness
  static const List<BoxShadow> cleanSm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity - close shadow
      blurRadius: 3,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity - far shadow
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
  ];

  /// Medium shadow - elevated cards, dropdowns, menus
  /// Enhanced lift while maintaining subtlety
  static const List<BoxShadow> cleanMd = [
    BoxShadow(
      color: Color(0x08000000), // 3% opacity - close shadow
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity - mid shadow
      blurRadius: 12,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x08000000), // 3% opacity - far ambient
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 16),
    ),
  ];

  /// Large shadow - modals, dialogs
  /// Pronounced elevation for focused attention
  static const List<BoxShadow> cleanLg = [
    BoxShadow(
      color: Color(0x08000000), // 3% opacity - close definition
      blurRadius: 6,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity - mid shadow
      blurRadius: 20,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity - far ambient
      blurRadius: 40,
      spreadRadius: 0,
      offset: Offset(0, 24),
    ),
  ];

  /// Extra large shadow - popovers, floating elements
  /// Maximum elevation for elements that float above the interface
  static const List<BoxShadow> cleanXl = [
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity - close definition
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x12000000), // 7% opacity - mid shadow
      blurRadius: 28,
      spreadRadius: 0,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity - far ambient
      blurRadius: 48,
      spreadRadius: -4,
      offset: Offset(0, 32),
    ),
  ];

  // ============================================================================
  // PLAYFUL THEME SHADOWS
  // ============================================================================
  // Warmer shadows tinted with the primary violet color.
  // Creates a friendly, inviting feel while maintaining professionalism.

  /// Extra small shadow for playful theme - subtle violet tint
  static const List<BoxShadow> playfulXs = [
    BoxShadow(
      color: Color(0x087C3AED), // 3% primary violet
      blurRadius: 3,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x05000000), // 2% black for depth
      blurRadius: 5,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];

  /// Small shadow for playful cards - violet-tinted warmth
  static const List<BoxShadow> playfulSm = [
    BoxShadow(
      color: Color(0x0C7C3AED), // 5% primary - close shadow
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A7C3AED), // 4% primary - far shadow
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  /// Medium shadow for playful elevated elements
  static const List<BoxShadow> playfulMd = [
    BoxShadow(
      color: Color(0x0A7C3AED), // 4% primary - close shadow
      blurRadius: 5,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0F7C3AED), // 6% primary - mid shadow
      blurRadius: 14,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x08000000), // 3% black - far ambient
      blurRadius: 28,
      spreadRadius: 0,
      offset: Offset(0, 18),
    ),
  ];

  /// Large shadow for playful modals
  static const List<BoxShadow> playfulLg = [
    BoxShadow(
      color: Color(0x0C7C3AED), // 5% primary - close shadow
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x147C3AED), // 8% primary - mid shadow
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 14),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% black - far ambient
      blurRadius: 44,
      spreadRadius: 0,
      offset: Offset(0, 28),
    ),
  ];

  /// Extra large shadow for playful floating elements
  static const List<BoxShadow> playfulXl = [
    BoxShadow(
      color: Color(0x0F7C3AED), // 6% primary - close shadow
      blurRadius: 10,
      spreadRadius: 0,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x187C3AED), // 9% primary - mid shadow
      blurRadius: 32,
      spreadRadius: 0,
      offset: Offset(0, 18),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% black - far ambient
      blurRadius: 52,
      spreadRadius: -4,
      offset: Offset(0, 36),
    ),
  ];

  // ============================================================================
  // SEMANTIC SHADOW GETTERS
  // ============================================================================
  // Context-aware shadows that automatically adapt to the active theme.

  /// Card shadow - subtle elevation for cards at rest
  static List<BoxShadow> card({required bool isPlayful}) {
    return isPlayful ? playfulSm : cleanSm;
  }

  /// Card hover shadow - lifted appearance for hover/focus states
  static List<BoxShadow> cardHover({required bool isPlayful}) {
    return isPlayful ? playfulMd : cleanMd;
  }

  /// Card pressed shadow - reduced shadow for pressed state
  static List<BoxShadow> cardPressed({required bool isPlayful}) {
    return isPlayful ? playfulXs : cleanXs;
  }

  /// Button shadow - subtle depth for elevated buttons
  static List<BoxShadow> button({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0A7C3AED), // 4% primary
              blurRadius: 3,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x087C3AED), // 3% primary
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x08000000), // 3% opacity
              blurRadius: 2,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x07000000), // 3% opacity
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ];
  }

  /// Button hover shadow - slightly elevated for hover state
  static List<BoxShadow> buttonHover({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0D7C3AED), // 5% primary
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x0A7C3AED), // 4% primary
              blurRadius: 12,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0A000000), // 4% opacity
              blurRadius: 3,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x08000000), // 3% opacity
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 5),
            ),
          ];
  }

  /// Button pressed shadow - reduced for pressed state
  static List<BoxShadow> buttonPressed({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x087C3AED), // 3% primary
              blurRadius: 1,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x05000000), // 2% opacity
              blurRadius: 1,
              spreadRadius: 0,
              offset: Offset(0, 0),
            ),
          ];
  }

  /// Dropdown/menu shadow - elevated for selection overlays
  static List<BoxShadow> dropdown({required bool isPlayful}) {
    return isPlayful ? playfulMd : cleanMd;
  }

  /// Modal/dialog shadow - prominent elevation for focused content
  static List<BoxShadow> modal({required bool isPlayful}) {
    return isPlayful ? playfulLg : cleanLg;
  }

  /// Bottom sheet shadow - upward elevation
  static List<BoxShadow> bottomSheet({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0C7C3AED), // 5% primary
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, -4),
            ),
            BoxShadow(
              color: Color(0x147C3AED), // 8% primary
              blurRadius: 24,
              spreadRadius: 0,
              offset: Offset(0, -12),
            ),
            BoxShadow(
              color: Color(0x0A000000), // 4% black
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset(0, -20),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x08000000), // 3% opacity
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, -4),
            ),
            BoxShadow(
              color: Color(0x0F000000), // 6% opacity
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, -12),
            ),
            BoxShadow(
              color: Color(0x0A000000), // 4% opacity
              blurRadius: 40,
              spreadRadius: 0,
              offset: Offset(0, -20),
            ),
          ];
  }

  /// Toast/snackbar shadow - elevated notification styling
  static List<BoxShadow> toast({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0A7C3AED), // 4% primary
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x0F7C3AED), // 6% primary
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, 10),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x08000000), // 3% opacity
              blurRadius: 5,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x0D000000), // 5% opacity
              blurRadius: 14,
              spreadRadius: 0,
              offset: Offset(0, 10),
            ),
          ];
  }

  /// Navigation bar shadow - subtle app bar elevation
  static List<BoxShadow> navigation({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x087C3AED), // 3% primary
              blurRadius: 3,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x057C3AED), // 2% primary
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x07000000), // 3% opacity
              blurRadius: 2,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
            BoxShadow(
              color: Color(0x05000000), // 2% opacity
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
          ];
  }

  /// Floating action button shadow
  static List<BoxShadow> fab({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x147C3AED), // 8% primary
              blurRadius: 6,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Color(0x0F7C3AED), // 6% primary
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0F000000), // 6% opacity
              blurRadius: 5,
              spreadRadius: 0,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Color(0x0A000000), // 4% opacity
              blurRadius: 14,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ];
  }

  // ============================================================================
  // FOCUS RING SHADOWS
  // ============================================================================
  // Focus indicators using box-shadow instead of borders for accessibility.

  /// Input focus shadow - glowing focus ring effect
  /// Uses spread radius to create a colored ring around the element
  static List<BoxShadow> inputFocus({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x407C3AED), // 25% primary
              blurRadius: 0,
              spreadRadius: 3,
              offset: Offset.zero,
            ),
            BoxShadow(
              color: Color(0x207C3AED), // 12% primary - outer glow
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x3D1E3A5F), // 24% primary
              blurRadius: 0,
              spreadRadius: 3,
              offset: Offset.zero,
            ),
            BoxShadow(
              color: Color(0x1A1E3A5F), // 10% primary - outer glow
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ];
  }

  /// Error focus shadow - red-tinted focus ring for error states
  static List<BoxShadow> inputFocusError({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x40F87171), // 25% playful error
              blurRadius: 0,
              spreadRadius: 3,
              offset: Offset.zero,
            ),
            BoxShadow(
              color: Color(0x20F87171), // 12% playful error - outer glow
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x3DEF4444), // 24% clean error
              blurRadius: 0,
              spreadRadius: 3,
              offset: Offset.zero,
            ),
            BoxShadow(
              color: Color(0x1AEF4444), // 10% clean error - outer glow
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ];
  }

  /// Success focus shadow - green-tinted focus ring
  static List<BoxShadow> inputFocusSuccess({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x4022C55E), // 25% playful success
              blurRadius: 0,
              spreadRadius: 3,
              offset: Offset.zero,
            ),
            BoxShadow(
              color: Color(0x2022C55E), // 12% playful success - outer glow
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x3D10B981), // 24% clean success
              blurRadius: 0,
              spreadRadius: 3,
              offset: Offset.zero,
            ),
            BoxShadow(
              color: Color(0x1A10B981), // 10% clean success - outer glow
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset.zero,
            ),
          ];
  }

  // ============================================================================
  // SPECIAL SHADOWS
  // ============================================================================

  /// Message bubble shadow for chat interfaces
  /// Tinted shadow based on message ownership
  static List<BoxShadow> message({
    required bool isFromMe,
    required Color primaryColor,
  }) {
    return [
      BoxShadow(
        color: (isFromMe ? primaryColor : const Color(0xFF000000))
            .withValues(alpha: 0.04),
        blurRadius: 4,
        spreadRadius: 0,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: (isFromMe ? primaryColor : const Color(0xFF000000))
            .withValues(alpha: 0.06),
        blurRadius: 12,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ];
  }

  /// Avatar shadow - circular element elevation
  static List<BoxShadow> avatar({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0A7C3AED), // 4% primary
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x087C3AED), // 3% primary
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x08000000), // 3% opacity
              blurRadius: 3,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x07000000), // 3% opacity
              blurRadius: 8,
              spreadRadius: 0,
              offset: Offset(0, 4),
            ),
          ];
  }

  /// Tooltip shadow - small floating helper
  static List<BoxShadow> tooltip({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0C7C3AED), // 5% primary
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x0A7C3AED), // 4% primary
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 5),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0A000000), // 4% opacity
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 2),
            ),
            BoxShadow(
              color: Color(0x08000000), // 3% opacity
              blurRadius: 10,
              spreadRadius: 0,
              offset: Offset(0, 5),
            ),
          ];
  }

  /// Inner shadow effect - for inset elements (recessed inputs, etc.)
  /// Note: Flutter's BoxShadow doesn't support inset; use with custom painting
  static List<BoxShadow> inner({required bool isPlayful}) {
    return isPlayful
        ? const [
            BoxShadow(
              color: Color(0x0A7C3AED), // 4% primary
              blurRadius: 4,
              spreadRadius: -2,
              offset: Offset(0, 2),
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x0A000000), // 4% opacity
              blurRadius: 4,
              spreadRadius: -2,
              offset: Offset(0, 2),
            ),
          ];
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Combine multiple shadow lists into one
  /// Useful for composing custom shadow effects
  static List<BoxShadow> combine(List<List<BoxShadow>> shadowLists) {
    return shadowLists.expand((list) => list).toList();
  }

  /// Create a new shadow list with adjusted opacity
  /// [factor] multiplies the existing alpha value (e.g., 0.5 = half opacity)
  static List<BoxShadow> withOpacityFactor(
    List<BoxShadow> shadows,
    double factor,
  ) {
    return shadows.map((shadow) {
      return BoxShadow(
        color: shadow.color.withValues(
          alpha: (shadow.color.a * factor).clamp(0.0, 1.0),
        ),
        blurRadius: shadow.blurRadius,
        spreadRadius: shadow.spreadRadius,
        offset: shadow.offset,
        blurStyle: shadow.blurStyle,
      );
    }).toList();
  }

  /// Create a shadow with a specific opacity (0.0 - 1.0)
  /// Replaces the alpha channel entirely
  static List<BoxShadow> withOpacity(
    List<BoxShadow> shadows,
    double opacity,
  ) {
    return shadows.map((shadow) {
      return BoxShadow(
        color: shadow.color.withValues(alpha: opacity.clamp(0.0, 1.0)),
        blurRadius: shadow.blurRadius,
        spreadRadius: shadow.spreadRadius,
        offset: shadow.offset,
        blurStyle: shadow.blurStyle,
      );
    }).toList();
  }

  /// Scale shadow offset and blur radius
  /// Useful for creating variants (e.g., larger/smaller elevation)
  static List<BoxShadow> scaled(
    List<BoxShadow> shadows,
    double scale,
  ) {
    return shadows.map((shadow) {
      return BoxShadow(
        color: shadow.color,
        blurRadius: shadow.blurRadius * scale,
        spreadRadius: shadow.spreadRadius * scale,
        offset: shadow.offset * scale,
        blurStyle: shadow.blurStyle,
      );
    }).toList();
  }

  /// Create a colored variant of a shadow
  /// Useful for semantic coloring (success, error states)
  static List<BoxShadow> colored(
    List<BoxShadow> shadows,
    Color color,
  ) {
    return shadows.map((shadow) {
      return BoxShadow(
        color: color.withValues(alpha: shadow.color.a),
        blurRadius: shadow.blurRadius,
        spreadRadius: shadow.spreadRadius,
        offset: shadow.offset,
        blurStyle: shadow.blurStyle,
      );
    }).toList();
  }

  /// Get shadow by elevation level (1-5)
  /// Convenience method for dynamic elevation needs
  static List<BoxShadow> elevation(int level, {required bool isPlayful}) {
    switch (level) {
      case 1:
        return isPlayful ? playfulXs : cleanXs;
      case 2:
        return isPlayful ? playfulSm : cleanSm;
      case 3:
        return isPlayful ? playfulMd : cleanMd;
      case 4:
        return isPlayful ? playfulLg : cleanLg;
      case 5:
        return isPlayful ? playfulXl : cleanXl;
      default:
        if (level <= 0) return none;
        return isPlayful ? playfulXl : cleanXl;
    }
  }

  /// Animated shadow transition helper
  /// Returns interpolated shadows for smooth animations
  static List<BoxShadow> lerp(
    List<BoxShadow>? a,
    List<BoxShadow>? b,
    double t,
  ) {
    a ??= none;
    b ??= none;

    final int maxLength =
        a.length > b.length ? a.length : b.length;
    final List<BoxShadow> result = [];

    for (int i = 0; i < maxLength; i++) {
      final BoxShadow shadowA = i < a.length
          ? a[i]
          : const BoxShadow(color: Color(0x00000000));
      final BoxShadow shadowB = i < b.length
          ? b[i]
          : const BoxShadow(color: Color(0x00000000));

      result.add(BoxShadow.lerp(shadowA, shadowB, t)!);
    }

    return result;
  }
}

/// Standardized opacity values for consistent transparency.
///
/// Use these instead of arbitrary values like 0.03, 0.1, 0.15, etc.
/// This ensures visual consistency across the entire application.
abstract final class AppOpacity {
  // ============ Semantic Opacity Levels ============

  /// Barely visible (2%) - very subtle overlays
  static const double faint = 0.02;

  /// Very subtle (4%) - light borders, dividers
  static const double subtle = 0.04;

  /// Light (8%) - hover states, light overlays
  static const double light = 0.08;

  /// Soft (12%) - selected states, soft overlays
  static const double soft = 0.12;

  /// Medium (16%) - active states, medium overlays
  static const double medium = 0.16;

  /// Semi (24%) - semi-transparent overlays
  static const double semi = 0.24;

  /// Strong (32%) - strong overlays
  static const double strong = 0.32;

  /// Heavy (48%) - heavy overlays
  static const double heavy = 0.48;

  /// Dominant (64%) - dominant overlays
  static const double dominant = 0.64;

  /// Almost opaque (80%) - nearly solid
  static const double almostOpaque = 0.80;

  // ============ Component-Specific Opacity ============

  /// Border opacity for subtle borders
  static const double border = 0.12;

  /// Divider opacity
  static const double divider = 0.08;

  /// Disabled state opacity
  static const double disabled = 0.38;

  /// Hint text opacity
  static const double hint = 0.48;

  /// Scrim/overlay background opacity
  static const double scrim = 0.32;

  /// Card border opacity
  static const double cardBorder = 0.06;

  /// Pressed state opacity
  static const double pressed = 0.12;

  /// Hover state opacity
  static const double hover = 0.08;

  /// Selected indicator opacity
  static const double selected = 0.12;

  /// Focus ring opacity
  static const double focus = 0.24;

  /// Icon on colored background opacity
  static const double iconOnColor = 0.72;

  // ============ Shadow-Specific Opacity ============

  /// Shadow close layer (3-4%)
  static const double shadowClose = 0.04;

  /// Shadow mid layer (5-6%)
  static const double shadowMid = 0.06;

  /// Shadow far layer (3-4%)
  static const double shadowFar = 0.04;

  /// Focus ring inner opacity (24-25%)
  static const double focusRing = 0.25;

  /// Focus ring outer glow opacity (10-12%)
  static const double focusGlow = 0.12;
}

/// Color extension helpers for applying opacity.
extension ColorOpacity on Color {
  /// Apply semantic opacity
  Color withOpacityValue(double opacity) => withValues(alpha: opacity);

  /// Faint overlay (2%)
  Color get faint => withValues(alpha: AppOpacity.faint);

  /// Subtle overlay (4%)
  Color get subtle => withValues(alpha: AppOpacity.subtle);

  /// Light overlay (8%)
  Color get lighter => withValues(alpha: AppOpacity.light);

  /// Soft overlay (12%)
  Color get soft => withValues(alpha: AppOpacity.soft);

  /// Medium overlay (16%)
  Color get medium => withValues(alpha: AppOpacity.medium);

  /// Semi overlay (24%)
  Color get semi => withValues(alpha: AppOpacity.semi);

  /// Strong overlay (32%)
  Color get strong => withValues(alpha: AppOpacity.strong);

  /// Heavy overlay (48%)
  Color get heavy => withValues(alpha: AppOpacity.heavy);

  /// Dominant overlay (64%)
  Color get dominant => withValues(alpha: AppOpacity.dominant);

  /// Focus ring opacity (25%)
  Color get focusRing => withValues(alpha: AppOpacity.focusRing);

  /// Focus glow opacity (12%)
  Color get focusGlow => withValues(alpha: AppOpacity.focusGlow);
}

/// Shadow decoration builder for common patterns
extension ShadowDecoration on List<BoxShadow> {
  /// Create a BoxDecoration with these shadows
  BoxDecoration toDecoration({
    Color? color,
    BorderRadius? borderRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: border,
      boxShadow: this,
    );
  }

  /// Create a BoxDecoration with rounded corners
  BoxDecoration rounded({
    required double radius,
    Color? color,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: this,
    );
  }
}
