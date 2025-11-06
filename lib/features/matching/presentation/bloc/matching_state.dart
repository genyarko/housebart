import 'package:equatable/equatable.dart';
import '../../domain/entities/barter_request.dart';

/// Base class for all matching states
abstract class MatchingState extends Equatable {
  const MatchingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MatchingInitial extends MatchingState {
  const MatchingInitial();
}

/// Loading state
class MatchingLoading extends MatchingState {
  const MatchingLoading();
}

/// State when a single request is loaded
class MatchingRequestLoaded extends MatchingState {
  final BarterRequest request;

  const MatchingRequestLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when multiple requests are loaded
class MatchingRequestsLoaded extends MatchingState {
  final List<BarterRequest> requests;
  final bool hasMore;
  final String? requestType; // 'sent' or 'received'

  const MatchingRequestsLoaded({
    required this.requests,
    this.hasMore = true,
    this.requestType,
  });

  @override
  List<Object?> get props => [requests, hasMore, requestType];
}

/// State when a request is created successfully
class MatchingRequestCreated extends MatchingState {
  final BarterRequest request;

  const MatchingRequestCreated(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when a request is accepted
class MatchingRequestAccepted extends MatchingState {
  final BarterRequest request;

  const MatchingRequestAccepted(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when a request is rejected
class MatchingRequestRejected extends MatchingState {
  final BarterRequest request;

  const MatchingRequestRejected(this.request);

  @override
  List<Object?> get props => [request];
}

/// State when a request is cancelled
class MatchingRequestCancelled extends MatchingState {
  final String requestId;

  const MatchingRequestCancelled(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Error state
class MatchingError extends MatchingState {
  final String message;

  const MatchingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state
class MatchingEmpty extends MatchingState {
  final String? message;

  const MatchingEmpty([this.message]);

  @override
  List<Object?> get props => [message];
}
