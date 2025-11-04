import '../../domain/entities/property.dart';

/// Property model for the data layer
class PropertyModel extends Property {
  const PropertyModel({
    required super.id,
    required super.ownerId,
    required super.title,
    required super.description,
    required super.location,
    required super.details,
    required super.images,
    required super.amenities,
    required super.houseRules,
    required super.verificationStatus,
    super.averageRating,
    required super.totalReviews,
    required super.isActive,
    required super.availableDates,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create PropertyModel from JSON
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      location: PropertyLocationModel.fromJson({
        'address': json['address'],
        'city': json['city'],
        'state_province': json['state_province'],
        'country': json['country'],
        'postal_code': json['postal_code'],
        'latitude': json['latitude'],
        'longitude': json['longitude'],
      }),
      details: PropertyDetailsModel.fromJson({
        'property_type': json['property_type'],
        'max_guests': json['max_guests'],
        'bedrooms': json['bedrooms'],
        'bathrooms': json['bathrooms'],
        'area_sqft': json['area_sqft'],
      }),
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : [],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'] as List)
          : [],
      houseRules: json['house_rules'] != null
          ? List<String>.from(json['house_rules'] as List)
          : [],
      verificationStatus: _parseVerificationStatus(
        json['verification_status'] as String?,
      ),
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
      totalReviews: json['total_reviews'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      availableDates: [], // Will be loaded separately
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert PropertyModel to JSON
  Map<String, dynamic> toJson() {
    final locationModel = location as PropertyLocationModel;
    final detailsModel = details as PropertyDetailsModel;

    return {
      'id': id,
      'owner_id': ownerId,
      'title': title,
      'description': description,
      'address': locationModel.address,
      'city': locationModel.city,
      'state_province': locationModel.stateProvince,
      'country': locationModel.country,
      'postal_code': locationModel.postalCode,
      'latitude': locationModel.latitude,
      'longitude': locationModel.longitude,
      'property_type': detailsModel.propertyType,
      'max_guests': detailsModel.maxGuests,
      'bedrooms': detailsModel.bedrooms,
      'bathrooms': detailsModel.bathrooms,
      'area_sqft': detailsModel.areaSqft,
      'amenities': amenities,
      'house_rules': houseRules,
      'verification_status': _verificationStatusToString(verificationStatus),
      'average_rating': averageRating,
      'total_reviews': totalReviews,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Parse verification status from string
  static VerificationStatus _parseVerificationStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.unverified;
    }
  }

  /// Convert verification status to string
  static String _verificationStatusToString(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'verified';
      case VerificationStatus.pending:
        return 'pending';
      case VerificationStatus.rejected:
        return 'rejected';
      case VerificationStatus.unverified:
        return 'unverified';
    }
  }

  /// Convert to Property entity
  Property toEntity() => this;

  /// Create PropertyModel from Property entity
  factory PropertyModel.fromEntity(Property property) {
    return PropertyModel(
      id: property.id,
      ownerId: property.ownerId,
      title: property.title,
      description: property.description,
      location: property.location,
      details: property.details,
      images: property.images,
      amenities: property.amenities,
      houseRules: property.houseRules,
      verificationStatus: property.verificationStatus,
      averageRating: property.averageRating,
      totalReviews: property.totalReviews,
      isActive: property.isActive,
      availableDates: property.availableDates,
      createdAt: property.createdAt,
      updatedAt: property.updatedAt,
    );
  }
}

/// Property location model
class PropertyLocationModel extends PropertyLocation {
  const PropertyLocationModel({
    required super.address,
    required super.city,
    super.stateProvince,
    required super.country,
    super.postalCode,
    required super.latitude,
    required super.longitude,
  });

  factory PropertyLocationModel.fromJson(Map<String, dynamic> json) {
    return PropertyLocationModel(
      address: json['address'] as String,
      city: json['city'] as String,
      stateProvince: json['state_province'] as String?,
      country: json['country'] as String,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state_province': stateProvince,
      'country': country,
      'postal_code': postalCode,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Property details model
class PropertyDetailsModel extends PropertyDetails {
  const PropertyDetailsModel({
    required super.propertyType,
    required super.maxGuests,
    required super.bedrooms,
    required super.bathrooms,
    super.areaSqft,
  });

  factory PropertyDetailsModel.fromJson(Map<String, dynamic> json) {
    return PropertyDetailsModel(
      propertyType: json['property_type'] as String,
      maxGuests: json['max_guests'] as int,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      areaSqft: json['area_sqft'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'property_type': propertyType,
      'max_guests': maxGuests,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqft': areaSqft,
    };
  }
}

/// Date range model
class DateRangeModel extends DateRange {
  const DateRangeModel({
    required super.startDate,
    required super.endDate,
  });

  factory DateRangeModel.fromJson(Map<String, dynamic> json) {
    return DateRangeModel(
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }

  /// Convert to DateRange entity
  DateRange toEntity() => this;
}
