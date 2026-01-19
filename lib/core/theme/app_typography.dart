import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

// ============================================================================
// APP TYPOGRAPHY
// ============================================================================
// Centralized typography system for premium enterprise-grade text hierarchy.
// Supports both Clean (Inter) and Playful (Nunito) themes with proper scaling.
// ============================================================================

/// Font family constants
abstract class AppFontFamily {
  /// Clean theme font - Inter (similar to SF Pro)
  /// Professional, geometric, highly readable
  static const String clean = 'Inter';

  /// Playful theme font - Nunito
  /// Rounded, friendly, approachable
  static const String playful = 'Nunito';
}

/// Line height constants for different text categories
abstract class AppLineHeight {
  /// Display text line height (1.1)
  /// For large hero text and display headings
  static const double display = 1.1;

  /// Headline text line height (1.2)
  /// For page and section headings
  static const double headline = 1.2;

  /// Title text line height (1.3)
  /// For card titles and smaller headings
  static const double title = 1.3;

  /// Body text line height (1.5)
  /// For paragraphs and general content
  static const double body = 1.5;

  /// Label text line height (1.4)
  /// For buttons, chips, and form labels
  static const double label = 1.4;
}

/// Font size constants following Material 3 type scale with refinements
abstract class AppFontSize {
  // Display sizes
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;

  // Headline sizes
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;

  // Title sizes
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;

  // Body sizes
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;

  // Label sizes
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;

  // Semantic sizes
  static const double pageTitle = 32.0;
  static const double sectionTitle = 24.0;
  static const double cardTitle = 18.0;
  static const double caption = 12.0;
  static const double overline = 10.0;
  static const double buttonSmall = 12.0;
  static const double buttonMedium = 14.0;
  static const double buttonLarge = 16.0;
}

/// Letter spacing constants
abstract class AppLetterSpacing {
  // Display
  static const double displayLarge = -1.5;
  static const double displayMedium = -0.5;
  static const double displaySmall = 0.0;

  // Headlines
  static const double headlineLarge = -0.5;
  static const double headlineMedium = -0.25;
  static const double headlineSmall = 0.0;

  // Titles
  static const double titleLarge = 0.0;
  static const double titleMedium = 0.15;
  static const double titleSmall = 0.1;

  // Body
  static const double bodyLarge = 0.5;
  static const double bodyMedium = 0.25;
  static const double bodySmall = 0.4;

  // Labels
  static const double labelLarge = 0.1;
  static const double labelMedium = 0.5;
  static const double labelSmall = 0.5;

  // Playful theme adjustments (tighter for headlines)
  static const double playfulHeadlineLarge = -0.75;
  static const double playfulHeadlineMedium = -0.5;
  static const double playfulHeadlineSmall = -0.25;
}

/// Font weight constants for semantic naming
abstract class AppFontWeight {
  // Clean theme weights
  static const FontWeight displayLight = FontWeight.w300;
  static const FontWeight displayRegular = FontWeight.w400;
  static const FontWeight bodyRegular = FontWeight.w400;
  static const FontWeight labelMedium = FontWeight.w500;
  static const FontWeight headlineSemiBold = FontWeight.w600;
  static const FontWeight titleSemiBold = FontWeight.w600;

  // Playful theme weights (+100 from clean)
  static const FontWeight playfulDisplayLight = FontWeight.w400;
  static const FontWeight playfulDisplayRegular = FontWeight.w500;
  static const FontWeight playfulBodyRegular = FontWeight.w400;
  static const FontWeight playfulLabelMedium = FontWeight.w600;
  static const FontWeight playfulHeadlineSemiBold = FontWeight.w700;
  static const FontWeight playfulTitleSemiBold = FontWeight.w700;
  static const FontWeight playfulExtraBold = FontWeight.w800;
}

// ============================================================================
// TEXT COLOR DEFINITIONS
// ============================================================================

