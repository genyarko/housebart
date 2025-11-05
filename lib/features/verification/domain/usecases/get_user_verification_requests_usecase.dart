import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

/// Use case for getting all verification requests for the current user
class GetUserVerificationRequestsUseCase {
  final VerificationRepository repository;

  GetUserVerificationRequestsUseCase(this.repository);

  Future<Either<Failure, List<VerificationRequest>>> call() async {
    return await repository.getUserRequests();
  }
}
