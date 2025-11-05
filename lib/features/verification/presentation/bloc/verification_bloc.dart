import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_verification_request_usecase.dart';
import '../../domain/usecases/get_verification_request_by_id_usecase.dart';
import '../../domain/usecases/get_user_verification_requests_usecase.dart';
import '../../domain/usecases/get_property_verification_usecase.dart';
import '../../domain/usecases/create_payment_intent_usecase.dart';
import '../../domain/usecases/confirm_payment_usecase.dart';
import 'verification_event.dart';
import 'verification_state.dart';

/// BLoC for handling verification business logic
class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final CreateVerificationRequestUseCase createVerificationRequestUseCase;
  final GetVerificationRequestByIdUseCase getVerificationRequestByIdUseCase;
  final GetUserVerificationRequestsUseCase getUserVerificationRequestsUseCase;
  final GetPropertyVerificationUseCase getPropertyVerificationUseCase;
  final CreatePaymentIntentUseCase createPaymentIntentUseCase;
  final ConfirmPaymentUseCase confirmPaymentUseCase;

  VerificationBloc({
    required this.createVerificationRequestUseCase,
    required this.getVerificationRequestByIdUseCase,
    required this.getUserVerificationRequestsUseCase,
    required this.getPropertyVerificationUseCase,
    required this.createPaymentIntentUseCase,
    required this.confirmPaymentUseCase,
  }) : super(const VerificationInitial()) {
    on<VerificationCreateRequestEvent>(_onCreateRequest);
    on<VerificationLoadRequestByIdEvent>(_onLoadRequestById);
    on<VerificationLoadUserRequestsEvent>(_onLoadUserRequests);
    on<VerificationLoadPropertyVerificationEvent>(_onLoadPropertyVerification);
    on<VerificationCreatePaymentIntentEvent>(_onCreatePaymentIntent);
    on<VerificationConfirmPaymentEvent>(_onConfirmPayment);
  }

  Future<void> _onCreateRequest(
    VerificationCreateRequestEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    final result = await createVerificationRequestUseCase(
      CreateVerificationRequestParams(
        propertyId: event.propertyId,
      ),
    );

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (request) => emit(VerificationRequestCreated(request)),
    );
  }

  Future<void> _onLoadRequestById(
    VerificationLoadRequestByIdEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    final result = await getVerificationRequestByIdUseCase(
      GetVerificationRequestByIdParams(
        requestId: event.requestId,
      ),
    );

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (request) => emit(VerificationRequestLoaded(request)),
    );
  }

  Future<void> _onLoadUserRequests(
    VerificationLoadUserRequestsEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    final result = await getUserVerificationRequestsUseCase();

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (requests) {
        if (requests.isEmpty) {
          emit(const VerificationEmpty('No verification requests found'));
        } else {
          emit(VerificationUserRequestsLoaded(requests));
        }
      },
    );
  }

  Future<void> _onLoadPropertyVerification(
    VerificationLoadPropertyVerificationEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    final result = await getPropertyVerificationUseCase(
      GetPropertyVerificationParams(
        propertyId: event.propertyId,
      ),
    );

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (request) => emit(VerificationPropertyVerificationLoaded(request)),
    );
  }

  Future<void> _onCreatePaymentIntent(
    VerificationCreatePaymentIntentEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    final result = await createPaymentIntentUseCase(
      CreatePaymentIntentParams(
        requestId: event.requestId,
      ),
    );

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (paymentData) => emit(VerificationPaymentIntentCreated(paymentData)),
    );
  }

  Future<void> _onConfirmPayment(
    VerificationConfirmPaymentEvent event,
    Emitter<VerificationState> emit,
  ) async {
    emit(const VerificationLoading());

    final result = await confirmPaymentUseCase(
      ConfirmPaymentParams(
        requestId: event.requestId,
        paymentIntentId: event.paymentIntentId,
      ),
    );

    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (request) => emit(VerificationPaymentConfirmed(request)),
    );
  }
}
