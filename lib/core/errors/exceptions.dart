/// Base class for all exceptions in the application
/// Exceptions are thrown from the data layer
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException(this.message, [this.code, this.data]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception - thrown when the API returns an error
class ServerException extends AppException {
  const ServerException([
    String message = 'Server error occurred',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'ServerException: $message (code: $code)';
}

/// Cache exception - thrown when local storage operations fail
class CacheException extends AppException {
  const CacheException([
    String message = 'Cache error occurred',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'CacheException: $message (code: $code)';
}

/// Network exception - thrown when there's no internet connection
class NetworkException extends AppException {
  const NetworkException([
    String message = 'No internet connection',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication exception - thrown when auth operations fail
class AuthenticationException extends AppException {
  const AuthenticationException([
    String message = 'Authentication failed',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'AuthenticationException: $message (code: $code)';
}

/// Validation exception - thrown when input validation fails
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException([
    String message = 'Validation error',
    String? code,
    this.errors,
  ]) : super(message, code, errors);

  @override
  String toString() => 'ValidationException: $message, errors: $errors';
}

/// Not found exception - thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'Resource not found',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'NotFoundException: $message (code: $code)';
}

/// Permission exception - thrown when user doesn't have permission
class PermissionException extends AppException {
  const PermissionException([
    String message = 'Permission denied',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'PermissionException: $message (code: $code)';
}

/// Timeout exception - thrown when a request times out
class TimeoutException extends AppException {
  const TimeoutException([
    String message = 'Request timeout',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Payment exception - thrown when payment processing fails
class PaymentException extends AppException {
  const PaymentException([
    String message = 'Payment failed',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'PaymentException: $message (code: $code)';
}

/// File upload exception - thrown when file upload fails
class FileUploadException extends AppException {
  const FileUploadException([
    String message = 'File upload failed',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'FileUploadException: $message (code: $code)';
}

/// Location exception - thrown when location services fail
class LocationException extends AppException {
  const LocationException([
    String message = 'Location service error',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'LocationException: $message (code: $code)';
}

/// Parse exception - thrown when data parsing fails
class ParseException extends AppException {
  const ParseException([
    String message = 'Failed to parse data',
    String? code,
    dynamic data,
  ]) : super(message, code, data);

  @override
  String toString() => 'ParseException: $message';
}
