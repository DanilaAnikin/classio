import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/generated/app_localizations.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/language_selector.dart';
import '../settings/settings_screen.dart';

/// Dashboard/Home screen - the main landing page of the app.
///
/// Features:
/// - Welcome message in the selected language
/// - Current theme and language info display
/// - Sample cards demonstrating the theme
/// - Navigation to Settings
///
/// Design System:
/// - Uses AppSpacing for all padding/margins
/// - Uses AppTypography for text styles
/// - Uses AppRadius for corners
/// - Uses AppColors for all colors
/// - Fully theme-aware (Clean vs Playful)
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeNotifierProvider);
    final currentLocale = ref.watch(localeNotifierProvider);
    final currentLanguage = getLanguageOption(currentLocale.languageCode);
    final isPlayful = currentTheme == ThemeType.playful;

    return Scaffold(
      backgroundColor: isPlayful ? PlayfulColors.background : CleanColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _DashboardAppBar(
            appName: l10n.appName,
            languageFlag: currentLanguage.flag,
            settingsTooltip: l10n.settings,
            isPlayful: isPlayful,
            onSettingsTap: () => _navigateToSettings(context),
          ),
          // Dashboard Content
          SliverPadding(
            padding: AppSpacing.getPagePadding(context, isPlayful: isPlayful),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Card
                _WelcomeCard(
                  welcomeMessage: l10n.welcomeMessage,
                  currentTheme: currentTheme,
                  l10n: l10n,
                ),
                SizedBox(height: AppSpacing.getSectionGap(isPlayful: isPlayful)),

                // Quick Stats Section
                _SectionHeader(
                  title: 'Quick Overview',
                  isPlayful: isPlayful,
                ),
                AppSpacing.gapSm,
                _QuickStatsRow(isPlayful: isPlayful),
                SizedBox(height: AppSpacing.getSectionGap(isPlayful: isPlayful)),

                // Feature Cards Section
                _SectionHeader(
                  title: 'Features',
                  isPlayful: isPlayful,
                ),
                AppSpacing.gapSm,
                _FeatureCardsGrid(isPlayful: isPlayful),
                SizedBox(height: AppSpacing.getSectionGap(isPlayful: isPlayful)),

                // Current Settings Card
                _SectionHeader(
                  title: 'Your Settings',
                  isPlayful: isPlayful,
                ),
                AppSpacing.gapSm,
                _SettingsPreviewCard(
                  currentTheme: currentTheme,
                  currentLanguage: currentLanguage,
                  l10n: l10n,
                  onSettingsTap: () => _navigateToSettings(context),
                ),
                SizedBox(height: AppSpacing.getSectionGap(isPlayful: isPlayful)),

                // Action Buttons Demo
                _SectionHeader(
                  title: 'Quick Actions',
                  isPlayful: isPlayful,
                ),
                AppSpacing.gapSm,
                _QuickActionsCard(
                  isPlayful: isPlayful,
                  onSettingsTap: () => _navigateToSettings(context),
                ),
                SizedBox(height: AppSpacing.space48),
              ]),
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: _DashboardFAB(
        label: l10n.settings,
        isPlayful: isPlayful,
        onPressed: () => _navigateToSettings(context),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: AppCurves.emphasized,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: AppCurves.decelerate,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: AppDuration.pageTransition,
      ),
    );
  }
}

/// Premium app bar for the dashboard.
class _DashboardAppBar extends StatelessWidget {
  final String appName;
  final String languageFlag;
  final String settingsTooltip;
  final bool isPlayful;
  final VoidCallback onSettingsTap;

  const _DashboardAppBar({
    required this.appName,
    required this.languageFlag,
    required this.settingsTooltip,
    required this.isPlayful,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar.large(
      title: Text(
        appName,
        style: AppTypography.appBarTitle(isPlayful: isPlayful),
      ),
      centerTitle: true,
      floating: true,
      pinned: true,
      backgroundColor: isPlayful ? PlayfulColors.appBar : CleanColors.appBar,
      surfaceTintColor: Colors.transparent,
      actions: [
        // Language indicator button
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.xs),
          child: _LanguageIndicator(
            flag: languageFlag,
            isPlayful: isPlayful,
            onTap: onSettingsTap,
          ),
        ),
        // Settings button
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            size: AppIconSize.appBar,
            color: isPlayful
                ? PlayfulColors.appBarForeground
                : CleanColors.appBarForeground,
          ),
          onPressed: onSettingsTap,
          tooltip: settingsTooltip,
        ),
        SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

/// Language indicator button showing the current flag.
class _LanguageIndicator extends StatelessWidget {
  final String flag;
  final bool isPlayful;
  final VoidCallback onTap;

