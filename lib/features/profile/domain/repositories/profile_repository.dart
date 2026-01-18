import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<void> updateAvatar(String userId, String avatarUrl);
}
