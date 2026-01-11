import 'assignment.dart';
import 'lesson.dart';

/// Aggregated dashboard data containing all information needed
/// for the dashboard view.
///
/// This includes today's lessons and upcoming assignments.
class DashboardData {
  /// Creates a [DashboardData] instance.
  const DashboardData({
    required this.todayLessons,
    required this.upcomingAssignments,
    this.currentLesson,
    this.nextLesson,
  });

  /// List of all lessons scheduled for today.
  final List<Lesson> todayLessons;

  /// List of upcoming assignments (typically within the next few days).
  final List<Assignment> upcomingAssignments;

  /// The lesson that is currently in progress (if any).
  final Lesson? currentLesson;

  /// The next upcoming lesson today (if any).
  final Lesson? nextLesson;

  /// Creates a copy of this [DashboardData] with the given fields replaced
  /// with new values.
  DashboardData copyWith({
    List<Lesson>? todayLessons,
    List<Assignment>? upcomingAssignments,
    Lesson? currentLesson,
    Lesson? nextLesson,
  }) {
    return DashboardData(
      todayLessons: todayLessons ?? this.todayLessons,
      upcomingAssignments: upcomingAssignments ?? this.upcomingAssignments,
      currentLesson: currentLesson ?? this.currentLesson,
      nextLesson: nextLesson ?? this.nextLesson,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardData &&
        _listEquals(other.todayLessons, todayLessons) &&
        _listEquals(other.upcomingAssignments, upcomingAssignments) &&
        other.currentLesson == currentLesson &&
        other.nextLesson == nextLesson;
  }

  /// Helper method to compare lists.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(todayLessons),
        Object.hashAll(upcomingAssignments),
        currentLesson,
        nextLesson,
      );

  @override
  String toString() => 'DashboardData(todayLessons: ${todayLessons.length}, '
      'upcomingAssignments: ${upcomingAssignments.length}, '
      'currentLesson: ${currentLesson?.subject.name}, '
      'nextLesson: ${nextLesson?.subject.name})';
}
