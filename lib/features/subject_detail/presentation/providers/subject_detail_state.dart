import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';

/// State class for subject detail data and loading state.
///
/// Represents the current state of the subject detail view including data,
/// loading status, and any error messages.
@immutable
class SubjectDetailState {
  const SubjectDetailState({
    this.data,
    this.isLoading = true,
    this.error,
  });

  final SubjectDetail? data;
  final bool isLoading;
  final String? error;

  /// Creates a copy of this state with the given fields replaced.
  SubjectDetailState copyWith({
    SubjectDetail? data,
    bool? isLoading,
    String? error,
  }) {
    return SubjectDetailState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Factory constructors for common states

  /// Initial state when the subject detail is first created.
  factory SubjectDetailState.initial() => const SubjectDetailState();

  /// Loading state while fetching data.
  factory SubjectDetailState.loading() =>
      const SubjectDetailState(isLoading: true);

  /// Loaded state with subject detail data.
  factory SubjectDetailState.loaded(SubjectDetail data) =>
      SubjectDetailState(data: data, isLoading: false);

  /// Error state with an error message.
  factory SubjectDetailState.error(String message) =>
      SubjectDetailState(error: message, isLoading: false);

  /// Getter to check if data has been loaded successfully.
  bool get hasData => data != null;

  /// Getter to check if there's an error.
  bool get hasError => error != null;

  @override
  String toString() {
    return 'SubjectDetailState(isLoading: $isLoading, hasData: $hasData, hasError: $hasError)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubjectDetailState &&
        other.data == data &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      data,
      isLoading,
      error,
    );
  }
}