/// Text colors for different semantic purposes
///
/// Usage Guide:
/// - primary: Main content, headings, important text
/// - secondary: Supporting text, descriptions, subtitles
/// - tertiary: Hints, placeholders, less important info
/// - disabled: Inactive or unavailable text
/// - error/success/warning: Status-specific text
abstract class AppTextColors {
  /// Get primary text color (highest emphasis)
  /// Use for: Headings, body text, important labels
  static Color primary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;

  /// Get secondary text color (medium emphasis)
  /// Use for: Subtitles, descriptions, supporting text
  static Color secondary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;

  /// Get tertiary text color (lower emphasis)
  /// Use for: Hints, captions, timestamps
  static Color tertiary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;

  /// Get muted text color (lowest emphasis)
  /// Use for: Placeholder text, very subtle info
  static Color muted({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textMuted : CleanColors.textMuted;

  /// Get disabled text color
  /// Use for: Disabled buttons, inactive states
  static Color disabled({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled;

  /// Get error text color
  /// Use for: Error messages, validation failures
  static Color error({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.error : CleanColors.error;

  /// Get success text color
  /// Use for: Success messages, confirmations
  static Color success({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.success : CleanColors.success;

  /// Get warning text color
  /// Use for: Warning messages, cautions
  static Color warning({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.warning : CleanColors.warning;

  /// Get info text color
  /// Use for: Informational messages, tips
  static Color info({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.info : CleanColors.info;

  /// Get on-primary text color (for text on primary backgrounds)
  static Color onPrimary({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.onPrimary : CleanColors.onPrimary;

  /// Get link text color
  static Color link({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.primary : CleanColors.primary;

  /// Get hint text color (for input placeholders)
  static Color hint({required bool isPlayful}) =>
      isPlayful ? PlayfulColors.hint : CleanColors.hint;
}

// ============================================================================
// MAIN TYPOGRAPHY CLASS
// ============================================================================

/// Centralized typography system for the app.
///
/// Provides:
/// - Complete TextTheme for both Clean and Playful themes
/// - Semantic text styles (pageTitle, cardTitle, etc.)
/// - Input field text styles
/// - Button text styles in multiple sizes
/// - Helper methods for style modifications
///
/// Example usage:
/// ```dart
/// // Get complete text theme
/// final textTheme = AppTypography.getTextTheme(isPlayful: false);
///
/// // Get semantic styles
/// final pageTitleStyle = AppTypography.pageTitle(isPlayful: false);
///
/// // Apply color to existing style
/// final coloredStyle = AppTypography.withColor(style, Colors.blue);
/// ```
abstract class AppTypography {
  // ==========================================================================
  // TEXT THEME GETTERS
  // ==========================================================================

  /// Get the complete TextTheme for the specified theme variant.
  ///
  /// Returns a fully configured TextTheme with all Material 3 text styles.
  /// Use this when setting up ThemeData.
  static TextTheme getTextTheme({required bool isPlayful}) {
    return isPlayful ? _playfulTextTheme : _cleanTextTheme;
  }

  /// Clean theme TextTheme (Inter font)
  static TextTheme get _cleanTextTheme {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        // Display styles - Light weight for elegance
        displayLarge: TextStyle(
          fontSize: AppFontSize.displayLarge,
          fontWeight: AppFontWeight.displayLight,
          letterSpacing: AppLetterSpacing.displayLarge,
          height: AppLineHeight.display,
          color: CleanColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppFontSize.displayMedium,
          fontWeight: AppFontWeight.displayLight,
          letterSpacing: AppLetterSpacing.displayMedium,
          height: AppLineHeight.display,
          color: CleanColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: AppFontSize.displaySmall,
          fontWeight: AppFontWeight.displayRegular,
          letterSpacing: AppLetterSpacing.displaySmall,
          height: AppLineHeight.display,
          color: CleanColors.textPrimary,
        ),

        // Headline styles - SemiBold for emphasis
        headlineLarge: TextStyle(
          fontSize: AppFontSize.headlineLarge,
          fontWeight: AppFontWeight.headlineSemiBold,
          letterSpacing: AppLetterSpacing.headlineLarge,
          height: AppLineHeight.headline,
          color: CleanColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppFontSize.headlineMedium,
          fontWeight: AppFontWeight.headlineSemiBold,
          letterSpacing: AppLetterSpacing.headlineMedium,
          height: AppLineHeight.headline,
          color: CleanColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: AppFontSize.headlineSmall,
          fontWeight: AppFontWeight.headlineSemiBold,
          letterSpacing: AppLetterSpacing.headlineSmall,
          height: AppLineHeight.headline,
          color: CleanColors.textPrimary,
        ),

        // Title styles - SemiBold for structure
        titleLarge: TextStyle(
          fontSize: AppFontSize.titleLarge,
          fontWeight: AppFontWeight.titleSemiBold,
          letterSpacing: AppLetterSpacing.titleLarge,
          height: AppLineHeight.title,
          color: CleanColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppFontSize.titleMedium,
          fontWeight: AppFontWeight.labelMedium,
          letterSpacing: AppLetterSpacing.titleMedium,
          height: AppLineHeight.title,
          color: CleanColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: AppFontSize.titleSmall,
          fontWeight: AppFontWeight.labelMedium,
          letterSpacing: AppLetterSpacing.titleSmall,
          height: AppLineHeight.title,
          color: CleanColors.textPrimary,
        ),

        // Body styles - Regular weight for readability
        bodyLarge: TextStyle(
          fontSize: AppFontSize.bodyLarge,
          fontWeight: AppFontWeight.bodyRegular,
          letterSpacing: AppLetterSpacing.bodyLarge,
          height: AppLineHeight.body,
          color: CleanColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppFontSize.bodyMedium,
          fontWeight: AppFontWeight.bodyRegular,
          letterSpacing: AppLetterSpacing.bodyMedium,
          height: AppLineHeight.body,
          color: CleanColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: AppFontSize.bodySmall,
          fontWeight: AppFontWeight.bodyRegular,
          letterSpacing: AppLetterSpacing.bodySmall,
          height: AppLineHeight.body,
          color: CleanColors.textSecondary,
        ),

        // Label styles - Medium weight for UI elements
        labelLarge: TextStyle(
          fontSize: AppFontSize.labelLarge,
          fontWeight: AppFontWeight.labelMedium,
          letterSpacing: AppLetterSpacing.labelLarge,
          height: AppLineHeight.label,
          color: CleanColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: AppFontSize.labelMedium,
          fontWeight: AppFontWeight.labelMedium,
          letterSpacing: AppLetterSpacing.labelMedium,
          height: AppLineHeight.label,
          color: CleanColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: AppFontSize.labelSmall,
          fontWeight: AppFontWeight.labelMedium,
          letterSpacing: AppLetterSpacing.labelSmall,
          height: AppLineHeight.label,
          color: CleanColors.textSecondary,
        ),
      ),
    );
  }

  /// Playful theme TextTheme (Nunito font)
  /// Features heavier weights and tighter headline spacing
  static TextTheme get _playfulTextTheme {
    return GoogleFonts.nunitoTextTheme(
      const TextTheme(
        // Display styles - Heavier than clean (+100 weight)
        displayLarge: TextStyle(
          fontSize: AppFontSize.displayLarge,
          fontWeight: AppFontWeight.playfulDisplayLight,
          letterSpacing: AppLetterSpacing.displayLarge,
          height: AppLineHeight.display,
          color: PlayfulColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: AppFontSize.displayMedium,
          fontWeight: AppFontWeight.playfulDisplayLight,
          letterSpacing: AppLetterSpacing.displayMedium,
          height: AppLineHeight.display,
          color: PlayfulColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: AppFontSize.displaySmall,
          fontWeight: AppFontWeight.playfulDisplayRegular,
          letterSpacing: AppLetterSpacing.displaySmall,
          height: AppLineHeight.display,
          color: PlayfulColors.textPrimary,
        ),

        // Headline styles - Bold/ExtraBold with tighter spacing
        headlineLarge: TextStyle(
          fontSize: AppFontSize.headlineLarge,
          fontWeight: AppFontWeight.playfulHeadlineSemiBold,
          letterSpacing: AppLetterSpacing.playfulHeadlineLarge,
          height: AppLineHeight.headline,
          color: PlayfulColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: AppFontSize.headlineMedium,
          fontWeight: AppFontWeight.playfulHeadlineSemiBold,
          letterSpacing: AppLetterSpacing.playfulHeadlineMedium,
          height: AppLineHeight.headline,
          color: PlayfulColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: AppFontSize.headlineSmall,
          fontWeight: AppFontWeight.playfulHeadlineSemiBold,
          letterSpacing: AppLetterSpacing.playfulHeadlineSmall,
          height: AppLineHeight.headline,
          color: PlayfulColors.textPrimary,
        ),

        // Title styles - Bold for playful emphasis
        titleLarge: TextStyle(
          fontSize: AppFontSize.titleLarge,
          fontWeight: AppFontWeight.playfulTitleSemiBold,
          letterSpacing: AppLetterSpacing.titleLarge,
          height: AppLineHeight.title,
          color: PlayfulColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: AppFontSize.titleMedium,
          fontWeight: AppFontWeight.playfulLabelMedium,
          letterSpacing: AppLetterSpacing.titleMedium,
          height: AppLineHeight.title,
          color: PlayfulColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: AppFontSize.titleSmall,
          fontWeight: AppFontWeight.playfulLabelMedium,
          letterSpacing: AppLetterSpacing.titleSmall,
          height: AppLineHeight.title,
          color: PlayfulColors.textPrimary,
        ),

        // Body styles - Same weight as clean
        bodyLarge: TextStyle(
          fontSize: AppFontSize.bodyLarge,
          fontWeight: AppFontWeight.playfulBodyRegular,
          letterSpacing: AppLetterSpacing.bodyLarge,
          height: AppLineHeight.body,
          color: PlayfulColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: AppFontSize.bodyMedium,
          fontWeight: AppFontWeight.playfulBodyRegular,
          letterSpacing: AppLetterSpacing.bodyMedium,
          height: AppLineHeight.body,
          color: PlayfulColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: AppFontSize.bodySmall,
          fontWeight: AppFontWeight.playfulBodyRegular,
          letterSpacing: AppLetterSpacing.bodySmall,
          height: AppLineHeight.body,
          color: PlayfulColors.textSecondary,
        ),

        // Label styles - SemiBold for playful UI
        labelLarge: TextStyle(
          fontSize: AppFontSize.labelLarge,
          fontWeight: AppFontWeight.playfulLabelMedium,
          letterSpacing: AppLetterSpacing.labelLarge,
          height: AppLineHeight.label,
          color: PlayfulColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: AppFontSize.labelMedium,
          fontWeight: AppFontWeight.playfulLabelMedium,
          letterSpacing: AppLetterSpacing.labelMedium,
          height: AppLineHeight.label,
          color: PlayfulColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: AppFontSize.labelSmall,
          fontWeight: AppFontWeight.playfulLabelMedium,
          letterSpacing: AppLetterSpacing.labelSmall,
          height: AppLineHeight.label,
          color: PlayfulColors.textSecondary,
        ),
      ),
    );
  }

  // ==========================================================================
  // SEMANTIC TEXT STYLES
  // ==========================================================================

  /// Page title style - Used for main page headings
  /// Example: "Dashboard", "Settings", "My Classes"
  static TextStyle pageTitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.pageTitle,
        fontWeight: AppFontWeight.playfulExtraBold,
        letterSpacing: AppLetterSpacing.playfulHeadlineLarge,
        height: AppLineHeight.headline,
        color: PlayfulColors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.pageTitle,
      fontWeight: AppFontWeight.headlineSemiBold,
      letterSpacing: AppLetterSpacing.headlineLarge,
      height: AppLineHeight.headline,
      color: CleanColors.textPrimary,
    );
  }

  /// Section title style - Used for section headings within pages
  /// Example: "Recent Activity", "Quick Actions", "Today's Schedule"
  static TextStyle sectionTitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.sectionTitle,
        fontWeight: AppFontWeight.playfulHeadlineSemiBold,
        letterSpacing: AppLetterSpacing.playfulHeadlineSmall,
        height: AppLineHeight.headline,
        color: PlayfulColors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.sectionTitle,
      fontWeight: AppFontWeight.headlineSemiBold,
      letterSpacing: AppLetterSpacing.headlineSmall,
      height: AppLineHeight.headline,
      color: CleanColors.textPrimary,
    );
  }

  /// Card title style - Used for titles within cards
  /// Example: "Math Grade", "Student Name", "Class 5A"
  static TextStyle cardTitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.cardTitle,
        fontWeight: AppFontWeight.playfulTitleSemiBold,
        letterSpacing: AppLetterSpacing.titleMedium,
        height: AppLineHeight.title,
        color: PlayfulColors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.cardTitle,
      fontWeight: AppFontWeight.titleSemiBold,
      letterSpacing: AppLetterSpacing.titleMedium,
      height: AppLineHeight.title,
      color: CleanColors.textPrimary,
    );
  }

  /// Primary text style - Main content text
  /// Example: Descriptions, primary info, prominent labels
  static TextStyle primaryText({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyLarge,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodyLarge,
        height: AppLineHeight.body,
        color: PlayfulColors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyLarge,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodyLarge,
      height: AppLineHeight.body,
      color: CleanColors.textPrimary,
    );
  }

  /// Secondary text style - Supporting content text
  /// Example: Subtitles, secondary info, descriptions
  static TextStyle secondaryText({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyMedium,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodyMedium,
        height: AppLineHeight.body,
        color: PlayfulColors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyMedium,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodyMedium,
      height: AppLineHeight.body,
      color: CleanColors.textSecondary,
    );
  }

  /// Tertiary text style - Less prominent text
  /// Example: Hints, timestamps, metadata
  static TextStyle tertiaryText({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodySmall,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodySmall,
        height: AppLineHeight.body,
        color: PlayfulColors.textTertiary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodySmall,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodySmall,
      height: AppLineHeight.body,
      color: CleanColors.textTertiary,
    );
  }

  // ==========================================================================
  // BUTTON TEXT STYLES
  // ==========================================================================

  /// Small button text style
  /// Example: Compact buttons, chip actions
  static TextStyle buttonTextSmall({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.buttonSmall,
        fontWeight: AppFontWeight.playfulLabelMedium,
        letterSpacing: AppLetterSpacing.labelMedium,
        height: AppLineHeight.label,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.buttonSmall,
      fontWeight: AppFontWeight.labelMedium,
      letterSpacing: AppLetterSpacing.labelMedium,
      height: AppLineHeight.label,
    );
  }

  /// Medium button text style (default)
  /// Example: Standard buttons, primary actions
  static TextStyle buttonTextMedium({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.buttonMedium,
        fontWeight: AppFontWeight.playfulTitleSemiBold,
        letterSpacing: AppLetterSpacing.labelLarge,
        height: AppLineHeight.label,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.buttonMedium,
      fontWeight: AppFontWeight.titleSemiBold,
      letterSpacing: AppLetterSpacing.labelLarge,
      height: AppLineHeight.label,
    );
  }

  /// Large button text style
  /// Example: Hero buttons, prominent CTAs
  static TextStyle buttonTextLarge({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.buttonLarge,
        fontWeight: AppFontWeight.playfulTitleSemiBold,
        letterSpacing: AppLetterSpacing.titleMedium,
        height: AppLineHeight.label,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.buttonLarge,
      fontWeight: AppFontWeight.titleSemiBold,
      letterSpacing: AppLetterSpacing.titleMedium,
      height: AppLineHeight.label,
    );
  }

  // ==========================================================================
  // INPUT FIELD TEXT STYLES
  // ==========================================================================

  /// Input text style - Text typed into input fields
  static TextStyle inputText({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyLarge,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodyMedium,
        height: AppLineHeight.body,
        color: PlayfulColors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyLarge,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodyMedium,
      height: AppLineHeight.body,
      color: CleanColors.textPrimary,
    );
  }

  /// Input label style - Label above/inside input fields
  static TextStyle inputLabel({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.labelLarge,
        fontWeight: AppFontWeight.playfulLabelMedium,
        letterSpacing: AppLetterSpacing.labelLarge,
        height: AppLineHeight.label,
        color: PlayfulColors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.labelLarge,
      fontWeight: AppFontWeight.labelMedium,
      letterSpacing: AppLetterSpacing.labelLarge,
      height: AppLineHeight.label,
      color: CleanColors.textSecondary,
    );
  }

  /// Input hint style - Placeholder text in inputs
  static TextStyle inputHint({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyLarge,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodyMedium,
        height: AppLineHeight.body,
        color: PlayfulColors.hint,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyLarge,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodyMedium,
      height: AppLineHeight.body,
      color: CleanColors.hint,
    );
  }

  /// Input error style - Error message below inputs
  static TextStyle inputError({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodySmall,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodySmall,
        height: AppLineHeight.body,
        color: PlayfulColors.error,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodySmall,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodySmall,
      height: AppLineHeight.body,
      color: CleanColors.error,
    );
  }

  // ==========================================================================
  // UTILITY TEXT STYLES
  // ==========================================================================

  /// Caption style - Small descriptive text
  /// Example: Image captions, timestamps, metadata
  static TextStyle caption({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.caption,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodySmall,
        height: AppLineHeight.body,
        color: PlayfulColors.textTertiary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.caption,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodySmall,
      height: AppLineHeight.body,
      color: CleanColors.textTertiary,
    );
  }

  /// Overline style - Uppercase category labels
  /// Example: "CATEGORY", "STATUS", "TYPE"
  static TextStyle overline({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.overline,
        fontWeight: AppFontWeight.playfulLabelMedium,
        letterSpacing: 1.5,
        height: AppLineHeight.label,
        color: PlayfulColors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.overline,
      fontWeight: AppFontWeight.labelMedium,
      letterSpacing: 1.5,
      height: AppLineHeight.label,
      color: CleanColors.textSecondary,
    );
  }

  /// App bar title style
  static TextStyle appBarTitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: AppFontWeight.playfulExtraBold,
        letterSpacing: 0,
        height: AppLineHeight.title,
        color: PlayfulColors.appBarForeground,
      );
    }
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: AppFontWeight.titleSemiBold,
      letterSpacing: 0,
      height: AppLineHeight.title,
      color: CleanColors.appBarForeground,
    );
  }

  /// List tile title style
  static TextStyle listTileTitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyLarge,
        fontWeight: AppFontWeight.playfulLabelMedium,
        letterSpacing: AppLetterSpacing.bodyMedium,
        height: AppLineHeight.body,
        color: PlayfulColors.textPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyLarge,
      fontWeight: AppFontWeight.labelMedium,
      letterSpacing: AppLetterSpacing.bodyMedium,
      height: AppLineHeight.body,
      color: CleanColors.textPrimary,
    );
  }

  /// List tile subtitle style
  static TextStyle listTileSubtitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyMedium,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodyMedium,
        height: AppLineHeight.body,
        color: PlayfulColors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyMedium,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodyMedium,
      height: AppLineHeight.body,
      color: CleanColors.textSecondary,
    );
  }

