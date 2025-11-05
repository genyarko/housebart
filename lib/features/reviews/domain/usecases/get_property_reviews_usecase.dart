import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetPropertyReviewsUseCase {
  final ReviewRepository repository;

  GetPropertyReviewsUseCase(this.repository);

  Future<Either<Failure, List<Review>>> call(GetPropertyReviewsParams params) async {
    return await repository.getPropertyReviews(
      propertyId: params.propertyId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetPropertyReviewsParams extends Equatable {
  final String propertyId;
  final int limit;
  final int offset;

  const GetPropertyReviewsParams({
    required this.propertyId,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [propertyId, limit, offset];
}
