import 'package:flutter/material.dart';

// =============================================================================
// CLASSIO COLOR SYSTEM v2.0
// =============================================================================
// A premium, enterprise-grade color system inspired by Linear, Vercel, and Stripe.
//
// Design Principles:
// - Never use pure black (#000000) or pure white (#FFFFFF) for text/backgrounds
// - Desaturated, sophisticated palettes for professional feel
// - WCAG AA compliant contrast ratios (4.5:1 for normal text, 3:1 for large text)
// - Consistent naming conventions across themes
// - Surface elevation hierarchy for depth
// - Interactive state variants (hover, pressed, disabled)
// =============================================================================

/// Clean Theme Color Palette
///
/// Enterprise/Professional aesthetic inspired by Stripe, Linear, and Vercel.
/// Uses a sophisticated blue primary with slate neutrals.
abstract class CleanColors {
  // ============================================================================
  // PRIMARY PALETTE
  // ============================================================================
  // Stripe-inspired sophisticated blue - professional and trustworthy
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryHover = Color(0xFF0052CC);
  static const Color primaryPressed = Color(0xFF0047B3);
  static const Color primaryLight = Color(0xFF3385FF);
  static const Color primaryDark = Color(0xFF0047B3);
  static const Color primarySubtle = Color(0xFFE6F0FF); // 10% opacity feel
  static const Color primaryMuted = Color(0xFFF0F7FF); // 5% opacity feel
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ============================================================================
  // SECONDARY PALETTE
  // ============================================================================
  // Linear-inspired indigo for accents and secondary actions
  static const Color secondary = Color(0xFF5B5BD6);
  static const Color secondaryHover = Color(0xFF4C4CC4);
  static const Color secondaryPressed = Color(0xFF4343B0);
  static const Color secondaryLight = Color(0xFF7B7BE5);
  static const Color secondaryDark = Color(0xFF4343B0);
  static const Color secondarySubtle = Color(0xFFEEEEFC);
  static const Color secondaryMuted = Color(0xFFF5F5FD);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ============================================================================
  // BACKGROUND & SURFACE HIERARCHY
  // ============================================================================
  // Off-white background - never pure white for main canvas
  static const Color background = Color(0xFFFAFBFC);
  static const Color onBackground = Color(0xFF0F172A); // Deep charcoal

  // Surface elevation system (cards, dialogs, sheets)
  static const Color surface = Color(0xFFFFFFFF); // Base surface (cards)
  static const Color surfaceSecondary = Color(0xFFF8FAFC); // Secondary surface
  static const Color surfaceHover = Color(0xFFF8FAFC);
  static const Color surfacePressed = Color(0xFFF1F5F9);
  static const Color surfaceElevated = Color(0xFFFFFFFF); // Modals, dropdowns
  static const Color surfaceOverlay = Color(0x80000000); // 50% black overlay
  static const Color surfaceMuted = Color(0xFFF8FAFC); // Subtle backgrounds
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Input backgrounds
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  // ============================================================================
  // TEXT HIERARCHY
  // ============================================================================
  // Deep charcoal - never pure black
  static const Color textPrimary = Color(0xFF0F172A); // Headings, primary content
  static const Color textSecondary = Color(0xFF64748B); // Slate gray - body text
  static const Color textTertiary = Color(0xFF94A3B8); // Light gray - captions
  static const Color textMuted = Color(0xFFCBD5E1); // Very light - placeholders
  static const Color textDisabled = Color(0xFFE2E8F0); // Disabled state
  static const Color textInverse = Color(0xFFF8FAFC); // On dark backgrounds

  // ============================================================================
  // BORDER SYSTEM
  // ============================================================================
  static const Color border = Color(0xFFE2E8F0); // Default borders
  static const Color borderHover = Color(0xFFCBD5E1); // Hover state
  static const Color borderFocus = Color(0xFF0066FF); // Focus ring
  static const Color borderSubtle = Color(0xFFF1F5F9); // Very subtle
  static const Color borderStrong = Color(0xFFCBD5E1); // Emphasized borders
  static const Color divider = Color(0xFFE2E8F0); // Separators

