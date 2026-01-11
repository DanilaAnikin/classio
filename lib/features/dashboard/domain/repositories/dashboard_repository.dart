import '../entities/entities.dart';

/// Repository interface for dashboard data operations.
///
/// Defines the contract for fetching dashboard-related data such as
/// lessons, assignments, and aggregated dashboard information.
abstract class DashboardRepository {
  /// Fetches all dashboard data including today's lessons and upcoming assignments.
  ///
  /// Returns a [DashboardData] object containing:
  /// - Today's lessons
  /// - Upcoming assignments
  /// - Current lesson (if any)
  /// - Next lesson (if any)
  Future<DashboardData> getDashboardData();

  /// Fetches all lessons scheduled for today.
  ///
  /// Returns a list of [Lesson] objects sorted by start time.
  Future<List<Lesson>> getTodayLessons();

  /// Fetches upcoming assignments.
  ///
  /// The [days] parameter specifies how many days ahead to look for assignments.
  /// Defaults to 2 days.
  ///
  /// Returns a list of [Assignment] objects sorted by due date.
  Future<List<Assignment>> getUpcomingAssignments({int days = 2});

  /// Refreshes the dashboard data by clearing any cached data.
  ///
  /// This method should be called when the user wants to force a refresh
  /// of all dashboard data from the data source.
  Future<void> refreshDashboard();
}
