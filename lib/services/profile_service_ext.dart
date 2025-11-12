import 'dart:typed_data';
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
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      final uniqueFileName = '$userId-${DateTime.now().millisecondsSinceEpoch}-$fileName';

      await _client.storage
          .from(ApiRoutes.userAvatarsBucket)
          .uploadBinary(uniqueFileName, fileBytes);

      final url = _client.storage
          .from(ApiRoutes.userAvatarsBucket)
          .getPublicUrl(uniqueFileName);

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

  Future<Map<String, int>> getProfileStatistics({required String userId}) async {
    try {
      // Get properties count
      final propertiesResponse = await _client
          .from(ApiRoutes.propertiesTable)
          .select('id')
          .eq('owner_id', userId)
          .count(CountOption.exact);

      // Get barters count (both sent and received)
      final bartersResponse = await _client
          .from(ApiRoutes.barterRequestsTable)
          .select('id')
          .or('requester_id.eq.$userId,owner_id.eq.$userId')
          .count(CountOption.exact);

      // Get saved properties count
      final savedResponse = await _client
          .from(ApiRoutes.savedPropertiesTable)
          .select('id')
          .eq('user_id', userId)
          .count(CountOption.exact);

      return {
        'properties': propertiesResponse.count,
        'barters': bartersResponse.count,
        'saved': savedResponse.count,
      };
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get profile statistics: ${e.toString()}');
    }
  }
}
