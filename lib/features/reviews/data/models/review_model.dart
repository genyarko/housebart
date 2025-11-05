import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.barterId,
    required super.propertyId,
    required super.reviewerId,
    required super.reviewerName,
    required super.rating,
    super.comment,
    super.images,
    required super.createdAt,
    super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      barterId: json['barter_id'] as String,
      propertyId: json['property_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: json['reviewer_name'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barter_id': barterId,
      'property_id': propertyId,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'rating': rating,
      'comment': comment,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Review toEntity() => Review(
        id: id,
        barterId: barterId,
        propertyId: propertyId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        rating: rating,
        comment: comment,
        images: images,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
