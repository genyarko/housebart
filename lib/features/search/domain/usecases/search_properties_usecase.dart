import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../property/domain/entities/property.dart';
import '../entities/search_filters.dart';
import '../repositories/search_repository.dart';

/// Use case for searching properties with filters
class SearchPropertiesUseCase {
  final SearchRepository repository;

  SearchPropertiesUseCase(this.repository);

  Future<Either<Failure, List<Property>>> call(
    SearchPropertiesParams params,
  ) async {
    return await repository.searchProperties(
      filters: params.filters,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parameters for searching properties
class SearchPropertiesParams extends Equatable {
  final SearchFilters filters;
  final int limit;
  final int offset;

  const SearchPropertiesParams({
    required this.filters,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [filters, limit, offset];
}
