import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/create_review_usecase.dart';
import '../../domain/usecases/get_property_reviews_usecase.dart';

// Events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class ReviewCreateEvent extends ReviewEvent {
  final String barterId;
  final String propertyId;
  final int rating;
  final String? comment;

  const ReviewCreateEvent({
    required this.barterId,
    required this.propertyId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [barterId, propertyId, rating, comment];
}

class ReviewLoadPropertyReviewsEvent extends ReviewEvent {
  final String propertyId;

  const ReviewLoadPropertyReviewsEvent({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

// States
abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class ReviewCreated extends ReviewState {
  final Review review;

  const ReviewCreated(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;

  const ReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final CreateReviewUseCase createReviewUseCase;
  final GetPropertyReviewsUseCase getPropertyReviewsUseCase;

  ReviewBloc({
    required this.createReviewUseCase,
    required this.getPropertyReviewsUseCase,
  }) : super(ReviewInitial()) {
    on<ReviewCreateEvent>(_onCreateReview);
    on<ReviewLoadPropertyReviewsEvent>(_onLoadPropertyReviews);
  }

  Future<void> _onCreateReview(
    ReviewCreateEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await createReviewUseCase(
      CreateReviewParams(
        barterId: event.barterId,
        propertyId: event.propertyId,
        rating: event.rating,
        comment: event.comment,
      ),
    );

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (review) => emit(ReviewCreated(review)),
    );
  }

  Future<void> _onLoadPropertyReviews(
    ReviewLoadPropertyReviewsEvent event,
    Emitter<ReviewState> emit,
  ) async {
    emit(ReviewLoading());

    final result = await getPropertyReviewsUseCase(
      GetPropertyReviewsParams(propertyId: event.propertyId),
    );

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (reviews) => emit(ReviewsLoaded(reviews)),
    );
  }
}
