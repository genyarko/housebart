import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import '../core/errors/exceptions.dart';

/// Service for handling saved properties operations
class SavedPropertiesService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Save/favorite a property
  Future<void> saveProperty({required String propertyId}) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      await _client.from(ApiRoutes.savedPropertiesTable).insert({
        'user_id': currentUserId,
        'property_id': propertyId,
      });
    } on PostgrestException catch (e) {
      // Handle duplicate key error (property already saved)
      if (e.code == '23505') {
        // Already saved, ignore
        return;
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to save property: ${e.toString()}');
    }
  }

  /// Unsave/unfavorite a property
  Future<void> unsaveProperty({required String propertyId}) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      await _client
          .from(ApiRoutes.savedPropertiesTable)
          .delete()
          .eq('user_id', currentUserId)
          .eq('property_id', propertyId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to unsave property: ${e.toString()}');
    }
  }

  /// Check if a property is saved
  Future<bool> isPropertySaved({required String propertyId}) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.savedPropertiesTable)
          .select('id')
          .eq('user_id', currentUserId)
          .eq('property_id', propertyId)
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to check saved status: ${e.toString()}');
    }
  }

  /// Get all saved properties with property details
  Future<List<Map<String, dynamic>>> getSavedProperties({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.savedPropertiesTable)
          .select('''
            id,
            created_at,
            property:property_id (
              id,
              user_id,
              title,
              description,
              address,
              city,
              country,
              latitude,
              longitude,
              property_type,
              bedrooms,
              bathrooms,
              max_guests,
              amenities,
              is_verified,
              is_active,
              created_at,
              property_images (
                id,
                image_url,
                display_order
              )
            )
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Extract the property data from the nested structure
      final List<Map<String, dynamic>> properties = [];
      for (var item in List<Map<String, dynamic>>.from(response)) {
        if (item['property'] != null) {
          properties.add(item['property'] as Map<String, dynamic>);
        }
      }

      return properties;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get saved properties: ${e.toString()}');
    }
  }

  /// Get count of saved properties
  Future<int> getSavedPropertiesCount() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.savedPropertiesTable)
          .select('id')
          .eq('user_id', currentUserId)
          .count();

      return response.count;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get saved properties count: ${e.toString()}');
    }
  }
}
