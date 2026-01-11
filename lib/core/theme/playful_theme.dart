import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Playful theme - A fun, engaging theme for younger students.
///
/// Features:
/// - Vibrant purple primary color (#7C3AED)
/// - Coral/Orange secondary (#F97316)
/// - Soft cream background (#FFFBF5)
/// - Colorful gradients and engaging visuals
/// - 16-24px border radius (very rounded)
/// - Nunito font
/// - Fun, playful aesthetic
class PlayfulTheme {
  PlayfulTheme._();

  /// Border radius values for the Playful theme
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusExtraLarge = 32.0;

  /// Elevation values
  static const double elevationNone = 0.0;
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  /// The complete ThemeData for the Playful theme
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: PlayfulColors.primary,
        onPrimary: PlayfulColors.onPrimary,
        primaryContainer: PlayfulColors.primaryLight,
        onPrimaryContainer: PlayfulColors.primaryDark,
        secondary: PlayfulColors.secondary,
        onSecondary: PlayfulColors.onSecondary,
        secondaryContainer: PlayfulColors.secondaryLight,
        onSecondaryContainer: PlayfulColors.secondaryDark,
        tertiary: PlayfulColors.accentCyan,
        onTertiary: PlayfulColors.onInfo,
        error: PlayfulColors.error,
        onError: PlayfulColors.onError,
        errorContainer: PlayfulColors.errorLight,
        onErrorContainer: PlayfulColors.error,
        surface: PlayfulColors.surface,
        onSurface: PlayfulColors.onSurface,
        surfaceContainerHighest: PlayfulColors.surfaceVariant,
        onSurfaceVariant: PlayfulColors.onSurfaceVariant,
        outline: PlayfulColors.border,
        outlineVariant: PlayfulColors.divider,
        shadow: PlayfulColors.shadow,
      ),

      // Scaffold
      scaffoldBackgroundColor: PlayfulColors.background,

      // Text theme
      textTheme: PlayfulTextStyles.textTheme,

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: PlayfulColors.appBar,
        foregroundColor: PlayfulColors.appBarForeground,
        elevation: elevationNone,
        scrolledUnderElevation: elevationSmall,
        centerTitle: true,
        titleTextStyle: PlayfulTextStyles.appBarTitle,
        iconTheme: const IconThemeData(
          color: PlayfulColors.appBarForeground,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: PlayfulColors.primary,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(borderRadiusMedium),
          ),
        ),
      ),

      // Card theme
      cardTheme: const CardThemeData(
        color: PlayfulColors.card,
        elevation: elevationSmall,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PlayfulColors.primary,
          foregroundColor: PlayfulColors.onPrimary,
          disabledBackgroundColor: PlayfulColors.disabled,
          disabledForegroundColor: PlayfulColors.textDisabled,
          elevation: elevationSmall,
          shadowColor: PlayfulColors.shadow,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(88, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          textStyle: PlayfulTextStyles.buttonText,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PlayfulColors.primary,
          disabledForegroundColor: PlayfulColors.disabled,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(88, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          side: const BorderSide(
            color: PlayfulColors.primary,
            width: 2,
          ),
          textStyle: PlayfulTextStyles.buttonText,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PlayfulColors.primary,
          disabledForegroundColor: PlayfulColors.disabled,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(64, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: PlayfulTextStyles.buttonText,
        ),
      ),

      // Filled button theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PlayfulColors.primary,
          foregroundColor: PlayfulColors.onPrimary,
          disabledBackgroundColor: PlayfulColors.disabled,
          disabledForegroundColor: PlayfulColors.textDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          minimumSize: const Size(88, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
          ),
          textStyle: PlayfulTextStyles.buttonText,
        ),
      ),

      // Icon button theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: PlayfulColors.primary,
          disabledForegroundColor: PlayfulColors.disabled,
          minimumSize: const Size(52, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          backgroundColor: PlayfulColors.primary.withValues(alpha: 0.1),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PlayfulColors.secondary,
        foregroundColor: PlayfulColors.onSecondary,
        elevation: elevationMedium,
        focusElevation: elevationLarge,
        hoverElevation: elevationLarge,
        highlightElevation: elevationLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PlayfulColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: PlayfulColors.inputBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: PlayfulColors.inputBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(
            color: PlayfulColors.inputFocusBorder,
            width: 3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: PlayfulColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(
            color: PlayfulColors.error,
            width: 3,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: PlayfulColors.divider, width: 2),
        ),
        labelStyle: PlayfulTextStyles.inputLabel,
        hintStyle: PlayfulTextStyles.inputHint,
        errorStyle: PlayfulTextStyles.inputError,
        prefixIconColor: PlayfulColors.primary,
        suffixIconColor: PlayfulColors.primary,
        floatingLabelStyle: PlayfulTextStyles.inputLabel.copyWith(
          color: PlayfulColors.primary,
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PlayfulColors.bottomNavBackground,
        selectedItemColor: PlayfulColors.bottomNavSelected,
        unselectedItemColor: PlayfulColors.bottomNavUnselected,
        selectedIconTheme: const IconThemeData(
          size: 28,
          color: PlayfulColors.bottomNavSelected,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 24,
          color: PlayfulColors.bottomNavUnselected,
        ),
        selectedLabelStyle: PlayfulTextStyles.bottomNavLabel.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: PlayfulTextStyles.bottomNavLabel,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: elevationMedium,
      ),

      // Navigation bar theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PlayfulColors.bottomNavBackground,
        indicatorColor: PlayfulColors.primary.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: 28,
              color: PlayfulColors.primary,
            );
          }
          return const IconThemeData(
            size: 24,
            color: PlayfulColors.bottomNavUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulTextStyles.bottomNavLabel.copyWith(
              color: PlayfulColors.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return PlayfulTextStyles.bottomNavLabel.copyWith(
            color: PlayfulColors.bottomNavUnselected,
          );
        }),
        elevation: elevationSmall,
        height: 88,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
      ),

      // Navigation rail theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: PlayfulColors.surface,
        selectedIconTheme: const IconThemeData(
          size: 28,
          color: PlayfulColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          size: 24,
          color: PlayfulColors.bottomNavUnselected,
        ),
        selectedLabelTextStyle: PlayfulTextStyles.bottomNavLabel.copyWith(
          color: PlayfulColors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: PlayfulTextStyles.bottomNavLabel.copyWith(
          color: PlayfulColors.bottomNavUnselected,
        ),
        indicatorColor: PlayfulColors.primary.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        useIndicator: true,
        elevation: elevationNone,
        minWidth: 80,
        groupAlignment: 0,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: PlayfulColors.textPrimary,
        size: 24,
      ),

      // Primary icon theme
      primaryIconTheme: const IconThemeData(
        color: PlayfulColors.onPrimary,
        size: 24,
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        tileColor: Colors.transparent,
        selectedTileColor: PlayfulColors.primary.withValues(alpha: 0.1),
        iconColor: PlayfulColors.primary,
        textColor: PlayfulColors.textPrimary,
        titleTextStyle: PlayfulTextStyles.listTileTitle,
        subtitleTextStyle: PlayfulTextStyles.listTileSubtitle,
        leadingAndTrailingTextStyle: PlayfulTextStyles.listTileSubtitle,
        minLeadingWidth: 28,
        horizontalTitleGap: 16,
        minVerticalPadding: 12,
        dense: false,
        visualDensity: VisualDensity.comfortable,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: PlayfulColors.divider,
        thickness: 2,
        space: 2,
        indent: 16,
        endIndent: 16,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: PlayfulColors.surface,
        disabledColor: PlayfulColors.surfaceVariant,
        selectedColor: PlayfulColors.primary.withValues(alpha: 0.15),
        secondarySelectedColor: PlayfulColors.secondary.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: PlayfulColors.border, width: 2),
        ),
        labelStyle: PlayfulTextStyles.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: PlayfulTextStyles.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        brightness: Brightness.light,
        elevation: elevationNone,
        pressElevation: elevationSmall,
        iconTheme: const IconThemeData(size: 18),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: PlayfulColors.surface,
        elevation: elevationLarge,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusExtraLarge),
        ),
        titleTextStyle: PlayfulTextStyles.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: PlayfulTextStyles.textTheme.bodyMedium,
        actionsPadding: const EdgeInsets.all(20),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: PlayfulColors.surface,
        elevation: elevationLarge,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusExtraLarge),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: PlayfulColors.primary.withValues(alpha: 0.3),
        dragHandleSize: const Size(48, 6),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PlayfulColors.primary,
        contentTextStyle: PlayfulTextStyles.textTheme.bodyMedium?.copyWith(
          color: PlayfulColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: PlayfulColors.secondaryLight,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
      ),

      // Tab bar theme
      tabBarTheme: TabBarThemeData(
        indicatorColor: PlayfulColors.primary,
        labelColor: PlayfulColors.primary,
        unselectedLabelColor: PlayfulColors.textSecondary,
        labelStyle: PlayfulTextStyles.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: PlayfulTextStyles.textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            width: 4,
            color: PlayfulColors.primary,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        dividerColor: Colors.transparent,
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: PlayfulColors.primary,
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
        textStyle: PlayfulTextStyles.textTheme.bodySmall?.copyWith(
          color: PlayfulColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        waitDuration: const Duration(milliseconds: 400),
        showDuration: const Duration(seconds: 2),
      ),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: PlayfulColors.primary,
        linearTrackColor: PlayfulColors.primary.withValues(alpha: 0.2),
        circularTrackColor: PlayfulColors.primary.withValues(alpha: 0.2),
        linearMinHeight: 8,
        refreshBackgroundColor: PlayfulColors.surfaceVariant,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.onPrimary;
          }
          return PlayfulColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.primary;
          }
          return PlayfulColors.border;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return PlayfulColors.border;
        }),
        trackOutlineWidth: WidgetStateProperty.all(2),
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(
              Icons.check_rounded,
              size: 14,
              color: PlayfulColors.primary,
            );
          }
          return null;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(PlayfulColors.onPrimary),
        side: const BorderSide(color: PlayfulColors.border, width: 2.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        splashRadius: 24,
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.primary;
          }
          return PlayfulColors.border;
        }),
        splashRadius: 24,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: PlayfulColors.primary,
        inactiveTrackColor: PlayfulColors.primary.withValues(alpha: 0.2),
        thumbColor: PlayfulColors.primary,
        overlayColor: PlayfulColors.primary.withValues(alpha: 0.15),
        valueIndicatorColor: PlayfulColors.primary,
        valueIndicatorTextStyle: PlayfulTextStyles.textTheme.labelMedium?.copyWith(
          color: PlayfulColors.onPrimary,
          fontWeight: FontWeight.w700,
        ),
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      ),

      // Drawer theme
      drawerTheme: DrawerThemeData(
        backgroundColor: PlayfulColors.surface,
        elevation: elevationMedium,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(borderRadiusExtraLarge),
          ),
        ),
      ),

      // Popup menu theme
      popupMenuTheme: PopupMenuThemeData(
        color: PlayfulColors.surface,
        elevation: elevationMedium,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: PlayfulTextStyles.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // Badge theme
      badgeTheme: BadgeThemeData(
        backgroundColor: PlayfulColors.secondary,
        textColor: PlayfulColors.onSecondary,
        smallSize: 10,
        largeSize: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        textStyle: PlayfulTextStyles.badge,
      ),

      // Search bar theme
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(PlayfulColors.inputBackground),
        elevation: WidgetStateProperty.all(elevationNone),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusLarge),
            side: const BorderSide(color: PlayfulColors.inputBorder, width: 2),
          ),
        ),
        textStyle: WidgetStateProperty.all(PlayfulTextStyles.inputText),
        hintStyle: WidgetStateProperty.all(PlayfulTextStyles.inputHint),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),

      // Segmented button theme
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PlayfulColors.primary;
            }
            return PlayfulColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return PlayfulColors.onPrimary;
            }
            return PlayfulColors.textPrimary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: PlayfulColors.border, width: 2),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusLarge),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          textStyle: WidgetStateProperty.all(
            PlayfulTextStyles.buttonText,
          ),
        ),
      ),

      // Date picker theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: PlayfulColors.surface,
        headerBackgroundColor: PlayfulColors.primary,
        headerForegroundColor: PlayfulColors.onPrimary,
        headerHeadlineStyle: PlayfulTextStyles.textTheme.headlineSmall?.copyWith(
          color: PlayfulColors.onPrimary,
        ),
        dayStyle: PlayfulTextStyles.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        weekdayStyle: PlayfulTextStyles.textTheme.labelMedium?.copyWith(
          color: PlayfulColors.primary,
          fontWeight: FontWeight.w700,
        ),
        yearStyle: PlayfulTextStyles.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        todayBackgroundColor: WidgetStateProperty.all(
          PlayfulColors.secondary.withValues(alpha: 0.2),
        ),
        todayForegroundColor: WidgetStateProperty.all(PlayfulColors.secondary),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.primary;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.onPrimary;
          }
          return PlayfulColors.textPrimary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusExtraLarge),
        ),
        dayShape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
        ),
      ),

      // Time picker theme
      timePickerTheme: TimePickerThemeData(
        backgroundColor: PlayfulColors.surface,
        hourMinuteColor: PlayfulColors.primary.withValues(alpha: 0.1),
        hourMinuteTextColor: PlayfulColors.primary,
        hourMinuteTextStyle: PlayfulTextStyles.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        dayPeriodColor: PlayfulColors.primary.withValues(alpha: 0.1),
        dayPeriodTextColor: PlayfulColors.primary,
        dayPeriodTextStyle: PlayfulTextStyles.textTheme.titleMedium,
        dialBackgroundColor: PlayfulColors.primary.withValues(alpha: 0.1),
        dialHandColor: PlayfulColors.primary,
        dialTextColor: PlayfulColors.textPrimary,
        dialTextStyle: PlayfulTextStyles.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        entryModeIconColor: PlayfulColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusExtraLarge),
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),

      // Expansion tile theme
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        iconColor: PlayfulColors.primary,
        collapsedIconColor: PlayfulColors.textSecondary,
        textColor: PlayfulColors.textPrimary,
        collapsedTextColor: PlayfulColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
    );
  }
}
