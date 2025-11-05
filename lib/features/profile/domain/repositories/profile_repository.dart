import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile({required String userId});
  Future<Either<Failure, UserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? bio,
    String? location,
  });
  Future<Either<Failure, String>> uploadAvatar({required String filePath});
  Future<Either<Failure, void>> deleteAccount();
}