  const _LanguageIndicator({
    required this.flag,
    required this.isPlayful,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.button(isPlayful: isPlayful),
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: AppOpacity.soft),
            borderRadius: AppRadius.button(isPlayful: isPlayful),
          ),
          child: Text(
            flag,
            style: TextStyle(fontSize: AppIconSize.md),
          ),
        ),
      ),
    );
  }
}

/// Section header with consistent styling.
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isPlayful;

  const _SectionHeader({
    required this.title,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.sectionTitle(isPlayful: isPlayful).copyWith(
        fontSize: AppFontSize.titleMedium,
      ),
    );
  }
}

/// Welcome card with greeting and theme info.
class _WelcomeCard extends StatelessWidget {
  final String welcomeMessage;
  final ThemeType currentTheme;
  final AppLocalizations l10n;

  const _WelcomeCard({
    required this.welcomeMessage,
    required this.currentTheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isPlayful = currentTheme == ThemeType.playful;
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final secondaryColor = isPlayful ? PlayfulColors.secondary : CleanColors.secondary;

    return AnimatedContainer(
      duration: AppDuration.medium,
      curve: AppCurves.emphasized,
      padding: AppSpacing.getCardPadding(isPlayful: isPlayful),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPlayful
              ? [
                  primaryColor,
                  primaryColor.withValues(alpha: AppOpacity.almostOpaque),
                  secondaryColor.withValues(alpha: AppOpacity.dominant),
                ]
              : [
                  primaryColor,
                  primaryColor.withValues(alpha: AppOpacity.almostOpaque),
                ],
        ),
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        boxShadow: AppShadows.cardHover(isPlayful: isPlayful),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting icon
          Container(
            padding: AppSpacing.insets12,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: AppOpacity.medium),
              borderRadius: AppRadius.button(isPlayful: isPlayful),
            ),
            child: Icon(
              isPlayful ? Icons.waving_hand_rounded : Icons.school_rounded,
              color: Colors.white,
              size: AppIconSize.lg,
            ),
          ),
          AppSpacing.gapLg,
          // Welcome message
          Text(
            welcomeMessage,
            style: AppTypography.pageTitle(isPlayful: isPlayful).copyWith(
              color: Colors.white,
              fontSize: AppFontSize.headlineSmall,
            ),
          ),
          AppSpacing.gap4,
          // Subtitle
          Text(
            'Your learning journey starts here',
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              color: Colors.white.withValues(alpha: AppOpacity.almostOpaque),
            ),
          ),
          AppSpacing.gapLg,
          // Theme badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.space4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: AppOpacity.medium),
              borderRadius: AppRadius.fullRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPlayful ? Icons.palette_outlined : Icons.auto_awesome_outlined,
                  color: Colors.white,
                  size: AppIconSize.sm,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${l10n.theme}: ${isPlayful ? l10n.playfulTheme : l10n.cleanTheme}',
                  style: AppTypography.buttonTextSmall(isPlayful: isPlayful).copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick stats row showing sample metrics.
class _QuickStatsRow extends StatelessWidget {
  final bool isPlayful;

  const _QuickStatsRow({required this.isPlayful});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.book_outlined,
            value: '12',
            label: 'Courses',
            color: isPlayful ? PlayfulColors.statBlue : CleanColors.statBlue,
            isPlayful: isPlayful,
          ),
        ),
        SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle_outline,
            value: '48',
            label: 'Completed',
            color: isPlayful ? PlayfulColors.statGreen : CleanColors.statGreen,
            isPlayful: isPlayful,
          ),
        ),
        SizedBox(width: AppSpacing.cardGap),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: '24h',
            label: 'Study Time',
            color: isPlayful ? PlayfulColors.statOrange : CleanColors.statOrange,
            isPlayful: isPlayful,
          ),
        ),
      ],
    );
  }
}

