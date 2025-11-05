import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/repositories/verification_repository.dart';
import '../datasources/verification_remote_datasource.dart';

/// Implementation of VerificationRepository
class VerificationRepositoryImpl implements VerificationRepository {
  final VerificationRemoteDataSource remoteDataSource;

  VerificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, VerificationRequest>> createRequest({
    required String propertyId,
  }) async {
    try {
      final requestModel = await remoteDataSource.createRequest(
        propertyId: propertyId,
      );
      return Right(requestModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to create verification request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VerificationRequest>> getRequestById({
    required String requestId,
  }) async {
    try {
      final requestModel = await remoteDataSource.getRequestById(
        requestId: requestId,
      );
      return Right(requestModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get verification request: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<VerificationRequest>>> getUserRequests() async {
    try {
      final requestModels = await remoteDataSource.getUserRequests();
      final requests = requestModels.map((model) => model.toEntity()).toList();
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get user verification requests: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VerificationRequest?>> getPropertyVerification({
    required String propertyId,
  }) async {
    try {
      final requestModel = await remoteDataSource.getPropertyVerification(
        propertyId: propertyId,
      );

      if (requestModel == null) {
        return const Right(null);
      }

      return Right(requestModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get property verification: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createPaymentIntent({
    required String requestId,
  }) async {
    try {
      final paymentData = await remoteDataSource.createPaymentIntent(
        requestId: requestId,
      );
      return Right(paymentData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to create payment intent: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VerificationRequest>> confirmPayment({
    required String requestId,
    required String paymentIntentId,
  }) async {
    try {
      final requestModel = await remoteDataSource.confirmPayment(
        requestId: requestId,
        paymentIntentId: paymentIntentId,
      );
      return Right(requestModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to confirm payment: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadDocument({
    required String requestId,
    required String filePath,
  }) async {
    try {
      final url = await remoteDataSource.uploadDocument(
        requestId: requestId,
        filePath: filePath,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to upload document: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRequest({
    required String requestId,
  }) async {
    try {
      await remoteDataSource.cancelRequest(requestId: requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel verification request: ${e.toString()}'));
    }
  }
}
