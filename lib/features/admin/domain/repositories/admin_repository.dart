import '../../../auth/domain/entities/app_user.dart';
import '../entities/entities.dart';

/// Repository interface for admin data operations.
///
/// Defines the contract for fetching and managing admin-related data such as
/// schools, users, classes, and invite codes.
abstract class AdminRepository {
  /// Fetches all schools in the system.
  ///
  /// This is typically used by superadmins to view and manage all schools.
  ///
  /// Returns a list of [SchoolEntity] objects sorted by name.
  Future<List<SchoolEntity>> getSchools();

  /// Creates a new school.
  ///
  /// The [name] parameter specifies the name of the new school.
  ///
  /// Returns the created [SchoolEntity] object with its generated ID.
  Future<SchoolEntity> createSchool(String name);

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
  /// Returns a list of [ClassEntity] objects for the specified school.
  Future<List<ClassEntity>> getSchoolClasses(String schoolId);

  /// Creates a new class in a school.
  ///
  /// Parameters:
  /// - [schoolId]: The school this class belongs to.
  /// - [name]: The name of the class (e.g., "Class 1A").
  /// - [gradeLevel]: The grade level of the class.
  /// - [academicYear]: The academic year (e.g., "2024-2025").
  ///
  /// Returns the created [ClassEntity] object with its generated ID.
  Future<ClassEntity> createClass({
    required String schoolId,
    required String name,
    required int gradeLevel,
    required String academicYear,
  });

  /// Generates a new invite code for user registration.
  ///
  /// Parameters:
  /// - [schoolId]: The school users will be associated with.
  /// - [role]: The role that will be assigned to users (as a string).
  /// - [classId]: Optional class ID for student/teacher assignments.
  /// - [usageLimit]: Maximum number of times the code can be used.
  /// - [expiresAt]: Optional expiration date for the code.
  ///
  /// Returns the generated invite code string.
  Future<String> createInviteCode({
    required String schoolId,
    required String role,
    String? classId,
    int usageLimit = 1,
    DateTime? expiresAt,
  });
}
