import 'package:flutter/material.dart';

import '../../../dashboard/domain/entities/lesson.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/repositories/schedule_repository.dart';

/// Mock implementation of [ScheduleRepository] for testing and development.
///
/// Provides realistic fake data for a student's weekly schedule including:
/// - Multiple subjects with different colors
/// - Full week schedule (Monday-Friday)
/// - Realistic school times (8:00-15:00)
/// - Various lesson statuses (normal, cancelled, substitution)
/// - Wednesday half day
class MockScheduleRepository implements ScheduleRepository {
  /// Creates a [MockScheduleRepository] instance.
  MockScheduleRepository() {
    _initializeSubjects();
  }

  // Mock subjects with colors
  late final Subject _mathematics;
  late final Subject _physics;
  late final Subject _chemistry;
  late final Subject _english;
  late final Subject _history;
  late final Subject _geography;
  late final Subject _computerScience;
  late final Subject _physicalEducation;

  /// Initializes mock subjects with realistic colors and teachers.
  void _initializeSubjects() {
    _mathematics = const Subject(
      id: 'math-1',
      name: 'Mathematics',
      color: Colors.blue,
      teacherName: 'Dr. Johnson',
    );

    _physics = const Subject(
      id: 'phys-1',
      name: 'Physics',
      color: Colors.orange,
      teacherName: 'Prof. Anderson',
    );

    _chemistry = const Subject(
      id: 'chem-1',
      name: 'Chemistry',
      color: Colors.green,
      teacherName: 'Dr. Martinez',
    );

    _english = const Subject(
      id: 'eng-1',
      name: 'English',
      color: Colors.red,
      teacherName: 'Mr. Smith',
    );

    _history = const Subject(
      id: 'hist-1',
      name: 'History',
      color: Colors.brown,
      teacherName: 'Dr. Williams',
    );

    _geography = const Subject(
      id: 'geo-1',
      name: 'Geography',
      color: Colors.teal,
      teacherName: 'Ms. Taylor',
    );

    _computerScience = const Subject(
      id: 'cs-1',
      name: 'Computer Science',
      color: Colors.purple,
      teacherName: 'Mr. Chen',
    );

    _physicalEducation = const Subject(
      id: 'pe-1',
      name: 'Physical Education',
      color: Colors.cyan,
      teacherName: 'Coach Davis',
    );
  }

  /// Creates a lesson with proper timing.
  ///
  /// [periodNumber] is 1-indexed (1st period, 2nd period, etc.)
  Lesson _createLesson({
    required String id,
    required Subject subject,
    required DateTime baseDate,
    required int periodNumber,
    LessonStatus status = LessonStatus.normal,
    String? substituteTeacher,
    String? note,
    String? room,
  }) {
    // School schedule:
    // 1st period: 8:00 - 8:45
    // 2nd period: 8:55 - 9:40
    // 3rd period: 9:50 - 10:35
    // 4th period: 10:45 - 11:30
    // 5th period: 11:40 - 12:25
    // 6th period: 12:35 - 13:20
    // 7th period: 13:30 - 14:15
    // 8th period: 14:25 - 15:10

    final periodTimes = [
      {'start': const Duration(hours: 8), 'end': const Duration(hours: 8, minutes: 45)},
      {'start': const Duration(hours: 8, minutes: 55), 'end': const Duration(hours: 9, minutes: 40)},
      {'start': const Duration(hours: 9, minutes: 50), 'end': const Duration(hours: 10, minutes: 35)},
      {'start': const Duration(hours: 10, minutes: 45), 'end': const Duration(hours: 11, minutes: 30)},
      {'start': const Duration(hours: 11, minutes: 40), 'end': const Duration(hours: 12, minutes: 25)},
      {'start': const Duration(hours: 12, minutes: 35), 'end': const Duration(hours: 13, minutes: 20)},
      {'start': const Duration(hours: 13, minutes: 30), 'end': const Duration(hours: 14, minutes: 15)},
      {'start': const Duration(hours: 14, minutes: 25), 'end': const Duration(hours: 15, minutes: 10)},
    ];

    final periodIndex = periodNumber - 1;
    final startDuration = periodTimes[periodIndex]['start']!;
    final endDuration = periodTimes[periodIndex]['end']!;

    return Lesson(
      id: id,
      subject: subject,
      startTime: baseDate.add(startDuration),
      endTime: baseDate.add(endDuration),
      room: room ?? _getDefaultRoom(subject),
      status: status,
      substituteTeacher: substituteTeacher,
      note: note,
    );
  }

  /// Returns a default room based on subject type.
  String _getDefaultRoom(Subject subject) {
    switch (subject.id) {
      case 'math-1':
        return 'A101';
      case 'phys-1':
        return 'B203';
      case 'chem-1':
        return 'Lab 1';
      case 'eng-1':
        return 'A302';
      case 'hist-1':
        return 'C104';
      case 'geo-1':
        return 'C105';
      case 'cs-1':
        return 'IT Lab';
      case 'pe-1':
        return 'Gym';
      default:
        return 'A101';
    }
  }

