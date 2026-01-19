import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_shadows.dart';
import 'app_typography.dart';
import 'spacing.dart';

/// Clean theme - A minimalist, enterprise-grade professional theme.
///
/// Inspired by Linear, Vercel, Stripe, and Apple design systems.
///
/// Features:
/// - Sophisticated blue primary (#0066FF)
/// - Off-white background (never pure white)
/// - Layered surface hierarchy for depth
/// - Subtle, multi-layer diffused shadows
/// - 8px button / 12px card border radius
/// - Inter font (similar to SF Pro)
/// - Premium, corporate aesthetic
///
/// Design Tokens Used:
/// - Colors: CleanColors from app_colors.dart
/// - Typography: AppTypography.getTextTheme(isPlayful: false)
/// - Shadows: AppShadows.clean* variants
/// - Radius: AppRadius.clean* variants
/// - Spacing: AppSpacing constants
class CleanTheme {
  CleanTheme._();

  // ============================================================================
  // THEME DATA
  // ============================================================================

  /// The complete ThemeData for the Clean theme
  static ThemeData get themeData {
    final textTheme = AppTypography.getTextTheme(isPlayful: false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ==========================================================================
      // COLOR SCHEME
      // ==========================================================================
      colorScheme: const ColorScheme.light(
        // Primary colors
        primary: CleanColors.primary,
        onPrimary: CleanColors.onPrimary,
        primaryContainer: CleanColors.primarySubtle,
        onPrimaryContainer: CleanColors.primaryDark,

        // Secondary colors
        secondary: CleanColors.secondary,
        onSecondary: CleanColors.onSecondary,
        secondaryContainer: CleanColors.secondarySubtle,
        onSecondaryContainer: CleanColors.secondaryDark,

        // Tertiary/Accent colors
        tertiary: CleanColors.info,
        onTertiary: CleanColors.onInfo,
        tertiaryContainer: CleanColors.infoMuted,
        onTertiaryContainer: CleanColors.info,

        // Error colors
        error: CleanColors.error,
        onError: CleanColors.onError,
        errorContainer: CleanColors.errorMuted,
        onErrorContainer: CleanColors.error,

        // Surface colors - using the new elevation hierarchy
        surface: CleanColors.surface,
        onSurface: CleanColors.onSurface,
        surfaceContainerLowest: CleanColors.background,
        surfaceContainerLow: CleanColors.surfaceMuted,
        surfaceContainer: CleanColors.surface,
        surfaceContainerHigh: CleanColors.surfaceSubtle,
        surfaceContainerHighest: CleanColors.surfaceElevated,
        onSurfaceVariant: CleanColors.onSurfaceVariant,

        // Outline colors
        outline: CleanColors.border,
        outlineVariant: CleanColors.borderSubtle,

        // Other
        shadow: CleanColors.shadowColor,
        scrim: CleanColors.surfaceOverlay,
        inverseSurface: CleanColors.slate800,
        onInverseSurface: CleanColors.slate50,
        inversePrimary: CleanColors.primaryLight,
      ),

      // Scaffold
      scaffoldBackgroundColor: CleanColors.background,

      // Text theme
      textTheme: textTheme,

      // ==========================================================================
      // APP BAR THEME - Clean, subtle, professional
      // ==========================================================================
      appBarTheme: AppBarTheme(
        backgroundColor: CleanColors.appBar,
        foregroundColor: CleanColors.appBarForeground,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.xs,
        centerTitle: true,
        titleTextStyle: AppTypography.appBarTitle(isPlayful: false),
        toolbarHeight: AppSpacing.appBarHeight,
        iconTheme: const IconThemeData(
          color: CleanColors.appBarForeground,
          size: AppIconSize.appBar,
        ),
        actionsIconTheme: const IconThemeData(
          color: CleanColors.appBarForeground,
          size: AppIconSize.appBar,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: CleanColors.surface,
        ),
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: CleanColors.appBarBorder,
            width: 1,
          ),
        ),
      ),

