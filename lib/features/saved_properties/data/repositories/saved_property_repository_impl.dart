import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../property/domain/entities/property.dart';
import '../../domain/repositories/saved_property_repository.dart';
import '../datasources/saved_property_remote_datasource.dart';

class SavedPropertyRepositoryImpl implements SavedPropertyRepository {
  final SavedPropertyRemoteDataSource remoteDataSource;

  SavedPropertyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> saveProperty({required String propertyId}) async {
    try {
      await remoteDataSource.saveProperty(propertyId: propertyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to save property: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveProperty({required String propertyId}) async {
    try {
      await remoteDataSource.unsaveProperty(propertyId: propertyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to unsave property: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isPropertySaved({required String propertyId}) async {
    try {
      final isSaved = await remoteDataSource.isPropertySaved(propertyId: propertyId);
      return Right(isSaved);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to check saved status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getSavedProperties({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final propertyModels = await remoteDataSource.getSavedProperties(
        limit: limit,
        offset: offset,
      );
      return Right(propertyModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get saved properties: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getSavedPropertiesCount() async {
    try {
      final count = await remoteDataSource.getSavedPropertiesCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get saved properties count: ${e.toString()}'));
    }
  }
}