  /// Bottom navigation label style
  static TextStyle bottomNavLabel({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.labelMedium,
        fontWeight: AppFontWeight.playfulLabelMedium,
        letterSpacing: AppLetterSpacing.labelMedium,
        height: AppLineHeight.label,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.labelMedium,
      fontWeight: AppFontWeight.labelMedium,
      letterSpacing: AppLetterSpacing.labelMedium,
      height: AppLineHeight.label,
    );
  }

  /// Badge text style
  static TextStyle badge({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: AppFontWeight.playfulTitleSemiBold,
        letterSpacing: 0.5,
        height: AppLineHeight.label,
        color: PlayfulColors.onPrimary,
      );
    }
    return GoogleFonts.inter(
      fontSize: 10,
      fontWeight: AppFontWeight.titleSemiBold,
      letterSpacing: 0.5,
      height: AppLineHeight.label,
      color: CleanColors.onPrimary,
    );
  }

  /// Label text style - Used for form labels, field labels, and small UI labels
  /// Example: "Email", "Password", "Username"
  static TextStyle labelText({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.labelMedium,
        fontWeight: AppFontWeight.playfulLabelMedium,
        letterSpacing: AppLetterSpacing.labelMedium,
        height: AppLineHeight.label,
        color: PlayfulColors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.labelMedium,
      fontWeight: AppFontWeight.labelMedium,
      letterSpacing: AppLetterSpacing.labelMedium,
      height: AppLineHeight.label,
      color: CleanColors.textSecondary,
    );
  }

  /// Card subtitle/description style
  static TextStyle cardSubtitle({required bool isPlayful}) {
    if (isPlayful) {
      return GoogleFonts.nunito(
        fontSize: AppFontSize.bodyMedium,
        fontWeight: AppFontWeight.playfulBodyRegular,
        letterSpacing: AppLetterSpacing.bodyMedium,
        height: AppLineHeight.body,
        color: PlayfulColors.textSecondary,
      );
    }
    return GoogleFonts.inter(
      fontSize: AppFontSize.bodyMedium,
      fontWeight: AppFontWeight.bodyRegular,
      letterSpacing: AppLetterSpacing.bodyMedium,
      height: AppLineHeight.body,
      color: CleanColors.textSecondary,
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Apply a color to an existing TextStyle.
  ///
  /// Example:
  /// ```dart
  /// final style = AppTypography.withColor(
  ///   AppTypography.pageTitle(isPlayful: false),
  ///   Colors.blue,
  /// );
  /// ```
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply a font weight to an existing TextStyle.
  ///
  /// Example:
  /// ```dart
  /// final style = AppTypography.withWeight(
  ///   AppTypography.bodyText(isPlayful: false),
  ///   FontWeight.w600,
  /// );
  /// ```
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply both color and weight to an existing TextStyle.
  ///
  /// Example:
  /// ```dart
  /// final style = AppTypography.withColorAndWeight(
  ///   AppTypography.bodyText(isPlayful: false),
  ///   Colors.blue,
  ///   FontWeight.w600,
  /// );
  /// ```
  static TextStyle withColorAndWeight(
    TextStyle style,
    Color color,
    FontWeight weight,
  ) {
    return style.copyWith(color: color, fontWeight: weight);
  }

  /// Apply a custom font size to an existing TextStyle.
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Apply a custom letter spacing to an existing TextStyle.
  static TextStyle withLetterSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }

  /// Apply a custom line height to an existing TextStyle.
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// Create a variant of a style with reduced emphasis (secondary color).
  static TextStyle asSecondary(TextStyle style, {required bool isPlayful}) {
    return style.copyWith(
      color: isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary,
    );
  }

  /// Create a variant of a style with lowest emphasis (tertiary color).
  static TextStyle asTertiary(TextStyle style, {required bool isPlayful}) {
    return style.copyWith(
      color: isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary,
    );
  }

  /// Create a disabled variant of a style.
  static TextStyle asDisabled(TextStyle style, {required bool isPlayful}) {
    return style.copyWith(
      color: isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled,
    );
  }

  /// Create an error variant of a style.
  static TextStyle asError(TextStyle style, {required bool isPlayful}) {
    return style.copyWith(
      color: isPlayful ? PlayfulColors.error : CleanColors.error,
    );
  }

  /// Create a success variant of a style.
  static TextStyle asSuccess(TextStyle style, {required bool isPlayful}) {
    return style.copyWith(
      color: isPlayful ? PlayfulColors.success : CleanColors.success,
    );
  }

  /// Create a warning variant of a style.
  static TextStyle asWarning(TextStyle style, {required bool isPlayful}) {
    return style.copyWith(
      color: isPlayful ? PlayfulColors.warning : CleanColors.warning,
    );
  }

  // ==========================================================================
  // RESPONSIVE TYPOGRAPHY HELPERS
  // ==========================================================================

  /// Get a scaled font size based on screen width.
  /// Useful for responsive typography.
  ///
  /// Example:
  /// ```dart
  /// final fontSize = AppTypography.scaledFontSize(
  ///   baseSize: 16,
  ///   screenWidth: MediaQuery.of(context).size.width,
  /// );
  /// ```
  static double scaledFontSize({
    required double baseSize,
    required double screenWidth,
    double minScale = 0.8,
    double maxScale = 1.2,
  }) {
    const double referenceWidth = 375.0; // iPhone 11 width
    final scale = (screenWidth / referenceWidth).clamp(minScale, maxScale);
    return baseSize * scale;
  }

  /// Get a dynamically scaled TextStyle based on screen width.
  static TextStyle scaled(
    TextStyle style, {
    required double screenWidth,
    double minScale = 0.8,
    double maxScale = 1.2,
  }) {
    final scaledSize = scaledFontSize(
      baseSize: style.fontSize ?? 14,
      screenWidth: screenWidth,
      minScale: minScale,
      maxScale: maxScale,
    );
    return style.copyWith(fontSize: scaledSize);
  }
}

