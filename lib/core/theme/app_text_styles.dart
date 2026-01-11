import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles for the Clean (Apple-inspired) theme.
///
/// Uses Inter font family, which is similar to SF Pro and provides
/// a professional, clean appearance.
abstract class CleanTextStyles {
  // Base text theme using Inter font
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme(
      const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          height: 1.12,
          color: CleanColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.16,
          color: CleanColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.22,
          color: CleanColors.textPrimary,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.25,
          color: CleanColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.25,
          height: 1.29,
          color: CleanColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
          color: CleanColors.textPrimary,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
          color: CleanColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.5,
          color: CleanColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
          color: CleanColors.textPrimary,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
          color: CleanColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: CleanColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: CleanColors.textSecondary,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
          color: CleanColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
          color: CleanColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
          color: CleanColors.textSecondary,
        ),
      ),
    );
  }

  // Custom text styles for specific use cases
  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.43,
      );

  static TextStyle get inputText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: CleanColors.textPrimary,
      );

  static TextStyle get inputLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: CleanColors.textSecondary,
      );

  static TextStyle get inputHint => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: CleanColors.hint,
      );

  static TextStyle get inputError => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: CleanColors.error,
      );

  static TextStyle get appBarTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.33,
        color: CleanColors.appBarForeground,
      );

  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: CleanColors.textPrimary,
      );

  static TextStyle get cardSubtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: CleanColors.textSecondary,
      );

  static TextStyle get listTileTitle => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
        color: CleanColors.textPrimary,
      );

  static TextStyle get listTileSubtitle => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: CleanColors.textSecondary,
      );

  static TextStyle get bottomNavLabel => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      );
}

/// Text styles for the Playful theme.
///
/// Uses Nunito font family, which has a rounded, friendly appearance
/// perfect for engaging younger students.
abstract class PlayfulTextStyles {
  // Base text theme using Nunito font
  static TextTheme get textTheme {
    return GoogleFonts.nunitoTextTheme(
      const TextTheme(
        // Display styles
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          height: 1.12,
          color: PlayfulColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
          color: PlayfulColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.22,
          color: PlayfulColors.textPrimary,
        ),

        // Headline styles
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.25,
          height: 1.25,
          color: PlayfulColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
          height: 1.29,
          color: PlayfulColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.33,
          color: PlayfulColors.textPrimary,
        ),

        // Title styles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.27,
          color: PlayfulColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.15,
          height: 1.5,
          color: PlayfulColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          height: 1.43,
          color: PlayfulColors.textPrimary,
        ),

        // Body styles
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.15,
          height: 1.5,
          color: PlayfulColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
          color: PlayfulColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
          color: PlayfulColors.textSecondary,
        ),

        // Label styles
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
          color: PlayfulColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.33,
          color: PlayfulColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.45,
          color: PlayfulColors.textSecondary,
        ),
      ),
    );
  }

  // Custom text styles for specific use cases
  static TextStyle get buttonText => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.43,
      );

  static TextStyle get inputText => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: PlayfulColors.textPrimary,
      );

  static TextStyle get inputLabel => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: PlayfulColors.textSecondary,
      );

  static TextStyle get inputHint => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: PlayfulColors.hint,
      );

  static TextStyle get inputError => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: PlayfulColors.error,
      );

  static TextStyle get appBarTitle => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
        height: 1.3,
        color: PlayfulColors.appBarForeground,
      );

  static TextStyle get cardTitle => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
        height: 1.5,
        color: PlayfulColors.textPrimary,
      );

  static TextStyle get cardSubtitle => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: PlayfulColors.textSecondary,
      );

  static TextStyle get listTileTitle => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: PlayfulColors.textPrimary,
      );

  static TextStyle get listTileSubtitle => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: PlayfulColors.textSecondary,
      );

  static TextStyle get bottomNavLabel => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
      );

  // Playful-specific styles
  static TextStyle get funHeading => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
        height: 1.25,
        color: PlayfulColors.primary,
      );

  static TextStyle get badge => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        height: 1.4,
        color: PlayfulColors.onPrimary,
      );
}