  // ============================================================================
  // STATUS COLORS (DESATURATED FOR ENTERPRISE)
  // ============================================================================
  // Soft emerald - success states
  static const Color success = Color(0xFF10B981);
  static const Color successHover = Color(0xFF059669);
  static const Color successPressed = Color(0xFF047857);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successMuted = Color(0xFFECFDF5);
  static const Color successBorder = Color(0xFFA7F3D0);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Soft rose - error states (DC2626 is less harsh than EF4444)
  static const Color error = Color(0xFFDC2626);
  static const Color errorHover = Color(0xFFB91C1C);
  static const Color errorPressed = Color(0xFF991B1B);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorMuted = Color(0xFFFEF2F2);
  static const Color errorSubtle = Color(0xFFFEF2F2); // Subtle error background
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color onError = Color(0xFFFFFFFF);

  // Soft amber - warning states
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningHover = Color(0xFFD97706);
  static const Color warningPressed = Color(0xFFB45309);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningMuted = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color onWarning = Color(0xFF0F172A);

  // Soft sky - info states
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoHover = Color(0xFF0284C7);
  static const Color infoPressed = Color(0xFF0369A1);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoMuted = Color(0xFFF0F9FF);
  static const Color infoBorder = Color(0xFFBAE6FD);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ============================================================================
  // NEUTRAL PALETTE (SLATE SCALE)
  // ============================================================================
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // ============================================================================
  // INTERACTIVE STATES
  // ============================================================================
  static const Color disabled = Color(0xFF94A3B8);
  static const Color disabledBackground = Color(0xFFF1F5F9);
  static const Color hint = Color(0xFF94A3B8);
  static const Color focusRing = Color(0x330066FF); // 20% primary
  static const Color hoverOverlay = Color(0x08000000); // 3% black
  static const Color pressedOverlay = Color(0x0F000000); // 6% black

  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  static const Color shadow = Color(0x08000000); // 3% black - subtle
  static const Color shadowMedium = Color(0x12000000); // 7% black - cards
  static const Color shadowStrong = Color(0x1A000000); // 10% black - elevated
  static const Color shadowColor = Color(0xFF0F172A); // For colored shadows

  // ============================================================================
  // CARD COLORS
  // ============================================================================
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFF8FAFC);
  static const Color cardPressed = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardBorderHover = Color(0xFFCBD5E1);

  // ============================================================================
  // INPUT COLORS
  // ============================================================================
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBackgroundHover = Color(0xFFF8FAFC);
  static const Color inputBackgroundFocus = Color(0xFFFFFFFF);
  static const Color inputBackgroundDisabled = Color(0xFFF1F5F9);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputBorderHover = Color(0xFFCBD5E1);
  static const Color inputBorderFocus = Color(0xFF0066FF);
  static const Color inputBorderError = Color(0xFFDC2626);
  static const Color inputFocusRing = Color(0x1A0066FF); // 10% primary

  // ============================================================================
  // NAVIGATION COLORS
  // ============================================================================
  static const Color appBar = Color(0xFFFFFFFF);
  static const Color appBarBorder = Color(0xFFE2E8F0);
  static const Color appBarForeground = Color(0xFF0F172A);
  static const Color bottomNav = Color(0xFFFFFFFF);
  static const Color bottomNavBorder = Color(0xFFE2E8F0);
  static const Color bottomNavSelected = Color(0xFF0066FF);
  static const Color bottomNavUnselected = Color(0xFF64748B);
  static const Color sidebarBackground = Color(0xFFF8FAFC);
  static const Color sidebarItemHover = Color(0xFFF1F5F9);
  static const Color sidebarItemActive = Color(0xFFE6F0FF);

  // ============================================================================
  // ROLE COLORS (User role badges and indicators)
  // ============================================================================
  static const Color superadminRole = Color(0xFF7C3AED); // Violet
  static const Color principalRole = Color(0xFF4F46E5); // Indigo
  static const Color deputyRole = Color(0xFF0891B2); // Cyan
  static const Color teacherRole = Color(0xFF0066FF); // Primary blue
  static const Color studentRole = Color(0xFF10B981); // Emerald
  static const Color parentRole = Color(0xFFEA580C); // Deep orange

  // ============================================================================
  // GRADE COLORS (Academic performance visualization)
  // ============================================================================
  static const Color gradeExcellent = Color(0xFF10B981); // Emerald (5/A)
  static const Color gradeGood = Color(0xFF22C55E); // Green (4/B)
  static const Color gradeAverage = Color(0xFFF59E0B); // Amber (3/C)
  static const Color gradeBelowAverage = Color(0xFFEA580C); // Orange (2/D)
  static const Color gradeFailing = Color(0xFFDC2626); // Red (1/F)

  // ============================================================================
  // ATTENDANCE COLORS
  // ============================================================================
  static const Color attendancePresent = Color(0xFF10B981); // Emerald
  static const Color attendanceAbsent = Color(0xFFDC2626); // Red
  static const Color attendanceLate = Color(0xFFF59E0B); // Amber
  static const Color attendanceExcused = Color(0xFF0EA5E9); // Sky blue
  static const Color attendanceUnknown = Color(0xFF94A3B8); // Slate gray

  // ============================================================================
  // SUBSCRIPTION TIER COLORS
  // ============================================================================
  static const Color subscriptionTrial = Color(0xFFF59E0B); // Amber
  static const Color subscriptionBasic = Color(0xFF0066FF); // Primary blue
  static const Color subscriptionPro = Color(0xFF7C3AED); // Violet
  static const Color subscriptionProMax = Color(0xFF4F46E5); // Indigo
  static const Color subscriptionExpired = Color(0xFFDC2626); // Red
  static const Color subscriptionInactive = Color(0xFF64748B); // Slate

  // ============================================================================
  // DASHBOARD STAT COLORS
  // ============================================================================
  static const Color statBlue = Color(0xFF0066FF);
  static const Color statGreen = Color(0xFF10B981);
  static const Color statOrange = Color(0xFFEA580C);
  static const Color statPurple = Color(0xFF7C3AED);
  static const Color statPink = Color(0xFFDB2777);
  static const Color statTeal = Color(0xFF0891B2);
  static const Color statIndigo = Color(0xFF4F46E5);
  static const Color statAmber = Color(0xFFF59E0B);
}