// ============================================================================
// EXTENSION METHODS
// ============================================================================

/// Extension on TextStyle for convenient modifications.
extension TextStyleExtension on TextStyle {
  /// Apply a color to this TextStyle.
  TextStyle withAppColor(Color color) => copyWith(color: color);

  /// Apply a font weight to this TextStyle.
  TextStyle withAppWeight(FontWeight weight) => copyWith(fontWeight: weight);

  /// Apply a font size to this TextStyle.
  TextStyle withAppSize(double size) => copyWith(fontSize: size);

  /// Apply letter spacing to this TextStyle.
  TextStyle withAppLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);

  /// Apply line height to this TextStyle.
  TextStyle withAppHeight(double height) => copyWith(height: height);

  /// Make this style semi-bold.
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make this style bold.
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// Make this style extra-bold.
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);

  /// Make this style medium weight.
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make this style regular weight.
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// Make this style light weight.
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
}

/// Extension on BuildContext for quick typography access.
extension TypographyContext on BuildContext {
  /// Get the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to display large style.
  TextStyle? get displayLarge => textTheme.displayLarge;

  /// Quick access to display medium style.
  TextStyle? get displayMedium => textTheme.displayMedium;

  /// Quick access to display small style.
  TextStyle? get displaySmall => textTheme.displaySmall;

  /// Quick access to headline large style.
  TextStyle? get headlineLarge => textTheme.headlineLarge;

  /// Quick access to headline medium style.
  TextStyle? get headlineMedium => textTheme.headlineMedium;

  /// Quick access to headline small style.
  TextStyle? get headlineSmall => textTheme.headlineSmall;

  /// Quick access to title large style.
  TextStyle? get titleLarge => textTheme.titleLarge;

  /// Quick access to title medium style.
  TextStyle? get titleMedium => textTheme.titleMedium;

  /// Quick access to title small style.
  TextStyle? get titleSmall => textTheme.titleSmall;

  /// Quick access to body large style.
  TextStyle? get bodyLarge => textTheme.bodyLarge;

  /// Quick access to body medium style.
  TextStyle? get bodyMedium => textTheme.bodyMedium;

  /// Quick access to body small style.
  TextStyle? get bodySmall => textTheme.bodySmall;

  /// Quick access to label large style.
  TextStyle? get labelLarge => textTheme.labelLarge;

  /// Quick access to label medium style.
  TextStyle? get labelMedium => textTheme.labelMedium;

  /// Quick access to label small style.
  TextStyle? get labelSmall => textTheme.labelSmall;
}
