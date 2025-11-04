import '../../domain/entities/user.dart';

/// User model for the data layer
/// Extends User entity and adds JSON serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.avatarUrl,
    super.bio,
    required super.isVerified,
    required super.createdAt,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create UserModel from Supabase User
  factory UserModel.fromSupabaseUser(
    Map<String, dynamic> supabaseUser,
    Map<String, dynamic>? profileData,
  ) {
    // Get user metadata
    final metadata = supabaseUser['user_metadata'] as Map<String, dynamic>?;

    return UserModel(
      id: supabaseUser['id'] as String,
      email: supabaseUser['email'] as String,
      firstName: metadata?['first_name'] as String? ??
          profileData?['first_name'] as String? ??
          '',
      lastName: metadata?['last_name'] as String? ??
          profileData?['last_name'] as String? ??
          '',
      phone: metadata?['phone'] as String? ??
          profileData?['phone'] as String?,
      avatarUrl: metadata?['avatar_url'] as String? ??
          profileData?['avatar_url'] as String?,
      bio: profileData?['bio'] as String?,
      isVerified: profileData?['is_verified'] as bool? ?? false,
      createdAt: supabaseUser['created_at'] != null
          ? DateTime.parse(supabaseUser['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to User entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      avatarUrl: avatarUrl,
      bio: bio,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }

  /// Create UserModel from User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      isVerified: user.isVerified,
      createdAt: user.createdAt,
    );
  }

  /// Copy with
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
    String? bio,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
