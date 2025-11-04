import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Use case for getting all properties with pagination
class GetPropertiesUseCase {
  final PropertyRepository repository;

  GetPropertiesUseCase(this.repository);

  Future<Either<Failure, List<Property>>> call(
    GetPropertiesParams params,
  ) async {
    return await repository.getProperties(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parameters for getting properties
class GetPropertiesParams extends Equatable {
  final int limit;
  final int offset;

  const GetPropertiesParams({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object> get props => [limit, offset];
}
