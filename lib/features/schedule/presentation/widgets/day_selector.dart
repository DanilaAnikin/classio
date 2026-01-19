import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/theme/theme.dart';
import '../providers/schedule_provider.dart';

/// A horizontal day picker widget for selecting weekdays.
///
/// Displays Monday through Friday as selectable buttons.
/// The currently selected day is highlighted with theme-aware styling.
/// Day labels are localized based on the current app locale.
class DaySelector extends ConsumerWidget {
  const DaySelector({super.key});

  /// Returns the localized short day label (e.g., "Mon", "Po") for a given weekday.
  ///
  /// [weekday] should be 1-5 (Monday-Friday).
  /// [locale] is the language code to use for formatting.
  String _getDayLabel(int weekday, String locale) {
    // Create a date that falls on the given weekday
    // Using a known Monday (Jan 6, 2025) as reference
    final referenceMonday = DateTime(2025, 1, 6);
    final date = referenceMonday.add(Duration(days: weekday - 1));
    return DateFormat.E(locale).format(date);
  }

  /// Returns the localized full day name (e.g., "Monday", "Pondeli") for a given weekday.
  ///
  /// [weekday] should be 1-5 (Monday-Friday).
  /// [locale] is the language code to use for formatting.
  String _getFullDayName(int weekday, String locale) {
    final referenceMonday = DateTime(2025, 1, 6);
    final date = referenceMonday.add(Duration(days: weekday - 1));
    return DateFormat.EEEE(locale).format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final locale = context.currentLocale.languageCode;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs,
        vertical: isPlayful ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isPlayful
            ? theme.colorScheme.surface.withValues(alpha: AppOpacity.almostOpaque)
            : theme.colorScheme.surface,
        borderRadius: AppRadius.card(isPlayful: isPlayful),
        boxShadow: AppShadows.card(isPlayful: isPlayful),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final weekday = index + 1; // 1=Monday, 5=Friday
          final isSelected = selectedDay == weekday;
          final isToday = DateTime.now().weekday == weekday;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              child: _DayButton(
                label: _getDayLabel(weekday, locale),
                fullName: _getFullDayName(weekday, locale),
                isSelected: isSelected,
                isToday: isToday,
                isPlayful: isPlayful,
                onTap: () {
                  ref.read(selectedDayProvider.notifier).selectDay(weekday);
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Individual day button in the selector.
class _DayButton extends StatelessWidget {
  const _DayButton({
    required this.label,
    required this.fullName,
    required this.isSelected,
    required this.isToday,
    required this.isPlayful,
    required this.onTap,
  });

  final String label;
  final String fullName;
  final bool isSelected;
  final bool isToday;
  final bool isPlayful;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonRadius = AppRadius.button(isPlayful: isPlayful);

    return Semantics(
      label: '$fullName${isSelected ? ", selected" : ""}${isToday ? ", today" : ""}',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: buttonRadius,
          child: AnimatedContainer(
            duration: AppDuration.normal,
            curve: AppCurves.standard,
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? AppSpacing.sm : AppSpacing.xs + AppSpacing.space2,
              vertical: isPlayful ? AppSpacing.sm + AppSpacing.space2 : AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: buttonRadius,
              gradient: isSelected && isPlayful
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: AppOpacity.almostOpaque),
                      ],
                    )
                  : null,
              color: isSelected
                  ? (isPlayful ? null : theme.colorScheme.primary)
                  : (isToday
                      ? theme.colorScheme.primary.withValues(alpha: AppOpacity.soft)
                      : Colors.transparent),
              boxShadow: isSelected && isPlayful
                  ? AppShadows.button(isPlayful: isPlayful)
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: isPlayful ? AppFontSize.labelLarge : AppFontSize.labelMedium + 1,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: AppOpacity.iconOnColor),
                    letterSpacing: isPlayful ? AppLetterSpacing.titleSmall : 0,
                  ),
                ),
                if (isToday && !isSelected) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Container(
                    width: AppSpacing.xs - AppSpacing.space2,
                    height: AppSpacing.xs - AppSpacing.space2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
