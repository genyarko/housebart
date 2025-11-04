import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/barter_request.dart';
import '../repositories/matching_repository.dart';

/// Use case for getting user's barter requests (sent by user)
class GetMyRequestsUseCase {
  final MatchingRepository repository;

  GetMyRequestsUseCase(this.repository);

  Future<Either<Failure, List<BarterRequest>>> call(GetMyRequestsParams params) async {
    return await repository.getMyBarterRequests(
      status: params.status,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetMyRequestsParams extends Equatable {
  final String? status;
  final int limit;
  final int offset;

  const GetMyRequestsParams({
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [status, limit, offset];
}
