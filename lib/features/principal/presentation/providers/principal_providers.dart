import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../admin_panel/domain/entities/invite_code.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../data/repositories/supabase_principal_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/principal_repository.dart';

part 'principal_providers.g.dart';

// ==================== Repository Provider ====================

/// Provider for the PrincipalRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
PrincipalRepository principalRepository(Ref ref) {
  return SupabasePrincipalRepository();
}

// ==================== Staff Providers ====================

/// Provider that fetches all staff members for a school.
///
/// The [schoolId] parameter identifies which school's staff to fetch.
/// Returns admins and teachers.
@riverpod
Future<List<AppUser>> schoolStaff(Ref ref, String schoolId) async {
  final repository = ref.watch(principalRepositoryProvider);
  return repository.getSchoolStaff(schoolId);
}

/// Provider that fetches all teachers for a school.
///
/// The [schoolId] parameter identifies which school's teachers to fetch.
@riverpod
Future<List<AppUser>> schoolTeachers(Ref ref, String schoolId) async {
  final repository = ref.watch(principalRepositoryProvider);
  return repository.getSchoolTeachers(schoolId);
}

// ==================== Class Providers ====================

/// Provider that fetches all classes with details for a school.
///
/// The [schoolId] parameter identifies which school's classes to fetch.
/// Returns classes with head teacher info and student count.
@riverpod
Future<List<ClassWithDetails>> principalSchoolClasses(
    Ref ref, String schoolId) async {
  final repository = ref.watch(principalRepositoryProvider);
  return repository.getSchoolClassesWithDetails(schoolId);
}

// ==================== Stats Provider ====================

/// Provider that fetches school statistics.
///
/// The [schoolId] parameter identifies which school's stats to fetch.
@riverpod
Future<SchoolStats> schoolStats(Ref ref, String schoolId) async {
  final repository = ref.watch(principalRepositoryProvider);
  return repository.getSchoolStats(schoolId);
}

// ==================== Invite Code Providers ====================

/// Provider that fetches all invite codes for a school.
///
/// The [schoolId] parameter identifies which school's invite codes to fetch.
@riverpod
Future<List<InviteCode>> principalInviteCodes(Ref ref, String schoolId) async {
  final repository = ref.watch(principalRepositoryProvider);
  return repository.getSchoolInviteCodes(schoolId);
}

// ==================== Principal Notifier ====================

/// Notifier for managing principal panel operations.
///
/// Provides methods for managing staff, classes, and invite codes.
@Riverpod(keepAlive: true)
class PrincipalNotifier extends _$PrincipalNotifier {
  late PrincipalRepository _repository;

  @override
  PrincipalState build() {
    _repository = ref.watch(principalRepositoryProvider);
    return PrincipalState.initial();
  }

  /// Removes a staff member from the school.
  Future<bool> removeStaffMember(String userId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.removeStaffMember(userId);
      state = state.copyWith(isLoading: false);

      if (success) {
        ref.invalidate(schoolStaffProvider(schoolId));
        ref.invalidate(schoolStatsProvider(schoolId));
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

  /// Creates a new class.
  Future<ClassInfo?> createClass({
    required String schoolId,
    required String name,
    String? gradeLevel,
    String? academicYear,
    String? headTeacherId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final classInfo = await _repository.createClass(
        schoolId: schoolId,
        name: name,
        gradeLevel: gradeLevel,
        academicYear: academicYear,
        headTeacherId: headTeacherId,
      );
      state = state.copyWith(isLoading: false);

      ref.invalidate(principalSchoolClassesProvider(schoolId));
      ref.invalidate(schoolStatsProvider(schoolId));

      return classInfo;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Updates an existing class.
  ///
  /// Optionally updates the head teacher if [headTeacherId] is provided.
  Future<ClassInfo?> updateClass(
    ClassInfo classInfo, {
    String? headTeacherId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updated = await _repository.updateClass(
        classInfo,
        headTeacherId: headTeacherId,
      );
      state = state.copyWith(isLoading: false);

      ref.invalidate(principalSchoolClassesProvider(classInfo.schoolId));

      return updated;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Assigns a head teacher to a class.
  Future<bool> assignHeadTeacher(
    String classId,
    String teacherId,
    String schoolId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.assignHeadTeacher(classId, teacherId);
      state = state.copyWith(isLoading: false);

      if (success) {
        ref.invalidate(principalSchoolClassesProvider(schoolId));
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

  /// Removes the head teacher from a class.
  Future<bool> removeHeadTeacher(String classId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.removeHeadTeacher(classId);
      state = state.copyWith(isLoading: false);

      if (success) {
        ref.invalidate(principalSchoolClassesProvider(schoolId));
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

  /// Deletes a class.
  Future<bool> deleteClass(String classId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.deleteClass(classId);
      state = state.copyWith(isLoading: false);

      if (success) {
        ref.invalidate(principalSchoolClassesProvider(schoolId));
        ref.invalidate(schoolStatsProvider(schoolId));
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

  /// Generates a new invite code.
  ///
  /// Either [expiresAt] or [expiryDays] can be provided to set the expiration.
  /// If [expiryDays] is provided, it will be used to calculate the expiration date.
  Future<InviteCode?> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
    int? expiryDays,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Calculate expiration date from expiryDays if provided
    final DateTime? calculatedExpiresAt = expiresAt ??
        (expiryDays != null
            ? DateTime.now().add(Duration(days: expiryDays))
            : null);

    try {
      final inviteCode = await _repository.generateInviteCode(
        schoolId: schoolId,
        role: role,
        classId: classId,
        usageLimit: usageLimit,
        expiresAt: calculatedExpiresAt,
      );
      state = state.copyWith(isLoading: false);

      ref.invalidate(principalInviteCodesProvider(schoolId));
      ref.invalidate(schoolStatsProvider(schoolId));

      return inviteCode;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Generates a new invite code and returns just the code string.
  ///
  /// Convenience method that returns the code string for easy copy/paste.
  Future<String?> generateInviteCodeString({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    int expiryDays = 7,
  }) async {
    final inviteCode = await generateInviteCode(
      schoolId: schoolId,
      role: role,
      classId: classId,
      usageLimit: usageLimit,
      expiryDays: expiryDays,
    );
    return inviteCode?.code;
  }

  /// Deactivates an invite code.
  Future<bool> deactivateInviteCode(String codeId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.deactivateInviteCode(codeId);
      state = state.copyWith(isLoading: false);

      if (success) {
        ref.invalidate(principalInviteCodesProvider(schoolId));
        ref.invalidate(schoolStatsProvider(schoolId));
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

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// State class for the PrincipalNotifier.
///
/// Tracks loading state and error messages for principal operations.
class PrincipalState {
  const PrincipalState({
    required this.isLoading,
    this.errorMessage,
  });

  /// Whether an operation is in progress.
  final bool isLoading;

  /// Error message from the last failed operation, if any.
  final String? errorMessage;

  /// Creates the initial principal state.
  factory PrincipalState.initial() {
    return const PrincipalState(
      isLoading: false,
      errorMessage: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  PrincipalState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return PrincipalState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PrincipalState &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(isLoading, errorMessage);

  @override
  String toString() =>
      'PrincipalState(isLoading: $isLoading, errorMessage: $errorMessage)';
}
