import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../property/domain/entities/property.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/usecases/search_properties_usecase.dart';
import '../../domain/usecases/get_search_suggestions_usecase.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchPropertiesEvent extends SearchEvent {
  final SearchFilters filters;

  const SearchPropertiesEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class SearchLoadMoreEvent extends SearchEvent {
  final SearchFilters filters;
  final int offset;

  const SearchLoadMoreEvent({
    required this.filters,
    required this.offset,
  });

  @override
  List<Object?> get props => [filters, offset];
}

class SearchGetSuggestionsEvent extends SearchEvent {
  final String query;

  const SearchGetSuggestionsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchClearEvent extends SearchEvent {}

// States
abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Property> properties;
  final SearchFilters appliedFilters;
  final bool hasMore;

  const SearchLoaded({
    required this.properties,
    required this.appliedFilters,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [properties, appliedFilters, hasMore];
}

class SearchLoadingMore extends SearchState {
  final List<Property> currentProperties;

  const SearchLoadingMore({required this.currentProperties});

  @override
  List<Object?> get props => [currentProperties];
}

class SearchSuggestionsLoaded extends SearchState {
  final List<String> suggestions;

  const SearchSuggestionsLoaded({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

class SearchEmpty extends SearchState {
  final String message;

  const SearchEmpty({this.message = 'No properties found'});

  @override
  List<Object?> get props => [message];
}

class SearchError extends SearchState {
  final String message;

  const SearchError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchPropertiesUseCase searchPropertiesUseCase;
  final GetSearchSuggestionsUseCase getSearchSuggestionsUseCase;

  SearchBloc({
    required this.searchPropertiesUseCase,
    required this.getSearchSuggestionsUseCase,
  }) : super(SearchInitial()) {
    on<SearchPropertiesEvent>(_onSearchProperties);
    on<SearchLoadMoreEvent>(_onLoadMore);
    on<SearchGetSuggestionsEvent>(_onGetSuggestions);
    on<SearchClearEvent>(_onClear);
  }

  Future<void> _onSearchProperties(
    SearchPropertiesEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    final result = await searchPropertiesUseCase(
      SearchPropertiesParams(filters: event.filters),
    );

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(const SearchEmpty());
        } else {
          emit(SearchLoaded(
            properties: properties,
            appliedFilters: event.filters,
            hasMore: properties.length >= 20,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMore(
    SearchLoadMoreEvent event,
    Emitter<SearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SearchLoaded) return;

    emit(SearchLoadingMore(currentProperties: currentState.properties));

    final result = await searchPropertiesUseCase(
      SearchPropertiesParams(
        filters: event.filters,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (newProperties) {
        final allProperties = [...currentState.properties, ...newProperties];
        emit(SearchLoaded(
          properties: allProperties,
          appliedFilters: event.filters,
          hasMore: newProperties.length >= 20,
        ));
      },
    );
  }

  Future<void> _onGetSuggestions(
    SearchGetSuggestionsEvent event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(const SearchSuggestionsLoaded(suggestions: []));
      return;
    }

    final result = await getSearchSuggestionsUseCase(
      GetSearchSuggestionsParams(query: event.query),
    );

    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (suggestions) => emit(SearchSuggestionsLoaded(suggestions: suggestions)),
    );
  }

  void _onClear(SearchClearEvent event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