  /// Generates lessons for a specific day of the week.
  List<Lesson> _generateLessonsForWeekday(DateTime date, int weekday) {
    final baseDate = DateTime(date.year, date.month, date.day);

    switch (weekday) {
      case 1: // Monday - Full day (7 lessons)
        return [
          _createLesson(id: 'mon-1', subject: _mathematics, baseDate: baseDate, periodNumber: 1),
          _createLesson(id: 'mon-2', subject: _physics, baseDate: baseDate, periodNumber: 2),
          _createLesson(id: 'mon-3', subject: _english, baseDate: baseDate, periodNumber: 3),
          _createLesson(
            id: 'mon-4',
            subject: _chemistry,
            baseDate: baseDate,
            periodNumber: 4,
            status: LessonStatus.substitution,
            substituteTeacher: 'Dr. Brown',
          ),
          _createLesson(id: 'mon-5', subject: _history, baseDate: baseDate, periodNumber: 5),
          _createLesson(id: 'mon-6', subject: _computerScience, baseDate: baseDate, periodNumber: 6),
          _createLesson(id: 'mon-7', subject: _physicalEducation, baseDate: baseDate, periodNumber: 7),
        ];

      case 2: // Tuesday - Full day (6 lessons)
        return [
          _createLesson(id: 'tue-1', subject: _english, baseDate: baseDate, periodNumber: 1),
          _createLesson(id: 'tue-2', subject: _mathematics, baseDate: baseDate, periodNumber: 2),
          _createLesson(
            id: 'tue-3',
            subject: _geography,
            baseDate: baseDate,
            periodNumber: 3,
            status: LessonStatus.cancelled,
            note: 'Teacher conference',
          ),
          _createLesson(id: 'tue-4', subject: _physics, baseDate: baseDate, periodNumber: 4),
          _createLesson(id: 'tue-5', subject: _chemistry, baseDate: baseDate, periodNumber: 5),
          _createLesson(id: 'tue-6', subject: _history, baseDate: baseDate, periodNumber: 6),
        ];

      case 3: // Wednesday - Half day (4 lessons)
        return [
          _createLesson(id: 'wed-1', subject: _computerScience, baseDate: baseDate, periodNumber: 1),
          _createLesson(id: 'wed-2', subject: _mathematics, baseDate: baseDate, periodNumber: 2),
          _createLesson(id: 'wed-3', subject: _english, baseDate: baseDate, periodNumber: 3),
          _createLesson(id: 'wed-4', subject: _physicalEducation, baseDate: baseDate, periodNumber: 4),
        ];

      case 4: // Thursday - Full day (7 lessons)
        return [
          _createLesson(id: 'thu-1', subject: _physics, baseDate: baseDate, periodNumber: 1),
          _createLesson(id: 'thu-2', subject: _chemistry, baseDate: baseDate, periodNumber: 2),
          _createLesson(id: 'thu-3', subject: _mathematics, baseDate: baseDate, periodNumber: 3),
          _createLesson(id: 'thu-4', subject: _geography, baseDate: baseDate, periodNumber: 4),
          _createLesson(
            id: 'thu-5',
            subject: _english,
            baseDate: baseDate,
            periodNumber: 5,
            status: LessonStatus.substitution,
            substituteTeacher: 'Ms. Thompson',
          ),
          _createLesson(id: 'thu-6', subject: _history, baseDate: baseDate, periodNumber: 6),
          _createLesson(id: 'thu-7', subject: _computerScience, baseDate: baseDate, periodNumber: 7),
        ];

      case 5: // Friday - Regular day (6 lessons)
        return [
          _createLesson(id: 'fri-1', subject: _mathematics, baseDate: baseDate, periodNumber: 1),
          _createLesson(id: 'fri-2', subject: _english, baseDate: baseDate, periodNumber: 2),
          _createLesson(
            id: 'fri-3',
            subject: _physics,
            baseDate: baseDate,
            periodNumber: 3,
            status: LessonStatus.cancelled,
            note: 'School assembly',
          ),
          _createLesson(id: 'fri-4', subject: _geography, baseDate: baseDate, periodNumber: 4),
          _createLesson(id: 'fri-5', subject: _chemistry, baseDate: baseDate, periodNumber: 5),
          _createLesson(id: 'fri-6', subject: _physicalEducation, baseDate: baseDate, periodNumber: 6),
        ];

      case 6: // Saturday - No school
      case 7: // Sunday - No school
      default:
        return [];
    }
  }

  @override
  Future<List<Lesson>> getLessonsForDay(DateTime date) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    final weekday = date.weekday;
    return _generateLessonsForWeekday(date, weekday);
  }

  @override
  Future<Map<int, List<Lesson>>> getWeekLessons(DateTime weekStart) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final Map<int, List<Lesson>> weekLessons = {};

    // Generate lessons for Monday (1) through Sunday (7)
    for (int weekday = 1; weekday <= 7; weekday++) {
      final dayDate = weekStart.add(Duration(days: weekday - 1));
      weekLessons[weekday] = _generateLessonsForWeekday(dayDate, weekday);
    }

    return weekLessons;
  }
}
