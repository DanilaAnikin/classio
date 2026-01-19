import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_typography.dart';
import 'spacing.dart';

/// Playful theme - A fun, engaging theme for younger students.
///
/// Refined and polished while maintaining a friendly, approachable feel.
/// Inspired by modern educational apps like Duolingo and Khan Academy.
///
/// Features:
/// - Refined violet primary (#7C3AED) with warm coral secondary (#EA580C)
/// - Warm stone neutrals for a friendly, inviting feel
/// - Violet-tinted shadows for subtle warmth
/// - More rounded corners (12-20px) for approachability
/// - Nunito font (friendly, rounded) with heavier weights
/// - Premium playful aesthetic - sophisticated, not childish
///
/// Design System Integration:
/// - Colors: PlayfulColors from app_colors.dart
/// - Typography: AppTypography with isPlayful: true
/// - Shadows: AppShadows with isPlayful: true
/// - Radius: AppRadius with isPlayful: true
/// - Spacing: AppSpacing tokens
class PlayfulTheme {
  PlayfulTheme._();

  // ===========================================================================
  // THEME DATA
  // ===========================================================================

  /// The complete ThemeData for the Playful theme
  static ThemeData get themeData {
    final textTheme = AppTypography.getTextTheme(isPlayful: true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // =========================================================================
      // COLOR SCHEME
      // =========================================================================
      colorScheme: const ColorScheme.light(
        // Primary - Refined violet
        primary: PlayfulColors.primary,
        onPrimary: PlayfulColors.onPrimary,
        primaryContainer: PlayfulColors.primarySubtle,
        onPrimaryContainer: PlayfulColors.primaryDark,

        // Secondary - Warm coral
        secondary: PlayfulColors.secondary,
        onSecondary: PlayfulColors.onSecondary,
        secondaryContainer: PlayfulColors.secondarySubtle,
        onSecondaryContainer: PlayfulColors.secondaryDark,

        // Tertiary - Cyan accent
        tertiary: PlayfulColors.accentCyan,
        onTertiary: PlayfulColors.onInfo,

        // Error - Soft coral red (friendlier)
        error: PlayfulColors.error,
        onError: PlayfulColors.onError,
        errorContainer: PlayfulColors.errorMuted,
        onErrorContainer: PlayfulColors.errorPressed,

        // Surface - Warm cream tones
        surface: PlayfulColors.surface,
        onSurface: PlayfulColors.onSurface,
        surfaceContainerHighest: PlayfulColors.surfaceSubtle,
        onSurfaceVariant: PlayfulColors.onSurfaceVariant,

        // Outline - Stone scale borders
        outline: PlayfulColors.border,
        outlineVariant: PlayfulColors.divider,

        // Shadow
        shadow: PlayfulColors.shadow,

        // Scrim
        scrim: PlayfulColors.surfaceOverlay,
      ),

      // Scaffold background - Warm cream
      scaffoldBackgroundColor: PlayfulColors.background,

      // =========================================================================
      // TEXT THEME
      // =========================================================================
      textTheme: textTheme,

      // =========================================================================
      // APPBAR THEME
      // =========================================================================
      // Warm, friendly but still professional
      appBarTheme: AppBarTheme(
        backgroundColor: PlayfulColors.appBar,
        foregroundColor: PlayfulColors.appBarForeground,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.xs,
        centerTitle: true,
        titleTextStyle: AppTypography.appBarTitle(isPlayful: true),
        iconTheme: const IconThemeData(
          color: PlayfulColors.appBarForeground,
          size: AppIconSize.md,
        ),
        actionsIconTheme: const IconThemeData(
          color: PlayfulColors.primary,
          size: AppIconSize.md,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: AppRadius.lgCircular,
          ),
        ),
      ),

      // =========================================================================
      // CARD THEME
      // =========================================================================
      // Slightly more rounded, warmer shadows
      cardTheme: CardThemeData(
        color: PlayfulColors.card,
        elevation: AppElevation.none, // Using custom shadows instead
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card(isPlayful: true), // 16px
          side: const BorderSide(
            color: PlayfulColors.cardBorder,
            width: 1,
          ),
        ),
      ),