/// Clean Theme Gradients
abstract class CleanGradients {
  // Primary gradient - subtle sophistication
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0066FF),
      Color(0xFF0052CC),
    ],
  );

  // Background gradient - very subtle depth
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFBFC),
      Color(0xFFF1F5F9),
    ],
  );

  // Card hover gradient
  static const LinearGradient cardHover = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );

  // Premium accent gradient
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0066FF),
      Color(0xFF5B5BD6),
    ],
  );

  // Shimmer/skeleton loading gradient
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

// =============================================================================
// PLAYFUL THEME
// =============================================================================

/// Playful Theme Color Palette
///
/// Educational/Engaging aesthetic with warmth and personality.
/// Uses a refined violet primary with warm coral accents and stone neutrals.
abstract class PlayfulColors {
  // ============================================================================
  // PRIMARY PALETTE
  // ============================================================================
  // Refined violet - friendly yet sophisticated
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryHover = Color(0xFF6D28D9);
  static const Color primaryPressed = Color(0xFF5B21B6);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primarySubtle = Color(0xFFF3E8FF);
  static const Color primaryMuted = Color(0xFFFAF5FF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ============================================================================
  // SECONDARY PALETTE
  // ============================================================================
  // Softened coral - warm and energetic (EA580C instead of F97316)
  static const Color secondary = Color(0xFFEA580C);
  static const Color secondaryHover = Color(0xFFC2410C);
  static const Color secondaryPressed = Color(0xFF9A3412);
  static const Color secondaryLight = Color(0xFFF97316);
  static const Color secondaryDark = Color(0xFF9A3412);
  static const Color secondarySubtle = Color(0xFFFFF7ED);
  static const Color secondaryMuted = Color(0xFFFFFAF5);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ============================================================================
  // BACKGROUND & SURFACE HIERARCHY
  // ============================================================================
  // Soft cream - warm and inviting
  static const Color background = Color(0xFFFFFBF5);
  static const Color onBackground = Color(0xFF1C1917); // Warm charcoal

  // Surface elevation system
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFFFFAF5); // Secondary surface
  static const Color surfaceHover = Color(0xFFFFFAF5);
  static const Color surfacePressed = Color(0xFFFFF5EB);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceOverlay = Color(0x801C1917); // 50% warm black
  static const Color surfaceMuted = Color(0xFFFFFBF5);
  static const Color surfaceSubtle = Color(0xFFFAF5F2);
  static const Color onSurface = Color(0xFF1C1917);
  static const Color onSurfaceVariant = Color(0xFF78716C);

