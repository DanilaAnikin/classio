import 'package:flutter/material.dart';

/// Configuration for the schedule editor grid.
///
/// Provides default time slots and lesson durations that can be
/// customized per school.
class ScheduleConfig {
  /// Default time slots for a typical school day.
  ///
  /// These represent the starting times of each lesson period.
  static const List<TimeOfDay> defaultTimeSlots = [
    TimeOfDay(hour: 8, minute: 0),   // 1st period
    TimeOfDay(hour: 8, minute: 45),  // 2nd period
    TimeOfDay(hour: 9, minute: 35),  // 3rd period
    TimeOfDay(hour: 10, minute: 25), // 4th period
    // 10:25 - 10:45 break
    TimeOfDay(hour: 10, minute: 45), // 5th period
    TimeOfDay(hour: 11, minute: 35), // 6th period
    TimeOfDay(hour: 12, minute: 25), // 7th period
    // 12:25 - 13:30 lunch
    TimeOfDay(hour: 13, minute: 30), // 8th period
    TimeOfDay(hour: 14, minute: 20), // 9th period
    TimeOfDay(hour: 15, minute: 10), // 10th period
  ];

  /// Default lesson duration in minutes.
  static const Duration lessonDuration = Duration(minutes: 45);

  /// Default break duration in minutes.
  static const Duration breakDuration = Duration(minutes: 10);

  /// Default lunch break duration in minutes.
  static const Duration lunchDuration = Duration(minutes: 65);

  /// Days of the week shown in the schedule grid.
  ///
  /// Uses 1=Monday through 5=Friday by default.
  static const List<int> defaultWorkDays = [1, 2, 3, 4, 5];

  /// All days including weekends (1=Monday through 7=Sunday).
  static const List<int> allDays = [1, 2, 3, 4, 5, 6, 7];

  /// Day labels for display.
  static const Map<int, String> dayLabels = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  /// Short day labels for compact display.
  static const Map<int, String> shortDayLabels = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  /// Very short day labels for mobile display.
  static const Map<int, String> tinyDayLabels = {
    1: 'M',
    2: 'T',
    3: 'W',
    4: 'T',
    5: 'F',
    6: 'S',
    7: 'S',
  };

  /// Returns the end time for a given start time based on lesson duration.
  static TimeOfDay getEndTime(TimeOfDay startTime, {int durationMinutes = 45}) {
    final totalMinutes = startTime.hour * 60 + startTime.minute + durationMinutes;
    return TimeOfDay(
      hour: totalMinutes ~/ 60,
      minute: totalMinutes % 60,
    );
  }

  /// Returns a formatted time string.
  static String formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Returns the grid row index for a given time.
  ///
  /// Used to position lessons in the schedule grid.
  static int getTimeSlotIndex(TimeOfDay time) {
    final timeMinutes = time.hour * 60 + time.minute;
    for (int i = 0; i < defaultTimeSlots.length; i++) {
      final slotMinutes = defaultTimeSlots[i].hour * 60 + defaultTimeSlots[i].minute;
      if (timeMinutes <= slotMinutes) {
        return i;
      }
    }
    return defaultTimeSlots.length - 1;
  }

  /// Returns the height ratio for a lesson based on its duration.
  ///
  /// A standard 45-minute lesson has a ratio of 1.0.
  static double getLessonHeightRatio(int durationMinutes) {
    return durationMinutes / 45.0;
  }

  /// Checks if a time is within working hours.
  static bool isWithinWorkHours(TimeOfDay time) {
    final minutes = time.hour * 60 + time.minute;
    const startOfDay = 8 * 60; // 8:00
    const endOfDay = 16 * 60;  // 16:00
    return minutes >= startOfDay && minutes < endOfDay;
  }

  /// Returns available time slots that don't conflict with existing lessons.
  static List<TimeOfDay> getAvailableTimeSlots(
    int dayOfWeek,
    List<({TimeOfDay start, TimeOfDay end})> existingLessons,
  ) {
    return defaultTimeSlots.where((slot) {
      final slotEnd = getEndTime(slot);
      final slotStart = slot.hour * 60 + slot.minute;
      final slotEndMinutes = slotEnd.hour * 60 + slotEnd.minute;

      for (final lesson in existingLessons) {
        final lessonStart = lesson.start.hour * 60 + lesson.start.minute;
        final lessonEnd = lesson.end.hour * 60 + lesson.end.minute;

        // Check for overlap
        if (!(slotEndMinutes <= lessonStart || slotStart >= lessonEnd)) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