/// Individual stat card.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isPlayful;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isPlayful,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isPlayful ? PlayfulColors.surface : CleanColors.surface;
    final cardBorder = isPlayful ? PlayfulColors.cardBorder : CleanColors.cardBorder;
    final textColor = isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;
    final secondaryTextColor = isPlayful
        ? PlayfulColors.textSecondary
        : CleanColors.textSecondary;

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppCurves.standard,
      padding: AppSpacing.cardInsetsCompact,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: AppShadows.card(isPlayful: isPlayful),
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.insets8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: AppOpacity.soft),
              borderRadius: AppRadius.button(isPlayful: isPlayful),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppIconSize.md,
            ),
          ),
          AppSpacing.gapSm,
          Text(
            value,
            style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
              color: textColor,
            ),
          ),
          AppSpacing.gap4,
          Text(
            label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Grid of feature cards.
class _FeatureCardsGrid extends StatelessWidget {
  final bool isPlayful;

  const _FeatureCardsGrid({required this.isPlayful});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.quiz_outlined,
                title: 'Quizzes',
                subtitle: 'Test your knowledge',
                color: isPlayful ? PlayfulColors.primary : CleanColors.primary,
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: _FeatureCard(
                icon: Icons.library_books_outlined,
                title: 'Library',
                subtitle: 'Browse materials',
                color: isPlayful ? PlayfulColors.secondary : CleanColors.secondary,
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.cardGap),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.people_outline,
                title: 'Community',
                subtitle: 'Connect with peers',
                color: isPlayful ? PlayfulColors.success : CleanColors.success,
                isPlayful: isPlayful,
              ),
            ),
            SizedBox(width: AppSpacing.cardGap),
            Expanded(
              child: _FeatureCard(
                icon: Icons.analytics_outlined,
                title: 'Progress',
                subtitle: 'Track your growth',
                color: isPlayful ? PlayfulColors.accentPink : CleanColors.info,
                isPlayful: isPlayful,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual feature card with hover effect.
class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isPlayful;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isPlayful,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = widget.isPlayful
        ? PlayfulColors.surface
        : CleanColors.surface;
    final cardBorder = widget.isPlayful
        ? PlayfulColors.cardBorder
        : CleanColors.cardBorder;
    final cardRadius = AppRadius.card(isPlayful: widget.isPlayful);
    final textColor = widget.isPlayful
        ? PlayfulColors.textPrimary
        : CleanColors.textPrimary;
    final secondaryTextColor = widget.isPlayful
        ? PlayfulColors.textSecondary
        : CleanColors.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          // Feature tap handler
        },
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: AppSpacing.getCardPadding(isPlayful: widget.isPlayful),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: cardRadius,
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: AppOpacity.semi)
                  : cardBorder,
              width: 1,
            ),
            boxShadow: _isHovered
                ? AppShadows.cardHover(isPlayful: widget.isPlayful)
                : AppShadows.card(isPlayful: widget.isPlayful),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: AppDuration.fast,
                curve: AppCurves.standard,
                padding: AppSpacing.insets12,
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: _isHovered ? AppOpacity.medium : AppOpacity.soft,
                  ),
                  borderRadius: AppRadius.button(isPlayful: widget.isPlayful),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: AppIconSize.md,
                ),
              ),
              AppSpacing.gapSm,
              Text(
                widget.title,
                style: AppTypography.cardTitle(isPlayful: widget.isPlayful).copyWith(
                  color: textColor,
                  fontSize: AppFontSize.titleMedium,
                ),
              ),
              AppSpacing.gap4,
              Text(
                widget.subtitle,
                style: AppTypography.caption(isPlayful: widget.isPlayful).copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings preview card with current configuration.
class _SettingsPreviewCard extends StatelessWidget {
  final ThemeType currentTheme;
  final LanguageOption currentLanguage;
  final AppLocalizations l10n;
  final VoidCallback onSettingsTap;

  const _SettingsPreviewCard({
    required this.currentTheme,
    required this.currentLanguage,
    required this.l10n,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlayful = currentTheme == ThemeType.playful;
    final surfaceColor = isPlayful ? PlayfulColors.surface : CleanColors.surface;
    final cardBorder = isPlayful ? PlayfulColors.cardBorder : CleanColors.cardBorder;
    final cardRadius = AppRadius.card(isPlayful: isPlayful);
    final textColor = isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary;
    final secondaryTextColor = isPlayful
        ? PlayfulColors.textSecondary
        : CleanColors.textSecondary;
    final primaryColor = isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final secondaryColor = isPlayful ? PlayfulColors.secondary : CleanColors.secondary;

    return Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      child: InkWell(
        onTap: onSettingsTap,
        borderRadius: cardRadius,
        child: AnimatedContainer(
          duration: AppDuration.fast,
          curve: AppCurves.standard,
          padding: AppSpacing.getCardPadding(isPlayful: isPlayful),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: cardRadius,
            border: Border.all(color: cardBorder, width: 1),
            boxShadow: AppShadows.card(isPlayful: isPlayful),
          ),
          child: Row(
            children: [
              // Theme indicator
              Container(
                width: AppSpacing.space48,
                height: AppSpacing.space48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                  ),
                  borderRadius: AppRadius.button(isPlayful: isPlayful),
                  boxShadow: AppShadows.button(isPlayful: isPlayful),
                ),
                child: Icon(
                  isPlayful ? Icons.palette_rounded : Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: AppIconSize.md,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              // Settings info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentLanguage.flag,
                          style: TextStyle(fontSize: AppIconSize.md),
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            currentLanguage.nativeName,
                            style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
                              color: textColor,
                              fontSize: AppFontSize.titleMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.gap4,
                    Text(
                      '${l10n.theme}: ${isPlayful ? l10n.playfulTheme : l10n.cleanTheme}',
                      style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: secondaryTextColor,
                size: AppIconSize.md,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick actions card with buttons.
class _QuickActionsCard extends StatelessWidget {
  final bool isPlayful;
  final VoidCallback onSettingsTap;

  const _QuickActionsCard({
    required this.isPlayful,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isPlayful ? PlayfulColors.surface : CleanColors.surface;
    final cardBorder = isPlayful ? PlayfulColors.cardBorder : CleanColors.cardBorder;
    final cardRadius = AppRadius.card(isPlayful: isPlayful);

    return AnimatedContainer(
      duration: AppDuration.fast,
      curve: AppCurves.standard,
      padding: AppSpacing.getCardPadding(isPlayful: isPlayful),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: cardRadius,
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: AppShadows.card(isPlayful: isPlayful),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary action button
          SizedBox(
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.play_arrow_rounded, size: AppIconSize.button),
              label: Text(
                'Start Learning',
                style: AppTypography.buttonTextMedium(isPlayful: isPlayful),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.button(isPlayful: isPlayful),
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.cardGap),
          Row(
            children: [
              // Secondary action button
              Expanded(
                child: SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: onSettingsTap,
                    icon: Icon(Icons.settings_outlined, size: AppIconSize.button),
                    label: Text(
                      'Customize',
                      style: AppTypography.buttonTextMedium(isPlayful: isPlayful),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button(isPlayful: isPlayful),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.cardGap),
              // Tertiary action button
              Expanded(
                child: SizedBox(
                  height: AppSpacing.buttonHeight,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.help_outline_rounded, size: AppIconSize.button),
                    label: Text(
                      'Help',
                      style: AppTypography.buttonTextMedium(isPlayful: isPlayful),
                    ),
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button(isPlayful: isPlayful),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Premium floating action button for the dashboard.
class _DashboardFAB extends StatelessWidget {
  final String label;
  final bool isPlayful;
  final VoidCallback onPressed;

  const _DashboardFAB({
    required this.label,
    required this.isPlayful,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(
        Icons.tune_rounded,
        size: AppIconSize.button,
      ),
      label: Text(
        label,
        style: AppTypography.buttonTextMedium(isPlayful: isPlayful).copyWith(
          color: Colors.white,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
    );
  }
}
