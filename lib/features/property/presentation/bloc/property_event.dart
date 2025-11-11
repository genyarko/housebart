import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Base class for all property events
abstract class PropertyEvent extends Equatable {
  const PropertyEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all properties with pagination
class PropertyLoadRequested extends PropertyEvent {
  final int limit;
  final int offset;
  final bool loadMore; // true when loading more for infinite scroll
  final String? propertyCategory; // filter by category

  const PropertyLoadRequested({
    this.limit = 20,
    this.offset = 0,
    this.loadMore = false,
    this.propertyCategory,
  });

  @override
  List<Object?> get props => [limit, offset, loadMore, propertyCategory];
}

/// Event to load a single property by ID
class PropertyLoadByIdRequested extends PropertyEvent {
  final String propertyId;

  const PropertyLoadByIdRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Event to load user's properties
class UserPropertiesLoadRequested extends PropertyEvent {
  final String userId;

  const UserPropertiesLoadRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new property
class PropertyCreateRequested extends PropertyEvent {
  final String title;
  final String description;
  final String address;
  final String city;
  final String? stateProvince;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String propertyType;
  final String propertyCategory;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final int? areaSqft;
  final List<String> amenities;
  final List<String>? houseRules;

  const PropertyCreateRequested({
    required this.title,
    required this.description,
    required this.address,
    required this.city,
    this.stateProvince,
    required this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
    required this.propertyType,
    required this.propertyCategory,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    this.areaSqft,
    required this.amenities,
    this.houseRules,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        address,
        city,
        stateProvince,
        country,
        postalCode,
        latitude,
        longitude,
        propertyType,
        propertyCategory,
        maxGuests,
        bedrooms,
        bathrooms,
        areaSqft,
        amenities,
        houseRules,
      ];
}

/// Event to update an existing property
class PropertyUpdateRequested extends PropertyEvent {
  final String propertyId;
  final Map<String, dynamic> updates;

  const PropertyUpdateRequested({
    required this.propertyId,
    required this.updates,
  });

  @override
  List<Object?> get props => [propertyId, updates];
}

/// Event to delete a property
class PropertyDeleteRequested extends PropertyEvent {
  final String propertyId;

  const PropertyDeleteRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Event to search properties with filters
class PropertySearchRequested extends PropertyEvent {
  final String? city;
  final String? country;
  final String? propertyType;
  final int? minGuests;
  final int limit;
  final int offset;

  const PropertySearchRequested({
    this.city,
    this.country,
    this.propertyType,
    this.minGuests,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
        city,
        country,
        propertyType,
        minGuests,
        limit,
        offset,
      ];
}

/// Event to search nearby properties
class PropertyNearbyRequested extends PropertyEvent {
  final double latitude;
  final double longitude;
  final int radiusKm;
  final int limit;

  const PropertyNearbyRequested({
    required this.latitude,
    required this.longitude,
    this.radiusKm = 50,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm, limit];
}

/// Event to upload property images
class PropertyImagesUploadRequested extends PropertyEvent {
  final String propertyId;
  final List<String> imagePaths;
  final List<Uint8List>? imageBytes;

  const PropertyImagesUploadRequested({
    required this.propertyId,
    required this.imagePaths,
    this.imageBytes,
  });

  @override
  List<Object?> get props => [propertyId, imagePaths, imageBytes];
}

/// Event to delete a property image
class PropertyImageDeleteRequested extends PropertyEvent {
  final String propertyId;
  final String imageUrl;

  const PropertyImageDeleteRequested({
    required this.propertyId,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [propertyId, imageUrl];
}

/// Event to add availability dates
class PropertyAvailabilityAddRequested extends PropertyEvent {
  final String propertyId;
  final DateTime startDate;
  final DateTime endDate;

  const PropertyAvailabilityAddRequested({
    required this.propertyId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [propertyId, startDate, endDate];
}

/// Event to toggle property active status
class PropertyStatusToggleRequested extends PropertyEvent {
  final String propertyId;

  const PropertyStatusToggleRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Event to clear property error
class PropertyErrorCleared extends PropertyEvent {
  const PropertyErrorCleared();
}

/// Event to reset property state
class PropertyStateReset extends PropertyEvent {
  const PropertyStateReset();
}

/// Event to toggle favorite status
class PropertyFavoriteToggleRequested extends PropertyEvent {
  final String propertyId;

  const PropertyFavoriteToggleRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// Event to load favorite properties
class FavoritePropertiesLoadRequested extends PropertyEvent {
  const FavoritePropertiesLoadRequested();
}
