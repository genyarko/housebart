import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class CreateReviewUseCase {
  final ReviewRepository repository;

  CreateReviewUseCase(this.repository);

  Future<Either<Failure, Review>> call(CreateReviewParams params) async {
    return await repository.createReview(
      barterId: params.barterId,
      propertyId: params.propertyId,
      rating: params.rating,
      comment: params.comment,
    );
  }
}

class CreateReviewParams extends Equatable {
  final String barterId;
  final String propertyId;
  final int rating;
  final String? comment;

  const CreateReviewParams({
    required this.barterId,
    required this.propertyId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [barterId, propertyId, rating, comment];
}
