import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/barter_request.dart';
import '../../domain/repositories/matching_repository.dart';
import '../datasources/matching_remote_datasource.dart';

/// Implementation of matching repository
class MatchingRepositoryImpl implements MatchingRepository {
  final MatchingRemoteDataSource remoteDataSource;

  MatchingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BarterRequest>> createBarterRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
    required DateTime requestedStartDate,
    required DateTime requestedEndDate,
    required DateTime offeredStartDate,
    required DateTime offeredEndDate,
    required int requesterGuests,
    required int ownerGuests,
    String? message,
  }) async {
    try {
      final barterModel = await remoteDataSource.createBarterRequest(
        requesterPropertyId: requesterPropertyId,
        ownerPropertyId: ownerPropertyId,
        requestedStartDate: requestedStartDate,
        requestedEndDate: requestedEndDate,
        offeredStartDate: offeredStartDate,
        offeredEndDate: offeredEndDate,
        requesterGuests: requesterGuests,
        ownerGuests: ownerGuests,
        message: message,
      );

      return Right(barterModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to create barter request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterRequest>> acceptBarterRequest(String requestId) async {
    try {
      final barterModel = await remoteDataSource.acceptBarterRequest(requestId);
      return Right(barterModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to accept barter request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterRequest>> rejectBarterRequest({
    required String requestId,
    String? reason,
  }) async {
    try {
      final barterModel = await remoteDataSource.rejectBarterRequest(
        requestId: requestId,
        reason: reason,
      );
      return Right(barterModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to reject barter request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBarterRequest(String requestId) async {
    try {
      await remoteDataSource.cancelBarterRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel barter request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterRequest>> completeBarterRequest(String requestId) async {
    try {
      final barterModel = await remoteDataSource.completeBarterRequest(requestId);
      return Right(barterModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to complete barter request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BarterRequest>> getBarterRequestById(String requestId) async {
    try {
      final barterModel = await remoteDataSource.getBarterRequestById(requestId);
      return Right(barterModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get barter request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BarterRequest>>> getMyBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final barterModels = await remoteDataSource.getMyBarterRequests(
        status: status,
        limit: limit,
        offset: offset,
      );

      final barters = barterModels.map((model) => model.toEntity()).toList();
      return Right(barters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get your barter requests: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BarterRequest>>> getReceivedBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final barterModels = await remoteDataSource.getReceivedBarterRequests(
        status: status,
        limit: limit,
        offset: offset,
      );

      final barters = barterModels.map((model) => model.toEntity()).toList();
      return Right(barters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get received barter requests: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BarterRequest>>> getPropertyBarterRequests({
    required String propertyId,
    String? status,
  }) async {
    try {
      final barterModels = await remoteDataSource.getPropertyBarterRequests(
        propertyId: propertyId,
        status: status,
      );

      final barters = barterModels.map((model) => model.toEntity()).toList();
      return Right(barters);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get property barter requests: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> findMatches({
    required String userPropertyId,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
  }) async {
    try {
      final propertyIds = await remoteDataSource.findMatches(
        userPropertyId: userPropertyId,
        city: city,
        country: country,
        startDate: startDate,
        endDate: endDate,
        minGuests: minGuests,
      );

      return Right(propertyIds);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to find matches: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkExistingRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
  }) async {
    try {
      final exists = await remoteDataSource.checkExistingRequest(
        requesterPropertyId: requesterPropertyId,
        ownerPropertyId: ownerPropertyId,
      );

      return Right(exists);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check existing request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserBarterStatistics() async {
    try {
      final stats = await remoteDataSource.getUserBarterStatistics();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get barter statistics: ${e.toString()}'));
    }
  }
}
