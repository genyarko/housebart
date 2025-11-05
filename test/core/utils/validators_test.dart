import 'package:flutter_test/flutter_test.dart';
import 'package:housebart/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co.uk'), isNull);
        expect(Validators.validateEmail('user+tag@example.com'), isNull);
      });

      test('returns error for null email', () {
        expect(Validators.validateEmail(null), equals('Email is required'));
      });

      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), equals('Email is required'));
      });

      test('returns error for invalid email format', () {
        expect(Validators.validateEmail('invalid'),
            equals('Please enter a valid email address'));
        expect(Validators.validateEmail('invalid@'),
            equals('Please enter a valid email address'));
        expect(Validators.validateEmail('@domain.com'),
            equals('Please enter a valid email address'));
        expect(Validators.validateEmail('user@'),
            equals('Please enter a valid email address'));
        expect(Validators.validateEmail('user@domain'),
            equals('Please enter a valid email address'));
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        expect(Validators.validatePassword('Password123'), isNull);
        expect(Validators.validatePassword('MyP@ssw0rd'), isNull);
        expect(Validators.validatePassword('Abcdefg1'), isNull);
      });

      test('returns error for null password', () {
        expect(Validators.validatePassword(null),
            equals('Password is required'));
      });

      test('returns error for empty password', () {
        expect(Validators.validatePassword(''),
            equals('Password is required'));
      });

      test('returns error for password shorter than 8 characters', () {
        expect(Validators.validatePassword('Pass1'),
            equals('Password must be at least 8 characters'));
      });

      test('returns error for password without uppercase letter', () {
        expect(Validators.validatePassword('password123'),
            equals('Password must contain at least one uppercase letter'));
      });

      test('returns error for password without lowercase letter', () {
        expect(Validators.validatePassword('PASSWORD123'),
            equals('Password must contain at least one lowercase letter'));
      });

      test('returns error for password without number', () {
        expect(Validators.validatePassword('Password'),
            equals('Password must contain at least one number'));
      });
    });

    group('validateConfirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.validateConfirmPassword('Password123', 'Password123'),
            isNull);
      });

      test('returns error for null value', () {
        expect(Validators.validateConfirmPassword(null, 'Password123'),
            equals('Please confirm your password'));
      });

      test('returns error for empty value', () {
        expect(Validators.validateConfirmPassword('', 'Password123'),
            equals('Please confirm your password'));
      });

      test('returns error when passwords do not match', () {
        expect(Validators.validateConfirmPassword('Password123', 'Different123'),
            equals('Passwords do not match'));
      });
    });

    group('validateRequired', () {
      test('returns null for valid input', () {
        expect(Validators.validateRequired('Some text', 'Field'), isNull);
      });

      test('returns error for null value', () {
        expect(Validators.validateRequired(null, 'Username'),
            equals('Username is required'));
      });

      test('returns error for empty value', () {
        expect(Validators.validateRequired('', 'Username'),
            equals('Username is required'));
      });

      test('returns error for whitespace only value', () {
        expect(Validators.validateRequired('   ', 'Username'),
            equals('Username is required'));
      });
    });

    group('validateMinLength', () {
      test('returns null for valid length', () {
        expect(Validators.validateMinLength('12345', 5, 'Code'), isNull);
        expect(Validators.validateMinLength('123456', 5, 'Code'), isNull);
      });

      test('returns error for null value', () {
        expect(Validators.validateMinLength(null, 5, 'Code'),
            equals('Code is required'));
      });

      test('returns error for empty value', () {
        expect(Validators.validateMinLength('', 5, 'Code'),
            equals('Code is required'));
      });

      test('returns error for value shorter than minimum', () {
        expect(Validators.validateMinLength('1234', 5, 'Code'),
            equals('Code must be at least 5 characters'));
      });
    });

    group('validateMaxLength', () {
      test('returns null for valid length', () {
        expect(Validators.validateMaxLength('12345', 10, 'Name'), isNull);
        expect(Validators.validateMaxLength(null, 10, 'Name'), isNull);
      });

      test('returns error for value exceeding maximum', () {
        expect(Validators.validateMaxLength('12345678901', 10, 'Name'),
            equals('Name must not exceed 10 characters'));
      });
    });

    group('validatePhone', () {
      test('returns null for valid phone numbers', () {
        expect(Validators.validatePhone('+1234567890'), isNull);
        expect(Validators.validatePhone('+12345678901234'), isNull);
        expect(Validators.validatePhone('+919876543210'), isNull);
      });

      test('returns error for null phone', () {
        expect(Validators.validatePhone(null),
            equals('Phone number is required'));
      });

      test('returns error for empty phone', () {
        expect(Validators.validatePhone(''),
            equals('Phone number is required'));
      });

      test('returns error for invalid phone format', () {
        expect(Validators.validatePhone('123'),
            equals('Please enter a valid phone number'));
        expect(Validators.validatePhone('abc'),
            equals('Please enter a valid phone number'));
        expect(Validators.validatePhone('+0123456789'),
            equals('Please enter a valid phone number'));
      });
    });

    group('validatePropertyTitle', () {
      test('returns null for valid title', () {
        expect(Validators.validatePropertyTitle('Beautiful Beach House'), isNull);
        expect(Validators.validatePropertyTitle('A' * 10), isNull);
        expect(Validators.validatePropertyTitle('A' * 100), isNull);
      });

      test('returns error for null title', () {
        expect(Validators.validatePropertyTitle(null),
            equals('Property title is required'));
      });

      test('returns error for empty title', () {
        expect(Validators.validatePropertyTitle(''),
            equals('Property title is required'));
      });

      test('returns error for title too short', () {
        expect(Validators.validatePropertyTitle('Short'),
            equals('Title must be at least 10 characters'));
      });

      test('returns error for title too long', () {
        expect(Validators.validatePropertyTitle('A' * 101),
            equals('Title must not exceed 100 characters'));
      });
    });

    group('validatePropertyDescription', () {
      test('returns null for valid description', () {
        expect(Validators.validatePropertyDescription('A' * 50), isNull);
        expect(Validators.validatePropertyDescription('A' * 2000), isNull);
      });

      test('returns error for null description', () {
        expect(Validators.validatePropertyDescription(null),
            equals('Property description is required'));
      });

      test('returns error for empty description', () {
        expect(Validators.validatePropertyDescription(''),
            equals('Property description is required'));
      });

      test('returns error for description too short', () {
        expect(Validators.validatePropertyDescription('Short'),
            equals('Description must be at least 50 characters'));
      });

      test('returns error for description too long', () {
        expect(Validators.validatePropertyDescription('A' * 2001),
            equals('Description must not exceed 2000 characters'));
      });
    });

    group('validateGuests', () {
      test('returns null for valid guest count', () {
        expect(Validators.validateGuests('1'), isNull);
        expect(Validators.validateGuests('10'), isNull);
        expect(Validators.validateGuests('20'), isNull);
      });

      test('returns error for null value', () {
        expect(Validators.validateGuests(null),
            equals('Number of guests is required'));
      });

      test('returns error for empty value', () {
        expect(Validators.validateGuests(''),
            equals('Number of guests is required'));
      });

      test('returns error for invalid number', () {
        expect(Validators.validateGuests('abc'),
            equals('Please enter a valid number'));
      });

      test('returns error for guests below minimum', () {
        expect(Validators.validateGuests('0'),
            equals('Minimum 1 guest'));
      });

      test('returns error for guests above maximum', () {
        expect(Validators.validateGuests('21'),
            equals('Maximum 20 guests'));
      });
    });

    group('validateBedrooms', () {
      test('returns null for valid bedroom count', () {
        expect(Validators.validateBedrooms('0'), isNull);
        expect(Validators.validateBedrooms('5'), isNull);
        expect(Validators.validateBedrooms('20'), isNull);
      });

      test('returns error for null value', () {
        expect(Validators.validateBedrooms(null),
            equals('Number of bedrooms is required'));
      });

      test('returns error for invalid number', () {
        expect(Validators.validateBedrooms('abc'),
            equals('Please enter a valid number'));
      });

      test('returns error for bedrooms below minimum', () {
        expect(Validators.validateBedrooms('-1'),
            equals('Minimum 0 bedrooms'));
      });

      test('returns error for bedrooms above maximum', () {
        expect(Validators.validateBedrooms('21'),
            equals('Maximum 20 bedrooms'));
      });
    });

    group('validateBathrooms', () {
      test('returns null for valid bathroom count', () {
        expect(Validators.validateBathrooms('1'), isNull);
        expect(Validators.validateBathrooms('5'), isNull);
        expect(Validators.validateBathrooms('10'), isNull);
      });

      test('returns error for null value', () {
        expect(Validators.validateBathrooms(null),
            equals('Number of bathrooms is required'));
      });

      test('returns error for invalid number', () {
        expect(Validators.validateBathrooms('abc'),
            equals('Please enter a valid number'));
      });

      test('returns error for bathrooms below minimum', () {
        expect(Validators.validateBathrooms('0'),
            equals('Minimum 1 bathroom'));
      });

      test('returns error for bathrooms above maximum', () {
        expect(Validators.validateBathrooms('11'),
            equals('Maximum 10 bathrooms'));
      });
    });

    group('validateCity', () {
      test('returns null for valid city', () {
        expect(Validators.validateCity('New York'), isNull);
        expect(Validators.validateCity('LA'), isNull);
      });

      test('returns error for null city', () {
        expect(Validators.validateCity(null),
            equals('City is required'));
      });

      test('returns error for empty city', () {
        expect(Validators.validateCity(''),
            equals('City is required'));
      });

      test('returns error for whitespace only city', () {
        expect(Validators.validateCity('   '),
            equals('City is required'));
      });

      test('returns error for city too short', () {
        expect(Validators.validateCity('A'),
            equals('City name must be at least 2 characters'));
      });
    });

    group('validateCountry', () {
      test('returns null for valid country', () {
        expect(Validators.validateCountry('United States'), isNull);
        expect(Validators.validateCountry('UK'), isNull);
      });

      test('returns error for null country', () {
        expect(Validators.validateCountry(null),
            equals('Country is required'));
      });

      test('returns error for empty country', () {
        expect(Validators.validateCountry(''),
            equals('Country is required'));
      });

      test('returns error for whitespace only country', () {
        expect(Validators.validateCountry('   '),
            equals('Country is required'));
      });

      test('returns error for country too short', () {
        expect(Validators.validateCountry('A'),
            equals('Country name must be at least 2 characters'));
      });
    });

    group('validateReview', () {
      test('returns null for valid review', () {
        expect(Validators.validateReview('A' * 20), isNull);
        expect(Validators.validateReview('A' * 1000), isNull);
      });

      test('returns error for null review', () {
        expect(Validators.validateReview(null),
            equals('Review is required'));
      });

      test('returns error for empty review', () {
        expect(Validators.validateReview(''),
            equals('Review is required'));
      });

      test('returns error for review too short', () {
        expect(Validators.validateReview('Short'),
            equals('Review must be at least 20 characters'));
      });

      test('returns error for review too long', () {
        expect(Validators.validateReview('A' * 1001),
            equals('Review must not exceed 1000 characters'));
      });
    });

    group('validateRating', () {
      test('returns null for valid rating', () {
        expect(Validators.validateRating(1), isNull);
        expect(Validators.validateRating(3), isNull);
        expect(Validators.validateRating(5), isNull);
      });

      test('returns error for null rating', () {
        expect(Validators.validateRating(null),
            equals('Rating is required'));
      });

      test('returns error for rating below minimum', () {
        expect(Validators.validateRating(0),
            equals('Rating must be between 1 and 5'));
      });

      test('returns error for rating above maximum', () {
        expect(Validators.validateRating(6),
            equals('Rating must be between 1 and 5'));
      });
    });

    group('validateUrl', () {
      test('returns null for valid URL', () {
        expect(Validators.validateUrl('https://example.com'), isNull);
        expect(Validators.validateUrl('http://www.example.com'), isNull);
        expect(Validators.validateUrl('https://example.com/path?query=1'), isNull);
      });

      test('returns null for null URL (optional)', () {
        expect(Validators.validateUrl(null), isNull);
      });

      test('returns null for empty URL (optional)', () {
        expect(Validators.validateUrl(''), isNull);
      });

      test('returns error for invalid URL format', () {
        expect(Validators.validateUrl('invalid'),
            equals('Please enter a valid URL'));
        expect(Validators.validateUrl('example.com'),
            equals('Please enter a valid URL'));
        expect(Validators.validateUrl('ftp://example.com'),
            equals('Please enter a valid URL'));
      });
    });

    group('validateDateRange', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));
      final nextYear = now.add(const Duration(days: 365));

      test('returns null for valid date range', () {
        expect(Validators.validateDateRange(now, tomorrow), isNull);
        expect(Validators.validateDateRange(now, nextWeek), isNull);
        expect(Validators.validateDateRange(now, nextYear), isNull);
      });

      test('returns error for null dates', () {
        expect(Validators.validateDateRange(null, null),
            equals('Please select both start and end dates'));
        expect(Validators.validateDateRange(now, null),
            equals('Please select both start and end dates'));
        expect(Validators.validateDateRange(null, tomorrow),
            equals('Please select both start and end dates'));
      });

      test('returns error when end date is before start date', () {
        expect(Validators.validateDateRange(tomorrow, now),
            equals('End date must be after start date'));
      });

      test('returns error for duration below minimum', () {
        final sameDay = now;
        expect(Validators.validateDateRange(now, sameDay),
            equals('Minimum booking duration is 1 day(s)'));
      });

      test('returns error for duration above maximum', () {
        final tooFar = now.add(const Duration(days: 366));
        expect(Validators.validateDateRange(now, tooFar),
            equals('Maximum booking duration is 365 days'));
      });
    });

    group('validateAdvanceBooking', () {
      final now = DateTime.now();
      final validDate = now.add(const Duration(days: 7));
      final invalidDate = now.add(const Duration(days: 6));

      test('returns null for valid advance booking', () {
        expect(Validators.validateAdvanceBooking(validDate), isNull);
        expect(Validators.validateAdvanceBooking(
            now.add(const Duration(days: 30))), isNull);
      });

      test('returns error for null date', () {
        expect(Validators.validateAdvanceBooking(null),
            equals('Please select a start date'));
      });

      test('returns error for date within minimum advance booking period', () {
        expect(Validators.validateAdvanceBooking(invalidDate),
            equals('Booking must be at least 7 days in advance'));
      });
    });
  });
}
