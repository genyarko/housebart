import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

/// Use case for creating a new verification request
class CreateVerificationRequestUseCase {
  final VerificationRepository repository;

  CreateVerificationRequestUseCase(this.repository);

  Future<Either<Failure, VerificationRequest>> call(
    CreateVerificationRequestParams params,
  ) async {
    return await repository.createRequest(
      propertyId: params.propertyId,
    );
  }
}

/// Parameters for creating a verification request
class CreateVerificationRequestParams extends Equatable {
  final String propertyId;

  const CreateVerificationRequestParams({
    required this.propertyId,
  });

  @override
  List<Object?> get props => [propertyId];
}