  // ============================================================================
  // TEXT HIERARCHY
  // ============================================================================
  // Warm charcoal - friendly and readable
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF57534E);
  static const Color textTertiary = Color(0xFF78716C);
  static const Color textMuted = Color(0xFFA8A29E);
  static const Color textDisabled = Color(0xFFD6D3D1);
  static const Color textInverse = Color(0xFFFAFAF9);

  // ============================================================================
  // BORDER SYSTEM
  // ============================================================================
  static const Color border = Color(0xFFE7E5E4);
  static const Color borderHover = Color(0xFFD6D3D1);
  static const Color borderFocus = Color(0xFF7C3AED);
  static const Color borderSubtle = Color(0xFFF5F5F4);
  static const Color borderStrong = Color(0xFFD6D3D1);
  static const Color divider = Color(0xFFE7E5E4);

  // ============================================================================
  // STATUS COLORS (Kid-friendly but refined)
  // ============================================================================
  // Fresh mint green
  static const Color success = Color(0xFF22C55E);
  static const Color successHover = Color(0xFF16A34A);
  static const Color successPressed = Color(0xFF15803D);
  static const Color successLight = Color(0xFFBBF7D0);
  static const Color successMuted = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFF86EFAC);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Soft coral red (friendlier than harsh red)
  static const Color error = Color(0xFFF87171);
  static const Color errorHover = Color(0xFFEF4444);
  static const Color errorPressed = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFECACA);
  static const Color errorMuted = Color(0xFFFEF2F2);
  static const Color errorSubtle = Color(0xFFFEF2F2); // Subtle error background
  static const Color errorBorder = Color(0xFFFCA5A5);
  static const Color onError = Color(0xFFFFFFFF);

  // Sunny amber
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningHover = Color(0xFFF59E0B);
  static const Color warningPressed = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFDE68A);
  static const Color warningMuted = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFCD34D);
  static const Color onWarning = Color(0xFF1C1917);

  // Sky cyan
  static const Color info = Color(0xFF06B6D4);
  static const Color infoHover = Color(0xFF0891B2);
  static const Color infoPressed = Color(0xFF0E7490);
  static const Color infoLight = Color(0xFFCFFAFE);
  static const Color infoMuted = Color(0xFFECFEFF);
  static const Color infoBorder = Color(0xFF67E8F9);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ============================================================================
  // NEUTRAL PALETTE (STONE SCALE - warmer than slate)
  // ============================================================================
  static const Color stone50 = Color(0xFFFAFAF9);
  static const Color stone100 = Color(0xFFF5F5F4);
  static const Color stone200 = Color(0xFFE7E5E4);
  static const Color stone300 = Color(0xFFD6D3D1);
  static const Color stone400 = Color(0xFFA8A29E);
  static const Color stone500 = Color(0xFF78716C);
  static const Color stone600 = Color(0xFF57534E);
  static const Color stone700 = Color(0xFF44403C);
  static const Color stone800 = Color(0xFF292524);
  static const Color stone900 = Color(0xFF1C1917);

  // ============================================================================
  // INTERACTIVE STATES
  // ============================================================================
  static const Color disabled = Color(0xFFA8A29E);
  static const Color disabledBackground = Color(0xFFF5F5F4);
  static const Color hint = Color(0xFFA8A29E);
  static const Color focusRing = Color(0x337C3AED); // 20% primary
  static const Color hoverOverlay = Color(0x081C1917); // 3%
  static const Color pressedOverlay = Color(0x0F1C1917); // 6%

  // ============================================================================
  // SHADOW COLORS (tinted with violet for warmth)
  // ============================================================================
  static const Color shadow = Color(0x087C3AED); // 3% primary
  static const Color shadowMedium = Color(0x127C3AED); // 7% primary
  static const Color shadowStrong = Color(0x1A7C3AED); // 10% primary
  static const Color shadowColor = Color(0xFF7C3AED);

  // ============================================================================
  // CARD COLORS
  // ============================================================================
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFFFFAF5);
  static const Color cardPressed = Color(0xFFFFF5EB);
  static const Color cardBorder = Color(0xFFE7E5E4);
  static const Color cardBorderHover = Color(0xFFD6D3D1);

  // ============================================================================
  // INPUT COLORS
  // ============================================================================
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBackgroundHover = Color(0xFFFFFBF5);
  static const Color inputBackgroundFocus = Color(0xFFFFFFFF);
  static const Color inputBackgroundDisabled = Color(0xFFF5F5F4);
  static const Color inputBorder = Color(0xFFE7E5E4);
  static const Color inputBorderHover = Color(0xFFD6D3D1);
  static const Color inputBorderFocus = Color(0xFF7C3AED);
  static const Color inputBorderError = Color(0xFFF87171);
  static const Color inputFocusRing = Color(0x1A7C3AED); // 10% primary

  // ============================================================================
  // NAVIGATION COLORS
  // ============================================================================
  static const Color appBar = Color(0xFFFFFBF5);
  static const Color appBarBorder = Color(0xFFE7E5E4);
  static const Color appBarForeground = Color(0xFF1C1917);
  static const Color bottomNav = Color(0xFFFFFFFF);
  static const Color bottomNavBorder = Color(0xFFE7E5E4);
  static const Color bottomNavSelected = Color(0xFF7C3AED);
  static const Color bottomNavUnselected = Color(0xFF78716C);
  static const Color sidebarBackground = Color(0xFFFAF5F2);
  static const Color sidebarItemHover = Color(0xFFF5F0EB);
  static const Color sidebarItemActive = Color(0xFFF3E8FF);

  // ============================================================================
  // ACCENT COLORS (for decorations and fun elements)
  // ============================================================================
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentIndigo = Color(0xFF6366F1);

  // ============================================================================
  // ROLE COLORS
  // ============================================================================
  static const Color superadminRole = Color(0xFF9333EA); // Vibrant purple
  static const Color principalRole = Color(0xFF6366F1); // Indigo
  static const Color deputyRole = Color(0xFF14B8A6); // Teal
  static const Color teacherRole = Color(0xFF7C3AED); // Primary violet
  static const Color studentRole = Color(0xFF22C55E); // Fresh green
  static const Color parentRole = Color(0xFFEA580C); // Warm orange

  // ============================================================================
  // GRADE COLORS
  // ============================================================================
  static const Color gradeExcellent = Color(0xFF22C55E); // Green (5/A)
  static const Color gradeGood = Color(0xFF84CC16); // Lime (4/B)
  static const Color gradeAverage = Color(0xFFFBBF24); // Amber (3/C)
  static const Color gradeBelowAverage = Color(0xFFF97316); // Orange (2/D)
  static const Color gradeFailing = Color(0xFFF87171); // Soft red (1/F)

  // ============================================================================
  // ATTENDANCE COLORS
  // ============================================================================
  static const Color attendancePresent = Color(0xFF22C55E); // Green
  static const Color attendanceAbsent = Color(0xFFF87171); // Soft red
  static const Color attendanceLate = Color(0xFFFBBF24); // Amber
  static const Color attendanceExcused = Color(0xFF06B6D4); // Cyan
  static const Color attendanceUnknown = Color(0xFFA8A29E); // Stone gray

  // ============================================================================
  // SUBSCRIPTION TIER COLORS
  // ============================================================================
  static const Color subscriptionTrial = Color(0xFFFBBF24); // Amber
  static const Color subscriptionBasic = Color(0xFF6366F1); // Indigo
  static const Color subscriptionPro = Color(0xFF7C3AED); // Violet
  static const Color subscriptionProMax = Color(0xFF9333EA); // Purple
  static const Color subscriptionExpired = Color(0xFFF87171); // Soft red
  static const Color subscriptionInactive = Color(0xFF78716C); // Stone

  // ============================================================================
  // DASHBOARD STAT COLORS
  // ============================================================================
  static const Color statBlue = Color(0xFF6366F1);
  static const Color statGreen = Color(0xFF22C55E);
  static const Color statOrange = Color(0xFFEA580C);
  static const Color statPurple = Color(0xFF7C3AED);
  static const Color statPink = Color(0xFFEC4899);
  static const Color statTeal = Color(0xFF14B8A6);
  static const Color statIndigo = Color(0xFF6366F1);
  static const Color statAmber = Color(0xFFFBBF24);
}

