import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/barter_request.dart';

/// Repository interface for barter/matching operations
abstract class MatchingRepository {
  /// Create a new barter request
  Future<Either<Failure, BarterRequest>> createBarterRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
    required DateTime requestedStartDate,
    required DateTime requestedEndDate,
    required DateTime offeredStartDate,
    required DateTime offeredEndDate,
    required int requesterGuests,
    required int ownerGuests,
    String? message,
  });

  /// Accept a barter request (by property owner)
  Future<Either<Failure, BarterRequest>> acceptBarterRequest(String requestId);

  /// Reject a barter request (by property owner)
  Future<Either<Failure, BarterRequest>> rejectBarterRequest({
    required String requestId,
    String? reason,
  });

  /// Cancel a barter request (by requester)
  Future<Either<Failure, void>> cancelBarterRequest(String requestId);

  /// Mark a barter as completed
  Future<Either<Failure, BarterRequest>> completeBarterRequest(String requestId);

  /// Get barter request by ID
  Future<Either<Failure, BarterRequest>> getBarterRequestById(String requestId);

  /// Get all barter requests made by the current user
  Future<Either<Failure, List<BarterRequest>>> getMyBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  /// Get all barter requests received by the current user (as property owner)
  Future<Either<Failure, List<BarterRequest>>> getReceivedBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  });

  /// Get barter requests for a specific property
  Future<Either<Failure, List<BarterRequest>>> getPropertyBarterRequests({
    required String propertyId,
    String? status,
  });

  /// Find matching properties based on user's property and preferences
  Future<Either<Failure, List<String>>> findMatches({
    required String userPropertyId,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
  });

  /// Check if a barter request exists between two properties
  Future<Either<Failure, bool>> checkExistingRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
  });

  /// Get barter statistics for a user
  Future<Either<Failure, Map<String, dynamic>>> getUserBarterStatistics();
}
