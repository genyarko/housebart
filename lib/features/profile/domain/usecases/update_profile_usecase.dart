import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      fullName: params.fullName,
      phone: params.phone,
      bio: params.bio,
      location: params.location,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? fullName;
  final String? phone;
  final String? bio;
  final String? location;

  const UpdateProfileParams({
    this.fullName,
    this.phone,
    this.bio,
    this.location,
  });

  @override
  List<Object?> get props => [fullName, phone, bio, location];
}
