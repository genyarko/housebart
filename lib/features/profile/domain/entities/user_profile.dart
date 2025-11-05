import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final int bartersCompleted;
  final double averageRating;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.location,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.bartersCompleted = 0,
    this.averageRating = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        avatarUrl,
        bio,
        location,
        createdAt,
        updatedAt,
        isVerified,
        bartersCompleted,
        averageRating,
      ];
}
