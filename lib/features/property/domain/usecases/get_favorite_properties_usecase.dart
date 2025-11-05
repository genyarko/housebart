import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Use case for getting user's favorite properties
class GetFavoritePropertiesUseCase {
  final PropertyRepository repository;

  GetFavoritePropertiesUseCase(this.repository);

  Future<Either<Failure, List<Property>>> call(UserIdParams params) async {
    return await repository.getFavoriteProperties(params.userId);
  }
}

/// Parameters for user ID
class UserIdParams extends Equatable {
  final String userId;

  const UserIdParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
