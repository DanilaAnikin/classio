import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../admin_panel/domain/entities/school.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../data/repositories/supabase_superadmin_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/superadmin_repository.dart';

part 'superadmin_provider.g.dart';

/// Provider for the SuperAdmin Repository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
SuperAdminRepository superAdminRepository(Ref ref) {
  return SupabaseSuperAdminRepository();
}

/// Provider that fetches all schools with their statistics.
///
/// Returns an async value containing the list of all schools with stats.
/// Used by superadmins to view and manage all schools in the system.
@riverpod
Future<List<SchoolWithStats>> schoolsWithStats(Ref ref) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getAllSchools();
}

/// Provider that fetches platform-wide statistics.
///
/// Returns an async value containing platform metrics.
@riverpod
Future<PlatformStats> platformStats(Ref ref) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getPlatformStats();
}

/// Provider that fetches a specific school with its statistics.
///
/// The [schoolId] parameter identifies which school to fetch.
@riverpod
Future<SchoolWithStats> schoolDetail(Ref ref, String schoolId) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getSchoolWithStats(schoolId);
}

/// Provider that fetches BigAdmins for a specific school.
///
/// The [schoolId] parameter identifies which school's admins to fetch.
@riverpod
Future<List<AppUser>> schoolBigAdmins(Ref ref, String schoolId) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getSchoolBigAdmins(schoolId);
}

/// Provider that fetches the active principal invitation token for a school.
///
/// Returns null if no active token exists.
@riverpod
Future<String?> schoolPrincipalToken(Ref ref, String schoolId) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getActivePrincipalToken(schoolId);
}

/// Provider that fetches detailed analytics for a specific school.
///
/// The [schoolId] parameter identifies which school's analytics to fetch.
@riverpod
Future<SchoolAnalytics> schoolAnalytics(Ref ref, String schoolId) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getSchoolAnalytics(schoolId);
}

/// Provider that fetches all users for a specific school.
///
/// The [schoolId] parameter identifies which school's users to fetch.
@riverpod
Future<List<AppUser>> schoolUsers(Ref ref, String schoolId) async {
  final repository = ref.watch(superAdminRepositoryProvider);
  return repository.getSchoolUsers(schoolId);
}

/// Provider for the currently selected school ID.
///
/// Used for navigation and detail views.
@riverpod
class SelectedSchool extends _$SelectedSchool {
  @override
  String? build() {
    return null;
  }

  void select(String schoolId) {
    state = schoolId;
  }

  void clear() {
    state = null;
  }
}

/// State class for the SuperAdmin Notifier.
///
/// Tracks loading state and error messages for superadmin operations.
class SuperAdminState {
  const SuperAdminState({
    required this.isLoading,
    this.errorMessage,
    this.generatedToken,
  });

  /// Whether a superadmin operation is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  /// Most recently generated principal token.
  final String? generatedToken;

  /// Creates the initial superadmin state.
  factory SuperAdminState.initial() {
    return const SuperAdminState(
      isLoading: false,
      errorMessage: null,
      generatedToken: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  SuperAdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? generatedToken,
    bool clearError = false,
    bool clearToken = false,
  }) {
    return SuperAdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      generatedToken: clearToken ? null : (generatedToken ?? this.generatedToken),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuperAdminState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage &&
        other.generatedToken == generatedToken;
  }

  @override
  int get hashCode => Object.hash(isLoading, errorMessage, generatedToken);

  @override
  String toString() =>
      'SuperAdminState(isLoading: $isLoading, errorMessage: $errorMessage, '
      'generatedToken: $generatedToken)';
}

/// Notifier for managing superadmin state and operations.
///
/// Provides methods for creating schools, managing subscriptions,
/// and generating principal tokens.
@Riverpod(keepAlive: true)
class SuperAdminNotifier extends _$SuperAdminNotifier {
  late final SuperAdminRepository _repository;

  @override
  SuperAdminState build() {
    _repository = ref.watch(superAdminRepositoryProvider);
    return SuperAdminState.initial();
  }

