import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/property_repository.dart';
import 'get_property_by_id_usecase.dart';

/// Use case for deleting a property
class DeletePropertyUseCase {
  final PropertyRepository repository;

  DeletePropertyUseCase(this.repository);

  Future<Either<Failure, void>> call(PropertyIdParams params) async {
    return await repository.deleteProperty(params.propertyId);
  }
}
