import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/property.dart';
import '../../domain/repositories/property_repository.dart';
import '../datasources/property_remote_datasource.dart';

/// Implementation of property repository
class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;

  PropertyRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Property>> createProperty({
    required String title,
    required String description,
    required String address,
    required String city,
    String? stateProvince,
    required String country,
    String? postalCode,
    required double latitude,
    required double longitude,
    required String propertyType,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    int? areaSqft,
    required List<String> amenities,
    List<String>? houseRules,
  }) async {
    try {
      final propertyModel = await remoteDataSource.createProperty(
        title: title,
        description: description,
        address: address,
        city: city,
        stateProvince: stateProvince,
        country: country,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        propertyType: propertyType,
        maxGuests: maxGuests,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        areaSqft: areaSqft,
        amenities: amenities,
        houseRules: houseRules,
      );

      return Right(propertyModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to create property: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Property>> updateProperty({
    required String propertyId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final propertyModel = await remoteDataSource.updateProperty(
        propertyId: propertyId,
        updates: updates,
      );

      return Right(propertyModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update property: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProperty(String propertyId) async {
    try {
      await remoteDataSource.deleteProperty(propertyId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete property: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Property>> getPropertyById(String propertyId) async {
    try {
      final propertyModel = await remoteDataSource.getPropertyById(propertyId);
      return Right(propertyModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get property: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getProperties({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final propertyModels = await remoteDataSource.getProperties(
        limit: limit,
        offset: offset,
      );

      final properties = propertyModels.map((model) => model.toEntity()).toList();
      return Right(properties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get properties: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Property>>> getUserProperties(
    String userId,
  ) async {
    try {
      final propertyModels =
          await remoteDataSource.getUserProperties(userId);

      final properties = propertyModels.map((model) => model.toEntity()).toList();
      return Right(properties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get user properties: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Property>>> searchProperties({
    String? city,
    String? country,
    String? propertyType,
    int? minGuests,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final propertyModels = await remoteDataSource.searchProperties(
        city: city,
        country: country,
        propertyType: propertyType,
        minGuests: minGuests,
        limit: limit,
        offset: offset,
      );

      final properties = propertyModels.map((model) => model.toEntity()).toList();
      return Right(properties);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to search properties: ${e.toString()}'));
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
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get nearby properties: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadPropertyImages({
    required String propertyId,
    required List<String> imagePaths,
  }) async {
    try {
      final imageUrls = await remoteDataSource.uploadPropertyImages(
        propertyId: propertyId,
        imagePaths: imagePaths,
      );

      return Right(imageUrls);
    } on FileUploadException catch (e) {
      return Left(FileUploadFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          FileUploadFailure('Failed to upload images: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePropertyImage({
    required String propertyId,
    required String imageUrl,
  }) async {
    try {
      await remoteDataSource.deletePropertyImage(
        propertyId: propertyId,
        imageUrl: imageUrl,
      );

      return const Right(null);
    } on FileUploadException catch (e) {
      return Left(FileUploadFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(FileUploadFailure('Failed to delete image: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> addAvailability({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await remoteDataSource.addAvailability(
        propertyId: propertyId,
        startDate: startDate,
        endDate: endDate,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to add availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<DateRange>>> getPropertyAvailability(
    String propertyId,
  ) async {
    try {
      final dateRangeModels =
          await remoteDataSource.getPropertyAvailability(propertyId);

      final dateRanges = dateRangeModels.map((model) => model.toEntity()).toList();
      return Right(dateRanges);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to get availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Property>> togglePropertyStatus(
    String propertyId,
  ) async {
    try {
      final propertyModel =
          await remoteDataSource.togglePropertyStatus(propertyId);

      return Right(propertyModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(
          ServerFailure('Failed to toggle property status: ${e.toString()}'));
    }
  }
}
