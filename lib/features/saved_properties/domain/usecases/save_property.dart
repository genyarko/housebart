import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/saved_property_repository.dart';

class SaveProperty implements UseCase<void, SavePropertyParams> {
  final SavedPropertyRepository repository;

  SaveProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(SavePropertyParams params) async {
    return await repository.saveProperty(propertyId: params.propertyId);
  }
}

class SavePropertyParams {
  final String propertyId;

  SavePropertyParams({required this.propertyId});
}
