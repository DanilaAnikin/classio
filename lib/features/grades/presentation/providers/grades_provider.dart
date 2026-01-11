import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/supabase_grades_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/grades_repository.dart';

part 'grades_provider.g.dart';

/// Provider for the GradesRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
GradesRepository gradesRepository(Ref ref) {
  return SupabaseGradesRepository();
}

/// Riverpod notifier for managing grades state.
///
/// Handles loading, refreshing, and managing grade data for all subjects.
/// Uses [GradesRepository] to fetch data and updates [AsyncValue<List<SubjectGradeStats>>] accordingly.
@Riverpod(keepAlive: true)
class GradesNotifier extends _$GradesNotifier {
  late final GradesRepository _repository;

  @override
  Future<List<SubjectGradeStats>> build() async {
    // Initialize repository
    _repository = ref.watch(gradesRepositoryProvider);

    // Load data on build
    return await loadGrades();
  }

  /// Loads grades data from the repository.
  ///
  /// Fetches all subject grade statistics and returns the list.
  /// The state will automatically be set to AsyncValue.loading() while fetching.
  Future<List<SubjectGradeStats>> loadGrades() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAllSubjectStats();
      state = AsyncValue.data(data);
      return data;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Refreshes the grades data.
  ///
  /// Reloads all subject grade statistics from the repository.
  /// Useful for pull-to-refresh functionality.
  Future<void> refreshGrades() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAllSubjectStats();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Helper providers for easier access to specific parts of grades data

/// Provider that returns the list of SubjectGradeStats or an empty list.
///
/// Returns an empty list if data is not yet loaded or if there's an error.
@riverpod
List<SubjectGradeStats> subjectGradesList(Ref ref) {
  final gradesAsync = ref.watch(gradesNotifierProvider);
  return gradesAsync.when(
    data: (grades) => grades,
    loading: () => [],
    error: (_, _) => [],
  );
}

/// Provider that calculates the overall average across all subjects.
///
/// Calculates the average of all subject averages.
/// Returns 0.0 if there are no subjects or data is not yet loaded.
@riverpod
double overallAverage(Ref ref) {
  final grades = ref.watch(subjectGradesListProvider);

  if (grades.isEmpty) return 0.0;

  final sum = grades.fold<double>(0.0, (sum, subject) => sum + subject.average);
  return sum / grades.length;
}
