import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import 'karma_service.dart';

/// Service for barter/matching-related Supabase operations
class BarterService {
  final SupabaseClient _client = Supabase.instance.client;
  final KarmaService _karmaService = KarmaService();

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Create a new barter request
  Future<Map<String, dynamic>> createBarterRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
    required DateTime requestedStartDate,
    required DateTime requestedEndDate,
    required DateTime offeredStartDate,
    required DateTime offeredEndDate,
    required int requesterGuests,
    required int ownerGuests,
    String? message,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get property owner ID
    final ownerPropertyData = await _client
        .from(ApiRoutes.propertiesTable)
        .select('owner_id')
        .eq('id', ownerPropertyId)
        .single();

    final ownerId = ownerPropertyData['owner_id'] as String;

    // Set expiration date (7 days from now)
    final expiresAt = DateTime.now().add(const Duration(days: 7));

    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .insert({
          'requester_id': userId,
          'requester_property_id': requesterPropertyId,
          'owner_id': ownerId,
          'owner_property_id': ownerPropertyId,
          'requested_start_date': requestedStartDate.toIso8601String(),
          'requested_end_date': requestedEndDate.toIso8601String(),
          'offered_start_date': offeredStartDate.toIso8601String(),
          'offered_end_date': offeredEndDate.toIso8601String(),
          'requester_guests': requesterGuests,
          'owner_guests': ownerGuests,
          'message': message,
          'status': 'pending',
          'expires_at': expiresAt.toIso8601String(),
        })
        .select()
        .single();

