import 'dart:typed_data';
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
  Future<Either<Failure, String>> uploadAvatar({
    required Uint8List fileBytes,
    required String fileName,
  });
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, Map<String, int>>> getProfileStatistics({required String userId});
}
