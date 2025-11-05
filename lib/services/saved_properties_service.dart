import 'package:flutter/foundation.dart';
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
        // Return empty list if user not authenticated (don't throw error)
        return [];
      }

      final response = await _client
          .from(ApiRoutes.savedPropertiesTable)
          .select('''
            id,
            created_at,
            property:property_id (
              id,
              owner_id,
              title,
              description,
              address,
              city,
              state_province,
              country,
              postal_code,
              latitude,
              longitude,
              property_type,
              bedrooms,
              bathrooms,
              max_guests,
              area_sqft,
              amenities,
              house_rules,
              verification_status,
              average_rating,
              total_reviews,
              is_active,
              created_at,
              updated_at,
              images,
              property_images (
                id,
                image_url,
                order_index
              )
            )
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Extract the property data from the nested structure
      final List<Map<String, dynamic>> properties = [];

      // Handle response safely - it might be null or empty
      if (response == null) {
        return properties;
      }

      // Safely iterate through the response
      final items = response is List ? response : [response];
      for (var item in items) {
        try {
          if (item is Map<String, dynamic> && item['property'] != null) {
            final propertyData = item['property'];
            if (propertyData is Map<String, dynamic>) {
              properties.add(propertyData);
            }
          }
        } catch (itemError) {
          // Skip this item if there's an error parsing it
          debugPrint('Error parsing saved property item: $itemError');
          continue;
        }
      }

      return properties;
    } on PostgrestException catch (e) {
      // Return empty list on database errors instead of throwing
      debugPrint('Postgrest error getting saved properties: ${e.message}');
      return [];
    } catch (e) {
      // Return empty list on any error instead of throwing
      debugPrint('Error getting saved properties: ${e.toString()}');
      return [];
    }
  }

  /// Get count of saved properties
  Future<int> getSavedPropertiesCount() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        // Return 0 if user not authenticated
        return 0;
      }

      final response = await _client
          .from(ApiRoutes.savedPropertiesTable)
          .select('id')
          .eq('user_id', currentUserId)
          .count();

      return response.count ?? 0;
    } on PostgrestException catch (e) {
      // Return 0 on database errors instead of throwing
      debugPrint('Postgrest error getting saved properties count: ${e.message}');
      return 0;
    } catch (e) {
      // Return 0 on any error instead of throwing
      debugPrint('Error getting saved properties count: ${e.toString()}');
      return 0;
    }
  }
}
