import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Use case for getting a property by ID
class GetPropertyByIdUseCase {
  final PropertyRepository repository;

  GetPropertyByIdUseCase(this.repository);

  Future<Either<Failure, Property>> call(PropertyIdParams params) async {
    return await repository.getPropertyById(params.propertyId);
  }
}

/// Parameters for getting property by ID
class PropertyIdParams extends Equatable {
  final String propertyId;

  const PropertyIdParams({required this.propertyId});

  @override
  List<Object> get props => [propertyId];
}
