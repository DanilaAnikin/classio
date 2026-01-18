import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:classio/features/auth/domain/entities/app_user.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/invite_token.dart';
import '../../domain/repositories/invite_repository.dart';
import '../../data/repositories/supabase_invite_repository.dart';

part 'invite_provider.g.dart';

/// Provider for the invite repository.
///
/// Can be overridden in tests to provide a mock implementation.
@riverpod
InviteRepository inviteRepository(Ref ref) {
  return SupabaseInviteRepository(
    supabaseClient: Supabase.instance.client,
  );
}

/// State class for invite operations.
class InviteState {
  /// Creates an [InviteState] instance.
  const InviteState({
    required this.isLoading,
    this.generatedToken,
    this.error,
    this.myTokens = const [],
    this.schoolTokens = const [],
  });

  /// Whether an operation is in progress.
  final bool isLoading;

  /// The most recently generated token.
  final String? generatedToken;

  /// Error message if an operation failed.
  final String? error;

  /// List of tokens created by the current user.
  final List<InviteToken> myTokens;

  /// List of all tokens for the school (admin only).
  final List<InviteToken> schoolTokens;

  /// Creates an initial state.
  factory InviteState.initial() {
    return const InviteState(
      isLoading: false,
      generatedToken: null,
      error: null,
      myTokens: [],
      schoolTokens: [],
    );
  }

  /// Creates a loading state.
  factory InviteState.loading() {
    return const InviteState(
      isLoading: true,
      generatedToken: null,
      error: null,
      myTokens: [],
      schoolTokens: [],
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  InviteState copyWith({
    bool? isLoading,
    String? generatedToken,
    String? error,
    List<InviteToken>? myTokens,
    List<InviteToken>? schoolTokens,
    bool clearGeneratedToken = false,
    bool clearError = false,
  }) {
    return InviteState(
      isLoading: isLoading ?? this.isLoading,
      generatedToken: clearGeneratedToken ? null : (generatedToken ?? this.generatedToken),
      error: clearError ? null : (error ?? this.error),
      myTokens: myTokens ?? this.myTokens,
      schoolTokens: schoolTokens ?? this.schoolTokens,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is InviteState &&
        other.isLoading == isLoading &&
        other.generatedToken == generatedToken &&
        other.error == error &&
        _listEquals(other.myTokens, myTokens) &&
        _listEquals(other.schoolTokens, schoolTokens);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        generatedToken,
        error,
        myTokens,
        schoolTokens,
      );
}

/// Notifier for invite operations.
@riverpod
class InviteNotifier extends _$InviteNotifier {
  late InviteRepository _repository;

  @override
  InviteState build() {
    _repository = ref.watch(inviteRepositoryProvider);
    return InviteState.initial();
  }

  /// Generates a new invite token for the specified role.
  ///
  /// Parameters:
  /// - [targetRole]: The role that will be assigned to users using this token
  /// - [classId]: Optional class ID (required when teacher invites student)
  /// - [expiresAt]: Optional expiration date for the token
  ///
  /// Returns the generated token string if successful, null otherwise.
  Future<String?> generateInvite({
    required UserRole targetRole,
    String? classId,
    DateTime? expiresAt,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearGeneratedToken: true);

    try {
      // Get school_id from current user
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw const InviteException('Not logged in');
      }

      if (currentUser.schoolId == null && currentUser.role != UserRole.superadmin) {
        throw const InviteException('User is not associated with a school');
      }

      final token = await _repository.generateToken(
        targetRole: targetRole,
        schoolId: currentUser.schoolId ?? '',
        classId: classId,
        expiresAt: expiresAt,
      );

      state = state.copyWith(
        isLoading: false,
        generatedToken: token,
      );

      // Refresh the token list
      await loadMyTokens();

      return token;
    } on InviteException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Loads all tokens created by the current user.
  Future<void> loadMyTokens() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final tokens = await _repository.getMyCreatedTokens();
      state = state.copyWith(
        isLoading: false,
        myTokens: tokens,
      );
    } on InviteException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Loads all tokens for the school (admin only).
  Future<void> loadSchoolTokens() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw const InviteException('Not logged in');
      }

      if (currentUser.schoolId == null) {
        throw const InviteException('User is not associated with a school');
      }

      final tokens = await _repository.getSchoolTokens(currentUser.schoolId!);
      state = state.copyWith(
        isLoading: false,
        schoolTokens: tokens,
      );
    } on InviteException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Revokes a token by marking it as used.
  Future<bool> revokeToken(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.revokeToken(token);

      // Refresh the token lists
      await loadMyTokens();

      state = state.copyWith(isLoading: false);
      return true;
    } on InviteException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Cleans up expired tokens for the school.
  Future<int> cleanupExpiredTokens() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        throw const InviteException('Not logged in');
      }

      if (currentUser.schoolId == null) {
        throw const InviteException('User is not associated with a school');
      }

      final count = await _repository.cleanupExpiredTokens(currentUser.schoolId!);

      // Refresh the token lists
      await loadMyTokens();
      await loadSchoolTokens();

      state = state.copyWith(isLoading: false);
      return count;
    } on InviteException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return 0;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return 0;
    }
  }

  /// Clears the generated token from state.
  void clearGeneratedToken() {
    state = state.copyWith(clearGeneratedToken: true);
  }

  /// Clears the error from state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider that checks if the current user can invite for a specific role.
@riverpod
bool canInviteForRole(Ref ref, UserRole targetRole) {
  final currentRole = ref.watch(currentUserRoleProvider);
  if (currentRole == null) return false;

  final repository = ref.read(inviteRepositoryProvider);
  return repository.canGenerateInviteFor(currentRole, targetRole);
}

/// Provider that returns the list of roles the current user can invite.
@riverpod
List<UserRole> invitableRoles(Ref ref) {
  final currentRole = ref.watch(currentUserRoleProvider);
  if (currentRole == null) return [];

  final repository = ref.read(inviteRepositoryProvider);
  return repository.getInvitableRoles(currentRole);
}

/// Provider that checks if the current user can invite anyone.
@riverpod
bool canInvite(Ref ref) {
  final invitableRolesList = ref.watch(invitableRolesProvider);
  return invitableRolesList.isNotEmpty;
}

/// Provider that returns the generated token from the invite state.
@riverpod
String? generatedToken(Ref ref) {
  final state = ref.watch(inviteNotifierProvider);
  return state.generatedToken;
}

/// Provider that returns the invite error message.
@riverpod
String? inviteError(Ref ref) {
  final state = ref.watch(inviteNotifierProvider);
  return state.error;
}

/// Provider that returns whether an invite operation is loading.
@riverpod
bool isInviteLoading(Ref ref) {
  final state = ref.watch(inviteNotifierProvider);
  return state.isLoading;
}

/// Provider that returns the list of tokens created by the current user.
@riverpod
List<InviteToken> myInviteTokens(Ref ref) {
  final state = ref.watch(inviteNotifierProvider);
  return state.myTokens;
}

/// Provider that returns only valid (unused and not expired) tokens.
@riverpod
List<InviteToken> myValidTokens(Ref ref) {
  final tokens = ref.watch(myInviteTokensProvider);
  return tokens.where((token) => token.isValid).toList();
}
