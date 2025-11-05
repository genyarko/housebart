import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/search_repository.dart';

/// Use case for getting search suggestions
class GetSearchSuggestionsUseCase {
  final SearchRepository repository;

  GetSearchSuggestionsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call(
    GetSearchSuggestionsParams params,
  ) async {
    return await repository.getSearchSuggestions(
      query: params.query,
      limit: params.limit,
    );
  }
}

/// Parameters for getting search suggestions
class GetSearchSuggestionsParams extends Equatable {
  final String query;
  final int limit;

  const GetSearchSuggestionsParams({
    required this.query,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [query, limit];
}
