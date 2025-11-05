import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../property/domain/entities/property.dart';
import '../entities/search_filters.dart';

/// Repository interface for search operations
abstract class SearchRepository {
  /// Search properties with filters
  Future<Either<Failure, List<Property>>> searchProperties({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  });

  /// Get search suggestions based on query
  Future<Either<Failure, List<String>>> getSearchSuggestions({
    required String query,
    int limit = 10,
  });

  /// Get popular locations
  Future<Either<Failure, List<String>>> getPopularLocations({
    int limit = 10,
  });

  /// Get nearby properties based on location
  Future<Either<Failure, List<Property>>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  });
}
