import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_property_usecase.dart';
import '../../domain/usecases/delete_property_usecase.dart';
import '../../domain/usecases/get_properties_usecase.dart';
import '../../domain/usecases/get_property_by_id_usecase.dart';
import '../../domain/usecases/get_user_properties_usecase.dart';
import '../../domain/usecases/upload_property_images_usecase.dart';
import '../../domain/repositories/property_repository.dart';
import 'property_event.dart';
import 'property_state.dart';

/// BLoC for managing property state
class PropertyBloc extends Bloc<PropertyEvent, PropertyState> {
  final CreatePropertyUseCase createPropertyUseCase;
  final GetPropertiesUseCase getPropertiesUseCase;
  final GetPropertyByIdUseCase getPropertyByIdUseCase;
  final GetUserPropertiesUseCase getUserPropertiesUseCase;
  final DeletePropertyUseCase deletePropertyUseCase;
  final UploadPropertyImagesUseCase uploadPropertyImagesUseCase;
  final PropertyRepository propertyRepository;

  PropertyBloc({
    required this.createPropertyUseCase,
    required this.getPropertiesUseCase,
    required this.getPropertyByIdUseCase,
    required this.getUserPropertiesUseCase,
    required this.deletePropertyUseCase,
    required this.uploadPropertyImagesUseCase,
    required this.propertyRepository,
  }) : super(const PropertyInitial()) {
    on<PropertyLoadRequested>(_onPropertyLoadRequested);
    on<PropertyLoadByIdRequested>(_onPropertyLoadByIdRequested);
    on<UserPropertiesLoadRequested>(_onUserPropertiesLoadRequested);
    on<PropertyCreateRequested>(_onPropertyCreateRequested);
    on<PropertyUpdateRequested>(_onPropertyUpdateRequested);
    on<PropertyDeleteRequested>(_onPropertyDeleteRequested);
    on<PropertySearchRequested>(_onPropertySearchRequested);
    on<PropertyNearbyRequested>(_onPropertyNearbyRequested);
    on<PropertyImagesUploadRequested>(_onPropertyImagesUploadRequested);
    on<PropertyImageDeleteRequested>(_onPropertyImageDeleteRequested);
    on<PropertyAvailabilityAddRequested>(_onPropertyAvailabilityAddRequested);
    on<PropertyStatusToggleRequested>(_onPropertyStatusToggleRequested);
    on<PropertyErrorCleared>(_onPropertyErrorCleared);
    on<PropertyStateReset>(_onPropertyStateReset);
  }

  /// Handle loading properties with pagination
  Future<void> _onPropertyLoadRequested(
    PropertyLoadRequested event,
    Emitter<PropertyState> emit,
  ) async {
    // If loading more, show loading more state
    if (event.loadMore && state is PropertiesLoaded) {
      final currentState = state as PropertiesLoaded;
      emit(PropertiesLoadingMore(
        properties: currentState.properties,
        hasMore: currentState.hasMore,
        currentOffset: currentState.currentOffset,
      ));
    } else {
      emit(const PropertyLoading());
    }

    final result = await getPropertiesUseCase(
      GetPropertiesParams(
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (properties) {
        if (properties.isEmpty && !event.loadMore) {
          emit(const PropertiesEmpty('No properties found'));
        } else if (event.loadMore && state is PropertiesLoadingMore) {
          // Append new properties to existing list
          final currentState = state as PropertiesLoadingMore;
          final allProperties = [...currentState.properties, ...properties];
          emit(PropertiesLoaded(
            properties: allProperties,
            hasMore: properties.length >= event.limit,
            currentOffset: event.offset + properties.length,
          ));
        } else {
          emit(PropertiesLoaded(
            properties: properties,
            hasMore: properties.length >= event.limit,
            currentOffset: properties.length,
          ));
        }
      },
    );
  }

  /// Handle loading a single property by ID
  Future<void> _onPropertyLoadByIdRequested(
    PropertyLoadByIdRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await getPropertyByIdUseCase(event.propertyId);

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (property) => emit(PropertyLoaded(property)),
    );
  }

