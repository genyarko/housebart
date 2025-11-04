import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/barter_request.dart';
import '../repositories/matching_repository.dart';

/// Use case for rejecting a barter request
class RejectBarterUseCase {
  final MatchingRepository repository;

  RejectBarterUseCase(this.repository);

  Future<Either<Failure, BarterRequest>> call(RejectBarterParams params) async {
    return await repository.rejectBarterRequest(
      requestId: params.requestId,
      reason: params.reason,
    );
  }
}

class RejectBarterParams extends Equatable {
  final String requestId;
  final String? reason;

  const RejectBarterParams({
    required this.requestId,
    this.reason,
  });

  @override
  List<Object?> get props => [requestId, reason];
}
