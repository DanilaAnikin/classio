import 'dart:async';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Mock implementation of [AuthRepository] for testing and development.
///
/// Simulates authentication without a real backend.
/// Always succeeds with a dummy user after a 2-second delay.
class MockAuthRepository implements AuthRepository {
  /// Creates a [MockAuthRepository] instance.
  MockAuthRepository() {
    // Initialize with no user
    _authStateController.add(null);
  }

  final StreamController<AppUser?> _authStateController =
      StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _authStateController.stream;

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<AppUser?> signIn(String email, String password) async {
    return signInWithEmailAndPassword(email: email, password: password);
  }

  Future<AppUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Create a mock user
      final user = AppUser(
        id: 'mock-user-123',
        email: email,
        role: UserRole.student,
        firstName: 'Mock',
        lastName: 'User',
        schoolId: 'mock-school-1',
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      _currentUser = user;
      _authStateController.add(user);

      return user;
    } catch (e) {
      return null;
    }
  }

  Future<AppUser?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserRole role,
    String? firstName,
    String? lastName,
    String? schoolId,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      // Create a mock user with the specified role
      final user = AppUser(
        id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        role: role,
        firstName: firstName ?? 'Mock',
        lastName: lastName ?? 'User',
        schoolId: schoolId ?? 'mock-school-1',
        avatarUrl: null,
        createdAt: DateTime.now(),
      );

      _currentUser = user;
      _authStateController.add(user);

      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = null;
      _authStateController.add(null);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signOutWithResult() async {
    try {
      await signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Always succeed
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Disposes of resources.
  void dispose() {
    _authStateController.close();
  }
}
