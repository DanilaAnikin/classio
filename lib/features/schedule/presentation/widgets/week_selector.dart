import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:classio/core/localization/localization.dart';
import 'package:classio/core/providers/theme_provider.dart';

/// The type of week view being displayed.
enum WeekViewType {
  /// Previous week
  previousWeek,

  /// Current week
  currentWeek,

  /// Next week
  nextWeek,

  /// Week after next
  weekAfterNext,

  /// Stable/baseline timetable
  stable,
}

/// Provider for tracking the selected week view.
final selectedWeekViewProvider = StateNotifierProvider<SelectedWeekViewNotifier, WeekViewType>(
  (ref) => SelectedWeekViewNotifier(),
);

/// Provider for getting the actual date of the selected week's Monday.
final selectedWeekStartDateProvider = Provider<DateTime?>((ref) {
  final weekView = ref.watch(selectedWeekViewProvider);
  final today = DateTime.now();
  final currentMonday = _getMondayOfWeek(today);

  switch (weekView) {
    case WeekViewType.previousWeek:
      return currentMonday.subtract(const Duration(days: 7));
    case WeekViewType.currentWeek:
      return currentMonday;
    case WeekViewType.nextWeek:
      return currentMonday.add(const Duration(days: 7));
    case WeekViewType.weekAfterNext:
      return currentMonday.add(const Duration(days: 14));
    case WeekViewType.stable:
      return null; // Stable view doesn't have a specific week date
  }
});

/// Returns the Monday of the week containing the given date.
DateTime _getMondayOfWeek(DateTime date) {
  return DateTime(date.year, date.month, date.day - (date.weekday - 1));
}

/// State notifier for the selected week view.
class SelectedWeekViewNotifier extends StateNotifier<WeekViewType> {
  SelectedWeekViewNotifier() : super(WeekViewType.currentWeek);

  /// Sets the selected week view.
  void setWeekView(WeekViewType type) {
    state = type;
  }

  /// Goes to the previous week.
  void previousWeek() {
    switch (state) {
      case WeekViewType.currentWeek:
        state = WeekViewType.previousWeek;
        break;
      case WeekViewType.nextWeek:
        state = WeekViewType.currentWeek;
        break;
      case WeekViewType.weekAfterNext:
        state = WeekViewType.nextWeek;
        break;
      case WeekViewType.previousWeek:
      case WeekViewType.stable:
        // Can't go further back
        break;
    }
  }

  /// Goes to the next week.
  void nextWeek() {
    switch (state) {
      case WeekViewType.previousWeek:
        state = WeekViewType.currentWeek;
        break;
      case WeekViewType.currentWeek:
        state = WeekViewType.nextWeek;
        break;
      case WeekViewType.nextWeek:
        state = WeekViewType.weekAfterNext;
        break;
      case WeekViewType.weekAfterNext:
      case WeekViewType.stable:
        // Can't go further forward
        break;
    }
  }

  /// Resets to current week.
  void goToCurrentWeek() {
    state = WeekViewType.currentWeek;
  }

  /// Shows the stable timetable.
  void showStable() {
    state = WeekViewType.stable;
  }
}

/// A widget for selecting which week to view in the timetable.
///
/// Shows navigation buttons for previous/next week, a button to jump to
/// the current week, and a button to view the stable timetable.
class WeekSelector extends ConsumerWidget {
  const WeekSelector({super.key});

  /// Returns the date range string for a given week.
  String _getWeekRangeString(DateTime monday, String locale) {
    final friday = monday.add(const Duration(days: 4));
    final dateFormat = DateFormat.MMMd(locale);
    return '${dateFormat.format(monday)} - ${dateFormat.format(friday)}';
  }

  /// Returns the localized label for the week view type.
  String _getWeekLabel(BuildContext context, WeekViewType type) {
    final l10n = context.l10n;
    switch (type) {
      case WeekViewType.previousWeek:
        return l10n.scheduleWeekPrevious;
      case WeekViewType.currentWeek:
        return l10n.scheduleWeekCurrent;
      case WeekViewType.nextWeek:
        return l10n.scheduleWeekNext;
      case WeekViewType.weekAfterNext:
        return l10n.scheduleWeekAfterNext;
      case WeekViewType.stable:
        return l10n.scheduleWeekStable;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekView = ref.watch(selectedWeekViewProvider);
    final weekStartDate = ref.watch(selectedWeekStartDateProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final locale = context.currentLocale.languageCode;
    final l10n = context.l10n;

    final canGoPrevious = weekView != WeekViewType.previousWeek && weekView != WeekViewType.stable;
    final canGoNext = weekView != WeekViewType.weekAfterNext && weekView != WeekViewType.stable;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 12 : 8,
        vertical: isPlayful ? 10 : 8,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Week navigation row
          Row(
            children: [
              // Previous button
              _WeekNavButton(
                icon: Icons.chevron_left,
                enabled: canGoPrevious,
                isPlayful: isPlayful,
                tooltip: l10n.scheduleWeekPrevious,
                onTap: () {
                  ref.read(selectedWeekViewProvider.notifier).previousWeek();
                },
              ),

              // Week label and date range
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getWeekLabel(context, weekView),
                      style: TextStyle(
                        fontSize: isPlayful ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: weekView == WeekViewType.stable
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primary,
                        letterSpacing: isPlayful ? 0.3 : 0,
                      ),
                    ),
                    if (weekStartDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _getWeekRangeString(weekStartDate, locale),
                        style: TextStyle(
                          fontSize: isPlayful ? 12 : 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Next button
              _WeekNavButton(
                icon: Icons.chevron_right,
                enabled: canGoNext,
                isPlayful: isPlayful,
                tooltip: l10n.scheduleWeekNext,
                onTap: () {
                  ref.read(selectedWeekViewProvider.notifier).nextWeek();
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Quick action buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionButton(
                label: l10n.scheduleWeekCurrent,
                isSelected: weekView == WeekViewType.currentWeek,
                isPlayful: isPlayful,
                onTap: () {
                  ref.read(selectedWeekViewProvider.notifier).goToCurrentWeek();
                },
              ),
              _QuickActionButton(
                label: l10n.scheduleWeekStable,
                isSelected: weekView == WeekViewType.stable,
                isPlayful: isPlayful,
                isStable: true,
                onTap: () {
                  ref.read(selectedWeekViewProvider.notifier).showStable();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Navigation button for previous/next week.
class _WeekNavButton extends StatelessWidget {
  const _WeekNavButton({
    required this.icon,
    required this.enabled,
    required this.isPlayful,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final bool isPlayful;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          child: Container(
            padding: EdgeInsets.all(isPlayful ? 10 : 8),
            child: Icon(
              icon,
              size: isPlayful ? 26 : 24,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick action button for jumping to specific week views.
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.isSelected,
    required this.isPlayful,
    required this.onTap,
    this.isStable = false,
  });

  final String label;
  final bool isSelected;
  final bool isPlayful;
  final VoidCallback onTap;
  final bool isStable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 16 : 12,
            vertical: isPlayful ? 8 : 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            color: isSelected
                ? (isStable
                    ? theme.colorScheme.secondary.withValues(alpha: 0.2)
                    : theme.colorScheme.primary.withValues(alpha: 0.2))
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? (isStable
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary)
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isStable) ...[
                Icon(
                  Icons.schedule,
                  size: isPlayful ? 16 : 14,
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: isPlayful ? 13 : 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? (isStable
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.primary)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
