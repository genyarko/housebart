import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/verification_request.dart';

/// Repository interface for verification operations
abstract class VerificationRepository {
  /// Create a new verification request
  Future<Either<Failure, VerificationRequest>> createRequest({
    required String propertyId,
  });

  /// Get verification request by ID
  Future<Either<Failure, VerificationRequest>> getRequestById({
    required String requestId,
  });

  /// Get all verification requests for the current user
  Future<Either<Failure, List<VerificationRequest>>> getUserRequests();

  /// Get verification request for a specific property
  Future<Either<Failure, VerificationRequest?>> getPropertyVerification({
    required String propertyId,
  });

  /// Create payment intent for verification
  Future<Either<Failure, Map<String, dynamic>>> createPaymentIntent({
    required String requestId,
  });

  /// Confirm payment for verification
  Future<Either<Failure, VerificationRequest>> confirmPayment({
    required String requestId,
    required String paymentIntentId,
  });

  /// Upload verification documents
  Future<Either<Failure, String>> uploadDocument({
    required String requestId,
    required String filePath,
  });

  /// Cancel verification request
  Future<Either<Failure, void>> cancelRequest({
    required String requestId,
  });
}
