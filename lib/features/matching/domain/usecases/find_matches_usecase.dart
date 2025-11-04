import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/matching_repository.dart';

/// Use case for finding matching properties for barter
class FindMatchesUseCase {
  final MatchingRepository repository;

  FindMatchesUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(FindMatchesParams params) async {
    return await repository.findMatches(
      userPropertyId: params.userPropertyId,
      city: params.city,
      country: params.country,
      startDate: params.startDate,
      endDate: params.endDate,
      minGuests: params.minGuests,
    );
  }
}

class FindMatchesParams extends Equatable {
  final String userPropertyId;
  final String? city;
  final String? country;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minGuests;

  const FindMatchesParams({
    required this.userPropertyId,
    this.city,
    this.country,
    this.startDate,
    this.endDate,
    this.minGuests,
  });

  @override
  List<Object?> get props => [
        userPropertyId,
        city,
        country,
        startDate,
        endDate,
        minGuests,
      ];
}
