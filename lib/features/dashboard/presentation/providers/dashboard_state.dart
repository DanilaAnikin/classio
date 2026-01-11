import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';

/// State class for dashboard data and loading state.
///
/// Represents the current state of the dashboard including data,
/// loading status, and any error messages.
@immutable
class DashboardState {
  const DashboardState({
    this.dashboardData,
    this.isLoading = true,
    this.error,
  });

  final DashboardData? dashboardData;
  final bool isLoading;
  final String? error;

  /// Creates a copy of this state with the given fields replaced.
  DashboardState copyWith({
    DashboardData? dashboardData,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      dashboardData: dashboardData ?? this.dashboardData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Factory constructors for common states

  /// Initial state when the dashboard is first created.
  factory DashboardState.initial() => const DashboardState();

  /// Loading state while fetching data.
  factory DashboardState.loading() => const DashboardState(isLoading: true);

  /// Loaded state with dashboard data.
  factory DashboardState.loaded(DashboardData data) =>
      DashboardState(dashboardData: data, isLoading: false);

  /// Error state with an error message.
  factory DashboardState.error(String message) =>
      DashboardState(error: message, isLoading: false);

  /// Getter to check if data has been loaded successfully.
  bool get hasData => dashboardData != null;

  /// Getter to check if there's an error.
  bool get hasError => error != null;

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, hasData: $hasData, hasError: $hasError)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardState &&
        other.dashboardData == dashboardData &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      dashboardData,
      isLoading,
      error,
    );
  }
}
