import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Review>> createReview({
    required String barterId,
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    try {
      final reviewModel = await remoteDataSource.createReview(
        barterId: barterId,
        propertyId: propertyId,
        rating: rating,
        comment: comment,
      );
      return Right(reviewModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to create review: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Review>>> getPropertyReviews({
    required String propertyId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final reviewModels = await remoteDataSource.getPropertyReviews(
        propertyId: propertyId,
        limit: limit,
        offset: offset,
      );
      return Right(reviewModels.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get reviews: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Review>> getReviewById({required String reviewId}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Review>>> getUserReviews() async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteReview({required String reviewId}) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, double>> getAverageRating({required String propertyId}) async {
    try {
      final avgRating = await remoteDataSource.getAverageRating(propertyId: propertyId);
      return Right(avgRating);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to get average rating: ${e.toString()}'));
    }
  }
}
