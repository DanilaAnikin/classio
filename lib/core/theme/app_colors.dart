import 'package:flutter/material.dart';

/// Color constants for the Clean (Apple-inspired) theme.
///
/// This theme uses a professional color palette with deep blues
/// and neutral grays, creating a corporate and minimalist look.
abstract class CleanColors {
  // Primary colors
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF2E5077);
  static const Color primaryDark = Color(0xFF152A45);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary colors
  static const Color secondary = Color(0xFF64748B);
  static const Color secondaryLight = Color(0xFF94A3B8);
  static const Color secondaryDark = Color(0xFF475569);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Background colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1A1A1A);

  // Surface colors
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Error colors
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);

  // Success colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Warning colors
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFFFFFFFF);

  // Info colors
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color disabled = Color(0xFF9CA3AF);
  static const Color hint = Color(0xFF9CA3AF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);

  // Card colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFF8F9FA);

  // Input colors
  static const Color inputBackground = Color(0xFFF8F9FA);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputFocusBorder = Color(0xFF1E3A5F);

  // AppBar colors
  static const Color appBar = Color(0xFFFFFFFF);
  static const Color appBarForeground = Color(0xFF1A1A1A);

  // Bottom Navigation colors
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = Color(0xFF1E3A5F);
  static const Color bottomNavUnselected = Color(0xFF9CA3AF);
}

/// Color constants for the Playful theme.
///
/// This theme uses vibrant purples and coral/orange accents
/// with a soft cream background, creating a fun and engaging look.
abstract class PlayfulColors {
  // Primary colors
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary colors
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryLight = Color(0xFFFDBA74);
  static const Color secondaryDark = Color(0xFFEA580C);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Background colors
  static const Color background = Color(0xFFFFFBF5);
  static const Color onBackground = Color(0xFF1F1F1F);

  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFFF7ED);
  static const Color onSurface = Color(0xFF1F1F1F);
  static const Color onSurfaceVariant = Color(0xFF57534E);

  // Error colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFECACA);
  static const Color onError = Color(0xFFFFFFFF);

  // Success colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFBBF7D0);
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Warning colors
  static const Color warning = Color(0xFFFBBF24);
  static const Color warningLight = Color(0xFFFEF08A);
  static const Color onWarning = Color(0xFF1F1F1F);

  // Info colors
  static const Color info = Color(0xFF06B6D4);
  static const Color infoLight = Color(0xFFCFFAFE);
  static const Color onInfo = Color(0xFFFFFFFF);

  // Neutral colors
  static const Color divider = Color(0xFFE7E5E4);
  static const Color border = Color(0xFFD6D3D1);
  static const Color disabled = Color(0xFFA8A29E);
  static const Color hint = Color(0xFFA8A29E);

  // Text colors
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF57534E);
  static const Color textTertiary = Color(0xFF78716C);
  static const Color textDisabled = Color(0xFFD6D3D1);

  // Shadow colors
  static const Color shadow = Color(0x1A7C3AED);
  static const Color shadowLight = Color(0x0D7C3AED);

  // Card colors
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardHover = Color(0xFFFFF7ED);

  // Input colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFD6D3D1);
  static const Color inputFocusBorder = Color(0xFF7C3AED);

  // AppBar colors
  static const Color appBar = Color(0xFFFFFBF5);
  static const Color appBarForeground = Color(0xFF1F1F1F);

  // Bottom Navigation colors
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = Color(0xFF7C3AED);
  static const Color bottomNavUnselected = Color(0xFFA8A29E);

  // Gradient colors (unique to Playful theme)
  static const Color gradientStart = Color(0xFF7C3AED);
  static const Color gradientMiddle = Color(0xFFA855F7);
  static const Color gradientEnd = Color(0xFFF97316);

  // Accent colors for decorations
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentGreen = Color(0xFF22C55E);
}

/// Gradient definitions for the Playful theme.
abstract class PlayfulGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PlayfulColors.gradientStart,
      PlayfulColors.gradientMiddle,
      PlayfulColors.gradientEnd,
    ],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFAF5FF),
      Color(0xFFFFF7ED),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFF7ED),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      PlayfulColors.primary,
      PlayfulColors.primaryLight,
    ],
  );
}