    return response;
  }

  /// Create a karma booking request (no property offered, paying with karma)
  Future<Map<String, dynamic>> createKarmaBookingRequest({
    required String propertyId,
    required DateTime requestedStartDate,
    required DateTime requestedEndDate,
    required int guests,
    String? message,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get property details including karma price and owner
    final propertyData = await _client
        .from(ApiRoutes.propertiesTable)
        .select('owner_id, karma_price, listing_type')
        .eq('id', propertyId)
        .single();

    final ownerId = propertyData['owner_id'] as String;
    final karmaPrice = propertyData['karma_price'] as int?;
    final listingType = propertyData['listing_type'] as String?;

    // Validate property is available for karma bookings
    if (listingType != 'karma_points') {
      throw Exception('This property is not available for karma bookings');
    }

    if (karmaPrice == null || karmaPrice <= 0) {
      throw Exception('Property does not have a valid karma price');
    }

    // Calculate number of days
    final numberOfDays = requestedEndDate.difference(requestedStartDate).inDays;
    if (numberOfDays < 1) {
      throw Exception('Booking must be at least 1 day');
    }

    // Calculate total karma amount (karma price per day × number of days)
    final totalKarmaAmount = karmaPrice * numberOfDays;

    // Check if user has sufficient karma balance
    final hasSufficientBalance = await _karmaService.hasSufficientBalance(totalKarmaAmount);
    if (!hasSufficientBalance) {
      throw Exception('Insufficient karma balance. Required: $totalKarmaAmount karma points');
    }

    // Prevent self-booking
    if (ownerId == userId) {
      throw Exception('Cannot book your own property');
    }

    // Set expiration date (7 days from now)
    final expiresAt = DateTime.now().add(const Duration(days: 7));

    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .insert({
          'requester_id': userId,
          'owner_id': ownerId,
          'owner_property_id': propertyId,
          'requested_start_date': requestedStartDate.toIso8601String(),
          'requested_end_date': requestedEndDate.toIso8601String(),
          'requester_guests': guests,
          'message': message,
          'payment_type': 'karma_points',
          'karma_amount': totalKarmaAmount,
          'status': 'pending',
          'expires_at': expiresAt.toIso8601String(),
        })
        .select()
        .single();

    return response;
  }

  /// Accept a barter request
  Future<Map<String, dynamic>> acceptBarterRequest(String requestId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get the request details to check payment type
    final request = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .eq('id', requestId)
        .eq('owner_id', userId)
        .single();

    final paymentType = request['payment_type'] as String?;
    final karmaAmount = request['karma_amount'] as int?;
    final requesterId = request['requester_id'] as String;
    final propertyId = request['owner_property_id'] as String;

    // Update request status
    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .update({
          'status': 'accepted',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('owner_id', userId) // Ensure only the owner can accept
        .select()
        .single();

    // If this is a karma payment, transfer the points
    if (paymentType == 'karma_points' && karmaAmount != null) {
      try {
        await _karmaService.transferKarmaPoints(
          bookingId: requestId,
          fromUserId: requesterId,
          toUserId: userId,
          amount: karmaAmount,
          propertyId: propertyId,
        );
      } catch (e) {
        // If karma transfer fails, revert the acceptance
        await _client
            .from(ApiRoutes.barterRequestsTable)
            .update({
              'status': 'pending',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', requestId);

        throw Exception('Failed to transfer karma points: $e');
      }
    }

    return response;
  }

  /// Reject a barter request
  Future<Map<String, dynamic>> rejectBarterRequest({
    required String requestId,
    String? reason,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .update({
          'status': 'rejected',
          'rejection_reason': reason,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('owner_id', userId) // Ensure only the owner can reject
        .select()
        .single();

    return response;
  }

  /// Cancel a barter request
  Future<void> cancelBarterRequest(String requestId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get the request details to check if karma refund needed
    final request = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .eq('id', requestId)
        .or('requester_id.eq.$userId,owner_id.eq.$userId')
        .single();

    final status = request['status'] as String;
    final paymentType = request['payment_type'] as String?;

    // Update to cancelled
    await _client
        .from(ApiRoutes.barterRequestsTable)
        .update({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .or('requester_id.eq.$userId,owner_id.eq.$userId');

    // If this was an accepted karma booking, refund the points
    if (status == 'accepted' && paymentType == 'karma_points') {
      try {
        await _karmaService.refundKarmaPoints(bookingId: requestId);
      } catch (e) {
        // Log error but don't throw - cancellation already happened
        print('Warning: Failed to refund karma points: $e');
      }
    }
  }

  /// Mark barter as completed
  Future<Map<String, dynamic>> completeBarterRequest(String requestId) async {
    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .update({
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .select()
        .single();

    return response;
  }

  /// Get barter request by ID
  Future<Map<String, dynamic>> getBarterRequestById(String requestId) async {
    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .eq('id', requestId)
        .single();

    return response;
  }

  /// Get user's sent barter requests
  Future<List<Map<String, dynamic>>> getMyBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    // Ensure we have a valid session
    final session = _client.auth.currentSession;
    if (session == null) {
      throw Exception('Session expired. Please log in again.');
    }

    // Try to refresh session to ensure it's valid
    try {
      await _client.auth.refreshSession();
    } catch (e) {
      // If refresh fails, session is invalid
      throw Exception('Session expired. Please log in again.');
    }

    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated. Please log in again.');
    }

    var query = _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .eq('requester_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Get barter requests received by user
  Future<List<Map<String, dynamic>>> getReceivedBarterRequests({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    // Ensure we have a valid session
    final session = _client.auth.currentSession;
    if (session == null) {
      throw Exception('Session expired. Please log in again.');
    }

    // Try to refresh session to ensure it's valid
    try {
      await _client.auth.refreshSession();
    } catch (e) {
      // If refresh fails, session is invalid
      throw Exception('Session expired. Please log in again.');
    }

    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated. Please log in again.');
    }

    var query = _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .eq('owner_id', userId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Get barter requests for a specific property
  Future<List<Map<String, dynamic>>> getPropertyBarterRequests({
    required String propertyId,
    String? status,
  }) async {
    var query = _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .or('requester_property_id.eq.$propertyId,owner_property_id.eq.$propertyId');

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Find matching properties for barter
  Future<List<String>> findMatches({
    required String userPropertyId,
    String? city,
    String? country,
    DateTime? startDate,
    DateTime? endDate,
    int? minGuests,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Build query for available properties
    var query = _client
        .from(ApiRoutes.propertiesTable)
        .select('id')
        .eq('is_active', true)
        .eq('verification_status', 'verified')
        .neq('owner_id', userId); // Exclude user's own properties

    if (city != null) {
      query = query.eq('city', city);
    }

    if (country != null) {
      query = query.eq('country', country);
    }

    if (minGuests != null) {
      query = query.gte('max_guests', minGuests);
    }

    final response = await query;
    final properties = List<Map<String, dynamic>>.from(response as List);

    // Extract property IDs
    return properties.map((p) => p['id'] as String).toList();
  }

  /// Check if a barter request already exists
  Future<bool> checkExistingRequest({
    required String requesterPropertyId,
    required String ownerPropertyId,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select('id')
        .eq('requester_id', userId)
        .eq('requester_property_id', requesterPropertyId)
        .eq('owner_property_id', ownerPropertyId)
        .inFilter('status', ['pending', 'accepted']);

    final requests = List<Map<String, dynamic>>.from(response as List);
    return requests.isNotEmpty;
  }

  /// Get user's barter statistics
  Future<Map<String, dynamic>> getUserBarterStatistics() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Count sent requests
    final sentCountResponse = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select('id')
        .eq('requester_id', userId)
        .count();

    // Count received requests
    final receivedCountResponse = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select('id')
        .eq('owner_id', userId)
        .count();

    // Count accepted requests
    final acceptedCountResponse = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select('id')
        .eq('requester_id', userId)
        .eq('status', 'accepted')
        .count();

    // Count completed barters
    final completedCountResponse = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select('id')
        .eq('requester_id', userId)
        .eq('status', 'completed')
        .count();

    return {
      'total_sent': sentCountResponse.count,
      'total_received': receivedCountResponse.count,
      'total_accepted': acceptedCountResponse.count,
      'total_completed': completedCountResponse.count,
    };
  }
}
