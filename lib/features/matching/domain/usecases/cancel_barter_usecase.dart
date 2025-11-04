import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/matching_repository.dart';

/// Use case for cancelling a barter request
class CancelBarterUseCase {
  final MatchingRepository repository;

  CancelBarterUseCase(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.cancelBarterRequest(requestId);
  }
}
