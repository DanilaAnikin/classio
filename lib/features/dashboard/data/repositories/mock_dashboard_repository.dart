import 'package:flutter/material.dart';

import '../../domain/domain.dart';

/// Mock implementation of [DashboardRepository] for testing and development.
///
/// Provides realistic fake data for a student's dashboard including:
/// - Multiple subjects with different colors
/// - Today's lessons with various statuses (normal, cancelled, substitution)
/// - Upcoming assignments with different due dates
class MockDashboardRepository implements DashboardRepository {
  /// Creates a [MockDashboardRepository] instance.
  MockDashboardRepository() {
    _initializeMockData();
  }

  // Mock subjects
  late final Subject mathematics;
  late final Subject physics;
  late final Subject czechLanguage;
  late final Subject english;
  late final Subject history;
  late final Subject chemistry;
  late final Subject physicalEducation;

  // Mock data
  late final List<Lesson> _todayLessons;
  late final List<Assignment> _upcomingAssignments;

  /// Initializes all mock data.
  void _initializeMockData() {
    _initializeSubjects();
    _initializeLessons();
    _initializeAssignments();
  }

  /// Initializes mock subjects.
  void _initializeSubjects() {
    mathematics = const Subject(
      id: 'math-1',
      name: 'Mathematics',
      color: Colors.blue,
      teacherName: 'Dr. Johnson',
    );

    physics = const Subject(
      id: 'phys-1',
      name: 'Physics',
      color: Colors.orange,
      teacherName: 'Prof. Anderson',
    );

    czechLanguage = const Subject(
      id: 'czech-1',
      name: 'Czech Language',
      color: Colors.red,
      teacherName: 'Ms. Nováková',
    );

    english = const Subject(
      id: 'eng-1',
      name: 'English',
      color: Colors.purple,
      teacherName: 'Mr. Smith',
    );

    history = const Subject(
      id: 'hist-1',
      name: 'History',
      color: Colors.brown,
      teacherName: 'Dr. Williams',
    );

    chemistry = const Subject(
      id: 'chem-1',
      name: 'Chemistry',
      color: Colors.green,
      teacherName: 'Dr. Martinez',
    );

    physicalEducation = const Subject(
      id: 'pe-1',
      name: 'Physical Education',
      color: Colors.teal,
      teacherName: 'Coach Davis',
    );
  }

  /// Initializes today's lessons with realistic school times.
  void _initializeLessons() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _todayLessons = [
      // 1st period: 8:00 - 8:45
      Lesson(
        id: 'lesson-1',
        subject: mathematics,
        startTime: today.add(const Duration(hours: 8)),
        endTime: today.add(const Duration(hours: 8, minutes: 45)),
        room: 'A101',
        status: LessonStatus.normal,
      ),

      // 2nd period: 8:55 - 9:40
      Lesson(
        id: 'lesson-2',
        subject: physics,
        startTime: today.add(const Duration(hours: 8, minutes: 55)),
        endTime: today.add(const Duration(hours: 9, minutes: 40)),
        room: 'B203',
        status: LessonStatus.normal,
      ),

      // 3rd period: 9:50 - 10:35 (CANCELLED)
      Lesson(
        id: 'lesson-3',
        subject: czechLanguage,
        startTime: today.add(const Duration(hours: 9, minutes: 50)),
        endTime: today.add(const Duration(hours: 10, minutes: 35)),
        room: 'A205',
        status: LessonStatus.cancelled,
        note: 'Teacher is sick',
      ),

      // 4th period: 10:45 - 11:30 (SUBSTITUTION)
      Lesson(
        id: 'lesson-4',
        subject: english,
        startTime: today.add(const Duration(hours: 10, minutes: 45)),
        endTime: today.add(const Duration(hours: 11, minutes: 30)),
        room: 'A302',
        status: LessonStatus.substitution,
        substituteTeacher: 'Ms. Thompson',
      ),

      // 5th period: 11:40 - 12:25
      Lesson(
        id: 'lesson-5',
        subject: history,
        startTime: today.add(const Duration(hours: 11, minutes: 40)),
        endTime: today.add(const Duration(hours: 12, minutes: 25)),
        room: 'C104',
        status: LessonStatus.normal,
      ),

      // 6th period: 12:35 - 13:20
      Lesson(
        id: 'lesson-6',
        subject: physicalEducation,
        startTime: today.add(const Duration(hours: 12, minutes: 35)),
        endTime: today.add(const Duration(hours: 13, minutes: 20)),
        room: 'Gym',
        status: LessonStatus.normal,
      ),
    ];
  }

  /// Initializes upcoming assignments.
  void _initializeAssignments() {
    final now = DateTime.now();

    _upcomingAssignments = [
      // Due today
      Assignment(
        id: 'assign-1',
        subject: mathematics,
        title: 'Quadratic Equations Worksheet',
        dueDate: DateTime(now.year, now.month, now.day, 23, 59),
        description: 'Complete exercises 1-15 from chapter 5',
      ),

      // Due tomorrow
      Assignment(
        id: 'assign-2',
        subject: physics,
        title: 'Lab Report - Motion Experiment',
        dueDate: DateTime(now.year, now.month, now.day + 1, 23, 59),
        description:
            'Write a detailed lab report about the motion experiment we conducted last week. Include graphs and analysis.',
      ),

      // Due in 2 days
      Assignment(
        id: 'assign-3',
        subject: english,
        title: 'Essay on Shakespeare',
        dueDate: DateTime(now.year, now.month, now.day + 2, 23, 59),
        description:
            'Write a 500-word essay analyzing the themes in Romeo and Juliet',
      ),

      // Due in 3 days (completed)
      Assignment(
        id: 'assign-4',
        subject: chemistry,
        title: 'Chemical Bonds Review',
        dueDate: DateTime(now.year, now.month, now.day + 3, 23, 59),
        isCompleted: true,
      ),

      // Due in 2 days - no description
      Assignment(
        id: 'assign-5',
        subject: history,
        title: 'Read Chapter 12',
        dueDate: DateTime(now.year, now.month, now.day + 2, 23, 59),
      ),
    ];
  }

  @override
  Future<DashboardData> getDashboardData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Find current lesson (if any)
    Lesson? currentLesson;
    for (final lesson in _todayLessons) {
      if (lesson.isInProgress) {
        currentLesson = lesson;
        break;
      }
    }

    // Find next lesson (if any)
    Lesson? nextLesson;
    for (final lesson in _todayLessons) {
      if (lesson.isUpcoming) {
        nextLesson = lesson;
        break;
      }
    }

    return DashboardData(
      todayLessons: _todayLessons,
      upcomingAssignments: _upcomingAssignments,
      currentLesson: currentLesson,
      nextLesson: nextLesson,
    );
  }

  @override
  Future<List<Lesson>> getTodayLessons() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _todayLessons;
  }

  @override
  Future<List<Assignment>> getUpcomingAssignments({int days = 2}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: days));

    // Filter assignments that are due within the specified number of days
    return _upcomingAssignments
        .where((assignment) =>
            assignment.dueDate.isBefore(cutoffDate) &&
            assignment.dueDate.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  @override
  Future<void> refreshDashboard() async {
    // Simulate network delay for refresh
    await Future.delayed(const Duration(milliseconds: 300));

    // Re-initialize the mock data to simulate a fresh fetch
    _initializeMockData();
  }
}
