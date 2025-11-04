import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Failures represent errors from the domain/use case layer
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

/// Server failure - occurs when the backend returns an error
class ServerFailure extends Failure {
  const ServerFailure([
    String message = 'Server error occurred',
    String? code,
  ]) : super(message, code);
}

/// Cache failure - occurs when local storage operations fail
class CacheFailure extends Failure {
  const CacheFailure([
    String message = 'Cache error occurred',
    String? code,
  ]) : super(message, code);
}

/// Network failure - occurs when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure([
    String message = 'No internet connection',
    String? code,
  ]) : super(message, code);
}

/// Authentication failure - occurs when auth operations fail
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([
    String message = 'Authentication failed',
    String? code,
  ]) : super(message, code);
}

/// Validation failure - occurs when input validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(
    String message, [
    String? code,
  ]) : super(message, code);
}

/// Not found failure - occurs when a resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    String message = 'Resource not found',
    String? code,
  ]) : super(message, code);
}

/// Permission failure - occurs when user doesn't have permission
class PermissionFailure extends Failure {
  const PermissionFailure([
    String message = 'Permission denied',
    String? code,
  ]) : super(message, code);
}

/// Timeout failure - occurs when a request times out
class TimeoutFailure extends Failure {
  const TimeoutFailure([
    String message = 'Request timeout',
    String? code,
  ]) : super(message, code);
}

/// Payment failure - occurs when payment processing fails
class PaymentFailure extends Failure {
  const PaymentFailure([
    String message = 'Payment failed',
    String? code,
  ]) : super(message, code);
}

/// File upload failure - occurs when file upload fails
class FileUploadFailure extends Failure {
  const FileUploadFailure([
    String message = 'File upload failed',
    String? code,
  ]) : super(message, code);
}

/// Location failure - occurs when location services fail
class LocationFailure extends Failure {
  const LocationFailure([
    String message = 'Location service error',
    String? code,
  ]) : super(message, code);
}

/// Helper function to get user-friendly error message
String getFailureMessage(Failure failure) {
  if (failure is ServerFailure) {
    return failure.message;
  } else if (failure is NetworkFailure) {
    return 'Please check your internet connection and try again.';
  } else if (failure is AuthenticationFailure) {
    return 'Please login again to continue.';
  } else if (failure is ValidationFailure) {
    return failure.message;
  } else if (failure is NotFoundFailure) {
    return 'The requested item could not be found.';
  } else if (failure is PermissionFailure) {
    return 'You do not have permission to perform this action.';
  } else if (failure is TimeoutFailure) {
    return 'Request timed out. Please try again.';
  } else if (failure is PaymentFailure) {
    return 'Payment processing failed. Please try again.';
  } else if (failure is FileUploadFailure) {
    return 'Failed to upload file. Please try again.';
  } else if (failure is LocationFailure) {
    return 'Unable to access location. Please check permissions.';
  } else {
    return 'An unexpected error occurred. Please try again.';
  }
}
