import 'package:equatable/equatable.dart';

/// Entity representing a property review
class Review extends Equatable {
  final String id;
  final String barterId;
  final String propertyId;
  final String reviewerId;
  final String reviewerName;
  final int rating; // 1-5 stars
  final String? comment;
  final List<String> images;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Review({
    required this.id,
    required this.barterId,
    required this.propertyId,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    this.comment,
    this.images = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if review has images
  bool get hasImages => images.isNotEmpty;

  /// Check if review has comment
  bool get hasComment => comment != null && comment!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        barterId,
        propertyId,
        reviewerId,
        reviewerName,
        rating,
        comment,
        images,
        createdAt,
        updatedAt,
      ];
}
