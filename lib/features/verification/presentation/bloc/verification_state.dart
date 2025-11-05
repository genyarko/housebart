import 'package:equatable/equatable.dart';
import '../../domain/entities/verification_request.dart';

/// Base class for verification states
abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VerificationInitial extends VerificationState {
  const VerificationInitial();
}

/// Loading state
class VerificationLoading extends VerificationState {
  const VerificationLoading();
}

/// State when a single request is loaded
class VerificationRequestLoaded extends VerificationState {
  final VerificationRequest request;

  const VerificationRequestLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when user requests are loaded
class VerificationUserRequestsLoaded extends VerificationState {
  final List<VerificationRequest> requests;

  const VerificationUserRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// State when property verification is loaded
class VerificationPropertyVerificationLoaded extends VerificationState {
  final VerificationRequest? request;

  const VerificationPropertyVerificationLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when request is created successfully
class VerificationRequestCreated extends VerificationState {
  final VerificationRequest request;

  const VerificationRequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when payment intent is created
class VerificationPaymentIntentCreated extends VerificationState {
  final Map<String, dynamic> paymentData;

  const VerificationPaymentIntentCreated(this.paymentData);

  @override
  List<Object?> get props => [paymentData];
}

/// State when payment is confirmed
class VerificationPaymentConfirmed extends VerificationState {
  final VerificationRequest request;

  const VerificationPaymentConfirmed(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when request is cancelled
class VerificationRequestCancelled extends VerificationState {
  const VerificationRequestCancelled();
}

/// Empty state (no requests found)
class VerificationEmpty extends VerificationState {
  final String message;

  const VerificationEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class VerificationError extends VerificationState {
  final String message;

  const VerificationError(this.message);

  @override
  List<Object?> get props => [message];
}
