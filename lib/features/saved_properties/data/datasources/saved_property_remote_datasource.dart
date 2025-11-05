import '../../../../services/saved_properties_service.dart';
import '../../../property/data/models/property_model.dart';

abstract class SavedPropertyRemoteDataSource {
  Future<void> saveProperty({required String propertyId});
  Future<void> unsaveProperty({required String propertyId});
  Future<bool> isPropertySaved({required String propertyId});
  Future<List<PropertyModel>> getSavedProperties({
    int limit = 50,
    int offset = 0,
  });
  Future<int> getSavedPropertiesCount();
}

class SavedPropertyRemoteDataSourceImpl implements SavedPropertyRemoteDataSource {
  final SavedPropertiesService savedPropertiesService;

  SavedPropertyRemoteDataSourceImpl({required this.savedPropertiesService});

  @override
  Future<void> saveProperty({required String propertyId}) async {
    await savedPropertiesService.saveProperty(propertyId: propertyId);
  }

  @override
  Future<void> unsaveProperty({required String propertyId}) async {
    await savedPropertiesService.unsaveProperty(propertyId: propertyId);
  }

  @override
  Future<bool> isPropertySaved({required String propertyId}) async {
    return await savedPropertiesService.isPropertySaved(propertyId: propertyId);
  }

  @override
  Future<List<PropertyModel>> getSavedProperties({
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await savedPropertiesService.getSavedProperties(
      limit: limit,
      offset: offset,
    );
    return data.map((json) => PropertyModel.fromJson(json)).toList();
  }

  @override
  Future<int> getSavedPropertiesCount() async {
    return await savedPropertiesService.getSavedPropertiesCount();
  }
}
