import '../../../../services/review_service.dart';
import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview({
    required String barterId,
    required String propertyId,
    required int rating,
    String? comment,
  });

  Future<List<ReviewModel>> getPropertyReviews({
    required String propertyId,
    int limit = 20,
    int offset = 0,
  });

  Future<double> getAverageRating({required String propertyId});
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final ReviewService reviewService;

  ReviewRemoteDataSourceImpl({required this.reviewService});

  @override
  Future<ReviewModel> createReview({
    required String barterId,
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    final data = await reviewService.createReview(
      barterId: barterId,
      propertyId: propertyId,
      rating: rating,
      comment: comment,
    );
    return ReviewModel.fromJson(data);
  }

  @override
  Future<List<ReviewModel>> getPropertyReviews({
    required String propertyId,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await reviewService.getPropertyReviews(
      propertyId: propertyId,
      limit: limit,
      offset: offset,
    );
    return data.map((json) => ReviewModel.fromJson(json)).toList();
  }

  @override
  Future<double> getAverageRating({required String propertyId}) async {
    return await reviewService.getAverageRating(propertyId: propertyId);
  }
}
