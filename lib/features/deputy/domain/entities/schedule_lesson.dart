import 'package:flutter/material.dart';

/// Represents a single lesson in the schedule editor.
///
/// Unlike the student-facing [Lesson] entity, this contains additional
/// information needed for schedule management by deputies/admins.
class ScheduleLesson {
  /// Creates a [ScheduleLesson] instance.
  const ScheduleLesson({
    required this.id,
    required this.subjectId,
    required this.classId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.subjectName,
    this.subjectColor,
    this.teacherId,
    this.teacherName,
    this.room,
    this.createdAt,
    this.isStable = true,
    this.stableLessonId,
    this.weekStartDate,
    this.modifiedFromStable = false,
  });

  /// Unique identifier for the lesson.
  final String id;

  /// Subject ID this lesson is for.
  final String subjectId;

  /// Class ID this lesson belongs to.
  final String classId;

  /// Day of the week (1=Monday, 7=Sunday).
  final int dayOfWeek;

  /// Start time of the lesson.
  final TimeOfDay startTime;

  /// End time of the lesson.
  final TimeOfDay endTime;

  /// Name of the subject (joined from subjects table).
  final String? subjectName;

  /// Color associated with the subject (ARGB int value).
  /// Convert to Flutter Color in UI layer using: Color(subjectColor)
  final int? subjectColor;

  /// ID of the teacher assigned to this subject.
  final String? teacherId;

  /// Name of the teacher (joined from profiles table).
  final String? teacherName;

  /// Room/location where the lesson takes place.
  final String? room;

  /// Timestamp when the lesson was created.
  final DateTime? createdAt;

  /// Whether this is a stable (recurring) lesson.
  /// If false, this is a week-specific override.
  final bool isStable;

  /// For week-specific overrides, references the stable lesson this modifies.
  final String? stableLessonId;

  /// For week-specific lessons, the Monday date of the week this applies to.
  final DateTime? weekStartDate;

  /// Whether this lesson has been modified from the stable timetable.
  /// True when viewing a week-specific override or when the lesson differs
  /// from the stable version.
  final bool modifiedFromStable;

  /// Creates a [ScheduleLesson] from a JSON map.
  factory ScheduleLesson.fromJson(Map<String, dynamic> json) {
    // Parse start_time from string (format: "HH:MM:SS" or "HH:MM")
    TimeOfDay startTime;
    TimeOfDay endTime;

    final startTimeStr = json['start_time'] as String?;
    final endTimeStr = json['end_time'] as String?;

    if (startTimeStr != null) {
      final parts = startTimeStr.split(':');
      startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      startTime = const TimeOfDay(hour: 8, minute: 0);
    }

    if (endTimeStr != null) {
      final parts = endTimeStr.split(':');
      endTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      endTime = const TimeOfDay(hour: 8, minute: 45);
    }

    // Parse subject data if joined
    final subjectData = json['subjects'] as Map<String, dynamic>?;
    String? subjectName;
    String? teacherId;
    String? teacherName;
    String? classId;

    if (subjectData != null) {
      subjectName = subjectData['name'] as String?;
      teacherId = subjectData['teacher_id'] as String?;
      // Get class_id from subject (lessons don't have class_id directly)
      classId = subjectData['class_id'] as String?;

      // Parse teacher data if joined
      final teacherData = subjectData['teacher'] as Map<String, dynamic>?;
      if (teacherData != null) {
        final firstName = teacherData['first_name'] as String?;
        final lastName = teacherData['last_name'] as String?;
        if (firstName != null || lastName != null) {
          teacherName = [firstName, lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
        }
      }
    }

    // Fallback: try to get class_id from json directly (for backwards compatibility)
    classId ??= json['class_id'] as String?;

    // Convert day_of_week from DB format (0=Sunday) to app format (1=Monday)
    final dbDayOfWeek = json['day_of_week'] as int? ?? 1;
    final dayOfWeek = dbDayOfWeek == 0 ? 7 : dbDayOfWeek;

    // Parse createdAt from string if present
    DateTime? createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAt = null;
      }
    }

