import '../entities/app_user.dart';

/// Abstract repository interface for authentication operations.
///
/// This repository defines the contract for authentication-related operations
/// in the Classio application. Implementations of this interface should handle
/// the actual authentication logic with the chosen backend service.
abstract class AuthRepository {
  /// Signs in a user with email and password.
  ///
  /// Returns the authenticated [AppUser] if successful, or null if
  /// authentication fails.
  ///
  /// Throws an exception if there's an error during the sign-in process.
  ///
  /// Parameters:
  /// - [email]: The user's email address.
  /// - [password]: The user's password.
  Future<AppUser?> signIn(String email, String password);

  /// Signs out the currently authenticated user.
  ///
  /// Throws an exception if there's an error during the sign-out process.
  Future<void> signOut();

  /// Retrieves the currently authenticated user.
  ///
  /// Returns the [AppUser] if a user is authenticated, or null if no user
  /// is currently signed in.
  ///
  /// Throws an exception if there's an error retrieving the user.
  Future<AppUser?> getCurrentUser();

  /// Provides a stream of authentication state changes.
  ///
  /// Emits an [AppUser] when a user signs in and null when a user signs out.
  /// This stream can be used to react to authentication state changes
  /// throughout the application.
  Stream<AppUser?> authStateChanges();

  /// Checks if a user is currently authenticated.
  ///
  /// Returns true if a user is signed in, false otherwise.
  bool get isAuthenticated;
}
