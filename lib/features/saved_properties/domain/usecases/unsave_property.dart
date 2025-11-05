import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/saved_property_repository.dart';

class UnsaveProperty implements UseCase<void, UnsavePropertyParams> {
  final SavedPropertyRepository repository;

  UnsaveProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(UnsavePropertyParams params) async {
    return await repository.unsaveProperty(propertyId: params.propertyId);
  }
}

class UnsavePropertyParams {
  final String propertyId;

  UnsavePropertyParams({required this.propertyId});
}
