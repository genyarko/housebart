import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/saved_property_repository.dart';

class GetSavedPropertiesCount implements UseCase<int, NoParams> {
  final SavedPropertyRepository repository;

  GetSavedPropertiesCount(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getSavedPropertiesCount();
  }
}
