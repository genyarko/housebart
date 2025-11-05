import 'package:equatable/equatable.dart';

/// Entity representing search filters for property search
class SearchFilters extends Equatable {
  final String? searchQuery;
  final String? city;
  final String? country;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minGuests;
  final int? maxGuests;
  final int? minBedrooms;
  final int? maxBedrooms;
  final double? minPrice;
  final double? maxPrice;
  final List<String> amenities;
  final String? propertyType;
  final bool? isVerified;
  final double? latitude;
  final double? longitude;
  final int? radiusKm;
  final String sortBy; // 'price', 'rating', 'distance', 'newest'
  final bool sortAscending;

  const SearchFilters({
    this.searchQuery,
    this.city,
    this.country,
    this.startDate,
    this.endDate,
    this.minGuests,
    this.maxGuests,
    this.minBedrooms,
    this.maxBedrooms,
    this.minPrice,
    this.maxPrice,
    this.amenities = const [],
    this.propertyType,
    this.isVerified,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.sortBy = 'newest',
    this.sortAscending = false,
  });

  /// Create empty filters
  factory SearchFilters.empty() => const SearchFilters();

  /// Check if any filters are applied
  bool get hasFilters =>
      searchQuery != null ||
      city != null ||
      country != null ||
      startDate != null ||
      endDate != null ||
      minGuests != null ||
      maxGuests != null ||
      minBedrooms != null ||
      maxBedrooms != null ||
      minPrice != null ||
      maxPrice != null ||
      amenities.isNotEmpty ||
      propertyType != null ||
      isVerified != null ||
      (latitude != null && longitude != null);

  /// Copy with method for updating filters
  SearchFilters copyWith({
    String? searchQuery,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
    int? maxGuests,
    int? minBedrooms,
    int? maxBedrooms,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? propertyType,
    bool? isVerified,
    double? latitude,
    double? longitude,
    int? radiusKm,
    String? sortBy,
    bool? sortAscending,
  }) {
    return SearchFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      city: city ?? this.city,
      country: country ?? this.country,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minGuests: minGuests ?? this.minGuests,
      maxGuests: maxGuests ?? this.maxGuests,
      minBedrooms: minBedrooms ?? this.minBedrooms,
      maxBedrooms: maxBedrooms ?? this.maxBedrooms,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      amenities: amenities ?? this.amenities,
      propertyType: propertyType ?? this.propertyType,
      isVerified: isVerified ?? this.isVerified,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Clear all filters
  SearchFilters clearFilters() => SearchFilters.empty();

  @override
  List<Object?> get props => [
        searchQuery,
        city,
        country,
        startDate,
        endDate,
        minGuests,
        maxGuests,
        minBedrooms,
        maxBedrooms,
        minPrice,
        maxPrice,
        amenities,
        propertyType,
        isVerified,
        latitude,
        longitude,
        radiusKm,
        sortBy,
        sortAscending,
      ];
}
