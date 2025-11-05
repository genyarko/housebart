import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/verification_repository.dart';

/// Use case for creating a payment intent for verification
class CreatePaymentIntentUseCase {
  final VerificationRepository repository;

  CreatePaymentIntentUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    CreatePaymentIntentParams params,
  ) async {
    return await repository.createPaymentIntent(
      requestId: params.requestId,
    );
  }
}

/// Parameters for creating a payment intent
class CreatePaymentIntentParams extends Equatable {
  final String requestId;

  const CreatePaymentIntentParams({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}
