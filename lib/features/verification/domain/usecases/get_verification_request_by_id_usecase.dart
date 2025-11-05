import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

/// Use case for getting a verification request by ID
class GetVerificationRequestByIdUseCase {
  final VerificationRepository repository;

  GetVerificationRequestByIdUseCase(this.repository);

  Future<Either<Failure, VerificationRequest>> call(
    GetVerificationRequestByIdParams params,
  ) async {
    return await repository.getRequestById(
      requestId: params.requestId,
    );
  }
}

/// Parameters for getting a verification request by ID
class GetVerificationRequestByIdParams extends Equatable {
  final String requestId;

  const GetVerificationRequestByIdParams({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}
