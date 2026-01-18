import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../admin_panel/domain/entities/invite_code.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/entities.dart';

/// Repository interface for principal panel data operations.
///
/// Defines the contract for fetching and managing principal-related data
/// such as staff, classes with details, and school statistics.
abstract class PrincipalRepository {
  // ==================== Staff Management ====================

  /// Fetches all staff members (admins + teachers) for a school.
  ///
  /// The [schoolId] parameter identifies which school's staff to fetch.
  ///
  /// Returns a list of [AppUser] objects with admin or teacher roles.
  Future<List<AppUser>> getSchoolStaff(String schoolId);

  /// Fetches all teachers for a school.
  ///
  /// The [schoolId] parameter identifies which school's teachers to fetch.
  ///
  /// Returns a list of [AppUser] objects with teacher role.
  Future<List<AppUser>> getSchoolTeachers(String schoolId);

  /// Removes a staff member from the school (soft delete).
  ///
  /// The [userId] parameter identifies the user to remove.
  ///
  /// Returns `true` if the removal was successful.
  Future<bool> removeStaffMember(String userId);

  // ==================== Class Management ====================

  /// Fetches all classes with additional details for a school.
  ///
  /// The [schoolId] parameter identifies which school's classes to fetch.
  ///
  /// Returns a list of [ClassWithDetails] objects with head teacher and student count.
  Future<List<ClassWithDetails>> getSchoolClassesWithDetails(String schoolId);

  /// Creates a new class in a school.
  ///
  /// Parameters:
  /// - [schoolId]: The school this class belongs to.
  /// - [name]: The name of the class (e.g., "Class 1A").
  /// - [gradeLevel]: Optional grade level of the class.
  /// - [academicYear]: Optional academic year (e.g., "2024-2025").
  /// - [headTeacherId]: Optional ID of the head teacher.
  ///
  /// Returns the created [ClassInfo] object with its generated ID.
  Future<ClassInfo> createClass({
    required String schoolId,
    required String name,
    String? gradeLevel,
    String? academicYear,
    String? headTeacherId,
  });

  /// Updates an existing class.
  ///
  /// The [classInfo] parameter contains the updated class data.
  /// The optional [headTeacherId] parameter can update the head teacher.
  ///
  /// Returns the updated [ClassInfo] object.
  Future<ClassInfo> updateClass(ClassInfo classInfo, {String? headTeacherId});

  /// Assigns a head teacher to a class.
  ///
  /// Parameters:
  /// - [classId]: The class to assign the head teacher to.
  /// - [teacherId]: The teacher to assign as head teacher.
  ///
  /// Returns `true` if the assignment was successful.
  Future<bool> assignHeadTeacher(String classId, String teacherId);

  /// Removes the head teacher from a class.
  ///
  /// The [classId] parameter identifies the class.
  ///
  /// Returns `true` if the removal was successful.
  Future<bool> removeHeadTeacher(String classId);

  /// Gets the student count for a specific class.
  ///
  /// The [classId] parameter identifies the class.
  ///
  /// Returns the number of students in the class.
  Future<int> getClassStudentCount(String classId);

  /// Deletes a class from the school.
  ///
  /// The [classId] parameter identifies the class to delete.
  ///
  /// Returns `true` if the deletion was successful.
  Future<bool> deleteClass(String classId);

  // ==================== Statistics ====================

  /// Fetches aggregated statistics for a school.
  ///
  /// The [schoolId] parameter identifies which school's stats to fetch.
  ///
  /// Returns a [SchoolStats] object with various counts.
  Future<SchoolStats> getSchoolStats(String schoolId);

  // ==================== Invite Codes ====================

  /// Fetches all invite codes for a school.
  ///
  /// The [schoolId] parameter identifies which school's invite codes to fetch.
  ///
  /// Returns a list of [InviteCode] objects.
  Future<List<InviteCode>> getSchoolInviteCodes(String schoolId);

  /// Generates a new invite code.
  ///
  /// Parameters:
  /// - [schoolId]: The school users will be associated with.
  /// - [role]: The role that will be assigned to users.
  /// - [classId]: Optional class ID for student assignments.
  /// - [usageLimit]: Maximum number of times the code can be used.
  /// - [expiresAt]: Optional expiration date for the code.
  ///
  /// Returns the created [InviteCode] object.
  Future<InviteCode> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
  });

  /// Deactivates an invite code.
  ///
  /// The [codeId] parameter identifies which invite code to deactivate.
  ///
  /// Returns `true` if the deactivation was successful.
  Future<bool> deactivateInviteCode(String codeId);
}
