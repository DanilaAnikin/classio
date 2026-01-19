import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:classio/features/dashboard/domain/entities/assignment.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';
import 'subject_detail_state.dart';

part 'subject_detail_provider.g.dart';

/// Provider for the SubjectDetailRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
SubjectDetailRepository subjectDetailRepository(Ref ref) {
  return SupabaseSubjectDetailRepository();
}

/// Riverpod notifier for managing subject detail state.
///
/// Handles loading, refreshing, and managing subject detail data.
/// Uses [SubjectDetailRepository] to fetch data and updates [SubjectDetailState] accordingly.
@riverpod
class SubjectDetailNotifier extends _$SubjectDetailNotifier {
  late final SubjectDetailRepository _repository;

  @override
  SubjectDetailState build(String subjectId) {
    // Initialize repository via provider for testability
    _repository = ref.watch(subjectDetailRepositoryProvider);

    // Load data on build
    loadSubjectDetail(subjectId);

    return SubjectDetailState.initial();
  }

  /// Loads subject detail data from the repository.
  ///
  /// Sets loading state, fetches data, and updates state accordingly.
  /// Catches and handles any errors during the fetch operation.
  Future<void> loadSubjectDetail(String subjectId) async {
    state = SubjectDetailState.loading();
    try {
      final data = await _repository.getSubjectDetail(subjectId);
      state = SubjectDetailState.loaded(data);
    } catch (e) {
      state = SubjectDetailState.error(e.toString());
    }
  }

  /// Refreshes the subject detail data.
  ///
  /// Reloads data from the repository.
  Future<void> refresh(String subjectId) async {
    await loadSubjectDetail(subjectId);
  }
}

// Helper providers for easier access to specific parts of subject detail data

/// Provider that returns the current subject detail data or null.
@riverpod
SubjectDetail? subjectDetailData(Ref ref, String subjectId) {
  return ref.watch(subjectDetailNotifierProvider(subjectId)).data;
}

/// Provider that returns the subject's posts.
@riverpod
List<CoursePost> subjectPosts(Ref ref, String subjectId) {
  return ref.watch(subjectDetailDataProvider(subjectId))?.posts ?? [];
}

/// Provider that returns the subject's materials.
@riverpod
List<CourseMaterial> subjectMaterials(
    Ref ref, String subjectId) {
  return ref.watch(subjectDetailDataProvider(subjectId))?.materials ?? [];
}

/// Provider that returns the subject's assignments.
@riverpod
List<Assignment> subjectAssignments(
    Ref ref, String subjectId) {
  return ref.watch(subjectDetailDataProvider(subjectId))?.assignments ?? [];
}

/// Provider that returns whether the subject detail is loading.
@riverpod
bool isSubjectDetailLoading(Ref ref, String subjectId) {
  return ref.watch(subjectDetailNotifierProvider(subjectId)).isLoading;
}

/// Provider that returns the error message if any.
@riverpod
String? subjectDetailError(Ref ref, String subjectId) {
  return ref.watch(subjectDetailNotifierProvider(subjectId)).error;
}
