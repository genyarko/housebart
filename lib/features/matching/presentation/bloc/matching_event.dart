import 'package:equatable/equatable.dart';

/// Base class for all matching events
abstract class MatchingEvent extends Equatable {
  const MatchingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to create a barter request
class MatchingCreateRequestEvent extends MatchingEvent {
  final String requesterPropertyId;
  final String ownerPropertyId;
  final DateTime requestedStartDate;
  final DateTime requestedEndDate;
  final DateTime offeredStartDate;
  final DateTime offeredEndDate;
  final int requesterGuests;
  final int ownerGuests;
  final String? message;

  const MatchingCreateRequestEvent({
    required this.requesterPropertyId,
    required this.ownerPropertyId,
    required this.requestedStartDate,
    required this.requestedEndDate,
    required this.offeredStartDate,
    required this.offeredEndDate,
    required this.requesterGuests,
    required this.ownerGuests,
    this.message,
  });

  @override
  List<Object?> get props => [
        requesterPropertyId,
        ownerPropertyId,
        requestedStartDate,
        requestedEndDate,
        offeredStartDate,
        offeredEndDate,
        requesterGuests,
        ownerGuests,
        message,
      ];
}

/// Event to accept a barter request
class MatchingAcceptRequestEvent extends MatchingEvent {
  final String requestId;

  const MatchingAcceptRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Event to reject a barter request
class MatchingRejectRequestEvent extends MatchingEvent {
  final String requestId;
  final String? reason;

  const MatchingRejectRequestEvent(this.requestId, {this.reason});

  @override
  List<Object?> get props => [requestId, reason];
}

/// Event to cancel a barter request
class MatchingCancelRequestEvent extends MatchingEvent {
  final String requestId;

  const MatchingCancelRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Event to load user's sent requests
class MatchingLoadMyRequestsEvent extends MatchingEvent {
  final String? status;
  final int limit;
  final int offset;

  const MatchingLoadMyRequestsEvent({
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [status, limit, offset];
}

/// Event to load received requests
class MatchingLoadReceivedRequestsEvent extends MatchingEvent {
  final String? status;
  final int limit;
  final int offset;

  const MatchingLoadReceivedRequestsEvent({
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [status, limit, offset];
}

/// Event to load a single barter request
class MatchingLoadRequestByIdEvent extends MatchingEvent {
  final String requestId;

  const MatchingLoadRequestByIdEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

/// Event to reset state
class MatchingResetStateEvent extends MatchingEvent {
  const MatchingResetStateEvent();
}