      // ==========================================================================
      // CARD THEME - Subtle border + soft shadow
      // ==========================================================================
      cardTheme: CardThemeData(
        color: CleanColors.card,
        elevation: AppElevation.none, // Using custom shadows instead
        shadowColor: CleanColors.shadowMedium,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cleanCardRadius,
          side: const BorderSide(
            color: CleanColors.cardBorder,
            width: 1,
          ),
        ),
      ),

      // ==========================================================================
      // ELEVATED BUTTON THEME - Primary action button
      // ==========================================================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CleanColors.primary,
          foregroundColor: CleanColors.onPrimary,
          disabledBackgroundColor: CleanColors.disabledBackground,
          disabledForegroundColor: CleanColors.disabled,
          elevation: AppElevation.none,
          shadowColor: CleanColors.shadow,
          padding: AppSpacing.buttonInsetsMd,
          minimumSize: Size(88, AppSpacing.buttonHeight),
          shape: AppRadius.cleanButtonShape,
          textStyle: AppTypography.buttonTextMedium(isPlayful: false),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return CleanColors.disabledBackground;
            }
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.primaryHover;
            }
            return CleanColors.primary;
          }),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppElevation.none;
            }
            if (states.contains(WidgetState.hovered)) {
              return AppElevation.xs;
            }
            return AppElevation.none;
          }),
        ),
      ),

      // ==========================================================================
      // FILLED BUTTON THEME - Secondary prominent action
      // ==========================================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: CleanColors.primary,
          foregroundColor: CleanColors.onPrimary,
          disabledBackgroundColor: CleanColors.disabledBackground,
          disabledForegroundColor: CleanColors.disabled,
          padding: AppSpacing.buttonInsetsMd,
          minimumSize: Size(88, AppSpacing.buttonHeight),
          shape: AppRadius.cleanButtonShape,
          textStyle: AppTypography.buttonTextMedium(isPlayful: false),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return CleanColors.disabledBackground;
            }
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.primaryHover;
            }
            return CleanColors.primary;
          }),
        ),
      ),

      // ==========================================================================
      // OUTLINED BUTTON THEME - Secondary action with border
      // ==========================================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CleanColors.primary,
          disabledForegroundColor: CleanColors.disabled,
          padding: AppSpacing.buttonInsetsMd,
          minimumSize: Size(88, AppSpacing.buttonHeight),
          shape: AppRadius.cleanButtonShape,
          side: const BorderSide(
            color: CleanColors.primary,
            width: 1.5,
          ),
          textStyle: AppTypography.buttonTextMedium(isPlayful: false),
        ).copyWith(
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return const BorderSide(color: CleanColors.disabled, width: 1.5);
            }
            if (states.contains(WidgetState.pressed)) {
              return const BorderSide(
                  color: CleanColors.primaryPressed, width: 1.5);
            }
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(
                  color: CleanColors.primaryHover, width: 1.5);
            }
            return const BorderSide(color: CleanColors.primary, width: 1.5);
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.primaryMuted;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.primaryMuted;
            }
            return Colors.transparent;
          }),
        ),
      ),

      // ==========================================================================
      // TEXT BUTTON THEME - Tertiary action, minimal visual weight
      // ==========================================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CleanColors.primary,
          disabledForegroundColor: CleanColors.disabled,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size(64, AppSpacing.buttonHeightCompact),
          shape: AppRadius.cleanButtonShape,
          textStyle: AppTypography.buttonTextMedium(isPlayful: false),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.primaryMuted;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.hoverOverlay;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return CleanColors.disabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.primaryPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.primaryHover;
            }
            return CleanColors.primary;
          }),
        ),
      ),

      // ==========================================================================
      // ICON BUTTON THEME
      // ==========================================================================
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: CleanColors.textSecondary,
          disabledForegroundColor: CleanColors.disabled,
          minimumSize: Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          shape: AppRadius.cleanButtonShape,
          padding: AppSpacing.insets8,
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.pressedOverlay;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.hoverOverlay;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return CleanColors.disabled;
            }
            if (states.contains(WidgetState.selected)) {
              return CleanColors.primary;
            }
            return CleanColors.textSecondary;
          }),
        ),
      ),

      // ==========================================================================
      // FLOATING ACTION BUTTON THEME
      // ==========================================================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: CleanColors.primary,
        foregroundColor: CleanColors.onPrimary,
        hoverColor: CleanColors.primaryHover,
        focusColor: CleanColors.primaryHover,
        splashColor: CleanColors.primaryPressed,
        elevation: AppElevation.md,
        focusElevation: AppElevation.lg,
        hoverElevation: AppElevation.lg,
        highlightElevation: AppElevation.sm,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlRadius,
        ),
      ),

      // ==========================================================================
      // INPUT DECORATION THEME - Clean borders, proper focus states
      // ==========================================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CleanColors.inputBackground,
        contentPadding: AppSpacing.inputInsets,
        constraints: BoxConstraints(minHeight: AppSpacing.inputHeight),

        // Border styles
        border: OutlineInputBorder(
          borderRadius: AppRadius.cleanInputRadius,
          borderSide: const BorderSide(color: CleanColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.cleanInputRadius,
          borderSide: const BorderSide(color: CleanColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.cleanInputRadius,
          borderSide: const BorderSide(
            color: CleanColors.inputBorderFocus,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.cleanInputRadius,
          borderSide: const BorderSide(color: CleanColors.inputBorderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.cleanInputRadius,
          borderSide: const BorderSide(
            color: CleanColors.inputBorderError,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.cleanInputRadius,
          borderSide: const BorderSide(color: CleanColors.borderSubtle),
        ),

        // Text styles
        labelStyle: AppTypography.inputLabel(isPlayful: false),
        floatingLabelStyle: AppTypography.inputLabel(isPlayful: false).copyWith(
          color: CleanColors.primary,
        ),
        hintStyle: AppTypography.inputHint(isPlayful: false),
        errorStyle: AppTypography.inputError(isPlayful: false),
        helperStyle: AppTypography.caption(isPlayful: false),
        counterStyle: AppTypography.caption(isPlayful: false),

        // Icon colors
        prefixIconColor: CleanColors.textSecondary,
        suffixIconColor: CleanColors.textSecondary,
        iconColor: CleanColors.textSecondary,

        // Other
        isDense: false,
        isCollapsed: false,
        alignLabelWithHint: true,
      ),

      // ==========================================================================
      // BOTTOM NAVIGATION BAR THEME
      // ==========================================================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CleanColors.bottomNav,
        selectedItemColor: CleanColors.bottomNavSelected,
        unselectedItemColor: CleanColors.bottomNavUnselected,
        selectedIconTheme: const IconThemeData(
          size: AppIconSize.navigation,
          color: CleanColors.bottomNavSelected,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppIconSize.navigation,
          color: CleanColors.bottomNavUnselected,
        ),
        selectedLabelStyle: AppTypography.bottomNavLabel(isPlayful: false),
        unselectedLabelStyle: AppTypography.bottomNavLabel(isPlayful: false),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.none,
      ),

      // ==========================================================================
      // NAVIGATION BAR THEME (Material 3)
      // ==========================================================================
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CleanColors.bottomNav,
        indicatorColor: CleanColors.primarySubtle,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.none,
        height: AppSpacing.navBarHeight + AppSpacing.xs,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: AppIconSize.navigation,
              color: CleanColors.primary,
            );
          }
          return const IconThemeData(
            size: AppIconSize.navigation,
            color: CleanColors.bottomNavUnselected,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final baseStyle = AppTypography.bottomNavLabel(isPlayful: false);
          if (states.contains(WidgetState.selected)) {
            return baseStyle.copyWith(color: CleanColors.primary);
          }
          return baseStyle.copyWith(color: CleanColors.bottomNavUnselected);
        }),
      ),

      // ==========================================================================
      // NAVIGATION RAIL THEME
      // ==========================================================================
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: CleanColors.sidebarBackground,
        selectedIconTheme: const IconThemeData(
          size: AppIconSize.navigation,
          color: CleanColors.primary,
        ),
        unselectedIconTheme: const IconThemeData(
          size: AppIconSize.navigation,
          color: CleanColors.bottomNavUnselected,
        ),
        selectedLabelTextStyle:
            AppTypography.bottomNavLabel(isPlayful: false).copyWith(
          color: CleanColors.primary,
        ),
        unselectedLabelTextStyle:
            AppTypography.bottomNavLabel(isPlayful: false).copyWith(
          color: CleanColors.bottomNavUnselected,
        ),
        indicatorColor: CleanColors.sidebarItemActive,
        useIndicator: true,
        elevation: AppElevation.none,
        minWidth: 72,
        minExtendedWidth: 256,
        groupAlignment: 0,
      ),

      // ==========================================================================
      // NAVIGATION DRAWER THEME
      // ==========================================================================
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: CleanColors.surface,
        elevation: AppElevation.none,
        surfaceTintColor: Colors.transparent,
        indicatorColor: CleanColors.sidebarItemActive,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
        tileHeight: AppSpacing.minTouchTarget,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final baseStyle =
              AppTypography.listTileTitle(isPlayful: false);
          if (states.contains(WidgetState.selected)) {
            return baseStyle.copyWith(color: CleanColors.primary);
          }
          return baseStyle;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              size: AppIconSize.listTile,
              color: CleanColors.primary,
            );
          }
          return const IconThemeData(
            size: AppIconSize.listTile,
            color: CleanColors.textSecondary,
          );
        }),
      ),

      // ==========================================================================
      // DRAWER THEME
      // ==========================================================================
      drawerTheme: DrawerThemeData(
        backgroundColor: CleanColors.surface,
        elevation: AppElevation.lg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.rightXl,
        ),
        width: 304,
      ),

      // ==========================================================================
      // DIALOG THEME
      // ==========================================================================
      dialogTheme: DialogThemeData(
        backgroundColor: CleanColors.surfaceElevated,
        elevation: AppElevation.xl,
        shadowColor: CleanColors.shadowStrong,
        surfaceTintColor: Colors.transparent,
        shape: AppRadius.cleanDialogShape,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        actionsPadding: EdgeInsets.only(
          left: AppSpacing.dialogPadding,
          right: AppSpacing.dialogPadding,
          bottom: AppSpacing.md,
        ),
        insetPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
      ),

      // ==========================================================================
      // BOTTOM SHEET THEME
      // ==========================================================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: CleanColors.surfaceElevated,
        elevation: AppElevation.xl,
        shadowColor: CleanColors.shadowStrong,
        surfaceTintColor: Colors.transparent,
        shape: AppRadius.bottomSheetShape,
        showDragHandle: true,
        dragHandleColor: CleanColors.slate300,
        dragHandleSize: Size(AppSpacing.xxl, AppSpacing.xxs),
        constraints: BoxConstraints(
          maxWidth: AppSpacing.maxContentWidth,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ==========================================================================
      // SNACKBAR THEME - Modern floating style
      // ==========================================================================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: CleanColors.slate800,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: CleanColors.textInverse,
        ),
        actionTextColor: CleanColors.primaryLight,
        disabledActionTextColor: CleanColors.slate400,
        elevation: AppElevation.md,
        shape: AppRadius.cleanSnackbarShape,
        behavior: SnackBarBehavior.floating,
        insetPadding: AppSpacing.pageInsets,
        width: null, // Responsive width
        actionOverflowThreshold: 0.25,
        showCloseIcon: false,
        closeIconColor: CleanColors.slate400,
      ),

      // ==========================================================================
      // TAB BAR THEME
      // ==========================================================================
      tabBarTheme: TabBarThemeData(
        indicatorColor: CleanColors.primary,
        labelColor: CleanColors.primary,
        unselectedLabelColor: CleanColors.textSecondary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: CleanColors.divider,
        dividerHeight: 1,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.hoverOverlay;
          }
          return Colors.transparent;
        }),
        labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(
            color: CleanColors.primary,
            width: 2,
          ),
          borderRadius: AppRadius.topOnly(2),
        ),
      ),

      // ==========================================================================
      // CHIP THEME - Pill-shaped with subtle border
      // ==========================================================================
      chipTheme: ChipThemeData(
        backgroundColor: CleanColors.surface,
        disabledColor: CleanColors.disabledBackground,
        selectedColor: CleanColors.primarySubtle,
        secondarySelectedColor: CleanColors.secondarySubtle,
        padding: AppSpacing.chipInsets,
        labelPadding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.fullRadius,
          side: const BorderSide(color: CleanColors.border, width: 1),
        ),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium,
        brightness: Brightness.light,
        elevation: AppElevation.none,
        pressElevation: AppElevation.none,
        showCheckmark: true,
        checkmarkColor: CleanColors.primary,
        deleteIconColor: CleanColors.textSecondary,
        iconTheme: const IconThemeData(
          size: AppIconSize.sm,
          color: CleanColors.textSecondary,
        ),
        surfaceTintColor: Colors.transparent,
      ),

      // ==========================================================================
      // LIST TILE THEME
      // ==========================================================================
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listItemInsets,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
        tileColor: Colors.transparent,
        selectedTileColor: CleanColors.primaryMuted,
        selectedColor: CleanColors.primary,
        iconColor: CleanColors.textSecondary,
        textColor: CleanColors.textPrimary,
        titleTextStyle: AppTypography.listTileTitle(isPlayful: false),
        subtitleTextStyle: AppTypography.listTileSubtitle(isPlayful: false),
        leadingAndTrailingTextStyle:
            AppTypography.listTileSubtitle(isPlayful: false),
        minLeadingWidth: AppIconSize.listTile,
        horizontalTitleGap: AppSpacing.sm,
        minVerticalPadding: AppSpacing.xs,
        dense: false,
        visualDensity: VisualDensity.comfortable,
        enableFeedback: true,
      ),

      // ==========================================================================
      // DIVIDER THEME
      // ==========================================================================
      dividerTheme: const DividerThemeData(
        color: CleanColors.divider,
        thickness: 1,
        space: 1,
        indent: 0,
        endIndent: 0,
      ),

      // ==========================================================================
      // ICON THEME
      // ==========================================================================
      iconTheme: const IconThemeData(
        color: CleanColors.textPrimary,
        size: AppIconSize.md,
      ),

      // ==========================================================================
      // PRIMARY ICON THEME
      // ==========================================================================
      primaryIconTheme: const IconThemeData(
        color: CleanColors.onPrimary,
        size: AppIconSize.md,
      ),

      // ==========================================================================
      // TOOLTIP THEME
      // ==========================================================================
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: CleanColors.slate800,
          borderRadius: AppRadius.tooltipRadius,
          boxShadow: AppShadows.tooltip(isPlayful: false),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: CleanColors.textInverse,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        margin: AppSpacing.insets8,
        waitDuration: AppDuration.slower,
        showDuration: const Duration(seconds: 2),
        preferBelow: true,
        verticalOffset: AppSpacing.xs,
      ),

      // ==========================================================================
      // PROGRESS INDICATOR THEME
      // ==========================================================================
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: CleanColors.primary,
        linearTrackColor: CleanColors.slate200,
        circularTrackColor: CleanColors.slate200,
        refreshBackgroundColor: CleanColors.surface,
        linearMinHeight: 4,
      ),

      // ==========================================================================
      // SWITCH THEME
      // ==========================================================================
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.slate300;
          }
          if (states.contains(WidgetState.selected)) {
            return CleanColors.onPrimary;
          }
          return CleanColors.slate400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.slate100;
          }
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return CleanColors.slate200;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.slate200;
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return CleanColors.slate300;
        }),
        trackOutlineWidth: WidgetStateProperty.all(1),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.soft);
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.light);
          }
          if (states.contains(WidgetState.focused)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.light);
          }
          return Colors.transparent;
        }),
        splashRadius: 20,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      // ==========================================================================
      // CHECKBOX THEME
      // ==========================================================================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.disabledBackground;
          }
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(CleanColors.onPrimary),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: CleanColors.slate200, width: 1.5);
          }
          if (states.contains(WidgetState.selected)) {
            return const BorderSide(color: CleanColors.primary, width: 1.5);
          }
          if (states.contains(WidgetState.error)) {
            return const BorderSide(color: CleanColors.error, width: 1.5);
          }
          return const BorderSide(color: CleanColors.slate300, width: 1.5);
        }),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xsRadius,
        ),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.soft);
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.light);
          }
          if (states.contains(WidgetState.focused)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.light);
          }
          return Colors.transparent;
        }),
        splashRadius: 20,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.comfortable,
      ),

      // ==========================================================================
      // RADIO THEME
      // ==========================================================================
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.slate300;
          }
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return CleanColors.slate400;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.soft);
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.light);
          }
          if (states.contains(WidgetState.focused)) {
            return CleanColors.primary.withValues(alpha: AppOpacity.light);
          }
          return Colors.transparent;
        }),
        splashRadius: 20,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        visualDensity: VisualDensity.comfortable,
      ),

      // ==========================================================================
      // SLIDER THEME
      // ==========================================================================
      sliderTheme: SliderThemeData(
        activeTrackColor: CleanColors.primary,
        inactiveTrackColor: CleanColors.slate200,
        disabledActiveTrackColor: CleanColors.slate300,
        disabledInactiveTrackColor: CleanColors.slate100,
        thumbColor: CleanColors.primary,
        disabledThumbColor: CleanColors.slate300,
        overlayColor: CleanColors.primary.withValues(alpha: AppOpacity.soft),
        valueIndicatorColor: CleanColors.primary,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: CleanColors.onPrimary,
        ),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 10,
          disabledThumbRadius: 8,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
        activeTickMarkColor: CleanColors.primaryLight,
        inactiveTickMarkColor: CleanColors.slate300,
        disabledActiveTickMarkColor: CleanColors.slate400,
        disabledInactiveTickMarkColor: CleanColors.slate200,
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        showValueIndicator: ShowValueIndicator.onlyForContinuous,
      ),

      // ==========================================================================
      // POPUP MENU THEME
      // ==========================================================================
      popupMenuTheme: PopupMenuThemeData(
        color: CleanColors.surfaceElevated,
        elevation: AppElevation.md,
        shadowColor: CleanColors.shadowMedium,
        surfaceTintColor: Colors.transparent,
        shape: AppRadius.popupMenuShape,
        textStyle: textTheme.bodyMedium,
        labelTextStyle: WidgetStateProperty.all(textTheme.bodyMedium),
        position: PopupMenuPosition.under,
        menuPadding: AppSpacing.insetsV8,
      ),

      // ==========================================================================
      // BADGE THEME
      // ==========================================================================
      badgeTheme: BadgeThemeData(
        backgroundColor: CleanColors.error,
        textColor: CleanColors.onError,
        smallSize: 8,
        largeSize: 16,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs + 2),
        alignment: AlignmentDirectional.topEnd,
        offset: const Offset(-4, 4),
        textStyle: textTheme.labelSmall?.copyWith(
          color: CleanColors.onError,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ==========================================================================
      // SEARCH BAR THEME
      // ==========================================================================
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStateProperty.all(CleanColors.inputBackground),
        elevation: WidgetStateProperty.all(AppElevation.none),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.pressedOverlay;
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.hoverOverlay;
          }
          return Colors.transparent;
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: AppRadius.cleanInputRadius,
            side: const BorderSide(color: CleanColors.inputBorder),
          ),
        ),
        textStyle: WidgetStateProperty.all(
          AppTypography.inputText(isPlayful: false),
        ),
        hintStyle: WidgetStateProperty.all(
          AppTypography.inputHint(isPlayful: false),
        ),
        padding: WidgetStateProperty.all(AppSpacing.insetsH16),
        constraints: BoxConstraints(
          minHeight: AppSpacing.inputHeight,
          maxWidth: AppSpacing.maxContentWidth,
        ),
      ),

      // ==========================================================================
      // SEARCH VIEW THEME
      // ==========================================================================
      searchViewTheme: SearchViewThemeData(
        backgroundColor: CleanColors.surfaceElevated,
        elevation: AppElevation.md,
        surfaceTintColor: Colors.transparent,
        shape: AppRadius.cleanDialogShape,
        headerTextStyle: textTheme.titleMedium,
        headerHintStyle: AppTypography.inputHint(isPlayful: false),
        dividerColor: CleanColors.divider,
      ),

      // ==========================================================================
      // SEGMENTED BUTTON THEME
      // ==========================================================================
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
            if (states.contains(WidgetState.disabled)) {
              return CleanColors.disabled;
            }
            return CleanColors.textPrimary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: CleanColors.border),
          ),
          shape: WidgetStateProperty.all(AppRadius.cleanButtonShape),
          padding: WidgetStateProperty.all(AppSpacing.buttonInsetsMd),
          textStyle: WidgetStateProperty.all(
            AppTypography.buttonTextMedium(isPlayful: false),
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return CleanColors.primaryPressed.withValues(alpha: AppOpacity.soft);
            }
            return CleanColors.hoverOverlay;
          }),
        ),
        selectedIcon: const Icon(Icons.check, size: AppIconSize.sm),
      ),

      // ==========================================================================
      // DATE PICKER THEME
      // ==========================================================================
      datePickerTheme: DatePickerThemeData(
        backgroundColor: CleanColors.surfaceElevated,
        elevation: AppElevation.lg,
        shadowColor: CleanColors.shadowStrong,
        surfaceTintColor: Colors.transparent,
        shape: AppRadius.cleanDialogShape,
        headerBackgroundColor: CleanColors.primary,
        headerForegroundColor: CleanColors.onPrimary,
        headerHeadlineStyle: textTheme.headlineSmall?.copyWith(
          color: CleanColors.onPrimary,
        ),
        headerHelpStyle: textTheme.labelLarge?.copyWith(
          color: CleanColors.onPrimary.withValues(alpha: 0.7),
        ),
        dayStyle: textTheme.bodyMedium,
        weekdayStyle: textTheme.labelMedium?.copyWith(
          color: CleanColors.textSecondary,
        ),
        yearStyle: textTheme.bodyLarge,
        rangePickerHeaderBackgroundColor: CleanColors.primary,
        rangePickerHeaderForegroundColor: CleanColors.onPrimary,
        rangeSelectionBackgroundColor: CleanColors.primarySubtle,
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return CleanColors.primaryMuted;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.onPrimary;
          }
          return CleanColors.primary;
        }),
        todayBorder: BorderSide.none,
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return Colors.transparent;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return CleanColors.onPrimary;
          }
          return CleanColors.textPrimary;
        }),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.primarySubtle;
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.primaryMuted;
          }
          return Colors.transparent;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primary;
          }
          return Colors.transparent;
        }),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return CleanColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return CleanColors.onPrimary;
          }
          return CleanColors.textPrimary;
        }),
        yearOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return CleanColors.primarySubtle;
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.primaryMuted;
          }
          return Colors.transparent;
        }),
        dividerColor: CleanColors.divider,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: CleanColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: AppRadius.cleanInputRadius,
            borderSide: const BorderSide(color: CleanColors.inputBorder),
          ),
          contentPadding: AppSpacing.inputInsets,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: CleanColors.textSecondary,
        ),
        confirmButtonStyle: FilledButton.styleFrom(
          backgroundColor: CleanColors.primary,
          foregroundColor: CleanColors.onPrimary,
        ),
      ),

      // ==========================================================================
      // TIME PICKER THEME
      // ==========================================================================
      timePickerTheme: TimePickerThemeData(
        backgroundColor: CleanColors.surfaceElevated,
        elevation: AppElevation.lg,
        shape: AppRadius.cleanDialogShape,
        hourMinuteColor: CleanColors.surfaceSubtle,
        hourMinuteTextColor: CleanColors.textPrimary,
        hourMinuteTextStyle: textTheme.displayMedium,
        dayPeriodColor: CleanColors.surfaceSubtle,
        dayPeriodTextColor: CleanColors.textPrimary,
        dayPeriodTextStyle: textTheme.labelLarge,
        dayPeriodShape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
        dayPeriodBorderSide: const BorderSide(color: CleanColors.border),
        dialBackgroundColor: CleanColors.surfaceSubtle,
        dialHandColor: CleanColors.primary,
        dialTextColor: CleanColors.textPrimary,
        dialTextStyle: textTheme.bodyLarge,
        entryModeIconColor: CleanColors.primary,
        helpTextStyle: textTheme.labelMedium?.copyWith(
          color: CleanColors.textSecondary,
        ),
        hourMinuteShape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: CleanColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: AppRadius.cleanInputRadius,
            borderSide: const BorderSide(color: CleanColors.inputBorder),
          ),
          contentPadding: AppSpacing.inputInsets,
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: CleanColors.textSecondary,
        ),
        confirmButtonStyle: FilledButton.styleFrom(
          backgroundColor: CleanColors.primary,
          foregroundColor: CleanColors.onPrimary,
        ),
      ),

      // ==========================================================================
      // DROPDOWN MENU THEME
      // ==========================================================================
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: CleanColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: AppRadius.cleanInputRadius,
            borderSide: const BorderSide(color: CleanColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.cleanInputRadius,
            borderSide: const BorderSide(color: CleanColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.cleanInputRadius,
            borderSide: const BorderSide(
              color: CleanColors.inputBorderFocus,
              width: 2,
            ),
          ),
          contentPadding: AppSpacing.inputInsets,
        ),
        textStyle: textTheme.bodyLarge,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(CleanColors.surfaceElevated),
          elevation: WidgetStateProperty.all(AppElevation.md),
          shadowColor: WidgetStateProperty.all(CleanColors.shadowMedium),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(AppRadius.popupMenuShape),
          padding: WidgetStateProperty.all(AppSpacing.insetsV8),
        ),
      ),

      // ==========================================================================
      // MENU THEME
      // ==========================================================================
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(CleanColors.surfaceElevated),
          elevation: WidgetStateProperty.all(AppElevation.md),
          shadowColor: WidgetStateProperty.all(CleanColors.shadowMedium),
          surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(AppRadius.popupMenuShape),
          padding: WidgetStateProperty.all(AppSpacing.insetsV8),
        ),
      ),

      // ==========================================================================
      // MENU BUTTON THEME
      // ==========================================================================
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return CleanColors.pressedOverlay;
            }
            if (states.contains(WidgetState.hovered)) {
              return CleanColors.hoverOverlay;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return CleanColors.disabled;
            }
            return CleanColors.textPrimary;
          }),
          padding: WidgetStateProperty.all(AppSpacing.listItemInsets),
          textStyle: WidgetStateProperty.all(textTheme.bodyMedium),
          minimumSize: WidgetStateProperty.all(
            Size(double.infinity, AppSpacing.minTouchTarget),
          ),
        ),
      ),

      // ==========================================================================
      // EXPANSION TILE THEME
      // ==========================================================================
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        tilePadding: AppSpacing.listItemInsets,
        childrenPadding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        expandedAlignment: Alignment.centerLeft,
        iconColor: CleanColors.textSecondary,
        collapsedIconColor: CleanColors.textSecondary,
        textColor: CleanColors.textPrimary,
        collapsedTextColor: CleanColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: AppRadius.mdRadius,
        ),
      ),

      // ==========================================================================
      // DATA TABLE THEME
      // ==========================================================================
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(CleanColors.surfaceMuted),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return CleanColors.primaryMuted;
          }
          if (states.contains(WidgetState.hovered)) {
            return CleanColors.surfaceHover;
          }
          return CleanColors.surface;
        }),
        headingTextStyle: textTheme.labelLarge?.copyWith(
          color: CleanColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: textTheme.bodyMedium,
        dividerThickness: 1,
        horizontalMargin: AppSpacing.md,
        columnSpacing: AppSpacing.xl,
        dataRowMinHeight: AppSpacing.minTouchTarget,
        dataRowMaxHeight: 72,
        headingRowHeight: AppSpacing.minTouchTarget + AppSpacing.xs,
        checkboxHorizontalMargin: AppSpacing.sm,
        decoration: BoxDecoration(
          border: Border.all(color: CleanColors.border),
          borderRadius: AppRadius.mdRadius,
        ),
      ),

      // ==========================================================================
      // BANNER THEME
      // ==========================================================================
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: CleanColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: AppElevation.none,
        contentTextStyle: textTheme.bodyMedium,
        padding: AppSpacing.cardInsets,
        leadingPadding: EdgeInsets.only(right: AppSpacing.md),
        dividerColor: CleanColors.divider,
      ),

      // ==========================================================================
      // ACTION ICON THEME (AppBar action icons)
      // ==========================================================================
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) => const Icon(Icons.arrow_back),
        closeButtonIconBuilder: (context) => const Icon(Icons.close),
        drawerButtonIconBuilder: (context) => const Icon(Icons.menu),
        endDrawerButtonIconBuilder: (context) => const Icon(Icons.menu),
      ),

      // ==========================================================================
      // PAGE TRANSITIONS THEME
      // ==========================================================================
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      // ==========================================================================
      // MISC THEME PROPERTIES
      // ==========================================================================
      splashColor: CleanColors.pressedOverlay,
      highlightColor: CleanColors.hoverOverlay,
      hoverColor: CleanColors.hoverOverlay,
      focusColor: CleanColors.focusRing,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.comfortable,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      applyElevationOverlayColor: false,
    );
  }

  // ============================================================================
  // DEPRECATED LEGACY CONSTANTS - For backward compatibility
  // ============================================================================

  /// @deprecated Use AppRadius.xs instead
  @Deprecated('Use AppRadius.xs instead')
  static const double borderRadiusSmall = AppRadius.xs;

  /// @deprecated Use AppRadius.md instead
  @Deprecated('Use AppRadius.md instead')
  static const double borderRadiusMedium = AppRadius.md;

  /// @deprecated Use AppRadius.lg instead
  @Deprecated('Use AppRadius.lg instead')
  static const double borderRadiusLarge = AppRadius.lg;

  /// @deprecated Use AppElevation.none instead
  @Deprecated('Use AppElevation.none instead')
  static const double elevationNone = AppElevation.none;

  /// @deprecated Use AppElevation.xs instead
  @Deprecated('Use AppElevation.xs instead')
  static const double elevationSmall = AppElevation.xs;

  /// @deprecated Use AppElevation.sm instead
  @Deprecated('Use AppElevation.sm instead')
  static const double elevationMedium = AppElevation.sm;

  /// @deprecated Use AppElevation.md instead
  @Deprecated('Use AppElevation.md instead')
  static const double elevationLarge = AppElevation.md;
}
