import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/barter_request.dart';
import '../repositories/matching_repository.dart';

/// Use case for getting barter requests received by user (as property owner)
class GetReceivedRequestsUseCase {
  final MatchingRepository repository;

  GetReceivedRequestsUseCase(this.repository);

  Future<Either<Failure, List<BarterRequest>>> call(GetReceivedRequestsParams params) async {
    return await repository.getReceivedBarterRequests(
      status: params.status,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetReceivedRequestsParams extends Equatable {
  final String? status;
  final int limit;
  final int offset;

  const GetReceivedRequestsParams({
    this.status,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [status, limit, offset];
}
