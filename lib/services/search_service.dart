import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import '../core/errors/exceptions.dart';

/// Service for handling property search operations
class SearchService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Search properties with comprehensive filters
  Future<List<Map<String, dynamic>>> searchProperties({
    String? searchQuery,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
    int? maxGuests,
    int? minBedrooms,
    int? maxBedrooms,
    List<String> amenities = const [],
    String? propertyType,
    bool? isVerified,
    double? latitude,
    double? longitude,
    int? radiusKm,
    String sortBy = 'created_at',
    bool sortAscending = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      dynamic query = _client
          .from(ApiRoutes.propertiesTable)
          .select('''
            *,
            property_images(*)
          ''')
          .eq('is_active', true);

      // Text search on title and description
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      // Location filters
      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }

      if (country != null && country.isNotEmpty) {
        query = query.eq('country', country);
      }

      // Guest count filters
      if (minGuests != null) {
        query = query.gte('max_guests', minGuests);
      }

      if (maxGuests != null) {
        query = query.lte('max_guests', maxGuests);
      }

      // Bedroom filters
      if (minBedrooms != null) {
        query = query.gte('bedrooms', minBedrooms);
      }

      if (maxBedrooms != null) {
        query = query.lte('bedrooms', maxBedrooms);
      }

      // Amenities filter
      if (amenities.isNotEmpty) {
        for (final amenity in amenities) {
          query = query.contains('amenities', [amenity]);
        }
      }

      // Property type filter
      if (propertyType != null && propertyType.isNotEmpty) {
        query = query.eq('property_type', propertyType);
      }

      // Verification filter
      if (isVerified != null && isVerified) {
        query = query.eq('verification_status', 'verified');
      }

      // Sorting
      query = query.order(sortBy, ascending: sortAscending);

      // Pagination
      query = query.range(offset, offset + limit - 1);

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to search properties: ${e.toString()}');
    }
  }

  /// Get search suggestions based on popular searches
  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      if (query.isEmpty) return [];

      // Search in cities and titles
      final citiesResponse = await _client
          .from(ApiRoutes.propertiesTable)
          .select('city')
          .ilike('city', '%$query%')
          .eq('is_active', true)
          .limit(limit);

      final cities = List<Map<String, dynamic>>.from(citiesResponse)
          .map((e) => e['city'] as String)
          .toSet()
          .toList();

      return cities;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get suggestions: ${e.toString()}');
    }
  }

  /// Get popular locations based on property count
  Future<List<String>> getPopularLocations({int limit = 10}) async {
    try {
      final response = await _client
          .from(ApiRoutes.propertiesTable)
          .select('city, country')
          .eq('is_active', true);

      final locations = List<Map<String, dynamic>>.from(response);

      // Group by city,country and count
      final Map<String, int> locationCounts = {};
      for (final loc in locations) {
        final key = '${loc['city']}, ${loc['country']}';
        locationCounts[key] = (locationCounts[key] ?? 0) + 1;
      }

      // Sort by count and return top locations
      final sorted = locationCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(limit).map((e) => e.key).toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get popular locations: ${e.toString()}');
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
        'search_properties_nearby',
        params: {
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusKm,
        },
      ).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get nearby properties: ${e.toString()}');
    }
  }
}