/// Playful Theme Gradients
abstract class PlayfulGradients {
  // Primary gradient - vibrant and engaging
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF8B5CF6),
    ],
  );

  // Rainbow gradient - for special elements
  static const LinearGradient rainbow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED), // Violet
      Color(0xFFA855F7), // Purple
      Color(0xFFEC4899), // Pink
      Color(0xFFEA580C), // Orange
    ],
  );

  // Background gradient - warm and soft
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBF5),
      Color(0xFFFAF5FF),
    ],
  );

  // Card hover gradient
  static const LinearGradient cardHover = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFF7ED),
    ],
  );

  // Soft gradient for decorative backgrounds
  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAF5FF),
      Color(0xFFFFF7ED),
    ],
  );

  // Button gradient
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED),
      Color(0xFF8B5CF6),
    ],
  );

  // Shimmer/skeleton loading gradient
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFF5F5F4),
      Color(0xFFE7E5E4),
      Color(0xFFF5F5F4),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

// =============================================================================
// SEMANTIC COLOR HELPERS
// =============================================================================

/// Helper class for accessing semantic colors based on the current theme.
///
/// Usage:
/// ```dart
/// final roleColor = AppSemanticColors.getRoleColor(UserRole.teacher, isPlayful: themeNotifier.isPlayful);
/// final gradeColor = AppSemanticColors.getGradeColor(4.5, isPlayful: themeNotifier.isPlayful);
/// ```
abstract class AppSemanticColors {
  /// Get the color for a user role
  static Color getRoleColor(String role, {required bool isPlayful}) {
    final colors = isPlayful ? _PlayfulRoleColors() : _CleanRoleColors();
    switch (role.toLowerCase()) {
      case 'superadmin':
        return colors.superadmin;
      case 'principal':
        return colors.principal;
      case 'deputy':
        return colors.deputy;
      case 'teacher':
        return colors.teacher;
      case 'student':
        return colors.student;
      case 'parent':
        return colors.parent;
      default:
        return colors.student;
    }
  }

