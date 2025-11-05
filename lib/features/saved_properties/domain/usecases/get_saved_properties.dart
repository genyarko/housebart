import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../property/domain/entities/property.dart';
import '../repositories/saved_property_repository.dart';

class GetSavedProperties implements UseCase<List<Property>, GetSavedPropertiesParams> {
  final SavedPropertyRepository repository;

  GetSavedProperties(this.repository);

  @override
  Future<Either<Failure, List<Property>>> call(GetSavedPropertiesParams params) async {
    return await repository.getSavedProperties(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetSavedPropertiesParams {
  final int limit;
  final int offset;

  GetSavedPropertiesParams({
    this.limit = 50,
    this.offset = 0,
  });
}
