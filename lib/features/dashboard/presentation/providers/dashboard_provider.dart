import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/supabase_dashboard_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

part 'dashboard_provider.g.dart';

/// Riverpod notifier for managing dashboard state.
///
/// Handles loading, refreshing, and managing dashboard data.
/// Uses [DashboardRepository] to fetch data and updates [DashboardState] accordingly.
@Riverpod(keepAlive: true)
class DashboardNotifier extends _$DashboardNotifier {
  late final DashboardRepository _repository;

  @override
  DashboardState build() {
    // Initialize repository - Supabase implementation for production
    _repository = SupabaseDashboardRepository();

    // Load data on build
    loadDashboard();

    return DashboardState.initial();
  }

  /// Loads dashboard data from the repository.
  ///
  /// Sets loading state, fetches data, and updates state accordingly.
  /// Catches and handles any errors during the fetch operation.
  Future<void> loadDashboard() async {
    state = DashboardState.loading();
    try {
      final data = await _repository.getDashboardData();
      state = DashboardState.loaded(data);
    } catch (e) {
      state = DashboardState.error(e.toString());
    }
  }

  /// Refreshes the dashboard data.
  ///
  /// Clears existing data and reloads from the repository.
  Future<void> refreshDashboard() async {
    await _repository.refreshDashboard();
    await loadDashboard();
  }
}

// Helper providers for easier access to specific parts of dashboard data

/// Provider that returns the current dashboard data or null.
@riverpod
DashboardData? dashboardData(Ref ref) {
  return ref.watch(dashboardNotifierProvider).dashboardData;
}

/// Provider that returns today's lessons.
@riverpod
List<Lesson> todayLessons(Ref ref) {
  return ref.watch(dashboardDataProvider)?.todayLessons ?? [];
}

/// Provider that returns upcoming assignments.
@riverpod
List<Assignment> upcomingAssignments(Ref ref) {
  return ref.watch(dashboardDataProvider)?.upcomingAssignments ?? [];
}

/// Provider that returns the current active lesson if any.
@riverpod
Lesson? currentLesson(Ref ref) {
  return ref.watch(dashboardDataProvider)?.currentLesson;
}

/// Provider that returns the next upcoming lesson if any.
@riverpod
Lesson? nextLesson(Ref ref) {
  return ref.watch(dashboardDataProvider)?.nextLesson;
}
