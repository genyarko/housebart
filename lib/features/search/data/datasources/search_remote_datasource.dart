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
      sortBy: filters.sortBy,
      sortAscending: filters.sortAscending,
      limit: limit,
      offset: offset,
    );

    return results.map((data) => PropertyModel.fromJson(data)).toList();
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
