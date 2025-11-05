import '../../../../services/profile_service_ext.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile({required String userId});
  Future<UserProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? location,
  });
  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ProfileService profileService;

  ProfileRemoteDataSourceImpl({required this.profileService});

  @override
  Future<UserProfileModel> getUserProfile({required String userId}) async {
    final data = await profileService.getUserProfile(userId: userId);
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<UserProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? location,
  }) async {
    final data = await profileService.updateProfile(
      userId: userId,
      fullName: fullName,
      phone: phone,
      bio: bio,
      location: location,
    );
    return UserProfileModel.fromJson(data);
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    return await profileService.uploadAvatar(
      userId: userId,
      filePath: filePath,
    );
  }
}