  /// Handle loading user's properties
  Future<void> _onUserPropertiesLoadRequested(
    UserPropertiesLoadRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await getUserPropertiesUseCase(event.userId);

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(const PropertiesEmpty('You have no properties yet'));
        } else {
          emit(PropertiesLoaded(
            properties: properties,
            hasMore: false,
            currentOffset: properties.length,
          ));
        }
      },
    );
  }

  /// Handle creating a new property
  Future<void> _onPropertyCreateRequested(
    PropertyCreateRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await createPropertyUseCase(
      CreatePropertyParams(
        title: event.title,
        description: event.description,
        address: event.address,
        city: event.city,
        stateProvince: event.stateProvince,
        country: event.country,
        postalCode: event.postalCode,
        latitude: event.latitude,
        longitude: event.longitude,
        propertyType: event.propertyType,
        maxGuests: event.maxGuests,
        bedrooms: event.bedrooms,
        bathrooms: event.bathrooms,
        areaSqft: event.areaSqft,
        amenities: event.amenities,
        houseRules: event.houseRules,
      ),
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (property) => emit(PropertyCreated(property)),
    );
  }

  /// Handle updating a property
  Future<void> _onPropertyUpdateRequested(
    PropertyUpdateRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await propertyRepository.updateProperty(
      propertyId: event.propertyId,
      updates: event.updates,
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (property) => emit(PropertyUpdated(property)),
    );
  }

  /// Handle deleting a property
  Future<void> _onPropertyDeleteRequested(
    PropertyDeleteRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await deletePropertyUseCase(event.propertyId);

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (_) => emit(PropertyDeleted(event.propertyId)),
    );
  }

  /// Handle searching properties
  Future<void> _onPropertySearchRequested(
    PropertySearchRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await propertyRepository.searchProperties(
      city: event.city,
      country: event.country,
      propertyType: event.propertyType,
      minGuests: event.minGuests,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(const PropertiesEmpty('No properties match your search'));
        } else {
          emit(PropertiesLoaded(
            properties: properties,
            hasMore: properties.length >= event.limit,
            currentOffset: properties.length,
          ));
        }
      },
    );
  }

  /// Handle searching nearby properties
  Future<void> _onPropertyNearbyRequested(
    PropertyNearbyRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await propertyRepository.getNearbyProperties(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusKm: event.radiusKm,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (properties) {
        if (properties.isEmpty) {
          emit(const PropertiesEmpty('No properties found nearby'));
        } else {
          emit(PropertiesLoaded(
            properties: properties,
            hasMore: false,
            currentOffset: properties.length,
          ));
        }
      },
    );
  }

  /// Handle uploading property images
  Future<void> _onPropertyImagesUploadRequested(
    PropertyImagesUploadRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await uploadPropertyImagesUseCase(
      UploadPropertyImagesParams(
        propertyId: event.propertyId,
        imagePaths: event.imagePaths,
      ),
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (imageUrls) => emit(PropertyImagesUploaded(
        propertyId: event.propertyId,
        imageUrls: imageUrls,
      )),
    );
  }

  /// Handle deleting property image
  Future<void> _onPropertyImageDeleteRequested(
    PropertyImageDeleteRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await propertyRepository.deletePropertyImage(
      propertyId: event.propertyId,
      imageUrl: event.imageUrl,
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (_) => emit(PropertyImageDeleted(
        propertyId: event.propertyId,
        imageUrl: event.imageUrl,
      )),
    );
  }

  /// Handle adding availability dates
  Future<void> _onPropertyAvailabilityAddRequested(
    PropertyAvailabilityAddRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await propertyRepository.addAvailability(
      propertyId: event.propertyId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (_) => emit(PropertyAvailabilityAdded(
        propertyId: event.propertyId,
        startDate: event.startDate,
        endDate: event.endDate,
      )),
    );
  }

  /// Handle toggling property status
  Future<void> _onPropertyStatusToggleRequested(
    PropertyStatusToggleRequested event,
    Emitter<PropertyState> emit,
  ) async {
    emit(const PropertyLoading());

    final result = await propertyRepository.togglePropertyStatus(event.propertyId);

    result.fold(
      (failure) => emit(PropertyError(failure.message)),
      (property) => emit(PropertyStatusToggled(property)),
    );
  }

  /// Handle clearing errors
  void _onPropertyErrorCleared(
    PropertyErrorCleared event,
    Emitter<PropertyState> emit,
  ) {
    emit(const PropertyInitial());
  }

  /// Handle resetting state
  void _onPropertyStateReset(
    PropertyStateReset event,
    Emitter<PropertyState> emit,
  ) {
    emit(const PropertyInitial());
  }
}
