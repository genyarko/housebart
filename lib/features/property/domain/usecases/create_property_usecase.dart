import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/property.dart';
import '../repositories/property_repository.dart';

/// Use case for creating a new property
class CreatePropertyUseCase {
  final PropertyRepository repository;

  CreatePropertyUseCase(this.repository);

  Future<Either<Failure, Property>> call(CreatePropertyParams params) async {
    return await repository.createProperty(
      title: params.title,
      description: params.description,
      address: params.address,
      city: params.city,
      stateProvince: params.stateProvince,
      country: params.country,
      postalCode: params.postalCode,
      latitude: params.latitude,
      longitude: params.longitude,
      propertyType: params.propertyType,
      propertyCategory: params.propertyCategory,
      maxGuests: params.maxGuests,
      bedrooms: params.bedrooms,
      bathrooms: params.bathrooms,
      areaSqft: params.areaSqft,
      amenities: params.amenities,
      houseRules: params.houseRules,
      listingType: params.listingType,
      karmaPrice: params.karmaPrice,
    );
  }
}

/// Parameters for creating a property
class CreatePropertyParams extends Equatable {
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
  final String? listingType;
  final int? karmaPrice;

  const CreatePropertyParams({
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
    this.listingType,
    this.karmaPrice,
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
        listingType,
        karmaPrice,
      ];
}
