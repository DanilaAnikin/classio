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
/// - Support for stable timetable and week-specific modifications
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

  // Mock class ID for testing
  static const String _mockClassId = 'mock-class-1';

  // Store for stable lessons
  final Map<String, Lesson> _stableLessons = {};

  // Store for week-specific lessons (key: 'classId-weekStartDate')
  final Map<String, Map<int, List<Lesson>>> _weekLessons = {};

  /// Initializes mock subjects with realistic colors and teachers.
  void _initializeSubjects() {
    _mathematics = const Subject(
      id: 'math-1',
      name: 'Mathematics',
      color: 0xFF2196F3, // Blue
      teacherName: 'Dr. Johnson',
    );

    _physics = const Subject(
      id: 'phys-1',
      name: 'Physics',
      color: 0xFFFF5722, // Deep Orange
      teacherName: 'Prof. Anderson',
    );

    _chemistry = const Subject(
      id: 'chem-1',
      name: 'Chemistry',
      color: 0xFF4CAF50, // Green
      teacherName: 'Dr. Martinez',
    );

    _english = const Subject(
      id: 'eng-1',
      name: 'English',
      color: 0xFFF44336, // Red
      teacherName: 'Mr. Smith',
    );

    _history = const Subject(
      id: 'hist-1',
      name: 'History',
      color: 0xFF795548, // Brown
      teacherName: 'Dr. Williams',
    );

    _geography = const Subject(
      id: 'geo-1',
      name: 'Geography',
      color: 0xFF009688, // Teal
      teacherName: 'Ms. Taylor',
    );

    _computerScience = const Subject(
      id: 'cs-1',
      name: 'Computer Science',
      color: 0xFF9C27B0, // Purple
      teacherName: 'Mr. Chen',
    );

    _physicalEducation = const Subject(
      id: 'pe-1',
      name: 'Physical Education',
      color: 0xFF00BCD4, // Cyan
      teacherName: 'Coach Davis',
    );

    // Initialize stable lessons
    _initializeStableLessons();
  }

  /// Initializes the stable (baseline) timetable.
  void _initializeStableLessons() {
    // Generate stable lessons for each weekday
    final today = DateTime.now();
    final mondayOfWeek = _getMondayOfWeek(today);

    for (int weekday = 1; weekday <= 5; weekday++) {
      final dayDate = mondayOfWeek.add(Duration(days: weekday - 1));
      final lessons = _generateStableLessonsForWeekday(dayDate, weekday);
      for (final lesson in lessons) {
        _stableLessons[lesson.id] = lesson;
      }
    }
  }

  /// Returns the Monday of the week containing the given date.
  DateTime _getMondayOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  /// Creates a stable lesson with proper timing.
  ///
  /// [periodNumber] is 1-indexed (1st period, 2nd period, etc.)
  Lesson _createStableLesson({
    required String id,
    required Subject subject,
    required DateTime baseDate,
    required int periodNumber,
    String? room,
  }) {
    final periodTimes = _getPeriodTimes();
    final periodIndex = periodNumber - 1;
    final startDuration = periodTimes[periodIndex]['start']!;
    final endDuration = periodTimes[periodIndex]['end']!;

    return Lesson(
      id: id,
      subject: subject,
      startTime: baseDate.add(startDuration),
      endTime: baseDate.add(endDuration),
      room: room ?? _getDefaultRoom(subject),
      status: LessonStatus.normal,
      isStable: true,
      stableLessonId: null,
      modifiedFromStable: false,
      weekStartDate: null,
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
    bool isStable = false,
    String? stableLessonId,
    bool modifiedFromStable = false,
    DateTime? weekStartDate,
    Lesson? stableLesson,
  }) {
    final periodTimes = _getPeriodTimes();
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
      isStable: isStable,
      stableLessonId: stableLessonId,
      modifiedFromStable: modifiedFromStable,
      weekStartDate: weekStartDate,
      stableLesson: stableLesson,
    );
  }

  /// Returns the period times for the school schedule.
  List<Map<String, Duration>> _getPeriodTimes() {
    return [
      {'start': const Duration(hours: 8), 'end': const Duration(hours: 8, minutes: 45)},
      {'start': const Duration(hours: 8, minutes: 55), 'end': const Duration(hours: 9, minutes: 40)},
      {'start': const Duration(hours: 9, minutes: 50), 'end': const Duration(hours: 10, minutes: 35)},
      {'start': const Duration(hours: 10, minutes: 45), 'end': const Duration(hours: 11, minutes: 30)},
      {'start': const Duration(hours: 11, minutes: 40), 'end': const Duration(hours: 12, minutes: 25)},
      {'start': const Duration(hours: 12, minutes: 35), 'end': const Duration(hours: 13, minutes: 20)},
      {'start': const Duration(hours: 13, minutes: 30), 'end': const Duration(hours: 14, minutes: 15)},
      {'start': const Duration(hours: 14, minutes: 25), 'end': const Duration(hours: 15, minutes: 10)},
    ];
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

  /// Generates stable lessons for a specific day of the week.
  List<Lesson> _generateStableLessonsForWeekday(DateTime date, int weekday) {
    final baseDate = DateTime(date.year, date.month, date.day);

    switch (weekday) {
      case 1: // Monday - Full day (7 lessons)
        return [
          _createStableLesson(id: 'stable-mon-1', subject: _mathematics, baseDate: baseDate, periodNumber: 1),
          _createStableLesson(id: 'stable-mon-2', subject: _physics, baseDate: baseDate, periodNumber: 2),
          _createStableLesson(id: 'stable-mon-3', subject: _english, baseDate: baseDate, periodNumber: 3),
          _createStableLesson(id: 'stable-mon-4', subject: _chemistry, baseDate: baseDate, periodNumber: 4),
          _createStableLesson(id: 'stable-mon-5', subject: _history, baseDate: baseDate, periodNumber: 5),
          _createStableLesson(id: 'stable-mon-6', subject: _computerScience, baseDate: baseDate, periodNumber: 6),
          _createStableLesson(id: 'stable-mon-7', subject: _physicalEducation, baseDate: baseDate, periodNumber: 7),
        ];

      case 2: // Tuesday - Full day (6 lessons)
        return [
          _createStableLesson(id: 'stable-tue-1', subject: _english, baseDate: baseDate, periodNumber: 1),
          _createStableLesson(id: 'stable-tue-2', subject: _mathematics, baseDate: baseDate, periodNumber: 2),
          _createStableLesson(id: 'stable-tue-3', subject: _geography, baseDate: baseDate, periodNumber: 3),
          _createStableLesson(id: 'stable-tue-4', subject: _physics, baseDate: baseDate, periodNumber: 4),
          _createStableLesson(id: 'stable-tue-5', subject: _chemistry, baseDate: baseDate, periodNumber: 5),
          _createStableLesson(id: 'stable-tue-6', subject: _history, baseDate: baseDate, periodNumber: 6),
        ];

      case 3: // Wednesday - Half day (4 lessons)
        return [
          _createStableLesson(id: 'stable-wed-1', subject: _computerScience, baseDate: baseDate, periodNumber: 1),
          _createStableLesson(id: 'stable-wed-2', subject: _mathematics, baseDate: baseDate, periodNumber: 2),
          _createStableLesson(id: 'stable-wed-3', subject: _english, baseDate: baseDate, periodNumber: 3),
          _createStableLesson(id: 'stable-wed-4', subject: _physicalEducation, baseDate: baseDate, periodNumber: 4),
        ];

      case 4: // Thursday - Full day (7 lessons)
        return [
          _createStableLesson(id: 'stable-thu-1', subject: _physics, baseDate: baseDate, periodNumber: 1),
          _createStableLesson(id: 'stable-thu-2', subject: _chemistry, baseDate: baseDate, periodNumber: 2),
          _createStableLesson(id: 'stable-thu-3', subject: _mathematics, baseDate: baseDate, periodNumber: 3),
          _createStableLesson(id: 'stable-thu-4', subject: _geography, baseDate: baseDate, periodNumber: 4),
          _createStableLesson(id: 'stable-thu-5', subject: _english, baseDate: baseDate, periodNumber: 5),
          _createStableLesson(id: 'stable-thu-6', subject: _history, baseDate: baseDate, periodNumber: 6),
          _createStableLesson(id: 'stable-thu-7', subject: _computerScience, baseDate: baseDate, periodNumber: 7),
        ];

      case 5: // Friday - Regular day (6 lessons)
        return [
          _createStableLesson(id: 'stable-fri-1', subject: _mathematics, baseDate: baseDate, periodNumber: 1),
          _createStableLesson(id: 'stable-fri-2', subject: _english, baseDate: baseDate, periodNumber: 2),
          _createStableLesson(id: 'stable-fri-3', subject: _physics, baseDate: baseDate, periodNumber: 3),
          _createStableLesson(id: 'stable-fri-4', subject: _geography, baseDate: baseDate, periodNumber: 4),
          _createStableLesson(id: 'stable-fri-5', subject: _chemistry, baseDate: baseDate, periodNumber: 5),
          _createStableLesson(id: 'stable-fri-6', subject: _physicalEducation, baseDate: baseDate, periodNumber: 6),
        ];

      case 6: // Saturday - No school
      case 7: // Sunday - No school
      default:
        return [];
    }
  }

  /// Generates lessons for a specific day of the week (with modifications).
  List<Lesson> _generateLessonsForWeekday(DateTime date, int weekday) {
    final baseDate = DateTime(date.year, date.month, date.day);
    final mondayOfWeek = _getMondayOfWeek(date);

    // Get the stable lessons for this weekday
    final stableLessons = _generateStableLessonsForWeekday(baseDate, weekday);

    // For the current week, add some modifications
    final today = DateTime.now();
    final currentMonday = _getMondayOfWeek(today);

    if (mondayOfWeek.year == currentMonday.year &&
        mondayOfWeek.month == currentMonday.month &&
        mondayOfWeek.day == currentMonday.day) {
      // Current week - add some modifications
      return stableLessons.map((stable) {
        // Apply modifications to specific lessons
        if (stable.id == 'stable-mon-4') {
          return _createLesson(
            id: 'week-mon-4',
            subject: stable.subject,
            baseDate: baseDate,
            periodNumber: 4,
            status: LessonStatus.substitution,
            substituteTeacher: 'Dr. Brown',
            stableLessonId: stable.id,
            modifiedFromStable: true,
            weekStartDate: mondayOfWeek,
            stableLesson: stable,
          );
        } else if (stable.id == 'stable-tue-3') {
          return _createLesson(
            id: 'week-tue-3',
            subject: stable.subject,
            baseDate: baseDate,
            periodNumber: 3,
            status: LessonStatus.cancelled,
            note: 'Teacher conference',
            stableLessonId: stable.id,
            modifiedFromStable: true,
            weekStartDate: mondayOfWeek,
            stableLesson: stable,
          );
        } else if (stable.id == 'stable-thu-5') {
          return _createLesson(
            id: 'week-thu-5',
            subject: stable.subject,
            baseDate: baseDate,
            periodNumber: 5,
            status: LessonStatus.substitution,
            substituteTeacher: 'Ms. Thompson',
            stableLessonId: stable.id,
            modifiedFromStable: true,
            weekStartDate: mondayOfWeek,
            stableLesson: stable,
          );
        } else if (stable.id == 'stable-fri-3') {
          return _createLesson(
            id: 'week-fri-3',
            subject: stable.subject,
            baseDate: baseDate,
            periodNumber: 3,
            status: LessonStatus.cancelled,
            note: 'School assembly',
            stableLessonId: stable.id,
            modifiedFromStable: true,
            weekStartDate: mondayOfWeek,
            stableLesson: stable,
          );
        }

        // Non-modified lessons
        return _createLesson(
          id: 'week-${stable.id.replaceAll('stable-', '')}',
          subject: stable.subject,
          baseDate: baseDate,
          periodNumber: _getPeriodNumberFromId(stable.id),
          stableLessonId: stable.id,
          modifiedFromStable: false,
          weekStartDate: mondayOfWeek,
          stableLesson: stable,
        );
      }).toList();
    }

    // Other weeks - return unmodified copies of stable lessons
    return stableLessons.map((stable) {
      return _createLesson(
        id: 'week-${stable.id.replaceAll('stable-', '')}',
        subject: stable.subject,
        baseDate: baseDate,
        periodNumber: _getPeriodNumberFromId(stable.id),
        stableLessonId: stable.id,
        modifiedFromStable: false,
        weekStartDate: mondayOfWeek,
        stableLesson: stable,
      );
    }).toList();
  }

  /// Extracts the period number from a lesson ID.
  int _getPeriodNumberFromId(String id) {
    final parts = id.split('-');
    if (parts.length >= 2) {
      final lastPart = parts.last;
      return int.tryParse(lastPart) ?? 1;
    }
    return 1;
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

    return getWeekTimetable(_mockClassId, weekStart);
  }

  @override
  Future<Map<int, List<Lesson>>> getStableTimetable(String classId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final Map<int, List<Lesson>> weekLessons = {};
    final today = DateTime.now();
    final mondayOfWeek = _getMondayOfWeek(today);

    // Generate stable lessons for Monday (1) through Sunday (7)
    for (int weekday = 1; weekday <= 7; weekday++) {
      final dayDate = mondayOfWeek.add(Duration(days: weekday - 1));
      weekLessons[weekday] = _generateStableLessonsForWeekday(dayDate, weekday);
    }

    return weekLessons;
  }

  @override
  Future<Map<int, List<Lesson>>> getWeekTimetable(
    String classId,
    DateTime weekStartDate,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final mondayOfWeek = _getMondayOfWeek(weekStartDate);
    final Map<int, List<Lesson>> weekLessons = {};

    // Generate lessons for Monday (1) through Sunday (7)
    for (int weekday = 1; weekday <= 7; weekday++) {
      final dayDate = mondayOfWeek.add(Duration(days: weekday - 1));
      weekLessons[weekday] = _generateLessonsForWeekday(dayDate, weekday);
    }

    return weekLessons;
  }

  @override
  Future<Map<int, List<Lesson>>> createWeekFromStable(
    String classId,
    DateTime weekStartDate,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // In mock, this just returns the week timetable
    return getWeekTimetable(classId, weekStartDate);
  }

  @override
  Future<Lesson> updateWeekLesson({
    required String lessonId,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In mock, we just return a modified lesson
    // In reality, this would update the database
    final today = DateTime.now();
    final baseDate = DateTime(today.year, today.month, today.day);

    return Lesson(
      id: lessonId,
      subject: _mathematics,
      startTime: baseDate.add(const Duration(hours: 8)),
      endTime: baseDate.add(const Duration(hours: 8, minutes: 45)),
      room: room ?? 'A101',
      status: LessonStatus.normal,
      isStable: false,
      stableLessonId: 'stable-mon-1',
      modifiedFromStable: true,
      weekStartDate: _getMondayOfWeek(today),
    );
  }

  @override
  Future<Lesson?> getStableLessonFor(String lessonId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Try to find a matching stable lesson
    final stableId = 'stable-${lessonId.replaceAll('week-', '')}';
    return _stableLessons[stableId];
  }
}
