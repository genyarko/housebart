import '../../domain/entities/saved_property.dart';

class SavedPropertyModel extends SavedProperty {
  const SavedPropertyModel({
    required super.id,
    required super.userId,
    required super.propertyId,
    required super.createdAt,
  });

  factory SavedPropertyModel.fromJson(Map<String, dynamic> json) {
    return SavedPropertyModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      propertyId: json['property_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'property_id': propertyId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SavedProperty toEntity() => SavedProperty(
        id: id,
        userId: userId,
        propertyId: propertyId,
        createdAt: createdAt,
      );
}
