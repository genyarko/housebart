import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    super.phone,
    super.avatarUrl,
    super.bio,
    super.location,
    required super.createdAt,
    super.updatedAt,
    super.isVerified,
    super.bartersCompleted,
    super.averageRating,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      bartersCompleted: json['barters_completed'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  UserProfile toEntity() => UserProfile(
        id: id,
        email: email,
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
        bio: bio,
        location: location,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isVerified: isVerified,
        bartersCompleted: bartersCompleted,
        averageRating: averageRating,
      );
}
