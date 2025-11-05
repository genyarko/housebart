import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';

/// Property repository interface
/// Defines the contract for property operations
abstract class PropertyRepository {
  /// Create a new property
  Future<Either<Failure, Property>> createProperty({
    required String title,
    required String description,
    required String address,
    required String city,
    String? stateProvince,
    required String country,
    String? postalCode,
    double? latitude,
    double? longitude,
    required String propertyType,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    int? areaSqft,
    required List<String> amenities,
    List<String>? houseRules,
  });

  /// Update an existing property
  Future<Either<Failure, Property>> updateProperty({
    required String propertyId,
    String? title,
    String? description,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
    String? propertyType,
    int? maxGuests,
    int? bedrooms,
    int? bathrooms,
    int? areaSqft,
    List<String>? amenities,
    List<String>? houseRules,
    bool? isActive,
  });

  /// Delete a property
  Future<Either<Failure, void>> deleteProperty(String propertyId);

  /// Get property by ID
  Future<Either<Failure, Property>> getPropertyById(String propertyId);

  /// Get all properties (with pagination)
  Future<Either<Failure, List<Property>>> getProperties({
    int limit = 20,
    int offset = 0,
  });

  /// Get user's properties
  Future<Either<Failure, List<Property>>> getUserProperties(String userId);

  /// Search properties with filters
  Future<Either<Failure, List<Property>>> searchProperties({
    String? city,
    String? country,
    String? propertyType,
    int? minGuests,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? amenities,
    int limit = 20,
    int offset = 0,
  });

  /// Get properties near location
  Future<Either<Failure, List<Property>>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  });

  /// Upload property images
  Future<Either<Failure, List<String>>> uploadPropertyImages({
    required String propertyId,
    required List<String> imagePaths,
    List<Uint8List>? imageBytes,
  });

  /// Delete property image
  Future<Either<Failure, void>> deletePropertyImage({
    required String propertyId,
    required String imageUrl,
  });

  /// Add availability dates
  Future<Either<Failure, void>> addAvailability({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Remove availability dates
  Future<Either<Failure, void>> removeAvailability({
    required String propertyId,
    required String availabilityId,
  });

  /// Get property availability
  Future<Either<Failure, List<DateRange>>> getPropertyAvailability(
    String propertyId,
  );

  /// Toggle property active status
  Future<Either<Failure, Property>> togglePropertyStatus(String propertyId);

  /// Save property to favorites
  Future<Either<Failure, void>> savePropertyToFavorites({
    required String userId,
    required String propertyId,
  });

  /// Remove property from favorites
  Future<Either<Failure, void>> removePropertyFromFavorites({
    required String userId,
    required String propertyId,
  });

  /// Get user's favorite properties
  Future<Either<Failure, List<Property>>> getFavoriteProperties(String userId);

  /// Check if property is favorited by user
  Future<Either<Failure, bool>> isPropertyFavorited({
    required String userId,
    required String propertyId,
  });
}
