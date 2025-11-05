import 'package:equatable/equatable.dart';
import '../../domain/entities/property.dart';

/// Base class for all property states
abstract class PropertyState extends Equatable {
  const PropertyState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PropertyInitial extends PropertyState {
  const PropertyInitial();
}

/// Loading state
class PropertyLoading extends PropertyState {
  const PropertyLoading();
}

/// State when a single property is loaded
class PropertyLoaded extends PropertyState {
  final Property property;

  const PropertyLoaded(this.property);

  @override
  List<Object?> get props => [property];
}

/// State when multiple properties are loaded
class PropertiesLoaded extends PropertyState {
  final List<Property> properties;
  final bool hasMore; // For pagination
  final int currentOffset;

  const PropertiesLoaded({
    required this.properties,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  @override
  List<Object?> get props => [properties, hasMore, currentOffset];

  /// Copy with for pagination
  PropertiesLoaded copyWith({
    List<Property>? properties,
    bool? hasMore,
    int? currentOffset,
  }) {
    return PropertiesLoaded(
      properties: properties ?? this.properties,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

/// State when loading more properties (for infinite scroll)
class PropertiesLoadingMore extends PropertiesLoaded {
  const PropertiesLoadingMore({
    required super.properties,
    required super.hasMore,
    required super.currentOffset,
  });
}

/// State when a property is created successfully
class PropertyCreated extends PropertyState {
  final Property property;

  const PropertyCreated(this.property);

  @override
  List<Object?> get props => [property];
}

/// State when a property is updated successfully
class PropertyUpdated extends PropertyState {
  final Property property;

  const PropertyUpdated(this.property);

  @override
  List<Object?> get props => [property];
}

/// State when a property is deleted successfully
class PropertyDeleted extends PropertyState {
  final String propertyId;

  const PropertyDeleted(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

/// State when property images are uploaded successfully
class PropertyImagesUploaded extends PropertyState {
  final String propertyId;
  final List<String> imageUrls;

  const PropertyImagesUploaded({
    required this.propertyId,
    required this.imageUrls,
  });

  @override
  List<Object?> get props => [propertyId, imageUrls];
}

/// State when a property image is deleted successfully
class PropertyImageDeleted extends PropertyState {
  final String propertyId;
  final String imageUrl;

  const PropertyImageDeleted({
    required this.propertyId,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [propertyId, imageUrl];
}

/// State when availability is added successfully
class PropertyAvailabilityAdded extends PropertyState {
  final String propertyId;
  final DateTime startDate;
  final DateTime endDate;

  const PropertyAvailabilityAdded({
    required this.propertyId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [propertyId, startDate, endDate];
}

/// State when property status is toggled successfully
class PropertyStatusToggled extends PropertyState {
  final Property property;

  const PropertyStatusToggled(this.property);

  @override
  List<Object?> get props => [property];
}

/// Error state
class PropertyError extends PropertyState {
  final String message;

  const PropertyError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (when no properties found)
class PropertiesEmpty extends PropertyState {
  final String? message;

  const PropertiesEmpty([this.message]);

  @override
  List<Object?> get props => [message];
}

/// State when favorite status is toggled
class PropertyFavoriteToggled extends PropertyState {
  final String propertyId;
  final bool isFavorited;

  const PropertyFavoriteToggled({
    required this.propertyId,
    required this.isFavorited,
  });

  @override
  List<Object?> get props => [propertyId, isFavorited];
}

/// State when favorite properties are loaded
class FavoritePropertiesLoaded extends PropertyState {
  final List<Property> properties;

  const FavoritePropertiesLoaded(this.properties);

  @override
  List<Object?> get props => [properties];
}
