import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/barter_request.dart';
import '../repositories/matching_repository.dart';

/// Use case for accepting a barter request
class AcceptBarterUseCase {
  final MatchingRepository repository;

  AcceptBarterUseCase(this.repository);

  Future<Either<Failure, BarterRequest>> call(String requestId) async {
    return await repository.acceptBarterRequest(requestId);
  }
}
