import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import '../core/errors/exceptions.dart';

/// Service for handling verification operations with Supabase
class VerificationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Create a new verification request
  Future<Map<String, dynamic>> createRequest({
    required String propertyId,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.verificationRequestsTable)
          .insert({
            'property_id': propertyId,
            'user_id': currentUserId,
            'status': 'pending',
            'amount': 29.99, // Default verification fee
            'currency': 'USD',
          })
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create verification request: ${e.toString()}');
    }
  }

  /// Get verification request by ID
  Future<Map<String, dynamic>> getRequestById({
    required String requestId,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.verificationRequestsTable)
          .select()
          .eq('id', requestId)
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get verification request: ${e.toString()}');
    }
  }

  /// Get all verification requests for the current user
  Future<List<Map<String, dynamic>>> getUserRequests() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.verificationRequestsTable)
          .select()
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get user verification requests: ${e.toString()}');
    }
  }

  /// Get verification request for a specific property
  Future<Map<String, dynamic>?> getPropertyVerification({
    required String propertyId,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.verificationRequestsTable)
          .select()
          .eq('property_id', propertyId)
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get property verification: ${e.toString()}');
    }
  }

  /// Create payment intent for verification via Edge Function
  Future<Map<String, dynamic>> createPaymentIntent({
    required String requestId,
  }) async {
    try {
      final response = await _client.functions.invoke(
        ApiRoutes.createVerificationPaymentFunction,
        body: {
          'request_id': requestId,
        },
      );

      if (response.status != 200) {
        throw ServerException(
          'Payment intent creation failed',
          response.status.toString(),
        );
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('Failed to create payment intent: ${e.toString()}');
    }
  }

  /// Confirm payment for verification
  Future<Map<String, dynamic>> confirmPayment({
    required String requestId,
    required String paymentIntentId,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.verificationRequestsTable)
          .update({
            'payment_intent_id': paymentIntentId,
            'status': 'payment_received',
          })
          .eq('id', requestId)
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to confirm payment: ${e.toString()}');
    }
  }

  /// Upload verification document
  Future<String> uploadDocument({
    required String requestId,
    required String filePath,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      // Generate unique file name
      final fileName = '$requestId-${DateTime.now().millisecondsSinceEpoch}';

      // Upload file to Supabase Storage
      await _client.storage
          .from(ApiRoutes.verificationDocsBucket)
          .upload(fileName, filePath);

      // Get public URL
      final url = _client.storage
          .from(ApiRoutes.verificationDocsBucket)
          .getPublicUrl(fileName);

      // Update verification request with document URL
      await _client
          .from(ApiRoutes.verificationRequestsTable)
          .update({
            'document_url': url,
          })
          .eq('id', requestId);

      return url;
    } on StorageException catch (e) {
      throw ServerException(e.message, e.statusCode);
    } catch (e) {
      throw ServerException('Failed to upload document: ${e.toString()}');
    }
  }

  /// Cancel verification request
  Future<void> cancelRequest({
    required String requestId,
  }) async {
    try {
      await _client
          .from(ApiRoutes.verificationRequestsTable)
          .update({
            'status': 'rejected',
            'rejection_reason': 'Cancelled by user',
          })
          .eq('id', requestId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to cancel verification request: ${e.toString()}');
    }
  }
}
