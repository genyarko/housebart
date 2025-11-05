import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../property/domain/entities/property.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

/// Implementation of SearchRepository
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Property>>> searchProperties({
    required SearchFilters filters,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final propertyModels = await remoteDataSource.searchProperties(
        filters: filters,
        limit: limit,
        offset: offset,
      );
      final properties = propertyModels.map((model) => model.toEntity()).toList();
      return Right(properties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to search properties: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSearchSuggestions({
    required String query,
    int limit = 10,
  }) async {
    try {
      final suggestions = await remoteDataSource.getSearchSuggestions(
        query: query,
        limit: limit,
      );
      return Right(suggestions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get suggestions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPopularLocations({
    int limit = 10,
  }) async {
    try {
      final locations = await remoteDataSource.getPopularLocations(limit: limit);
      return Right(locations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get popular locations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      final propertyModels = await remoteDataSource.getNearbyProperties(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
      );
      final properties = propertyModels.map((model) => model.toEntity()).toList();
      return Right(properties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get nearby properties: ${e.toString()}'));
    }
  }
}
