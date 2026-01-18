import 'package:classio/features/auth/domain/entities/app_user.dart';

/// Extended user profile with additional settings
class UserProfile {
  final AppUser user;
  final String? bio;
  final String? phoneNumber;
  final DateTime? lastActive;
  final Map<String, dynamic> preferences;

  const UserProfile({
    required this.user,
    this.bio,
    this.phoneNumber,
    this.lastActive,
    this.preferences = const {},
  });

  UserProfile copyWith({
    AppUser? user,
    String? bio,
    String? phoneNumber,
    DateTime? lastActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      user: user ?? this.user,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastActive: lastActive ?? this.lastActive,
      preferences: preferences ?? this.preferences,
    );
  }
}
