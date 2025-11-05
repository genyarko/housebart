import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/exceptions.dart';
import '../core/constants/api_routes.dart';

/// Service for handling property operations with Supabase
class PropertyService {
  final SupabaseClient _client = Supabase.instance.client;
  final _uuid = const Uuid();

  /// Create a new property
  Future<Map<String, dynamic>> createProperty({
    required String title,
    required String description,
    required String address,
    required String city,
    String? stateProvince,
    required String country,
    String? postalCode,
    double? latitude,
    double? longitude,
    required String propertyType,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    int? areaSqft,
    required List<String> amenities,
    List<String>? houseRules,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException('User not authenticated');
      }

      // Build the data object with required fields
      final Map<String, dynamic> data = {
        'owner_id': userId,
        'title': title,
        'description': description,
        'address': address,
        'city': city,
        'state_province': stateProvince,
        'country': country,
        'postal_code': postalCode,
        'property_type': propertyType,
        'max_guests': maxGuests,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area_sqft': areaSqft,
        'amenities': amenities,
        'house_rules': houseRules ?? [],
        'is_active': true,
      };

      // Add coordinates only if both are provided
      if (latitude != null && longitude != null) {
        data['latitude'] = latitude;
        data['longitude'] = longitude;
        data['location'] = 'POINT($longitude $latitude)';
      }

      final response = await _client.from(ApiRoutes.propertiesTable).insert(data).select().single();

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create property: ${e.toString()}');
    }
  }

  /// Update a property
  Future<Map<String, dynamic>> updateProperty({
    required String propertyId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.propertiesTable)
          .update(updates)
          .eq('id', propertyId)
          .select()
          .single();

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to update property: ${e.toString()}');
    }
  }

  /// Delete a property
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _client
          .from(ApiRoutes.propertiesTable)
          .delete()
          .eq('id', propertyId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to delete property: ${e.toString()}');
    }
  }

  /// Get property by ID
  Future<Map<String, dynamic>> getPropertyById(String propertyId) async {
    try {
      final response = await _client
          .from(ApiRoutes.propertiesTable)
          .select()
          .eq('id', propertyId)
          .single();

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundException('Property not found');
      }
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get property: ${e.toString()}');
    }
  }

  /// Get all properties with pagination
  Future<List<Map<String, dynamic>>> getProperties({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.propertiesTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get properties: ${e.toString()}');
    }
  }

  /// Get user's properties
  Future<List<Map<String, dynamic>>> getUserProperties(String userId) async {
    try {
      final response = await _client
          .from(ApiRoutes.propertiesTable)
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get user properties: ${e.toString()}');
    }
  }

  /// Search properties with filters
  Future<List<Map<String, dynamic>>> searchProperties({
    String? city,
    String? country,
    String? propertyType,
    int? minGuests,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? amenities,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query =
          _client.from(ApiRoutes.propertiesTable).select().eq('is_active', true);

      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }

      if (country != null && country.isNotEmpty) {
        query = query.eq('country', country);
      }

      if (propertyType != null && propertyType.isNotEmpty) {
        query = query.eq('property_type', propertyType);
      }

      if (minGuests != null) {
        query = query.gte('max_guests', minGuests);
      }

      if (amenities != null && amenities.isNotEmpty) {
        query = query.contains('amenities', amenities);
      }

      // Note: Date filtering would require joining with availability table
      // For now, we'll filter on the property side only
      // You may need to implement a custom RPC function for complex date queries

      final response =
          await query.order('created_at', ascending: false).range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to search properties: ${e.toString()}');
    }
  }

  /// Get nearby properties using PostGIS
  Future<List<Map<String, dynamic>>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      final response = await _client.rpc(
        ApiRoutes.searchPropertiesNearbyRPC,
        params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusKm,
        },
      ).limit(limit);

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get nearby properties: ${e.toString()}');
    }
  }

  /// Upload property images to Supabase Storage
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<String> imagePaths,
  }) async {
    try {
      final List<String> imageUrls = [];

      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
        final file = File(imagePath);

        if (!await file.exists()) {
          throw FileUploadException('File does not exist: $imagePath');
        }

        // Generate unique filename
        final extension = imagePath.split('.').last;
        final fileName = '$propertyId/${_uuid.v4()}.$extension';

        // Upload to Supabase Storage
        await _client.storage.from(ApiRoutes.propertyImagesBucket).upload(
              fileName,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        // Get public URL
        final imageUrl = _client.storage.from(ApiRoutes.propertyImagesBucket).getPublicUrl(fileName);

        // Save image record to database
        await _client.from(ApiRoutes.propertyImagesTable).insert({
          'property_id': propertyId,
          'image_url': imageUrl,
          'storage_path': fileName,
          'is_primary': i == 0,
          'order_index': i,
        });

        imageUrls.add(imageUrl);

        // Update property images array
        await _client.from(ApiRoutes.propertiesTable).update({
          'images': imageUrls,
        }).eq('id', propertyId);
      }

      return imageUrls;
    } on StorageException catch (e) {
      throw FileUploadException(e.message, e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw FileUploadException('Failed to upload images: ${e.toString()}');
    }
  }

  /// Delete property image
  Future<void> deletePropertyImage({
    required String propertyId,
    required String storagePath,
  }) async {
    try {
      // Delete from storage
      await _client.storage.from(ApiRoutes.propertyImagesBucket).remove([storagePath]);

      // Delete from database
      await _client
          .from(ApiRoutes.propertyImagesTable)
          .delete()
          .eq('property_id', propertyId)
          .eq('storage_path', storagePath);
    } on StorageException catch (e) {
      throw FileUploadException(e.message, e.statusCode);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw FileUploadException('Failed to delete image: ${e.toString()}');
    }
  }

  /// Add availability dates for property
  Future<void> addAvailability({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _client.from(ApiRoutes.propertyAvailabilityTable).insert({
        'property_id': propertyId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'is_available': true,
      });
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to add availability: ${e.toString()}');
    }
  }

  /// Remove availability dates for property
  Future<void> removeAvailability({
    required String propertyId,
    required String availabilityId,
  }) async {
    try {
      await _client
          .from(ApiRoutes.propertyAvailabilityTable)
          .delete()
          .eq('id', availabilityId)
          .eq('property_id', propertyId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to remove availability: ${e.toString()}');
    }
  }

  /// Get property availability
  Future<List<Map<String, dynamic>>> getPropertyAvailability(
    String propertyId,
  ) async {
    try {
      final response = await _client
          .from(ApiRoutes.propertyAvailabilityTable)
          .select()
          .eq('property_id', propertyId)
          .eq('is_available', true)
          .order('start_date');

      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get availability: ${e.toString()}');
    }
  }

  /// Toggle property active status
  Future<Map<String, dynamic>> togglePropertyStatus(String propertyId) async {
    try {
      // Get current status
      final property = await getPropertyById(propertyId);
      final currentStatus = property['is_active'] as bool;

      // Toggle status
      final response = await _client
          .from(ApiRoutes.propertiesTable)
          .update({'is_active': !currentStatus})
          .eq('id', propertyId)
          .select()
          .single();

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to toggle property status: ${e.toString()}');
    }
  }
}
