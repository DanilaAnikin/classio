import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';
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
        horizontal: isPlayful ? 12 : 8,
        vertical: isPlayful ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: isPlayful
            ? theme.colorScheme.surface.withValues(alpha: 0.8)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: isPlayful ? 12 : 6,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final weekday = index + 1; // 1=Monday, 5=Friday
          final isSelected = selectedDay == weekday;
          final isToday = DateTime.now().weekday == weekday;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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

    return Semantics(
      label: '$fullName${isSelected ? ", selected" : ""}${isToday ? ", today" : ""}',
      button: true,
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 12 : 10,
              vertical: isPlayful ? 14 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
              gradient: isSelected && isPlayful
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isSelected
                  ? (isPlayful ? null : theme.colorScheme.primary)
                  : (isToday
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent),
              boxShadow: isSelected && isPlayful
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: isPlayful ? 0.3 : 0,
                  ),
                ),
                if (isToday && !isSelected) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
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
