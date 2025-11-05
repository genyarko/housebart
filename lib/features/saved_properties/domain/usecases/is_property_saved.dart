import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/saved_property_repository.dart';

class IsPropertySaved implements UseCase<bool, IsPropertySavedParams> {
  final SavedPropertyRepository repository;

  IsPropertySaved(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsPropertySavedParams params) async {
    return await repository.isPropertySaved(propertyId: params.propertyId);
  }
}

class IsPropertySavedParams {
  final String propertyId;

  IsPropertySavedParams({required this.propertyId});
}
