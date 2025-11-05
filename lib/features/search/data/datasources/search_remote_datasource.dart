import '../../../../services/search_service.dart';
import '../../../property/data/models/property_model.dart';
import '../../domain/entities/search_filters.dart';

/// Interface for search remote data source
abstract class SearchRemoteDataSource {
  Future<List<PropertyModel>> searchProperties({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 10,
  });

  Future<List<String>> getPopularLocations({int limit = 10});

  Future<List<PropertyModel>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  });
}

/// Implementation of search remote data source
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SearchService searchService;

  SearchRemoteDataSourceImpl({required this.searchService});

  @override
  Future<List<PropertyModel>> searchProperties({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    // Map user-friendly sort values to actual database columns
    String sortByColumn = _mapSortByToColumn(filters.sortBy);

    final results = await searchService.searchProperties(
      searchQuery: filters.searchQuery,
      city: filters.city,
      country: filters.country,
      startDate: filters.startDate,
      endDate: filters.endDate,
      minGuests: filters.minGuests,
      maxGuests: filters.maxGuests,
      minBedrooms: filters.minBedrooms,
      maxBedrooms: filters.maxBedrooms,
      amenities: filters.amenities,
      propertyType: filters.propertyType,
      isVerified: filters.isVerified,
      latitude: filters.latitude,
      longitude: filters.longitude,
      radiusKm: filters.radiusKm,
      sortBy: sortByColumn,
      sortAscending: filters.sortAscending,
      limit: limit,
      offset: offset,
    );

    return results.map((data) => PropertyModel.fromJson(data)).toList();
  }

  /// Map user-friendly sort values to actual database column names
  String _mapSortByToColumn(String sortBy) {
    switch (sortBy) {
      case 'newest':
        return 'created_at';
      case 'size':
        return 'area_sqft'; // Sort by property size
      case 'rating':
        return 'average_rating';
      case 'distance':
        return 'distance'; // Used in nearby searches
      default:
        return 'created_at'; // Default to newest
    }
  }

  @override
  Future<List<String>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    return await searchService.getSearchSuggestions(
      query: query,
      limit: limit,
    );
  }

  @override
  Future<List<String>> getPopularLocations({int limit = 10}) async {
    return await searchService.getPopularLocations(limit: limit);
  }

  @override
  Future<List<PropertyModel>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  }) async {
    final results = await searchService.getNearbyProperties(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      limit: limit,
    );

    return results.map((data) => PropertyModel.fromJson(data)).toList();
  }
}
