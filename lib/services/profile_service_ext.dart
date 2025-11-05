import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import '../core/errors/exceptions.dart';

/// Service for profile operations (extends existing services)
class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile({required String userId}) async {
    try {
      final response = await _client
          .from(ApiRoutes.profilesTable)
          .select()
          .eq('id', userId)
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? location,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;

      if (updates.isEmpty) {
        throw const ServerException('No updates provided');
      }

      final response = await _client
          .from(ApiRoutes.profilesTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to update profile: ${e.toString()}');
    }
  }

  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}';

      await _client.storage
          .from(ApiRoutes.userAvatarsBucket)
          .upload(fileName, filePath);

      final url = _client.storage
          .from(ApiRoutes.userAvatarsBucket)
          .getPublicUrl(fileName);

      // Update profile with avatar URL
      await _client
          .from(ApiRoutes.profilesTable)
          .update({'avatar_url': url}).eq('id', userId);

      return url;
    } on StorageException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Failed to upload avatar: ${e.toString()}');
    }
  }
}
