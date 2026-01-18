import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Exception thrown when profile operations fail.
class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => 'ProfileException: $message';
}

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabase;

  SupabaseProfileRepository(this._supabase);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile(
        user: AppUser.fromJson(response),
        bio: response['bio'] as String?,
        phoneNumber: response['phone_number'] as String?,
        lastActive: response['last_active'] != null
            ? DateTime.parse(response['last_active'] as String)
            : null,
        preferences: response['preferences'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching profile: $e');
      }
      return null;
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      await _supabase.from('profiles').update({
        'first_name': profile.user.firstName,
        'last_name': profile.user.lastName,
        'bio': profile.bio,
        'phone_number': profile.phoneNumber,
      }).eq('id', profile.user.id);
    } on PostgrestException catch (e) {
      debugPrint('Profile update failed: ${e.message}');
      throw ProfileException('Failed to update profile: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error updating profile: $e');
      throw ProfileException('Unexpected error: $e');
    }
  }

  @override
  Future<void> updateAvatar(String userId, String avatarUrl) async {
    try {
      await _supabase.from('profiles').update({
        'avatar_url': avatarUrl,
      }).eq('id', userId);
    } on PostgrestException catch (e) {
      debugPrint('Avatar update failed: ${e.message}');
      throw ProfileException('Failed to update avatar: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error updating avatar: $e');
      throw ProfileException('Unexpected error: $e');
    }
  }
}
