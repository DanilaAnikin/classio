import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../data/repositories/supabase_admin_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/admin_repository.dart';

part 'admin_providers.g.dart';

/// Provider for the AdminRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
AdminRepository adminRepository(Ref ref) {
  return SupabaseAdminRepository();
}

/// Provider that fetches all schools.
///
/// Returns an async value containing the list of all schools.
/// Used by superadmins to view and manage all schools in the system.
@riverpod
Future<List<School>> schools(Ref ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getSchools();
}

/// Provider that fetches users for a specific school.
///
/// The [schoolId] parameter identifies which school's users to fetch.
/// Returns an async value containing the list of users for that school.
@riverpod
Future<List<AppUser>> schoolUsers(Ref ref, String schoolId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getSchoolUsers(schoolId);
}

/// Provider that fetches classes for a specific school.
///
/// The [schoolId] parameter identifies which school's classes to fetch.
/// Returns an async value containing the list of classes for that school.
@riverpod
Future<List<ClassInfo>> schoolClasses(Ref ref, String schoolId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getSchoolClasses(schoolId);
}

/// Provider that fetches subjects for a specific teacher.
///
/// The [teacherId] parameter identifies which teacher's subjects to fetch.
/// Returns an async value containing the list of subjects assigned to the teacher.
@riverpod
Future<List<Subject>> teacherSubjects(Ref ref, String teacherId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getTeacherSubjects(teacherId);
}

/// Provider that fetches invite codes for a specific school.
///
/// The [schoolId] parameter identifies which school's invite codes to fetch.
/// Returns an async value containing the list of invite codes for that school.
@riverpod
Future<List<InviteCode>> schoolInviteCodes(Ref ref, String schoolId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getSchoolInviteCodes(schoolId);
}

/// Notifier for managing admin panel state and operations.
///
/// Provides methods for creating schools, classes, and invite codes,
/// as well as managing users and their roles.
@Riverpod(keepAlive: true)
class AdminNotifier extends _$AdminNotifier {
  late final AdminRepository _repository;

  @override
  AdminState build() {
    _repository = ref.watch(adminRepositoryProvider);
    return AdminState.initial();
  }

  /// Creates a new school.
  ///
  /// Returns the created school on success, or sets an error state on failure.
  Future<School?> createSchool(String name) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final school = await _repository.createSchool(name);
      state = state.copyWith(isLoading: false);

      // Invalidate the schools provider to refresh the list
      ref.invalidate(schoolsProvider);

      return school;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Creates a new class in a school.
  ///
  /// Returns the created class on success, or sets an error state on failure.
  Future<ClassInfo?> createClass({
    required String schoolId,
    required String name,
    required int gradeLevel,
    required String academicYear,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final classInfo = await _repository.createClass(
        schoolId: schoolId,
        name: name,
        gradeLevel: gradeLevel,
        academicYear: academicYear,
      );
      state = state.copyWith(isLoading: false);

      // Invalidate the school classes provider to refresh the list
      ref.invalidate(schoolClassesProvider(schoolId));

      return classInfo;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Generates a new invite code.
  ///
  /// Returns the generated invite code on success, or sets an error state on failure.
  Future<InviteCode?> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final inviteCode = await _repository.generateInviteCode(
        schoolId: schoolId,
        role: role,
        classId: classId,
        usageLimit: usageLimit,
        expiresAt: expiresAt,
      );
      state = state.copyWith(isLoading: false);

      // Invalidate the school invite codes provider to refresh the list
      ref.invalidate(schoolInviteCodesProvider(schoolId));

      return inviteCode;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Deactivates an invite code.
  ///
  /// Returns the deactivated invite code on success, or sets an error state on failure.
  Future<InviteCode?> deactivateInviteCode(String codeId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final inviteCode = await _repository.deactivateInviteCode(codeId);
      state = state.copyWith(isLoading: false);

      // Invalidate the school invite codes provider to refresh the list
      ref.invalidate(schoolInviteCodesProvider(schoolId));

      return inviteCode;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Deletes a class from a school.
  ///
  /// Returns true on success, or sets an error state on failure.
  Future<bool> deleteClass(String classId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.deleteClass(classId);
      state = state.copyWith(isLoading: false);

      if (success) {
        // Invalidate the school classes provider to refresh the list
        ref.invalidate(schoolClassesProvider(schoolId));
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Updates a user's role.
  ///
  /// Returns the updated user on success, or sets an error state on failure.
  Future<AppUser?> updateUserRole(
    String userId,
    UserRole newRole,
    String schoolId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await _repository.updateUserRole(userId, newRole);
      state = state.copyWith(isLoading: false);

      // Invalidate the school users provider to refresh the list
      ref.invalidate(schoolUsersProvider(schoolId));

      return user;
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
    state = state.copyWith(errorMessage: null);
  }
}

/// State class for the AdminNotifier.
///
/// Tracks loading state and error messages for admin operations.
class AdminState {
  const AdminState({
    required this.isLoading,
    this.errorMessage,
  });

  /// Whether an admin operation is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  /// Creates the initial admin state.
  factory AdminState.initial() {
    return const AdminState(
      isLoading: false,
      errorMessage: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(isLoading, errorMessage);

  @override
  String toString() =>
      'AdminState(isLoading: $isLoading, errorMessage: $errorMessage)';
}
