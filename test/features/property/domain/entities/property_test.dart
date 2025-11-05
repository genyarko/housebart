import 'package:flutter_test/flutter_test.dart';
import 'package:housebart/features/property/domain/entities/property.dart';

void main() {
  group('Property', () {
    final tLocation = const PropertyLocation(
      address: '123 Main St',
      city: 'New York',
      stateProvince: 'NY',
      country: 'USA',
      postalCode: '10001',
      latitude: 40.7128,
      longitude: -74.0060,
    );

    final tDetails = const PropertyDetails(
      propertyType: 'apartment',
      maxGuests: 4,
      bedrooms: 2,
      bathrooms: 2,
      areaSqft: 1200,
    );

    final tProperty = Property(
      id: 'property-1',
      ownerId: 'owner-1',
      title: 'Beautiful Apartment in NYC',
      description: 'A beautiful apartment with great views',
      location: tLocation,
      details: tDetails,
      images: ['image1.jpg', 'image2.jpg'],
      amenities: ['WiFi', 'Kitchen'],
      houseRules: ['No smoking', 'No pets'],
      verificationStatus: VerificationStatus.verified,
      averageRating: 4.5,
      totalReviews: 10,
      isActive: true,
      availableDates: [],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    test('hasImages returns true when property has images', () {
      expect(tProperty.hasImages, isTrue);
    });

    test('hasImages returns false when property has no images', () {
      final property = tProperty.copyWith(images: []);
      expect(property.hasImages, isFalse);
    });

    test('primaryImage returns first image', () {
      expect(tProperty.primaryImage, equals('image1.jpg'));
    });

    test('primaryImage returns null when no images', () {
      final property = tProperty.copyWith(images: []);
      expect(property.primaryImage, isNull);
    });

    test('isVerified returns true for verified property', () {
      expect(tProperty.isVerified, isTrue);
    });

    test('isVerified returns false for unverified property', () {
      final property = tProperty.copyWith(
        verificationStatus: VerificationStatus.unverified,
      );
      expect(property.isVerified, isFalse);
    });

    test('hasRating returns true when property has rating and reviews', () {
      expect(tProperty.hasRating, isTrue);
    });

    test('hasRating returns false when no rating', () {
      final property = tProperty.copyWith(averageRating: null);
      expect(property.hasRating, isFalse);
    });

    test('hasRating returns false when no reviews', () {
      final property = tProperty.copyWith(totalReviews: 0);
      expect(property.hasRating, isFalse);
    });

    test('ratingDisplay formats rating correctly', () {
      expect(tProperty.ratingDisplay, equals('4.5 (10)'));
    });

    test('ratingDisplay shows no rating when null', () {
      final property = tProperty.copyWith(averageRating: null);
      expect(property.ratingDisplay, equals('No rating'));
    });

    test('copyWith creates new instance with updated values', () {
      final updated = tProperty.copyWith(title: 'Updated Title');
      expect(updated.title, equals('Updated Title'));
      expect(updated.description, equals(tProperty.description));
    });

    test('supports equality', () {
      final property1 = tProperty;
      final property2 = tProperty.copyWith();
      expect(property1, equals(property2));
    });
  });

  group('PropertyLocation', () {
    const tLocation = PropertyLocation(
      address: '123 Main St',
      city: 'New York',
      stateProvince: 'NY',
      country: 'USA',
      postalCode: '10001',
      latitude: 40.7128,
      longitude: -74.0060,
    );

    test('fullAddress returns complete address', () {
      expect(
        tLocation.fullAddress,
        equals('123 Main St, New York, NY, USA, 10001'),
      );
    });

    test('fullAddress omits null values', () {
      const location = PropertyLocation(
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
      );
      expect(location.fullAddress, equals('123 Main St, New York, USA'));
    });

    test('cityCountry returns city and country', () {
      expect(tLocation.cityCountry, equals('New York, USA'));
    });

    test('supports equality', () {
      const location1 = PropertyLocation(
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
      );
      const location2 = PropertyLocation(
        address: '123 Main St',
        city: 'New York',
        country: 'USA',
      );
      expect(location1, equals(location2));
    });
  });

  group('PropertyDetails', () {
    const tDetails = PropertyDetails(
      propertyType: 'apartment',
      maxGuests: 4,
      bedrooms: 2,
      bathrooms: 2,
      areaSqft: 1200,
    );

    test('propertyTypeDisplay capitalizes property type', () {
      expect(tDetails.propertyTypeDisplay, equals('Apartment'));
    });

    test('specsSummary formats details correctly', () {
      expect(tDetails.specsSummary, equals('4 guests · 2 beds · 2 baths · 1200 sqft'));
    });

    test('specsSummary handles single bedroom', () {
      const details = PropertyDetails(
        propertyType: 'apartment',
        maxGuests: 2,
        bedrooms: 1,
        bathrooms: 1,
      );
      expect(details.specsSummary, equals('2 guests · 1 bed · 1 bath'));
    });

    test('specsSummary omits area when null', () {
      const details = PropertyDetails(
        propertyType: 'apartment',
        maxGuests: 4,
        bedrooms: 2,
        bathrooms: 2,
      );
      expect(details.specsSummary, equals('4 guests · 2 beds · 2 baths'));
    });

    test('supports equality', () {
      const details1 = PropertyDetails(
        propertyType: 'apartment',
        maxGuests: 4,
        bedrooms: 2,
        bathrooms: 2,
      );
      const details2 = PropertyDetails(
        propertyType: 'apartment',
        maxGuests: 4,
        bedrooms: 2,
        bathrooms: 2,
      );
      expect(details1, equals(details2));
    });
  });

  group('DateRange', () {
    final tStartDate = DateTime(2024, 6, 1);
    final tEndDate = DateTime(2024, 6, 10);
    final tDateRange = DateRange(startDate: tStartDate, endDate: tEndDate);

    test('durationInDays calculates duration correctly', () {
      expect(tDateRange.durationInDays, equals(9));
    });

    test('contains returns true for date within range', () {
      final midDate = DateTime(2024, 6, 5);
      expect(tDateRange.contains(midDate), isTrue);
    });

    test('contains returns true for start date', () {
      expect(tDateRange.contains(tStartDate), isTrue);
    });

    test('contains returns true for end date', () {
      expect(tDateRange.contains(tEndDate), isTrue);
    });

    test('contains returns false for date before range', () {
      final beforeDate = DateTime(2024, 5, 31);
      expect(tDateRange.contains(beforeDate), isFalse);
    });

    test('contains returns false for date after range', () {
      final afterDate = DateTime(2024, 6, 11);
      expect(tDateRange.contains(afterDate), isFalse);
    });

    test('overlaps returns true when ranges overlap', () {
      final overlappingRange = DateRange(
        startDate: DateTime(2024, 6, 5),
        endDate: DateTime(2024, 6, 15),
      );
      expect(tDateRange.overlaps(overlappingRange), isTrue);
    });

    test('overlaps returns false when ranges do not overlap', () {
      final nonOverlappingRange = DateRange(
        startDate: DateTime(2024, 6, 15),
        endDate: DateTime(2024, 6, 20),
      );
      expect(tDateRange.overlaps(nonOverlappingRange), isFalse);
    });

    test('supports equality', () {
      final range1 = DateRange(
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
      );
      final range2 = DateRange(
        startDate: DateTime(2024, 6, 1),
        endDate: DateTime(2024, 6, 10),
      );
      expect(range1, equals(range2));
    });
  });
}
