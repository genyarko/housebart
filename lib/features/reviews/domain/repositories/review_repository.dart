import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';

/// Repository interface for review operations
abstract class ReviewRepository {
  /// Create a new review
  Future<Either<Failure, Review>> createReview({
    required String barterId,
    required String propertyId,
    required int rating,
    String? comment,
  });

  /// Get reviews for a property
  Future<Either<Failure, List<Review>>> getPropertyReviews({
    required String propertyId,
    int limit = 20,
    int offset = 0,
  });

  /// Get review by ID
  Future<Either<Failure, Review>> getReviewById({
    required String reviewId,
  });

  /// Get user's reviews
  Future<Either<Failure, List<Review>>> getUserReviews();

  /// Update review
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
  });

  /// Delete review
  Future<Either<Failure, void>> deleteReview({
    required String reviewId,
  });

  /// Get average rating for a property
  Future<Either<Failure, double>> getAverageRating({
    required String propertyId,
  });
}
