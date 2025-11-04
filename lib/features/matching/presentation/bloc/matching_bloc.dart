import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/accept_barter_usecase.dart';
import '../../domain/usecases/cancel_barter_usecase.dart';
import '../../domain/usecases/create_barter_request_usecase.dart';
import '../../domain/usecases/get_my_requests_usecase.dart';
import '../../domain/usecases/get_received_requests_usecase.dart';
import '../../domain/usecases/reject_barter_usecase.dart';
import '../../domain/repositories/matching_repository.dart';
import 'matching_event.dart';
import 'matching_state.dart';

/// BLoC for managing matching/barter state
class MatchingBloc extends Bloc<MatchingEvent, MatchingState> {
  final CreateBarterRequestUseCase createBarterRequestUseCase;
  final AcceptBarterUseCase acceptBarterUseCase;
  final RejectBarterUseCase rejectBarterUseCase;
  final CancelBarterUseCase cancelBarterUseCase;
  final GetMyRequestsUseCase getMyRequestsUseCase;
  final GetReceivedRequestsUseCase getReceivedRequestsUseCase;
  final MatchingRepository matchingRepository;

  MatchingBloc({
    required this.createBarterRequestUseCase,
    required this.acceptBarterUseCase,
    required this.rejectBarterUseCase,
    required this.cancelBarterUseCase,
    required this.getMyRequestsUseCase,
    required this.getReceivedRequestsUseCase,
    required this.matchingRepository,
  }) : super(const MatchingInitial()) {
    on<MatchingCreateRequestEvent>(_onCreateRequest);
    on<MatchingAcceptRequestEvent>(_onAcceptRequest);
    on<MatchingRejectRequestEvent>(_onRejectRequest);
    on<MatchingCancelRequestEvent>(_onCancelRequest);
    on<MatchingLoadMyRequestsEvent>(_onLoadMyRequests);
    on<MatchingLoadReceivedRequestsEvent>(_onLoadReceivedRequests);
    on<MatchingLoadRequestByIdEvent>(_onLoadRequestById);
    on<MatchingResetStateEvent>(_onResetState);
  }

  /// Handle creating a barter request
  Future<void> _onCreateRequest(
    MatchingCreateRequestEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await createBarterRequestUseCase(
      CreateBarterRequestParams(
        requesterPropertyId: event.requesterPropertyId,
        ownerPropertyId: event.ownerPropertyId,
        requestedStartDate: event.requestedStartDate,
        requestedEndDate: event.requestedEndDate,
        offeredStartDate: event.offeredStartDate,
        offeredEndDate: event.offeredEndDate,
        requesterGuests: event.requesterGuests,
        ownerGuests: event.ownerGuests,
        message: event.message,
      ),
    );

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (request) => emit(MatchingRequestCreated(request)),
    );
  }

  /// Handle accepting a barter request
  Future<void> _onAcceptRequest(
    MatchingAcceptRequestEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await acceptBarterUseCase(event.requestId);

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (request) => emit(MatchingRequestAccepted(request)),
    );
  }

  /// Handle rejecting a barter request
  Future<void> _onRejectRequest(
    MatchingRejectRequestEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await rejectBarterUseCase(
      RejectBarterParams(
        requestId: event.requestId,
        reason: event.reason,
      ),
    );

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (request) => emit(MatchingRequestRejected(request)),
    );
  }

  /// Handle cancelling a barter request
  Future<void> _onCancelRequest(
    MatchingCancelRequestEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await cancelBarterUseCase(event.requestId);

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (_) => emit(MatchingRequestCancelled(event.requestId)),
    );
  }

  /// Handle loading user's sent requests
  Future<void> _onLoadMyRequests(
    MatchingLoadMyRequestsEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await getMyRequestsUseCase(
      GetMyRequestsParams(
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (requests) {
        if (requests.isEmpty) {
          emit(const MatchingEmpty('No barter requests found'));
        } else {
          emit(MatchingRequestsLoaded(
            requests: requests,
            hasMore: requests.length >= event.limit,
          ));
        }
      },
    );
  }

  /// Handle loading received requests
  Future<void> _onLoadReceivedRequests(
    MatchingLoadReceivedRequestsEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await getReceivedRequestsUseCase(
      GetReceivedRequestsParams(
        status: event.status,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (requests) {
        if (requests.isEmpty) {
          emit(const MatchingEmpty('No requests received yet'));
        } else {
          emit(MatchingRequestsLoaded(
            requests: requests,
            hasMore: requests.length >= event.limit,
          ));
        }
      },
    );
  }

  /// Handle loading a single request by ID
  Future<void> _onLoadRequestById(
    MatchingLoadRequestByIdEvent event,
    Emitter<MatchingState> emit,
  ) async {
    emit(const MatchingLoading());

    final result = await matchingRepository.getBarterRequestById(event.requestId);

    result.fold(
      (failure) => emit(MatchingError(failure.message)),
      (request) => emit(MatchingRequestLoaded(request)),
    );
  }

  /// Handle resetting state
  void _onResetState(
    MatchingResetStateEvent event,
    Emitter<MatchingState> emit,
  ) {
    emit(const MatchingInitial());
  }
}
