import '../../../../core/errors/exceptions.dart';
import '../../../../services/property_service.dart';
import '../models/property_model.dart';

/// Abstract class defining property remote data source contract
abstract class PropertyRemoteDataSource {
  Future<PropertyModel> createProperty({
    required String title,
    required String description,
    required String address,
    required String city,
    String? stateProvince,
    required String country,
    String? postalCode,
    required double latitude,
    required double longitude,
    required String propertyType,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    int? areaSqft,
    required List<String> amenities,
    List<String>? houseRules,
  });

  Future<PropertyModel> updateProperty({
    required String propertyId,
    Map<String, dynamic> updates,
  });

  Future<void> deleteProperty(String propertyId);

  Future<PropertyModel> getPropertyById(String propertyId);

  Future<List<PropertyModel>> getProperties({
    int limit = 20,
    int offset = 0,
  });

  Future<List<PropertyModel>> getUserProperties(String userId);

  Future<List<PropertyModel>> searchProperties({
    String? city,
    String? country,
    String? propertyType,
    int? minGuests,
    int limit = 20,
    int offset = 0,
  });

  Future<List<PropertyModel>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  });

  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<String> imagePaths,
  });

  Future<void> deletePropertyImage({
    required String propertyId,
    required String imageUrl,
  });

  Future<void> addAvailability({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<DateRangeModel>> getPropertyAvailability(String propertyId);

  Future<PropertyModel> togglePropertyStatus(String propertyId);
}

/// Implementation of property remote data source using PropertyService
class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final PropertyService propertyService;

  PropertyRemoteDataSourceImpl({required this.propertyService});

  @override
  Future<PropertyModel> createProperty({
    required String title,
    required String description,
    required String address,
    required String city,
    String? stateProvince,
    required String country,
    String? postalCode,
    required double latitude,
    required double longitude,
    required String propertyType,
    required int maxGuests,
    required int bedrooms,
    required int bathrooms,
    int? areaSqft,
    required List<String> amenities,
    List<String>? houseRules,
  }) async {
    try {
      final propertyData = await propertyService.createProperty(
        title: title,
        description: description,
        address: address,
        city: city,
        stateProvince: stateProvince,
        country: country,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        propertyType: propertyType,
        maxGuests: maxGuests,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        areaSqft: areaSqft,
        amenities: amenities,
        houseRules: houseRules,
      );

      return PropertyModel.fromJson(propertyData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PropertyModel> updateProperty({
    required String propertyId,
    Map<String, dynamic> updates,
  }) async {
    try {
      final propertyData = await propertyService.updateProperty(
        propertyId: propertyId,
        updates: updates,
      );

      return PropertyModel.fromJson(propertyData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProperty(String propertyId) async {
    try {
      await propertyService.deleteProperty(propertyId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PropertyModel> getPropertyById(String propertyId) async {
    try {
      final propertyData = await propertyService.getPropertyById(propertyId);
      return PropertyModel.fromJson(propertyData);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PropertyModel>> getProperties({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final propertiesData = await propertyService.getProperties(
        limit: limit,
        offset: offset,
      );

      return propertiesData.map((data) => PropertyModel.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PropertyModel>> getUserProperties(String userId) async {
    try {
      final propertiesData = await propertyService.getUserProperties(userId);
      return propertiesData.map((data) => PropertyModel.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PropertyModel>> searchProperties({
    String? city,
    String? country,
    String? propertyType,
    int? minGuests,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final propertiesData = await propertyService.searchProperties(
        city: city,
        country: country,
        propertyType: propertyType,
        minGuests: minGuests,
        limit: limit,
        offset: offset,
      );

      return propertiesData.map((data) => PropertyModel.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PropertyModel>> getNearbyProperties({
    required double latitude,
    required double longitude,
    int radiusKm = 50,
    int limit = 20,
  }) async {
    try {
      final propertiesData = await propertyService.getNearbyProperties(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
      );

      return propertiesData.map((data) => PropertyModel.fromJson(data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadPropertyImages({
    required String propertyId,
    required List<String> imagePaths,
  }) async {
    try {
      return await propertyService.uploadPropertyImages(
        propertyId: propertyId,
        imagePaths: imagePaths,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deletePropertyImage({
    required String propertyId,
    required String imageUrl,
  }) async {
    try {
      // Extract storage path from URL
      final uri = Uri.parse(imageUrl);
      final storagePath = uri.pathSegments.last;

      await propertyService.deletePropertyImage(
        propertyId: propertyId,
        storagePath: storagePath,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addAvailability({
    required String propertyId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await propertyService.addAvailability(
        propertyId: propertyId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<DateRangeModel>> getPropertyAvailability(
    String propertyId,
  ) async {
    try {
      final availabilityData =
          await propertyService.getPropertyAvailability(propertyId);

      return availabilityData
          .map((data) => DateRangeModel.fromJson(data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PropertyModel> togglePropertyStatus(String propertyId) async {
    try {
      final propertyData =
          await propertyService.togglePropertyStatus(propertyId);
      return PropertyModel.fromJson(propertyData);
    } catch (e) {
      rethrow;
    }
  }
}