    // Parse week_start_date if present
    DateTime? weekStartDate;
    final weekStartDateStr = json['week_start_date'] as String?;
    if (weekStartDateStr != null) {
      try {
        weekStartDate = DateTime.parse(weekStartDateStr);
      } catch (_) {
        weekStartDate = null;
      }
    }

    // Parse stable timetable fields
    final isStable = json['is_stable'] as bool? ?? true;
    final stableLessonId = json['stable_lesson_id'] as String?;
    final modifiedFromStable = json['modified_from_stable'] as bool? ?? false;

    return ScheduleLesson(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      classId: classId ?? '',
      dayOfWeek: dayOfWeek,
      startTime: startTime,
      endTime: endTime,
      subjectName: subjectName,
      teacherId: teacherId,
      teacherName: teacherName,
      room: json['room'] as String?,
      createdAt: createdAt,
      isStable: isStable,
      stableLessonId: stableLessonId,
      weekStartDate: weekStartDate,
      modifiedFromStable: modifiedFromStable,
    );
  }

  /// Converts this [ScheduleLesson] to a JSON map for database insertion.
  /// Note: The lessons table doesn't have class_id - it's linked through subject_id.
  Map<String, dynamic> toJson() {
    // Convert day_of_week from app format (1=Monday) to DB format (0=Sunday)
    final dbDayOfWeek = dayOfWeek == 7 ? 0 : dayOfWeek;

    return {
      if (id.isNotEmpty && !id.startsWith('temp_')) 'id': id,
      'subject_id': subjectId,
      // Note: class_id is not stored in lessons table, it's derived from subject
      'day_of_week': dbDayOfWeek,
      'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
      'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
      'room': room,
      'is_stable': isStable,
      if (stableLessonId != null) 'stable_lesson_id': stableLessonId,
      if (weekStartDate != null) 'week_start_date': weekStartDate!.toIso8601String().split('T')[0],
    };
  }

  /// Creates a copy of this [ScheduleLesson] with the given fields replaced.
  ScheduleLesson copyWith({
    String? id,
    String? subjectId,
    String? classId,
    int? dayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? subjectName,
    int? subjectColor,
    String? teacherId,
    String? teacherName,
    String? room,
    DateTime? createdAt,
    bool? isStable,
    String? stableLessonId,
    DateTime? weekStartDate,
    bool? modifiedFromStable,
  }) {
    return ScheduleLesson(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      classId: classId ?? this.classId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectName: subjectName ?? this.subjectName,
      subjectColor: subjectColor ?? this.subjectColor,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      room: room ?? this.room,
      createdAt: createdAt ?? this.createdAt,
      isStable: isStable ?? this.isStable,
      stableLessonId: stableLessonId ?? this.stableLessonId,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      modifiedFromStable: modifiedFromStable ?? this.modifiedFromStable,
    );
  }

  /// Returns the day name for this lesson.
  String get dayName {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek - 1];
  }

  /// Returns a formatted time range string.
  String get timeRange {
    String formatTime(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  /// Returns the duration of the lesson in minutes.
  int get durationMinutes {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  /// Checks if this lesson conflicts with another lesson.
  bool conflictsWith(ScheduleLesson other) {
    if (dayOfWeek != other.dayOfWeek) return false;
    if (classId != other.classId) return false;
    if (id == other.id) return false;

    final thisStart = startTime.hour * 60 + startTime.minute;
    final thisEnd = endTime.hour * 60 + endTime.minute;
    final otherStart = other.startTime.hour * 60 + other.startTime.minute;
    final otherEnd = other.endTime.hour * 60 + other.endTime.minute;

    return !(thisEnd <= otherStart || thisStart >= otherEnd);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScheduleLesson &&
        other.id == id &&
        other.subjectId == subjectId &&
        other.classId == classId &&
        other.dayOfWeek == dayOfWeek &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.room == room;
  }

  @override
  int get hashCode => Object.hash(
        id,
        subjectId,
        classId,
        dayOfWeek,
        startTime,
        endTime,
        room,
      );

  @override
  String toString() =>
      'ScheduleLesson(id: $id, subject: $subjectName, day: $dayName, time: $timeRange, room: $room)';
}
