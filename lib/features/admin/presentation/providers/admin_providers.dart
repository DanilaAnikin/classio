import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../data/repositories/supabase_admin_repository.dart';
import '../../data/repositories/supabase_teacher_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/repositories/teacher_repository.dart';

/// Provider for the admin repository.
///
/// Returns a [SupabaseAdminRepository] instance that implements [AdminRepository].
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return SupabaseAdminRepository();
});

/// Provider for the teacher repository.
///
/// Returns a [SupabaseTeacherRepository] instance that implements [TeacherRepository].
final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return SupabaseTeacherRepository();
});

/// Provider that fetches all users for a specific school.
///
/// The [schoolId] parameter identifies which school's users to fetch.
/// Returns an async value containing the list of [AppUser] for that school.
final schoolUsersProvider =
    FutureProvider.family<List<AppUser>, String>((ref, schoolId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getSchoolUsers(schoolId);
});

/// Provider that fetches all classes for a specific school.
///
/// The [schoolId] parameter identifies which school's classes to fetch.
/// Returns an async value containing the list of [ClassEntity] for that school.
final schoolClassesProvider =
    FutureProvider.family<List<ClassEntity>, String>((ref, schoolId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getSchoolClasses(schoolId);
});

/// Provider for generating invite codes.
///
/// This provider exposes the admin repository's createInviteCode method.
/// Parameters:
/// - schoolId: The school the invite code is for
/// - role: The role to assign to users who use this code
/// - usageLimit: How many times the code can be used
final generateInviteCodeProvider = FutureProvider.family<
    String,
    ({
      String schoolId,
      String role,
      int usageLimit,
    })>((ref, params) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.createInviteCode(
    schoolId: params.schoolId,
    role: params.role,
    usageLimit: params.usageLimit,
  );
});

/// Provider for creating a new class in a school.
///
/// Parameters:
/// - schoolId: The school to create the class in
/// - name: The name of the class
/// - gradeLevel: The grade level of the class
/// - academicYear: The academic year for the class
final createClassProvider = FutureProvider.family<
    ClassEntity,
    ({
      String schoolId,
      String name,
      int gradeLevel,
      String academicYear,
    })>((ref, params) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.createClass(
    schoolId: params.schoolId,
    name: params.name,
    gradeLevel: params.gradeLevel,
    academicYear: params.academicYear,
  );
});

/// Notifier for managing schools state.
///
/// Handles loading, refreshing, and creating schools.
/// Uses [AdminRepository] to interact with the data source.
class SchoolsNotifier extends AutoDisposeAsyncNotifier<List<SchoolEntity>> {
  late final AdminRepository _repository;

  @override
  Future<List<SchoolEntity>> build() async {
    _repository = ref.watch(adminRepositoryProvider);
    return await _loadSchools();
  }

  /// Loads schools from the repository.
  Future<List<SchoolEntity>> _loadSchools() async {
    return await _repository.getSchools();
  }

  /// Refreshes the schools list.
  ///
  /// Reloads all schools from the repository.
  /// Useful for pull-to-refresh functionality.
  Future<void> refreshSchools() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadSchools());
  }

  /// Creates a new school with the given name.
  ///
  /// After successful creation, refreshes the schools list.
  Future<void> createSchool(String name) async {
    await _repository.createSchool(name);
    await refreshSchools();
  }
}

/// Provider for the schools notifier.
///
/// Manages the state of schools list and provides methods for
/// refreshing and creating schools.
final schoolsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SchoolsNotifier, List<SchoolEntity>>(
  SchoolsNotifier.new,
);
