import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class GetProfileStatisticsUseCase {
  final ProfileRepository repository;

  GetProfileStatisticsUseCase({required this.repository});

  Future<Either<Failure, Map<String, int>>> call(
    GetProfileStatisticsParams params,
  ) async {
    return await repository.getProfileStatistics(userId: params.userId);
  }
}

class GetProfileStatisticsParams {
  final String userId;

  GetProfileStatisticsParams({required this.userId});
}