  /// Get the color for a grade value (1-5 or 1-6 scale)
  static Color getGradeColor(double value, {required bool isPlayful}) {
    if (isPlayful) {
      if (value >= 5) return PlayfulColors.gradeExcellent;
      if (value >= 4) return PlayfulColors.gradeGood;
      if (value >= 3) return PlayfulColors.gradeAverage;
      if (value >= 2) return PlayfulColors.gradeBelowAverage;
      return PlayfulColors.gradeFailing;
    } else {
      if (value >= 5) return CleanColors.gradeExcellent;
      if (value >= 4) return CleanColors.gradeGood;
      if (value >= 3) return CleanColors.gradeAverage;
      if (value >= 2) return CleanColors.gradeBelowAverage;
      return CleanColors.gradeFailing;
    }
  }

  /// Get the color for an attendance status
  static Color getAttendanceColor(String status, {required bool isPlayful}) {
    final lowerStatus = status.toLowerCase();
    if (isPlayful) {
      if (lowerStatus == 'present') return PlayfulColors.attendancePresent;
      if (lowerStatus == 'absent') return PlayfulColors.attendanceAbsent;
      if (lowerStatus == 'late') return PlayfulColors.attendanceLate;
      if (lowerStatus == 'excused') return PlayfulColors.attendanceExcused;
      return PlayfulColors.attendanceUnknown;
    } else {
      if (lowerStatus == 'present') return CleanColors.attendancePresent;
      if (lowerStatus == 'absent') return CleanColors.attendanceAbsent;
      if (lowerStatus == 'late') return CleanColors.attendanceLate;
      if (lowerStatus == 'excused') return CleanColors.attendanceExcused;
      return CleanColors.attendanceUnknown;
    }
  }

  /// Get the color for a subscription tier
  static Color getSubscriptionColor(String tier, {required bool isPlayful}) {
    final lowerTier = tier.toLowerCase();
    if (isPlayful) {
      if (lowerTier == 'trial') return PlayfulColors.subscriptionTrial;
      if (lowerTier == 'basic') return PlayfulColors.subscriptionBasic;
      if (lowerTier == 'pro') return PlayfulColors.subscriptionPro;
      if (lowerTier == 'pro_max' || lowerTier == 'promax') {
        return PlayfulColors.subscriptionProMax;
      }
      if (lowerTier == 'expired') return PlayfulColors.subscriptionExpired;
      return PlayfulColors.subscriptionInactive;
    } else {
      if (lowerTier == 'trial') return CleanColors.subscriptionTrial;
      if (lowerTier == 'basic') return CleanColors.subscriptionBasic;
      if (lowerTier == 'pro') return CleanColors.subscriptionPro;
      if (lowerTier == 'pro_max' || lowerTier == 'promax') {
        return CleanColors.subscriptionProMax;
      }
      if (lowerTier == 'expired') return CleanColors.subscriptionExpired;
      return CleanColors.subscriptionInactive;
    }
  }

