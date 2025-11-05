import 'package:flutter_test/flutter_test.dart';
import 'package:housebart/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatDate', () {
      test('formats date correctly', () {
        final date = DateTime(2024, 3, 15);
        expect(Formatters.formatDate(date), equals('Mar 15, 2024'));
      });

      test('formats different months correctly', () {
        expect(Formatters.formatDate(DateTime(2024, 1, 1)), equals('Jan 01, 2024'));
        expect(Formatters.formatDate(DateTime(2024, 12, 31)), equals('Dec 31, 2024'));
      });
    });

    group('formatDateTime', () {
      test('formats date and time correctly', () {
        final dateTime = DateTime(2024, 3, 15, 14, 30);
        expect(Formatters.formatDateTime(dateTime), equals('Mar 15, 2024 14:30'));
      });
    });

    group('formatTime', () {
      test('formats time correctly', () {
        final time = DateTime(2024, 3, 15, 14, 30);
        expect(Formatters.formatTime(time), equals('14:30'));
      });

      test('formats time with leading zeros', () {
        final time = DateTime(2024, 3, 15, 9, 5);
        expect(Formatters.formatTime(time), equals('09:05'));
      });
    });

    group('formatApiDate', () {
      test('formats date for API correctly', () {
        final date = DateTime(2024, 3, 15);
        expect(Formatters.formatApiDate(date), equals('2024-03-15'));
      });
    });

    group('formatApiDateTime', () {
      test('formats datetime for API correctly in UTC', () {
        final dateTime = DateTime.utc(2024, 3, 15, 14, 30, 45, 123);
        final result = Formatters.formatApiDateTime(dateTime);
        expect(result, contains('2024-03-15T14:30:45'));
      });
    });

    group('formatDateRange', () {
      test('formats date range correctly', () {
        final start = DateTime(2024, 3, 15);
        final end = DateTime(2024, 3, 20);
        expect(Formatters.formatDateRange(start, end),
            equals('Mar 15, 2024 - Mar 20, 2024'));
      });
    });

    group('formatCurrency', () {
      test('formats currency with default symbol', () {
        expect(Formatters.formatCurrency(100.0), equals('\$100.00'));
        expect(Formatters.formatCurrency(99.99), equals('\$99.99'));
      });

      test('formats currency with custom symbol', () {
        expect(Formatters.formatCurrency(100.0, symbol: '€'), equals('€100.00'));
      });

      test('formats currency with two decimal places', () {
        expect(Formatters.formatCurrency(100.5), equals('\$100.50'));
        expect(Formatters.formatCurrency(100.1), equals('\$100.10'));
      });
    });

    group('formatPrice', () {
      test('formats price correctly', () {
        expect(Formatters.formatPrice(100.0), equals('\$100.00'));
        expect(Formatters.formatPrice(1234.56), equals('\$1,234.56'));
      });
    });

    group('formatNumber', () {
      test('formats number with commas', () {
        expect(Formatters.formatNumber(1000), equals('1,000'));
        expect(Formatters.formatNumber(1000000), equals('1,000,000'));
      });

      test('formats small numbers without commas', () {
        expect(Formatters.formatNumber(100), equals('100'));
        expect(Formatters.formatNumber(999), equals('999'));
      });
    });

    group('formatRating', () {
      test('formats rating with one decimal place', () {
        expect(Formatters.formatRating(4.5), equals('4.5'));
        expect(Formatters.formatRating(3.0), equals('3.0'));
        expect(Formatters.formatRating(4.99), equals('5.0'));
      });
    });

    group('formatPhoneNumber', () {
      test('formats 10-digit phone number', () {
        expect(Formatters.formatPhoneNumber('1234567890'),
            equals('(123) 456-7890'));
      });

      test('formats 11-digit phone number starting with 1', () {
        expect(Formatters.formatPhoneNumber('11234567890'),
            equals('+1 (123) 456-7890'));
      });

      test('removes non-digit characters before formatting', () {
        expect(Formatters.formatPhoneNumber('(123) 456-7890'),
            equals('(123) 456-7890'));
        expect(Formatters.formatPhoneNumber('123-456-7890'),
            equals('(123) 456-7890'));
      });

      test('returns original for invalid format', () {
        expect(Formatters.formatPhoneNumber('12345'), equals('12345'));
        expect(Formatters.formatPhoneNumber('123'), equals('123'));
      });
    });

    group('formatFileSize', () {
      test('formats bytes', () {
        expect(Formatters.formatFileSize(500), equals('500 B'));
      });

      test('formats kilobytes', () {
        expect(Formatters.formatFileSize(1024), equals('1.0 KB'));
        expect(Formatters.formatFileSize(1536), equals('1.5 KB'));
      });

      test('formats megabytes', () {
        expect(Formatters.formatFileSize(1024 * 1024), equals('1.0 MB'));
        expect(Formatters.formatFileSize(1024 * 1024 * 2), equals('2.0 MB'));
      });

      test('formats gigabytes', () {
        expect(Formatters.formatFileSize(1024 * 1024 * 1024), equals('1.0 GB'));
      });
    });

    group('formatDuration', () {
      test('formats days', () {
        expect(Formatters.formatDuration(const Duration(days: 1)), equals('1 day'));
        expect(Formatters.formatDuration(const Duration(days: 2)), equals('2 days'));
      });

      test('formats hours', () {
        expect(Formatters.formatDuration(const Duration(hours: 1)), equals('1 hour'));
        expect(Formatters.formatDuration(const Duration(hours: 5)), equals('5 hours'));
      });

      test('formats minutes', () {
        expect(Formatters.formatDuration(const Duration(minutes: 1)), equals('1 minute'));
        expect(Formatters.formatDuration(const Duration(minutes: 30)), equals('30 minutes'));
      });

      test('formats seconds', () {
        expect(Formatters.formatDuration(const Duration(seconds: 1)), equals('1 second'));
        expect(Formatters.formatDuration(const Duration(seconds: 45)), equals('45 seconds'));
      });
    });

    group('formatRelativeTime', () {
      test('formats just now', () {
        final now = DateTime.now();
        expect(Formatters.formatRelativeTime(now), equals('Just now'));
      });

      test('formats minutes ago', () {
        final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));
        expect(Formatters.formatRelativeTime(fiveMinutesAgo), equals('5 minutes ago'));
      });

      test('formats hours ago', () {
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        expect(Formatters.formatRelativeTime(twoHoursAgo), equals('2 hours ago'));
      });

      test('formats days ago', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        expect(Formatters.formatRelativeTime(threeDaysAgo), equals('3 days ago'));
      });

      test('formats as date for more than 7 days ago', () {
        final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
        final result = Formatters.formatRelativeTime(tenDaysAgo);
        expect(result, isNot(contains('ago')));
        expect(result, contains(','));
      });
    });

    group('formatPropertyType', () {
      test('formats known property types', () {
        expect(Formatters.formatPropertyType('apartment'), equals('Apartment'));
        expect(Formatters.formatPropertyType('house'), equals('House'));
        expect(Formatters.formatPropertyType('villa'), equals('Villa'));
        expect(Formatters.formatPropertyType('condo'), equals('Condo'));
        expect(Formatters.formatPropertyType('cabin'), equals('Cabin'));
      });

      test('formats unknown property type as Other', () {
        expect(Formatters.formatPropertyType('unknown'), equals('Other'));
        expect(Formatters.formatPropertyType('mansion'), equals('Other'));
      });

      test('handles case insensitivity', () {
        expect(Formatters.formatPropertyType('APARTMENT'), equals('Apartment'));
        expect(Formatters.formatPropertyType('HoUsE'), equals('House'));
      });
    });

    group('formatVerificationStatus', () {
      test('formats known verification statuses', () {
        expect(Formatters.formatVerificationStatus('verified'), equals('Verified'));
        expect(Formatters.formatVerificationStatus('pending'), equals('Pending'));
        expect(Formatters.formatVerificationStatus('unverified'), equals('Unverified'));
        expect(Formatters.formatVerificationStatus('rejected'), equals('Rejected'));
      });

      test('returns original for unknown status', () {
        expect(Formatters.formatVerificationStatus('custom'), equals('custom'));
      });
    });

    group('formatBarterStatus', () {
      test('formats known barter statuses', () {
        expect(Formatters.formatBarterStatus('pending'), equals('Pending'));
        expect(Formatters.formatBarterStatus('accepted'), equals('Accepted'));
        expect(Formatters.formatBarterStatus('rejected'), equals('Rejected'));
        expect(Formatters.formatBarterStatus('cancelled'), equals('Cancelled'));
        expect(Formatters.formatBarterStatus('completed'), equals('Completed'));
      });

      test('returns original for unknown status', () {
        expect(Formatters.formatBarterStatus('custom'), equals('custom'));
      });
    });

    group('capitalize', () {
      test('capitalizes first letter', () {
        expect(Formatters.capitalize('hello'), equals('Hello'));
        expect(Formatters.capitalize('world'), equals('World'));
      });

      test('handles already capitalized text', () {
        expect(Formatters.capitalize('Hello'), equals('Hello'));
      });

      test('handles empty string', () {
        expect(Formatters.capitalize(''), equals(''));
      });

      test('handles single character', () {
        expect(Formatters.capitalize('a'), equals('A'));
      });
    });

    group('capitalizeWords', () {
      test('capitalizes first letter of each word', () {
        expect(Formatters.capitalizeWords('hello world'), equals('Hello World'));
        expect(Formatters.capitalizeWords('the quick brown fox'),
            equals('The Quick Brown Fox'));
      });

      test('handles already capitalized words', () {
        expect(Formatters.capitalizeWords('Hello World'), equals('Hello World'));
      });

      test('handles empty string', () {
        expect(Formatters.capitalizeWords(''), equals(''));
      });

      test('handles multiple spaces', () {
        expect(Formatters.capitalizeWords('hello  world'), equals('Hello  World'));
      });
    });

    group('truncate', () {
      test('truncates text exceeding max length', () {
        expect(Formatters.truncate('This is a long text', 10),
            equals('This is a ...'));
      });

      test('returns original text if shorter than max length', () {
        expect(Formatters.truncate('Short', 10), equals('Short'));
      });

      test('returns original text if equal to max length', () {
        expect(Formatters.truncate('Exactly10!', 10), equals('Exactly10!'));
      });
    });

    group('formatInitials', () {
      test('formats initials from full name', () {
        expect(Formatters.formatInitials('John Doe'), equals('JD'));
        expect(Formatters.formatInitials('Jane Smith'), equals('JS'));
      });

      test('formats initial from single name', () {
        expect(Formatters.formatInitials('John'), equals('J'));
      });

      test('formats initials from name with multiple words', () {
        expect(Formatters.formatInitials('John Michael Doe'), equals('JD'));
      });

      test('handles empty string', () {
        expect(Formatters.formatInitials(''), equals(''));
      });

      test('handles whitespace', () {
        expect(Formatters.formatInitials('  John   Doe  '), equals('JD'));
      });

      test('converts to uppercase', () {
        expect(Formatters.formatInitials('john doe'), equals('JD'));
      });
    });
  });
}
