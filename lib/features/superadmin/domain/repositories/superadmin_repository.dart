import '../../../admin_panel/domain/entities/school.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../entities/entities.dart';

/// Repository interface for superadmin operations.
///
/// Defines the contract for managing schools, users, subscriptions,
/// and platform-wide statistics from the superadmin perspective.
abstract class SuperAdminRepository {
  /// Creates a new school with the given name.
  ///
  /// Returns the created [School] with its generated ID.
  /// Also creates an initial principal token for the school.
  Future<School> createSchool(String name);

  /// Gets all schools with their associated statistics.
  ///
  /// Returns a list of [SchoolWithStats] sorted by name.
  Future<List<SchoolWithStats>> getAllSchools();

  /// Gets a specific school by ID.
  ///
  /// Returns the [School] if found, throws if not found.
  Future<School> getSchool(String id);

  /// Gets detailed statistics for a specific school.
  ///
  /// Returns [SchoolWithStats] with all metrics for the school.
  Future<SchoolWithStats> getSchoolWithStats(String schoolId);

  /// Updates a school's subscription status.
  ///
  /// Parameters:
  /// - [schoolId]: The school to update.
  /// - [status]: The new subscription status.
  Future<void> updateSubscriptionStatus(
    String schoolId,
    SubscriptionStatus status,
  );

  /// Updates a school's subscription with status and optional expiry date.
  ///
  /// Parameters:
  /// - [schoolId]: The school to update.
  /// - [status]: The new subscription status (trial, pro, max, etc.).
  /// - [expiresAt]: When the subscription expires. Pass null for no expiry (perpetual).
  ///
  /// For trial subscriptions, the expiry is typically set to the end of the school year
  /// (July 1st of the following year from September 1st).
  Future<void> updateSubscription(
    String schoolId,
    SubscriptionStatus status,
    DateTime? expiresAt,
  );

  /// Gets all BigAdmin/Principal users for a specific school.
  ///
  /// Returns a list of [AppUser] with bigadmin role for the school.
  Future<List<AppUser>> getSchoolBigAdmins(String schoolId);

  /// Creates an initial principal token when a school is created.
  ///
  /// This token allows the first principal/bigadmin to register.
  ///
  /// Parameters:
  /// - [schoolId]: The school to create the token for.
  ///
  /// Returns the generated token string.
  Future<String> createPrincipalToken(String schoolId);

  /// Gets platform-wide statistics.
  ///
  /// Returns [PlatformStats] with aggregate metrics across all schools.
  Future<PlatformStats> getPlatformStats();

  /// Suspends a school by setting its status to suspended.
  ///
  /// Parameters:
  /// - [schoolId]: The school to suspend.
  Future<void> suspendSchool(String schoolId);

  /// Activates a school by setting its status to active.
  ///
  /// Parameters:
  /// - [schoolId]: The school to activate.
  Future<void> activateSchool(String schoolId);

  /// Deletes a school and all associated data.
  ///
  /// This is a destructive operation and should be used with caution.
  ///
  /// Parameters:
  /// - [schoolId]: The school to delete.
  ///
  /// Returns true if deletion was successful.
  Future<bool> deleteSchool(String schoolId);

  /// Updates a school's name.
  ///
  /// Parameters:
  /// - [schoolId]: The school to update.
  /// - [newName]: The new name for the school.
  ///
  /// Returns the updated [School].
  Future<School> updateSchoolName(String schoolId, String newName);

  /// Gets the active principal/bigadmin invitation token for a school.
  ///
  /// Returns the active (unused, not expired) token if one exists,
  /// or null if no active token is found.
  ///
  /// Parameters:
  /// - [schoolId]: The school to get the token for.
  Future<String?> getActivePrincipalToken(String schoolId);

  /// Gets detailed analytics for a specific school.
  ///
  /// Returns [SchoolAnalytics] with extended metrics including
  /// user counts by role, class count, subject count, etc.
  Future<SchoolAnalytics> getSchoolAnalytics(String schoolId);

  /// Gets all users for a specific school.
  ///
  /// Returns a list of [AppUser] belonging to the school.
  Future<List<AppUser>> getSchoolUsers(String schoolId);
}