      // =========================================================================
      // ELEVATED BUTTON THEME
      // =========================================================================
      // More rounded with subtle gradient feel
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PlayfulColors.primary,
          foregroundColor: PlayfulColors.onPrimary,
          disabledBackgroundColor: PlayfulColors.disabledBackground,
          disabledForegroundColor: PlayfulColors.textDisabled,
          elevation: AppElevation.none,
          shadowColor: PlayfulColors.shadow,
          padding: AppSpacing.buttonInsetsMd,
          minimumSize: const Size(88, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button(isPlayful: true), // 12px
          ),
          textStyle: AppTypography.buttonTextMedium(isPlayful: true),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return PlayfulColors.disabledBackground;
            }
            if (states.contains(WidgetState.pressed)) {
              return PlayfulColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return PlayfulColors.primaryHover;
            }
            return PlayfulColors.primary;
          }),
        ),
      ),

      // =========================================================================
      // FILLED BUTTON THEME
      // =========================================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PlayfulColors.primary,
          foregroundColor: PlayfulColors.onPrimary,
          disabledBackgroundColor: PlayfulColors.disabledBackground,
          disabledForegroundColor: PlayfulColors.textDisabled,
          padding: AppSpacing.buttonInsetsMd,
          minimumSize: const Size(88, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button(isPlayful: true),
          ),
          textStyle: AppTypography.buttonTextMedium(isPlayful: true),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return PlayfulColors.disabledBackground;
            }
            if (states.contains(WidgetState.pressed)) {
              return PlayfulColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return PlayfulColors.primaryHover;
            }
            return PlayfulColors.primary;
          }),
        ),
      ),

      // =========================================================================
      // OUTLINED BUTTON THEME
      // =========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PlayfulColors.primary,
          disabledForegroundColor: PlayfulColors.disabled,
          padding: AppSpacing.buttonInsetsMd,
          minimumSize: const Size(88, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button(isPlayful: true),
          ),
          side: const BorderSide(
            color: PlayfulColors.primary,
            width: 1.5,
          ),
          textStyle: AppTypography.buttonTextMedium(isPlayful: true),
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: PlayfulColors.disabled, width: 1.5);
            }
            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(
                  color: PlayfulColors.primaryPressed, width: 1.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(
                  color: PlayfulColors.primaryHover, width: 1.5);
            }
            return const BorderSide(color: PlayfulColors.primary, width: 1.5);
          }),
        ),
      ),

      // =========================================================================
      // TEXT BUTTON THEME
      // =========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PlayfulColors.primary,
          disabledForegroundColor: PlayfulColors.disabled,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: const Size(64, AppSpacing.buttonHeightCompact),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonSmall(isPlayful: true),
          ),
          textStyle: AppTypography.buttonTextMedium(isPlayful: true),
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return PlayfulColors.disabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return PlayfulColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return PlayfulColors.primaryHover;
            }
            return PlayfulColors.primary;
          }),
        ),
      ),

      // =========================================================================
      // ICON BUTTON THEME
      // =========================================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: PlayfulColors.primary,
          disabledForegroundColor: PlayfulColors.disabled,
          minimumSize:
              const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button(isPlayful: true),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return PlayfulColors.primary
                  .withValues(alpha: AppOpacity.soft);
            }
            if (states.contains(WidgetState.hovered)) {
              return PlayfulColors.primary
                  .withValues(alpha: AppOpacity.light);
            }
            return Colors.transparent;
          }),
        ),
      ),

      // =========================================================================
      // FLOATING ACTION BUTTON THEME
      // =========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PlayfulColors.secondary,
        foregroundColor: PlayfulColors.onSecondary,
        elevation: AppElevation.sm,
        focusElevation: AppElevation.md,
        hoverElevation: AppElevation.md,
        highlightElevation: AppElevation.md,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card(isPlayful: true), // 16px
        ),
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        extendedIconLabelSpacing: AppSpacing.xs,
      ),

      // =========================================================================
      // INPUT DECORATION THEME
      // =========================================================================
      // Softer, more rounded inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PlayfulColors.inputBackground,
        contentPadding: AppSpacing.inputInsets,
        isDense: false,
        border: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: true), // 12px
          borderSide: const BorderSide(
            color: PlayfulColors.inputBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: true),
          borderSide: const BorderSide(
            color: PlayfulColors.inputBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: true),
          borderSide: const BorderSide(
            color: PlayfulColors.inputBorderFocus,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: true),
          borderSide: const BorderSide(
            color: PlayfulColors.inputBorderError,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: true),
          borderSide: const BorderSide(
            color: PlayfulColors.inputBorderError,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input(isPlayful: true),
          borderSide: const BorderSide(
            color: PlayfulColors.divider,
            width: 1.5,
          ),
        ),
        labelStyle: AppTypography.inputLabel(isPlayful: true),
        hintStyle: AppTypography.inputHint(isPlayful: true),
        errorStyle: AppTypography.inputError(isPlayful: true),
        prefixIconColor: PlayfulColors.primary,
        suffixIconColor: PlayfulColors.textSecondary,
        floatingLabelStyle: AppTypography.inputLabel(isPlayful: true).copyWith(
          color: PlayfulColors.primary,
        ),
      ),

      // =========================================================================
      // BOTTOM NAVIGATION BAR THEME
      // =========================================================================
      // Friendly indicators
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: PlayfulColors.bottomNav,
        selectedItemColor: PlayfulColors.bottomNavSelected,
        unselectedItemColor: PlayfulColors.bottomNavUnselected,
        selectedIconTheme: const IconThemeData(
          size: AppIconSize.lg,
          color: PlayfulColors.bottomNavSelected,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppIconSize.md,
          color: PlayfulColors.bottomNavUnselected,
        ),
        selectedLabelStyle:
            AppTypography.bottomNavLabel(isPlayful: true).copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: AppTypography.bottomNavLabel(isPlayful: true),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.sm,
      ),

      // =========================================================================
      // NAVIGATION BAR THEME (Material 3)
      // =========================================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PlayfulColors.bottomNav,
        indicatorColor: PlayfulColors.primarySubtle,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: AppRadius.button(isPlayful: true),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: AppIconSize.lg,
              color: PlayfulColors.primary,
            );
          }
          return const IconThemeData(
            size: AppIconSize.md,
            color: PlayfulColors.bottomNavUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final baseStyle = AppTypography.bottomNavLabel(isPlayful: true);
          if (states.contains(WidgetState.selected)) {
            return baseStyle.copyWith(
              color: PlayfulColors.primary,
              fontWeight: FontWeight.w700,
            );
          }
          return baseStyle.copyWith(
            color: PlayfulColors.bottomNavUnselected,
          );
        }),
        elevation: AppElevation.none,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        surfaceTintColor: Colors.transparent,
      ),

      // =========================================================================
      // NAVIGATION RAIL THEME
      // =========================================================================
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: PlayfulColors.surface,
        selectedIconTheme: const IconThemeData(
          size: AppIconSize.lg,
          color: PlayfulColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppIconSize.md,
          color: PlayfulColors.bottomNavUnselected,
        ),
        selectedLabelTextStyle:
            AppTypography.bottomNavLabel(isPlayful: true).copyWith(
          color: PlayfulColors.primary,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle:
            AppTypography.bottomNavLabel(isPlayful: true).copyWith(
          color: PlayfulColors.bottomNavUnselected,
        ),
        indicatorColor: PlayfulColors.primarySubtle,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: AppRadius.button(isPlayful: true),
        ),
        useIndicator: true,
        elevation: AppElevation.none,
        minWidth: 80,
        groupAlignment: 0,
      ),

      // =========================================================================
      // ICON THEMES
      // =========================================================================
      iconTheme: const IconThemeData(
        color: PlayfulColors.textPrimary,
        size: AppIconSize.md,
      ),
      primaryIconTheme: const IconThemeData(
        color: PlayfulColors.onPrimary,
        size: AppIconSize.md,
      ),

      // =========================================================================
      // LIST TILE THEME
      // =========================================================================
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemInsets,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card(isPlayful: true),
        ),
        tileColor: Colors.transparent,
        selectedTileColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.light),
        iconColor: PlayfulColors.primary,
        textColor: PlayfulColors.textPrimary,
        titleTextStyle: AppTypography.listTileTitle(isPlayful: true),
        subtitleTextStyle: AppTypography.listTileSubtitle(isPlayful: true),
        leadingAndTrailingTextStyle:
            AppTypography.listTileSubtitle(isPlayful: true),
        minLeadingWidth: AppIconSize.lg,
        horizontalTitleGap: AppSpacing.sm,
        minVerticalPadding: AppSpacing.xs,
        dense: false,
        visualDensity: VisualDensity.comfortable,
      ),

      // =========================================================================
      // DIVIDER THEME
      // =========================================================================
      dividerTheme: const DividerThemeData(
        color: PlayfulColors.divider,
        thickness: 1,
        space: 1,
        indent: AppSpacing.md,
        endIndent: AppSpacing.md,
      ),

      // =========================================================================
      // CHIP THEME
      // =========================================================================
      // Pill-shaped for playful aesthetic
      chipTheme: ChipThemeData(
        backgroundColor: PlayfulColors.surface,
        disabledColor: PlayfulColors.surfaceSubtle,
        selectedColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.soft),
        secondarySelectedColor:
            PlayfulColors.secondary.withValues(alpha: AppOpacity.soft),
        padding: AppSpacing.chipInsets,
        labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chip(isPlayful: true), // Pill shape
          side: const BorderSide(color: PlayfulColors.border, width: 1),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        brightness: Brightness.light,
        elevation: AppElevation.none,
        pressElevation: AppElevation.xs,
        iconTheme: const IconThemeData(size: AppIconSize.xs),
      ),

      // =========================================================================
      // DIALOG THEME
      // =========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: PlayfulColors.surface,
        elevation: AppElevation.lg,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog(isPlayful: true), // 20px
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium,
        actionsPadding: AppSpacing.dialogInsets,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
      ),

      // =========================================================================
      // BOTTOM SHEET THEME
      // =========================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: PlayfulColors.surface,
        elevation: AppElevation.lg,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheetRadius,
        ),
        showDragHandle: true,
        dragHandleColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.medium),
        dragHandleSize: const Size(40, 4),
      ),

      // =========================================================================
      // SNACKBAR THEME
      // =========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PlayfulColors.stone800,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: PlayfulColors.stone50,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: PlayfulColors.secondaryLight,
        elevation: AppElevation.md,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.snackbar(isPlayful: true), // 12px
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: AppSpacing.pageInsets,
        width: AppSpacing.maxContentWidth,
      ),

      // =========================================================================
      // TAB BAR THEME
      // =========================================================================
      tabBarTheme: TabBarThemeData(
        indicatorColor: PlayfulColors.primary,
        labelColor: PlayfulColors.primary,
        unselectedLabelColor: PlayfulColors.textSecondary,
        labelStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            width: 3,
            color: PlayfulColors.primary,
          ),
          borderRadius: AppRadius.fullRadius,
        ),
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(
          PlayfulColors.primary.withValues(alpha: AppOpacity.light),
        ),
      ),

      // =========================================================================
      // TOOLTIP THEME
      // =========================================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: PlayfulColors.stone800,
          borderRadius: AppRadius.tooltip(),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: PlayfulColors.stone50,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        waitDuration: AppDuration.medium,
        showDuration: const Duration(seconds: 2),
      ),

      // =========================================================================
      // PROGRESS INDICATOR THEME
      // =========================================================================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: PlayfulColors.primary,
        linearTrackColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.soft),
        circularTrackColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.soft),
        linearMinHeight: 6,
        refreshBackgroundColor: PlayfulColors.surfaceSubtle,
      ),

      // =========================================================================
      // SWITCH THEME
      // =========================================================================
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
          return PlayfulColors.stone300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackOutlineWidth: WidgetStateProperty.all(0),
        thumbIcon: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(
              Icons.check_rounded,
              size: AppIconSize.xs,
              color: PlayfulColors.primary,
            );
          }
          return null;
        }),
        splashRadius: AppSpacing.xl,
      ),

      // =========================================================================
      // CHECKBOX THEME
      // =========================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(PlayfulColors.onPrimary),
        side: const BorderSide(color: PlayfulColors.stone400, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.badge(isPlayful: true), // 6px
        ),
        splashRadius: AppSpacing.xl,
      ),

      // =========================================================================
      // RADIO THEME
      // =========================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return PlayfulColors.primary;
          }
          return PlayfulColors.stone400;
        }),
        splashRadius: AppSpacing.xl,
      ),

      // =========================================================================
      // SLIDER THEME
      // =========================================================================
      sliderTheme: SliderThemeData(
        activeTrackColor: PlayfulColors.primary,
        inactiveTrackColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.soft),
        thumbColor: PlayfulColors.primary,
        overlayColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.soft),
        valueIndicatorColor: PlayfulColors.stone800,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: PlayfulColors.stone50,
          fontWeight: FontWeight.w600,
        ),
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
      ),

      // =========================================================================
      // DRAWER THEME
      // =========================================================================
      drawerTheme: DrawerThemeData(
        backgroundColor: PlayfulColors.surface,
        elevation: AppElevation.md,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: AppRadius.xlCircular,
          ),
        ),
      ),

      // =========================================================================
      // POPUP MENU THEME
      // =========================================================================
      popupMenuTheme: PopupMenuThemeData(
        color: PlayfulColors.surface,
        elevation: AppElevation.md,
        shadowColor: PlayfulColors.shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.popupMenu(isPlayful: true), // 12px
          side: const BorderSide(color: PlayfulColors.cardBorder, width: 1),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),

      // =========================================================================
      // BADGE THEME
      // =========================================================================
      badgeTheme: BadgeThemeData(
        backgroundColor: PlayfulColors.secondary,
        textColor: PlayfulColors.onSecondary,
        smallSize: 8,
        largeSize: AppSpacing.lg,
        padding: AppSpacing.badgeInsets,
        textStyle: AppTypography.badge(isPlayful: true),
      ),

      // =========================================================================
      // SEARCH BAR THEME
      // =========================================================================
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(PlayfulColors.inputBackground),
        elevation: WidgetStateProperty.all(AppElevation.none),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.searchBar(isPlayful: true), // Pill shape
            side: const BorderSide(color: PlayfulColors.inputBorder, width: 1),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          AppTypography.inputText(isPlayful: true),
        ),
        hintStyle: WidgetStateProperty.all(
          AppTypography.inputHint(isPlayful: true),
        ),
        padding: WidgetStateProperty.all(AppSpacing.horizontalInsets),
        constraints: const BoxConstraints(
          minHeight: AppSpacing.inputHeight,
          maxWidth: AppSpacing.maxContentWidth,
        ),
      ),

      // =========================================================================
      // SEGMENTED BUTTON THEME
      // =========================================================================
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
            const BorderSide(color: PlayfulColors.border, width: 1),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppRadius.buttonSmall(isPlayful: true),
            ),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          textStyle: WidgetStateProperty.all(
            AppTypography.buttonTextMedium(isPlayful: true),
          ),
          minimumSize: WidgetStateProperty.all(
            const Size(0, AppSpacing.buttonHeightCompact),
          ),
        ),
      ),

      // =========================================================================
      // DATE PICKER THEME
      // =========================================================================
      datePickerTheme: DatePickerThemeData(
        backgroundColor: PlayfulColors.surface,
        headerBackgroundColor: PlayfulColors.primary,
        headerForegroundColor: PlayfulColors.onPrimary,
        headerHeadlineStyle: textTheme.headlineSmall?.copyWith(
          color: PlayfulColors.onPrimary,
        ),
        dayStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        weekdayStyle: textTheme.labelMedium?.copyWith(
          color: PlayfulColors.primary,
          fontWeight: FontWeight.w600,
        ),
        yearStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        todayBackgroundColor: WidgetStateProperty.all(
          PlayfulColors.secondary.withValues(alpha: AppOpacity.soft),
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
          borderRadius: AppRadius.dialog(isPlayful: true),
        ),
        dayShape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.buttonSmall(isPlayful: true),
          ),
        ),
      ),

      // =========================================================================
      // TIME PICKER THEME
      // =========================================================================
      timePickerTheme: TimePickerThemeData(
        backgroundColor: PlayfulColors.surface,
        hourMinuteColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.light),
        hourMinuteTextColor: PlayfulColors.primary,
        hourMinuteTextStyle: textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        dayPeriodColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.light),
        dayPeriodTextColor: PlayfulColors.primary,
        dayPeriodTextStyle: textTheme.titleMedium,
        dialBackgroundColor:
            PlayfulColors.primary.withValues(alpha: AppOpacity.light),
        dialHandColor: PlayfulColors.primary,
        dialTextColor: PlayfulColors.textPrimary,
        dialTextStyle: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        entryModeIconColor: PlayfulColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog(isPlayful: true),
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: AppRadius.button(isPlayful: true),
        ),
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: AppRadius.button(isPlayful: true),
        ),
      ),

      // =========================================================================
      // EXPANSION TILE THEME
      // =========================================================================
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: AppSpacing.listItemInsets,
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        iconColor: PlayfulColors.primary,
        collapsedIconColor: PlayfulColors.textSecondary,
        textColor: PlayfulColors.textPrimary,
        collapsedTextColor: PlayfulColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card(isPlayful: true),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: AppRadius.card(isPlayful: true),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER METHODS FOR CUSTOM WIDGETS
  // ===========================================================================

  /// Get card decoration with playful shadows
  static BoxDecoration cardDecoration({
    bool isHovered = false,
    bool isPressed = false,
  }) {
    List<BoxShadow> shadows;
    if (isPressed) {
      shadows = AppShadows.cardPressed(isPlayful: true);
    } else if (isHovered) {
      shadows = AppShadows.cardHover(isPlayful: true);
    } else {
      shadows = AppShadows.card(isPlayful: true);
    }

    return BoxDecoration(
      color: PlayfulColors.card,
      borderRadius: AppRadius.card(isPlayful: true),
      border: Border.all(
        color: isHovered
            ? PlayfulColors.cardBorderHover
            : PlayfulColors.cardBorder,
        width: 1,
      ),
      boxShadow: shadows,
    );
  }

  /// Get button decoration with playful shadows and gradient
  static BoxDecoration buttonDecoration({
    bool isHovered = false,
    bool isPressed = false,
    bool useGradient = false,
  }) {
    List<BoxShadow> shadows;
    if (isPressed) {
      shadows = AppShadows.buttonPressed(isPlayful: true);
    } else if (isHovered) {
      shadows = AppShadows.buttonHover(isPlayful: true);
    } else {
      shadows = AppShadows.button(isPlayful: true);
    }

    return BoxDecoration(
      gradient: useGradient ? PlayfulGradients.button : null,
      color: useGradient
          ? null
          : (isPressed
              ? PlayfulColors.primaryPressed
              : isHovered
                  ? PlayfulColors.primaryHover
                  : PlayfulColors.primary),
      borderRadius: AppRadius.button(isPlayful: true),
      boxShadow: shadows,
    );
  }

  /// Get input decoration with focus ring shadow
  static BoxDecoration inputDecoration({
    bool isFocused = false,
    bool hasError = false,
  }) {
    List<BoxShadow> shadows = [];
    if (isFocused) {
      shadows = hasError
          ? AppShadows.inputFocusError(isPlayful: true)
          : AppShadows.inputFocus(isPlayful: true);
    }

    return BoxDecoration(
      color: PlayfulColors.inputBackground,
      borderRadius: AppRadius.input(isPlayful: true),
      border: Border.all(
        color: hasError
            ? PlayfulColors.inputBorderError
            : isFocused
                ? PlayfulColors.inputBorderFocus
                : PlayfulColors.inputBorder,
        width: isFocused ? 2 : 1.5,
      ),
      boxShadow: shadows,
    );
  }

  /// Get dialog/modal decoration with playful shadows
  static BoxDecoration modalDecoration() {
    return BoxDecoration(
      color: PlayfulColors.surface,
      borderRadius: AppRadius.dialog(isPlayful: true),
      boxShadow: AppShadows.modal(isPlayful: true),
    );
  }

  /// Get dropdown/popup decoration with playful shadows
  static BoxDecoration dropdownDecoration() {
    return BoxDecoration(
      color: PlayfulColors.surface,
      borderRadius: AppRadius.popupMenu(isPlayful: true),
      border: Border.all(
        color: PlayfulColors.cardBorder,
        width: 1,
      ),
      boxShadow: AppShadows.dropdown(isPlayful: true),
    );
  }

  /// Get toast/snackbar decoration with playful shadows
  static BoxDecoration toastDecoration() {
    return BoxDecoration(
      color: PlayfulColors.stone800,
      borderRadius: AppRadius.snackbar(isPlayful: true),
      boxShadow: AppShadows.toast(isPlayful: true),
    );
  }

  /// Get avatar decoration with playful shadows
  static BoxDecoration avatarDecoration({double? size}) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: PlayfulColors.primarySubtle,
      boxShadow: AppShadows.avatar(isPlayful: true),
    );
  }
}
