import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/barter_request.dart';
import '../repositories/matching_repository.dart';

/// Use case for creating a barter request
class CreateBarterRequestUseCase {
  final MatchingRepository repository;

  CreateBarterRequestUseCase(this.repository);

  Future<Either<Failure, BarterRequest>> call(CreateBarterRequestParams params) async {
    return await repository.createBarterRequest(
      requesterPropertyId: params.requesterPropertyId,
      ownerPropertyId: params.ownerPropertyId,
      requestedStartDate: params.requestedStartDate,
      requestedEndDate: params.requestedEndDate,
      offeredStartDate: params.offeredStartDate,
      offeredEndDate: params.offeredEndDate,
      requesterGuests: params.requesterGuests,
      ownerGuests: params.ownerGuests,
      message: params.message,
    );
  }
}

class CreateBarterRequestParams extends Equatable {
  final String requesterPropertyId;
  final String ownerPropertyId;
  final DateTime requestedStartDate;
  final DateTime requestedEndDate;
  final DateTime offeredStartDate;
  final DateTime offeredEndDate;
  final int requesterGuests;
  final int ownerGuests;
  final String? message;

  const CreateBarterRequestParams({
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
