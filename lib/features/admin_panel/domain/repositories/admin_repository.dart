import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../entities/entities.dart';

/// Repository interface for admin panel data operations.
///
/// Defines the contract for fetching and managing admin-related data such as
/// schools, users, classes, subjects, and invite codes.
abstract class AdminRepository {
  /// Fetches all schools in the system.
  ///
  /// This is typically used by superadmins to view and manage all schools.
  ///
  /// Returns a list of [School] objects sorted by name.
  Future<List<School>> getSchools();

  /// Creates a new school.
  ///
  /// The [name] parameter specifies the name of the new school.
  ///
  /// Returns the created [School] object with its generated ID.
  Future<School> createSchool(String name);

  /// Fetches all users belonging to a specific school.
  ///
  /// The [schoolId] parameter identifies which school's users to fetch.
  ///
  /// Returns a list of [AppUser] objects for the specified school.
  Future<List<AppUser>> getSchoolUsers(String schoolId);

  /// Fetches all classes belonging to a specific school.
  ///
  /// The [schoolId] parameter identifies which school's classes to fetch.
  ///
  /// Returns a list of [ClassInfo] objects for the specified school.
  Future<List<ClassInfo>> getSchoolClasses(String schoolId);

  /// Creates a new class in a school.
  ///
  /// Parameters:
  /// - [schoolId]: The school this class belongs to.
  /// - [name]: The name of the class (e.g., "Class 1A").
  /// - [gradeLevel]: The grade level of the class.
  /// - [academicYear]: The academic year (e.g., "2024-2025").
  ///
  /// Returns the created [ClassInfo] object with its generated ID.
  Future<ClassInfo> createClass({
    required String schoolId,
    required String name,
    required int gradeLevel,
    required String academicYear,
  });

  /// Generates a new invite code for user registration.
  ///
  /// Parameters:
  /// - [schoolId]: The school users will be associated with.
  /// - [role]: The role that will be assigned to users.
  /// - [classId]: Optional class ID for student/teacher assignments.
  /// - [usageLimit]: Maximum number of times the code can be used.
  /// - [expiresAt]: Optional expiration date for the code.
  ///
  /// Returns the created [InviteCode] object with its generated code.
  Future<InviteCode> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
  });

  /// Fetches all subjects assigned to a specific teacher.
  ///
  /// The [teacherId] parameter identifies the teacher.
  ///
  /// Returns a list of [Subject] objects assigned to the teacher.
  Future<List<Subject>> getTeacherSubjects(String teacherId);

  /// Fetches all invite codes for a specific school.
  ///
  /// The [schoolId] parameter identifies which school's invite codes to fetch.
  ///
  /// Returns a list of [InviteCode] objects for the specified school.
  Future<List<InviteCode>> getSchoolInviteCodes(String schoolId);

  /// Deactivates an invite code.
  ///
  /// The [codeId] parameter identifies which invite code to deactivate.
  ///
  /// Returns the updated [InviteCode] object.
  Future<InviteCode> deactivateInviteCode(String codeId);

  /// Deletes a class from a school.
  ///
  /// The [classId] parameter identifies which class to delete.
  ///
  /// Returns `true` if the deletion was successful.
  Future<bool> deleteClass(String classId);

  /// Updates a user's role.
  ///
  /// Parameters:
  /// - [userId]: The user to update.
  /// - [newRole]: The new role to assign.
  ///
  /// Returns the updated [AppUser] object.
  Future<AppUser> updateUserRole(String userId, UserRole newRole);
}
