import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_saved_properties.dart';
import '../../domain/usecases/get_saved_properties_count.dart';
import '../../domain/usecases/is_property_saved.dart';
import '../../domain/usecases/save_property.dart';
import '../../domain/usecases/unsave_property.dart';
import 'saved_property_event.dart';
import 'saved_property_state.dart';

class SavedPropertyBloc extends Bloc<SavedPropertyEvent, SavedPropertyState> {
  final GetSavedProperties getSavedProperties;
  final GetSavedPropertiesCount getSavedPropertiesCount;
  final SaveProperty saveProperty;
  final UnsaveProperty unsaveProperty;
  final IsPropertySaved isPropertySaved;

  static const int _pageSize = 50;
  int _currentOffset = 0;

  SavedPropertyBloc({
    required this.getSavedProperties,
    required this.getSavedPropertiesCount,
    required this.saveProperty,
    required this.unsaveProperty,
    required this.isPropertySaved,
  }) : super(SavedPropertyInitial()) {
    on<LoadSavedProperties>(_onLoadSavedProperties);
    on<LoadMoreSavedProperties>(_onLoadMoreSavedProperties);
    on<ToggleSaveProperty>(_onToggleSaveProperty);
    on<CheckPropertySaved>(_onCheckPropertySaved);
  }

  Future<void> _onLoadSavedProperties(
    LoadSavedProperties event,
    Emitter<SavedPropertyState> emit,
  ) async {
    if (event.refresh) {
      _currentOffset = 0;
    }

    emit(SavedPropertyLoading());

    final propertiesResult = await getSavedProperties(
      GetSavedPropertiesParams(limit: _pageSize, offset: 0),
    );

    final countResult = await getSavedPropertiesCount(NoParams());

    await propertiesResult.fold(
      (failure) async {
        emit(SavedPropertyError(message: failure.message));
      },
      (properties) async {
        final count = countResult.fold(
          (failure) => 0,
          (c) => c,
        );

        _currentOffset = properties.length;

        // Build saved status cache
        final cache = <String, bool>{};
        for (var property in properties) {
          cache[property.id] = true;
        }

        emit(SavedPropertyLoaded(
          savedProperties: properties,
          totalCount: count,
          hasMore: properties.length >= _pageSize,
          savedStatusCache: cache,
        ));
      },
    );
  }

  Future<void> _onLoadMoreSavedProperties(
    LoadMoreSavedProperties event,
    Emitter<SavedPropertyState> emit,
  ) async {
    if (state is SavedPropertyLoaded) {
      final currentState = state as SavedPropertyLoaded;

      if (!currentState.hasMore || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      final result = await getSavedProperties(
        GetSavedPropertiesParams(limit: _pageSize, offset: _currentOffset),
      );

      await result.fold(
        (failure) async {
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (newProperties) async {
          _currentOffset += newProperties.length;

          final updatedProperties = [
            ...currentState.savedProperties,
            ...newProperties,
          ];

          // Update cache
          final updatedCache = Map<String, bool>.from(currentState.savedStatusCache);
          for (var property in newProperties) {
            updatedCache[property.id] = true;
          }

          emit(SavedPropertyLoaded(
            savedProperties: updatedProperties,
            totalCount: currentState.totalCount,
            hasMore: newProperties.length >= _pageSize,
            isLoadingMore: false,
            savedStatusCache: updatedCache,
          ));
        },
      );
    }
  }

  Future<void> _onToggleSaveProperty(
    ToggleSaveProperty event,
    Emitter<SavedPropertyState> emit,
  ) async {
    SavedPropertyState previousState = state;

    // Check current saved status
    final isSavedResult = await isPropertySaved(
      IsPropertySavedParams(propertyId: event.propertyId),
    );

    await isSavedResult.fold(
      (failure) async {
        emit(SavedPropertyError(message: failure.message));
        emit(previousState);
      },
      (isSaved) async {
        if (isSaved) {
          // Unsave the property
          final result = await unsaveProperty(
            UnsavePropertyParams(propertyId: event.propertyId),
          );

          await result.fold(
            (failure) async {
              emit(SavedPropertyError(message: failure.message));
              emit(previousState);
            },
            (_) async {
              // Update state if we're on the saved properties list
              if (state is SavedPropertyLoaded) {
                final currentState = state as SavedPropertyLoaded;
                final updatedProperties = currentState.savedProperties
                    .where((p) => p.id != event.propertyId)
                    .toList();

                final updatedCache = Map<String, bool>.from(currentState.savedStatusCache);
                updatedCache[event.propertyId] = false;

                emit(currentState.copyWith(
                  savedProperties: updatedProperties,
                  totalCount: currentState.totalCount - 1,
                  savedStatusCache: updatedCache,
                ));
              }

              emit(const SavedPropertyActionSuccess(message: 'Property removed from saved'));
              emit(state is SavedPropertyLoaded ? state : previousState);
            },
          );
        } else {
          // Save the property
          final result = await saveProperty(
            SavePropertyParams(propertyId: event.propertyId),
          );

          await result.fold(
            (failure) async {
              emit(SavedPropertyError(message: failure.message));
              emit(previousState);
            },
            (_) async {
              // Update cache
              if (state is SavedPropertyLoaded) {
                final currentState = state as SavedPropertyLoaded;
                final updatedCache = Map<String, bool>.from(currentState.savedStatusCache);
                updatedCache[event.propertyId] = true;

                emit(currentState.copyWith(
                  totalCount: currentState.totalCount + 1,
                  savedStatusCache: updatedCache,
                ));
              }

              emit(const SavedPropertyActionSuccess(message: 'Property saved successfully'));
              emit(state is SavedPropertyLoaded ? state : previousState);
            },
          );
        }
      },
    );
  }

  Future<void> _onCheckPropertySaved(
    CheckPropertySaved event,
    Emitter<SavedPropertyState> emit,
  ) async {
    // Check if property is saved and update cache
    if (state is SavedPropertyLoaded) {
      final currentState = state as SavedPropertyLoaded;

      final result = await isPropertySaved(
        IsPropertySavedParams(propertyId: event.propertyId),
      );

      await result.fold(
        (failure) async {
          // Silently fail
        },
        (isSaved) async {
          final updatedCache = Map<String, bool>.from(currentState.savedStatusCache);
          updatedCache[event.propertyId] = isSaved;

          emit(currentState.copyWith(savedStatusCache: updatedCache));
        },
      );
    }
  }
}
