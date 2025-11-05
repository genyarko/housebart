import 'package:flutter_test/flutter_test.dart';
import 'package:housebart/core/errors/failures.dart';

void main() {
  group('Failures', () {
    group('ServerFailure', () {
      test('creates instance with default message', () {
        const failure = ServerFailure();
        expect(failure.message, equals('Server error occurred'));
        expect(failure.code, isNull);
      });

      test('creates instance with custom message', () {
        const failure = ServerFailure('Custom error');
        expect(failure.message, equals('Custom error'));
      });

      test('creates instance with message and code', () {
        const failure = ServerFailure('Custom error', '500');
        expect(failure.message, equals('Custom error'));
        expect(failure.code, equals('500'));
      });

      test('supports equality', () {
        const failure1 = ServerFailure('Error', '500');
        const failure2 = ServerFailure('Error', '500');
        const failure3 = ServerFailure('Different', '500');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('CacheFailure', () {
      test('creates instance with default message', () {
        const failure = CacheFailure();
        expect(failure.message, equals('Cache error occurred'));
      });

      test('creates instance with custom message and code', () {
        const failure = CacheFailure('Custom cache error', 'CACHE_001');
        expect(failure.message, equals('Custom cache error'));
        expect(failure.code, equals('CACHE_001'));
      });
    });

    group('NetworkFailure', () {
      test('creates instance with default message', () {
        const failure = NetworkFailure();
        expect(failure.message, equals('No internet connection'));
      });

      test('creates instance with custom message', () {
        const failure = NetworkFailure('Connection timeout');
        expect(failure.message, equals('Connection timeout'));
      });
    });

    group('AuthenticationFailure', () {
      test('creates instance with default message', () {
        const failure = AuthenticationFailure();
        expect(failure.message, equals('Authentication failed'));
      });

      test('creates instance with custom message and code', () {
        const failure = AuthenticationFailure('Invalid credentials', 'AUTH_001');
        expect(failure.message, equals('Invalid credentials'));
        expect(failure.code, equals('AUTH_001'));
      });
    });

    group('ValidationFailure', () {
      test('creates instance with message', () {
        const failure = ValidationFailure('Invalid email');
        expect(failure.message, equals('Invalid email'));
      });

      test('creates instance with message and code', () {
        const failure = ValidationFailure('Invalid input', 'VAL_001');
        expect(failure.message, equals('Invalid input'));
        expect(failure.code, equals('VAL_001'));
      });
    });

    group('NotFoundFailure', () {
      test('creates instance with default message', () {
        const failure = NotFoundFailure();
        expect(failure.message, equals('Resource not found'));
      });

      test('creates instance with custom message', () {
        const failure = NotFoundFailure('Property not found');
        expect(failure.message, equals('Property not found'));
      });
    });

    group('PermissionFailure', () {
      test('creates instance with default message', () {
        const failure = PermissionFailure();
        expect(failure.message, equals('Permission denied'));
      });

      test('creates instance with custom message', () {
        const failure = PermissionFailure('Access denied');
        expect(failure.message, equals('Access denied'));
      });
    });

    group('TimeoutFailure', () {
      test('creates instance with default message', () {
        const failure = TimeoutFailure();
        expect(failure.message, equals('Request timeout'));
      });

      test('creates instance with custom message', () {
        const failure = TimeoutFailure('Connection timed out');
        expect(failure.message, equals('Connection timed out'));
      });
    });

    group('PaymentFailure', () {
      test('creates instance with default message', () {
        const failure = PaymentFailure();
        expect(failure.message, equals('Payment failed'));
      });

      test('creates instance with custom message and code', () {
        const failure = PaymentFailure('Card declined', 'PAY_001');
        expect(failure.message, equals('Card declined'));
        expect(failure.code, equals('PAY_001'));
      });
    });

    group('FileUploadFailure', () {
      test('creates instance with default message', () {
        const failure = FileUploadFailure();
        expect(failure.message, equals('File upload failed'));
      });

      test('creates instance with custom message', () {
        const failure = FileUploadFailure('File too large');
        expect(failure.message, equals('File too large'));
      });
    });

    group('LocationFailure', () {
      test('creates instance with default message', () {
        const failure = LocationFailure();
        expect(failure.message, equals('Location service error'));
      });

      test('creates instance with custom message', () {
        const failure = LocationFailure('GPS disabled');
        expect(failure.message, equals('GPS disabled'));
      });
    });

    group('getFailureMessage', () {
      test('returns appropriate message for ServerFailure', () {
        const failure = ServerFailure('Custom server error');
        expect(getFailureMessage(failure), equals('Custom server error'));
      });

      test('returns appropriate message for NetworkFailure', () {
        const failure = NetworkFailure();
        expect(getFailureMessage(failure),
            equals('Please check your internet connection and try again.'));
      });

      test('returns appropriate message for AuthenticationFailure', () {
        const failure = AuthenticationFailure();
        expect(getFailureMessage(failure),
            equals('Please login again to continue.'));
      });

      test('returns appropriate message for ValidationFailure', () {
        const failure = ValidationFailure('Invalid input');
        expect(getFailureMessage(failure), equals('Invalid input'));
      });

      test('returns appropriate message for NotFoundFailure', () {
        const failure = NotFoundFailure();
        expect(getFailureMessage(failure),
            equals('The requested item could not be found.'));
      });

      test('returns appropriate message for PermissionFailure', () {
        const failure = PermissionFailure();
        expect(getFailureMessage(failure),
            equals('You do not have permission to perform this action.'));
      });

      test('returns appropriate message for TimeoutFailure', () {
        const failure = TimeoutFailure();
        expect(getFailureMessage(failure),
            equals('Request timed out. Please try again.'));
      });

      test('returns appropriate message for PaymentFailure', () {
        const failure = PaymentFailure();
        expect(getFailureMessage(failure),
            equals('Payment processing failed. Please try again.'));
      });

      test('returns appropriate message for FileUploadFailure', () {
        const failure = FileUploadFailure();
        expect(getFailureMessage(failure),
            equals('Failed to upload file. Please try again.'));
      });

      test('returns appropriate message for LocationFailure', () {
        const failure = LocationFailure();
        expect(getFailureMessage(failure),
            equals('Unable to access location. Please check permissions.'));
      });

      test('returns generic message for CacheFailure', () {
        const failure = CacheFailure();
        expect(getFailureMessage(failure),
            equals('An unexpected error occurred. Please try again.'));
      });
    });
  });
}
