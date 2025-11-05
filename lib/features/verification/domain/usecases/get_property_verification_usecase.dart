import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

/// Use case for getting verification request for a specific property
class GetPropertyVerificationUseCase {
  final VerificationRepository repository;

  GetPropertyVerificationUseCase(this.repository);

  Future<Either<Failure, VerificationRequest?>> call(
    GetPropertyVerificationParams params,
  ) async {
    return await repository.getPropertyVerification(
      propertyId: params.propertyId,
    );
  }
}

/// Parameters for getting property verification
class GetPropertyVerificationParams extends Equatable {
  final String propertyId;

  const GetPropertyVerificationParams({
    required this.propertyId,
  });

  @override
  List<Object?> get props => [propertyId];
}
