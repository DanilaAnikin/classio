/// Base exception class for all application exceptions.
///
/// All custom exceptions in the application should extend this class
/// to enable consistent error handling and logging.
class AppException implements Exception {
  /// Creates an [AppException] with a required [message].
  ///
  /// Optionally accepts:
  /// - [code]: An error code for categorizing the exception
  /// - [originalError]: The original error that caused this exception
  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  /// Human-readable error message describing what went wrong.
  final String message;

  /// Optional error code for categorizing the exception.
  ///
  /// Can be used for error tracking, analytics, or localized error messages.
  final String? code;

  /// The original error that caused this exception, if any.
  ///
  /// Useful for debugging and error chain tracking.
  final Object? originalError;

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when repository operations fail.
///
/// Use this class for data layer exceptions that occur during
/// database queries, API calls, or other data operations.
///
/// Example:
/// ```dart
/// throw RepositoryException(
///   'Failed to fetch user data',
///   code: 'USER_FETCH_ERROR',
///   originalError: postgrestException,
/// );
/// ```
class RepositoryException extends AppException {
  /// Creates a [RepositoryException] with a required [message].
  ///
  /// Optionally accepts:
  /// - [code]: An error code for categorizing the exception
  /// - [originalError]: The original error that caused this exception
  const RepositoryException(
    super.message, {
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'RepositoryException: $message';
}