  /// Creates a new school and generates an initial principal token.
  ///
  /// Returns a tuple of (School, token) on success, or sets an error state on failure.
  Future<(School?, String?)> createSchoolWithToken(String name) async {
    state = state.copyWith(isLoading: true, clearError: true, clearToken: true);

    try {
      // Create the school
      final school = await _repository.createSchool(name);

      // Generate the principal token
      final token = await _repository.createPrincipalToken(school.id);

      state = state.copyWith(
        isLoading: false,
        generatedToken: token,
      );

      // Invalidate the schools list to refresh it
      ref.invalidate(schoolsWithStatsProvider);
      ref.invalidate(platformStatsProvider);

      return (school, token);
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return (null, null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return (null, null);
    }
  }

  /// Creates a new school without generating a token.
  ///
  /// Returns the created school on success, or sets an error state on failure.
  Future<School?> createSchool(String name) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final school = await _repository.createSchool(name);
      state = state.copyWith(isLoading: false);

      // Invalidate the schools list to refresh it
      ref.invalidate(schoolsWithStatsProvider);
      ref.invalidate(platformStatsProvider);

      return school;
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Generates a new principal token for a school.
  ///
  /// Returns the generated token on success, or sets an error state on failure.
  Future<String?> generatePrincipalToken(String schoolId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearToken: true);

    try {
      final token = await _repository.createPrincipalToken(schoolId);
      state = state.copyWith(
        isLoading: false,
        generatedToken: token,
      );

      return token;
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Updates a school's subscription status.
  ///
  /// Returns true on success, or sets an error state on failure.
  Future<bool> updateSubscriptionStatus(
    String schoolId,
    SubscriptionStatus status,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.updateSubscriptionStatus(schoolId, status);
      state = state.copyWith(isLoading: false);

      // Invalidate related providers to refresh data
      ref.invalidate(schoolsWithStatsProvider);
      ref.invalidate(schoolDetailProvider(schoolId));
      ref.invalidate(platformStatsProvider);

      return true;
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Suspends a school.
  ///
  /// Returns true on success, or sets an error state on failure.
  Future<bool> suspendSchool(String schoolId) async {
    return updateSubscriptionStatus(schoolId, SubscriptionStatus.suspended);
  }

  /// Activates a school by setting it to Pro tier.
  ///
  /// Returns true on success, or sets an error state on failure.
  Future<bool> activateSchool(String schoolId) async {
    return updateSubscriptionStatus(schoolId, SubscriptionStatus.pro);
  }

  /// Updates a school's subscription with status and optional expiry date.
  ///
  /// Parameters:
  /// - [schoolId]: The school to update.
  /// - [status]: The new subscription status (trial, pro, max).
  /// - [expiresAt]: When the subscription expires. Null means no expiry (perpetual).
  ///
  /// Returns true on success, or sets an error state on failure.
  Future<bool> updateSubscription(
    String schoolId,
    SubscriptionStatus status,
    DateTime? expiresAt,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.updateSubscription(schoolId, status, expiresAt);
      state = state.copyWith(isLoading: false);

      // Invalidate related providers to refresh data
      ref.invalidate(schoolsWithStatsProvider);
      ref.invalidate(schoolDetailProvider(schoolId));
      ref.invalidate(platformStatsProvider);

      return true;
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Deletes a school.
  ///
  /// Returns true on success, or sets an error state on failure.
  Future<bool> deleteSchool(String schoolId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final success = await _repository.deleteSchool(schoolId);
      state = state.copyWith(isLoading: false);

      if (success) {
        // Invalidate related providers to refresh data
        ref.invalidate(schoolsWithStatsProvider);
        ref.invalidate(platformStatsProvider);
      }

      return success;
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Updates a school's name.
  ///
  /// Returns the updated school on success, or sets an error state on failure.
  Future<School?> updateSchoolName(String schoolId, String newName) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final school = await _repository.updateSchoolName(schoolId, newName);
      state = state.copyWith(isLoading: false);

      // Invalidate related providers to refresh data
      ref.invalidate(schoolsWithStatsProvider);
      ref.invalidate(schoolDetailProvider(schoolId));

      return school;
    } on SuperAdminException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears the generated token.
  void clearToken() {
    state = state.copyWith(clearToken: true);
  }
}
