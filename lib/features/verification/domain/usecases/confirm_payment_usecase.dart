import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_request.dart';
import '../repositories/verification_repository.dart';

/// Use case for confirming payment for verification
class ConfirmPaymentUseCase {
  final VerificationRepository repository;

  ConfirmPaymentUseCase(this.repository);

  Future<Either<Failure, VerificationRequest>> call(
    ConfirmPaymentParams params,
  ) async {
    return await repository.confirmPayment(
      requestId: params.requestId,
      paymentIntentId: params.paymentIntentId,
    );
  }
}

/// Parameters for confirming payment
class ConfirmPaymentParams extends Equatable {
  final String requestId;
  final String paymentIntentId;

  const ConfirmPaymentParams({
    required this.requestId,
    required this.paymentIntentId,
  });

  @override
  List<Object?> get props => [requestId, paymentIntentId];
}
