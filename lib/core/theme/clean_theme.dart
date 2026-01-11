import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Clean theme - A minimalist, Apple-inspired professional theme.
///
/// Features:
/// - Deep blue primary color (#1E3A5F)
/// - Pure white background
/// - Light gray surfaces
/// - Subtle shadows and heavy whitespace
/// - 8px border radius (subtle rounding)
/// - Inter font (SF Pro-like)
/// - Professional, corporate aesthetic
class CleanTheme {
  CleanTheme._();

  /// Border radius values for the Clean theme
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  /// Elevation values
  static const double elevationNone = 0.0;
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationLarge = 4.0;

  /// The complete ThemeData for the Clean theme
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: CleanColors.primary,
        onPrimary: CleanColors.onPrimary,
        primaryContainer: CleanColors.primaryLight,
        onPrimaryContainer: CleanColors.onPrimary,
        secondary: CleanColors.secondary,
        onSecondary: CleanColors.onSecondary,
        secondaryContainer: CleanColors.secondaryLight,
        onSecondaryContainer: CleanColors.secondaryDark,
        tertiary: CleanColors.info,
        onTertiary: CleanColors.onInfo,
        error: CleanColors.error,
        onError: CleanColors.onError,
        errorContainer: CleanColors.errorLight,
        onErrorContainer: CleanColors.error,
        surface: CleanColors.surface,
        onSurface: CleanColors.onSurface,
        surfaceContainerHighest: CleanColors.surfaceVariant,
        onSurfaceVariant: CleanColors.onSurfaceVariant,
        outline: CleanColors.border,
        outlineVariant: CleanColors.divider,
        shadow: CleanColors.shadow,
      ),

      // Scaffold
      scaffoldBackgroundColor: CleanColors.background,

      // Text theme
      textTheme: CleanTextStyles.textTheme,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: CleanColors.appBar,
        foregroundColor: CleanColors.appBarForeground,
        elevation: elevationNone,
        scrolledUnderElevation: elevationSmall,
        centerTitle: true,
        titleTextStyle: CleanTextStyles.appBarTitle,
        iconTheme: const IconThemeData(
          color: CleanColors.appBarForeground,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: CleanColors.appBarForeground,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: const CardThemeData(
        color: CleanColors.card,
        elevation: elevationSmall,
        shadowColor: CleanColors.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CleanColors.primary,
          foregroundColor: CleanColors.onPrimary,
          disabledBackgroundColor: CleanColors.disabled,
          disabledForegroundColor: CleanColors.textDisabled,
          elevation: elevationNone,
          shadowColor: CleanColors.shadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: CleanTextStyles.buttonText,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CleanColors.primary,
          disabledForegroundColor: CleanColors.disabled,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          side: const BorderSide(
            color: CleanColors.primary,
            width: 1.5,
          ),
          textStyle: CleanTextStyles.buttonText,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CleanColors.primary,
          disabledForegroundColor: CleanColors.disabled,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(64, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: CleanTextStyles.buttonText,
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CleanColors.primary,
          foregroundColor: CleanColors.onPrimary,
          disabledBackgroundColor: CleanColors.disabled,
          disabledForegroundColor: CleanColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: CleanTextStyles.buttonText,
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: CleanColors.primary,
          disabledForegroundColor: CleanColors.disabled,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CleanColors.primary,
        foregroundColor: CleanColors.onPrimary,
        elevation: elevationMedium,
        focusElevation: elevationLarge,
        hoverElevation: elevationLarge,
        highlightElevation: elevationLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CleanColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: CleanColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: CleanColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(
            color: CleanColors.inputFocusBorder,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: CleanColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(
            color: CleanColors.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: CleanColors.divider),
        ),
        labelStyle: CleanTextStyles.inputLabel,
        hintStyle: CleanTextStyles.inputHint,
        errorStyle: CleanTextStyles.inputError,
        prefixIconColor: CleanColors.textSecondary,
        suffixIconColor: CleanColors.textSecondary,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CleanColors.bottomNavBackground,
        selectedItemColor: CleanColors.bottomNavSelected,
        unselectedItemColor: CleanColors.bottomNavUnselected,
        selectedIconTheme: const IconThemeData(
          size: 24,
          color: CleanColors.bottomNavSelected,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 24,
          color: CleanColors.bottomNavUnselected,
        ),
        selectedLabelStyle: CleanTextStyles.bottomNavLabel,
        unselectedLabelStyle: CleanTextStyles.bottomNavLabel,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: elevationMedium,
      ),

      // Navigation bar theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CleanColors.bottomNavBackground,
        indicatorColor: CleanColors.primary.withValues(alpha: 0.1),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: 24,
              color: CleanColors.primary,
            );
          }
          return const IconThemeData(
            size: 24,
            color: CleanColors.bottomNavUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanTextStyles.bottomNavLabel.copyWith(
              color: CleanColors.primary,
            );
          }
          return CleanTextStyles.bottomNavLabel.copyWith(
            color: CleanColors.bottomNavUnselected,
          );
        }),
        elevation: elevationSmall,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: CleanColors.surface,
        selectedIconTheme: const IconThemeData(
          size: 24,
          color: CleanColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 24,
          color: CleanColors.bottomNavUnselected,
        ),
        selectedLabelTextStyle: CleanTextStyles.bottomNavLabel.copyWith(
          color: CleanColors.primary,
        ),
        unselectedLabelTextStyle: CleanTextStyles.bottomNavLabel.copyWith(
          color: CleanColors.bottomNavUnselected,
        ),
        indicatorColor: CleanColors.primary.withValues(alpha: 0.1),
        useIndicator: true,
        elevation: elevationNone,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: CleanColors.textPrimary,
        size: 24,
      ),

      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: CleanColors.onPrimary,
        size: 24,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: CleanColors.primary.withValues(alpha: 0.08),
        iconColor: CleanColors.textSecondary,
        textColor: CleanColors.textPrimary,
        titleTextStyle: CleanTextStyles.listTileTitle,
        subtitleTextStyle: CleanTextStyles.listTileSubtitle,
        leadingAndTrailingTextStyle: CleanTextStyles.listTileSubtitle,
        minLeadingWidth: 24,
        horizontalTitleGap: 16,
        minVerticalPadding: 8,
        dense: false,
        visualDensity: VisualDensity.standard,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: CleanColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: CleanColors.surface,
        disabledColor: CleanColors.surfaceVariant,
        selectedColor: CleanColors.primary.withValues(alpha: 0.12),
        secondarySelectedColor: CleanColors.secondary.withValues(alpha: 0.12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: const BorderSide(color: CleanColors.border),
        ),
        labelStyle: CleanTextStyles.textTheme.labelMedium,
        secondaryLabelStyle: CleanTextStyles.textTheme.labelMedium,
        brightness: Brightness.light,
        elevation: elevationNone,
        pressElevation: elevationSmall,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: CleanColors.surface,
        elevation: elevationLarge,
        shadowColor: CleanColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        titleTextStyle: CleanTextStyles.textTheme.titleLarge,
        contentTextStyle: CleanTextStyles.textTheme.bodyMedium,
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: CleanColors.surface,
        elevation: elevationLarge,
        shadowColor: CleanColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: CleanColors.border,
        dragHandleSize: const Size(32, 4),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CleanColors.textPrimary,
        contentTextStyle: CleanTextStyles.textTheme.bodyMedium?.copyWith(
          color: CleanColors.background,
        ),
        actionTextColor: CleanColors.primaryLight,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        indicatorColor: CleanColors.primary,
        labelColor: CleanColors.primary,
        unselectedLabelColor: CleanColors.textSecondary,
        labelStyle: CleanTextStyles.textTheme.labelLarge,
        unselectedLabelStyle: CleanTextStyles.textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: CleanColors.divider,
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: CleanColors.textPrimary,
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        textStyle: CleanTextStyles.textTheme.bodySmall?.copyWith(
          color: CleanColors.background,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 2),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CleanColors.primary,
        linearTrackColor: CleanColors.surfaceVariant,
        circularTrackColor: CleanColors.surfaceVariant,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return CleanColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary.withValues(alpha: 0.5);
          }
          return CleanColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return CleanColors.border;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(CleanColors.onPrimary),
        side: const BorderSide(color: CleanColors.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return CleanColors.border;
        }),
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: CleanColors.primary,
        inactiveTrackColor: CleanColors.surfaceVariant,
        thumbColor: CleanColors.primary,
        overlayColor: CleanColors.primary.withValues(alpha: 0.12),
        valueIndicatorColor: CleanColors.primary,
        valueIndicatorTextStyle: CleanTextStyles.textTheme.labelMedium?.copyWith(
          color: CleanColors.onPrimary,
        ),
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: CleanColors.surface,
        elevation: elevationMedium,
        surfaceTintColor: Colors.transparent,
      ),

      // Popup menu theme
      popupMenuTheme: PopupMenuThemeData(
        color: CleanColors.surface,
        elevation: elevationMedium,
        shadowColor: CleanColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: CleanTextStyles.textTheme.bodyMedium,
      ),

      // Badge theme
      badgeTheme: BadgeThemeData(
        backgroundColor: CleanColors.error,
        textColor: CleanColors.onError,
        smallSize: 8,
        largeSize: 16,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        textStyle: CleanTextStyles.textTheme.labelSmall?.copyWith(
          color: CleanColors.onError,
        ),
      ),

      // Search bar theme
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(CleanColors.inputBackground),
        elevation: WidgetStateProperty.all(elevationNone),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            side: const BorderSide(color: CleanColors.inputBorder),
          ),
        ),
        textStyle: WidgetStateProperty.all(CleanTextStyles.inputText),
        hintStyle: WidgetStateProperty.all(CleanTextStyles.inputHint),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),

      // Segmented button theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return CleanColors.primary;
            }
            return CleanColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return CleanColors.onPrimary;
            }
            return CleanColors.textPrimary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: CleanColors.border),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusMedium),
            ),
          ),
        ),
      ),

      // Date picker theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: CleanColors.surface,
        headerBackgroundColor: CleanColors.primary,
        headerForegroundColor: CleanColors.onPrimary,
        dayStyle: CleanTextStyles.textTheme.bodyMedium,
        weekdayStyle: CleanTextStyles.textTheme.labelMedium,
        yearStyle: CleanTextStyles.textTheme.bodyLarge,
        todayBackgroundColor: WidgetStateProperty.all(
          CleanColors.primary.withValues(alpha: 0.1),
        ),
        todayForegroundColor: WidgetStateProperty.all(CleanColors.primary),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.onPrimary;
          }
          return CleanColors.textPrimary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),

      // Time picker theme
      timePickerTheme: TimePickerThemeData(
        backgroundColor: CleanColors.surface,
        hourMinuteColor: CleanColors.surfaceVariant,
        hourMinuteTextColor: CleanColors.textPrimary,
        dayPeriodColor: CleanColors.surfaceVariant,
        dayPeriodTextColor: CleanColors.textPrimary,
        dialBackgroundColor: CleanColors.surfaceVariant,
        dialHandColor: CleanColors.primary,
        dialTextColor: CleanColors.textPrimary,
        entryModeIconColor: CleanColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
    );
  }
}
