import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import '../core/errors/exceptions.dart';

/// Service for handling review operations with Supabase
class ReviewService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Create a new review
  Future<Map<String, dynamic>> createReview({
    required String barterId,
    required String propertyId,
    required int rating,
    String? comment,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      // Get reviewer name from profiles
      final profile = await _client
          .from(ApiRoutes.profilesTable)
          .select('full_name')
          .eq('id', currentUserId)
          .single();

      final response = await _client.from(ApiRoutes.reviewsTable).insert({
        'barter_id': barterId,
        'property_id': propertyId,
        'reviewer_id': currentUserId,
        'reviewer_name': profile['full_name'] ?? 'Anonymous',
        'rating': rating,
        'comment': comment,
      }).select().single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create review: ${e.toString()}');
    }
  }

  /// Get reviews for a property
  Future<List<Map<String, dynamic>>> getPropertyReviews({
    required String propertyId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.reviewsTable)
          .select()
          .eq('property_id', propertyId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get property reviews: ${e.toString()}');
    }
  }

  /// Get average rating for a property
  Future<double> getAverageRating({
    required String propertyId,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.reviewsTable)
          .select('rating')
          .eq('property_id', propertyId);

      if (response.isEmpty) return 0.0;

      final ratings = List<Map<String, dynamic>>.from(response);
      final sum = ratings.fold<int>(
        0,
        (prev, review) => prev + (review['rating'] as int),
      );

      return sum / ratings.length;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get average rating: ${e.toString()}');
    }
  }
}
