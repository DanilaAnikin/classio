import 'package:classio/features/auth/domain/entities/app_user.dart';
import '../entities/invite_token.dart';

/// Abstract repository interface for invite token operations.
///
/// This repository defines the contract for invite token-related operations
/// in the Classio application. Implementations of this interface should handle
/// the actual token generation and management logic with the chosen backend service.
///
/// ## Hierarchical Permission Rules
///
/// The invite system follows a strict hierarchical permission model:
/// - **SuperAdmin**: Can invite BigAdmin only
/// - **BigAdmin**: Can invite Admin, Teacher
/// - **Admin**: Can invite Teacher, Parent
/// - **Teacher**: Can invite Student (with specific_class_id required)
/// - **Student/Parent**: Cannot invite anyone
abstract class InviteRepository {
  /// Generates a new invite token.
  ///
  /// Returns the token string if successful.
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - User doesn't have permission to create invites for the target role
  /// - For teachers inviting students: class_id is missing or teacher doesn't teach the class
  /// - Database operation fails
  ///
  /// Parameters:
  /// - [targetRole]: The role that will be assigned to users who use this token
  /// - [schoolId]: The school ID that users will be associated with
  /// - [classId]: Optional class ID (required when teacher invites student)
  /// - [expiresAt]: Optional expiration date for the token
  Future<String> generateToken({
    required UserRole targetRole,
    required String schoolId,
    String? classId,
    DateTime? expiresAt,
  });

  /// Validates whether a user with [creatorRole] can create invites for [targetRole].
  ///
  /// ## Permission Matrix
  /// | Creator Role | Can Invite                    |
  /// |--------------|-------------------------------|
  /// | SuperAdmin   | BigAdmin                      |
  /// | BigAdmin     | Admin, Teacher                |
  /// | Admin        | Teacher, Parent               |
  /// | Teacher      | Student (with class_id)       |
  /// | Student      | None                          |
  /// | Parent       | None                          |
  ///
  /// Returns `true` if the creator can generate invites for the target role.
  bool canGenerateInviteFor(UserRole creatorRole, UserRole targetRole);

  /// Returns a list of roles that a user with [creatorRole] can invite.
  ///
  /// This is useful for building UI elements like role selection dropdowns.
  List<UserRole> getInvitableRoles(UserRole creatorRole);

  /// Gets all tokens created by the currently authenticated user.
  ///
  /// Returns a list of [InviteToken] objects, sorted by creation date (newest first).
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - Database operation fails
  Future<List<InviteToken>> getMyCreatedTokens();

  /// Gets all tokens for a specific school.
  ///
  /// This operation requires admin privileges (SuperAdmin, BigAdmin, or Admin).
  ///
  /// Parameters:
  /// - [schoolId]: The school ID to get tokens for
  ///
  /// Returns a list of [InviteToken] objects, sorted by creation date (newest first).
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - User doesn't have admin privileges for the school
  /// - Database operation fails
  Future<List<InviteToken>> getSchoolTokens(String schoolId);

  /// Revokes a token by marking it as used.
  ///
  /// Parameters:
  /// - [token]: The token string to revoke
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - Token doesn't exist
  /// - User doesn't have permission to revoke the token
  /// - Database operation fails
  Future<void> revokeToken(String token);

  /// Deletes expired tokens for a specific school.
  ///
  /// This operation requires admin privileges (SuperAdmin, BigAdmin, or Admin).
  ///
  /// Parameters:
  /// - [schoolId]: The school ID to clean up tokens for
  ///
  /// Returns the number of tokens deleted.
  ///
  /// Throws an exception if:
  /// - User is not authenticated
  /// - User doesn't have admin privileges for the school
  /// - Database operation fails
  Future<int> cleanupExpiredTokens(String schoolId);

  /// Validates an invite token without using it.
  ///
  /// Parameters:
  /// - [token]: The token string to validate
  ///
  /// Returns the [InviteToken] if valid.
  ///
  /// Throws an exception if:
  /// - Token doesn't exist
  /// - Token has been used
  /// - Token has expired
  Future<InviteToken> validateToken(String token);
}
