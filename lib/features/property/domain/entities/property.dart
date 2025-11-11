import 'package:equatable/equatable.dart';

/// Verification status enum
enum VerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
}

/// Property category enum
enum PropertyCategory {
  vacationHome,
  spareProperty,
  primaryHome,
}

/// Property entity representing an accommodation in the domain layer
class Property extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final PropertyLocation location;
  final PropertyDetails details;
  final PropertyCategory propertyCategory;
  final List<String> images;
  final List<String> amenities;
  final List<String> houseRules;
  final VerificationStatus verificationStatus;
  final double? averageRating;
  final int totalReviews;
  final bool isActive;
  final List<DateRange> availableDates;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Property({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.location,
    required this.details,
    required this.propertyCategory,
    required this.images,
    required this.amenities,
    required this.houseRules,
    required this.verificationStatus,
    this.averageRating,
    required this.totalReviews,
    required this.isActive,
    required this.availableDates,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if property has images
  bool get hasImages => images.isNotEmpty;

  /// Get primary image
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  /// Check if property is verified
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// Check if property has rating
  bool get hasRating => averageRating != null && totalReviews > 0;

  /// Format rating for display
  String get ratingDisplay {
    if (averageRating == null) return 'No rating';
    return '${averageRating!.toStringAsFixed(1)} (${totalReviews})';
  }

  /// Get property category display text
  String get propertyCategoryDisplay {
    switch (propertyCategory) {
      case PropertyCategory.vacationHome:
        return 'Vacation Home';
      case PropertyCategory.spareProperty:
        return 'Spare Property';
      case PropertyCategory.primaryHome:
        return 'Primary Home';
    }
  }

  /// Copy with
  Property copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    PropertyLocation? location,
    PropertyDetails? details,
    PropertyCategory? propertyCategory,
    List<String>? images,
    List<String>? amenities,
    List<String>? houseRules,
    VerificationStatus? verificationStatus,
    double? averageRating,
    int? totalReviews,
    bool? isActive,
    List<DateRange>? availableDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      details: details ?? this.details,
      propertyCategory: propertyCategory ?? this.propertyCategory,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      houseRules: houseRules ?? this.houseRules,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isActive: isActive ?? this.isActive,
      availableDates: availableDates ?? this.availableDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        location,
        details,
        propertyCategory,
        images,
        amenities,
        houseRules,
        verificationStatus,
        averageRating,
        totalReviews,
        isActive,
        availableDates,
        createdAt,
        updatedAt,
      ];
}

/// Property location entity
class PropertyLocation extends Equatable {
  final String address;
  final String city;
  final String? stateProvince;
  final String country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  const PropertyLocation({
    required this.address,
    required this.city,
    this.stateProvince,
    required this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  /// Get full address
  String get fullAddress {
    final parts = [address, city, stateProvince, country, postalCode];
    return parts.where((p) => p != null && p.isNotEmpty).join(', ');
  }

  /// Get city and country
  String get cityCountry => '$city, $country';

  @override
  List<Object?> get props => [
        address,
        city,
        stateProvince,
        country,
        postalCode,
        latitude,
        longitude,
      ];
}

/// Property details entity
class PropertyDetails extends Equatable {
  final String propertyType;
  final int maxGuests;
  final int bedrooms;
  final int bathrooms;
  final int? areaSqft;

  const PropertyDetails({
    required this.propertyType,
    required this.maxGuests,
    required this.bedrooms,
    required this.bathrooms,
    this.areaSqft,
  });

  /// Format property type for display
  String get propertyTypeDisplay {
    return propertyType[0].toUpperCase() + propertyType.substring(1);
  }

  /// Get property specs summary
  String get specsSummary {
    final parts = [
      '$maxGuests guests',
      '$bedrooms bed${bedrooms != 1 ? 's' : ''}',
      '$bathrooms bath${bathrooms != 1 ? 's' : ''}',
    ];
    if (areaSqft != null) {
      parts.add('$areaSqft sqft');
    }
    return parts.join(' · ');
  }

  @override
  List<Object?> get props => [
        propertyType,
        maxGuests,
        bedrooms,
        bathrooms,
        areaSqft,
      ];
}

/// Date range entity
class DateRange extends Equatable {
  final DateTime startDate;
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// Check if date ranges overlap
  bool overlaps(DateRange other) {
    return startDate.isBefore(other.endDate) &&
        endDate.isAfter(other.startDate);
  }

  /// Get duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }

  /// Check if date is within this range
  bool contains(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate) ||
        date.isAtSameMomentAs(startDate) ||
        date.isAtSameMomentAs(endDate);
  }

  @override
  List<Object> get props => [startDate, endDate];
}