  /// Get success color
  static Color success({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.success : CleanColors.success;

  /// Get error color
  static Color error({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.error : CleanColors.error;

  /// Get warning color
  static Color warning({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.warning : CleanColors.warning;

  /// Get info color
  static Color info({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.info : CleanColors.info;

  /// Get the color for a percentage-based grade value (0-100 scale)
  static Color getGradeColorPercentage(
    double percentage, {
    required bool isPlayful,
  }) {
    if (isPlayful) {
      if (percentage >= 70) return PlayfulColors.gradeExcellent;
      if (percentage >= 50) return PlayfulColors.gradeAverage;
      return PlayfulColors.gradeFailing;
    } else {
      if (percentage >= 70) return CleanColors.gradeExcellent;
      if (percentage >= 50) return CleanColors.gradeAverage;
      return CleanColors.gradeFailing;
    }
  }

  /// Get the text color for a percentage-based grade value (0-100 scale)
  static Color getGradeTextColorPercentage(
    double percentage, {
    required bool isPlayful,
  }) {
    return getGradeColorPercentage(percentage, isPlayful: isPlayful);
  }

  /// Get stat color by semantic name
  static Color getStatColor(String statType, {required bool isPlayful}) {
    switch (statType.toLowerCase()) {
      case 'blue':
        return isPlayful ? PlayfulColors.statBlue : CleanColors.statBlue;
      case 'green':
        return isPlayful ? PlayfulColors.statGreen : CleanColors.statGreen;
      case 'orange':
        return isPlayful ? PlayfulColors.statOrange : CleanColors.statOrange;
      case 'purple':
        return isPlayful ? PlayfulColors.statPurple : CleanColors.statPurple;
      case 'pink':
        return isPlayful ? PlayfulColors.statPink : CleanColors.statPink;
      case 'teal':
        return isPlayful ? PlayfulColors.statTeal : CleanColors.statTeal;
      case 'indigo':
        return isPlayful ? PlayfulColors.statIndigo : CleanColors.statIndigo;
      case 'amber':
        return isPlayful ? PlayfulColors.statAmber : CleanColors.statAmber;
      default:
        return isPlayful ? PlayfulColors.statBlue : CleanColors.statBlue;
    }
  }

  /// Get primary color
  static Color primary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.primary : CleanColors.primary;

  /// Get secondary color
  static Color secondary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.secondary : CleanColors.secondary;

  /// Get background color
  static Color background({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.background : CleanColors.background;

  /// Get surface color
  static Color surface({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.surface : CleanColors.surface;

  /// Get text primary color
  static Color textPrimary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

  /// Get text secondary color
  static Color textSecondary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;

  /// Get border color
  static Color border({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.border : CleanColors.border;
}

// =============================================================================
// ROLE COLOR IMPLEMENTATIONS
// =============================================================================

abstract class _RoleColors {
  Color get superadmin;
  Color get principal;
  Color get deputy;
  Color get teacher;
  Color get student;
  Color get parent;
}

class _CleanRoleColors implements _RoleColors {
  @override
  Color get superadmin => CleanColors.superadminRole;
  @override
  Color get principal => CleanColors.principalRole;
  @override
  Color get deputy => CleanColors.deputyRole;
  @override
  Color get teacher => CleanColors.teacherRole;
  @override
  Color get student => CleanColors.studentRole;
  @override
  Color get parent => CleanColors.parentRole;
}

class _PlayfulRoleColors implements _RoleColors {
  @override
  Color get superadmin => PlayfulColors.superadminRole;
  @override
  Color get principal => PlayfulColors.principalRole;
  @override
  Color get deputy => PlayfulColors.deputyRole;
  @override
  Color get teacher => PlayfulColors.teacherRole;
  @override
  Color get student => PlayfulColors.studentRole;
  @override
  Color get parent => PlayfulColors.parentRole;
}
