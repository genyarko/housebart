import 'package:equatable/equatable.dart';

/// Base class for verification events
abstract class VerificationEvent extends Equatable {
  const VerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a new verification request
class VerificationCreateRequestEvent extends VerificationEvent {
  final String propertyId;

  const VerificationCreateRequestEvent({
    required this.propertyId,
  });

  @override
  List<Object?> get props => [propertyId];
}

/// Event to load a verification request by ID
class VerificationLoadRequestByIdEvent extends VerificationEvent {
  final String requestId;

  const VerificationLoadRequestByIdEvent({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}

/// Event to load all user verification requests
class VerificationLoadUserRequestsEvent extends VerificationEvent {
  const VerificationLoadUserRequestsEvent();
}

/// Event to load property verification
class VerificationLoadPropertyVerificationEvent extends VerificationEvent {
  final String propertyId;

  const VerificationLoadPropertyVerificationEvent({
    required this.propertyId,
  });

  @override
  List<Object?> get props => [propertyId];
}

/// Event to create payment intent
class VerificationCreatePaymentIntentEvent extends VerificationEvent {
  final String requestId;

  const VerificationCreatePaymentIntentEvent({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}

/// Event to confirm payment
class VerificationConfirmPaymentEvent extends VerificationEvent {
  final String requestId;
  final String paymentIntentId;

  const VerificationConfirmPaymentEvent({
    required this.requestId,
    required this.paymentIntentId,
  });

  @override
  List<Object?> get props => [requestId, paymentIntentId];
}

/// Event to cancel verification request
class VerificationCancelRequestEvent extends VerificationEvent {
  final String requestId;

  const VerificationCancelRequestEvent({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}
