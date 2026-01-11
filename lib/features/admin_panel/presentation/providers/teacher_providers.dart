import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/supabase_teacher_repository.dart';
import '../../domain/domain.dart';

part 'teacher_providers.g.dart';

/// Provider for the [TeacherRepository] implementation.
///
/// Returns a [SupabaseTeacherRepository] for production use.
@riverpod
TeacherRepository teacherRepository(Ref ref) {
  return SupabaseTeacherRepository();
}

/// Provider that fetches subjects for the teacher dashboard.
///
/// [teacherId] - The ID of the teacher to fetch subjects for.
///
/// Returns an [AsyncValue] containing the list of [TeacherSubject]s
/// with their class counts. Unlike the basic teacherSubjects provider,
/// this returns TeacherSubject entities with additional dashboard-specific
/// fields like classCount and description.
@riverpod
Future<List<TeacherSubject>> teacherDashboardSubjects(
  Ref ref,
  String teacherId,
) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return await repository.getTeacherSubjects(teacherId);
}

/// State class for the teacher dashboard.
class TeacherDashboardState {
  const TeacherDashboardState({
    this.subjects = const [],
    this.isLoading = false,
    this.error,
  });

  /// List of subjects taught by the teacher.
  final List<TeacherSubject> subjects;

  /// Whether the data is being loaded.
  final bool isLoading;

  /// Error message if loading failed.
  final String? error;

  /// Whether the state has an error.
  bool get hasError => error != null;

  /// Whether the state has data.
  bool get hasData => subjects.isNotEmpty || (!isLoading && error == null);

  TeacherDashboardState copyWith({
    List<TeacherSubject>? subjects,
    bool? isLoading,
    String? error,
  }) {
    return TeacherDashboardState(
      subjects: subjects ?? this.subjects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing the teacher dashboard state.
///
/// Handles fetching and refreshing of teacher subjects data.
@riverpod
class TeacherDashboardNotifier extends _$TeacherDashboardNotifier {
  @override
  TeacherDashboardState build(String teacherId) {
    // Load initial data
    _loadSubjects(teacherId);
    return const TeacherDashboardState(isLoading: true);
  }

  Future<void> _loadSubjects(String teacherId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final repository = ref.read(teacherRepositoryProvider);
      final subjects = await repository.getTeacherSubjects(teacherId);
      state = TeacherDashboardState(subjects: subjects, isLoading: false);
    } catch (e) {
      state = TeacherDashboardState(isLoading: false, error: e.toString());
    }
  }

  /// Refreshes the teacher's subjects data.
  Future<void> refresh() async {
    // Re-use the build parameter by invalidating the provider
    ref.invalidateSelf();
  }
}
