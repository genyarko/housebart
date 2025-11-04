import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Use case for getting user's properties
class GetUserPropertiesUseCase {
  final PropertyRepository repository;

  GetUserPropertiesUseCase(this.repository);

  Future<Either<Failure, List<Property>>> call(UserIdParams params) async {
    return await repository.getUserProperties(params.userId);
  }
}

/// Parameters for getting user properties
class UserIdParams extends Equatable {
  final String userId;

  const UserIdParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
