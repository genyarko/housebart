import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';
import '../core/errors/exceptions.dart';

/// Service for handling notification operations
class NotificationService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all notifications for current user
  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.notificationsTable)
          .select()
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get notifications: ${e.toString()}');
    }
  }

  /// Get unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      final response = await _client
          .from(ApiRoutes.notificationsTable)
          .select('id')
          .eq('user_id', currentUserId)
          .eq('is_read', false)
          .count();

      return response.count;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to get unread count: ${e.toString()}');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead({required String notificationId}) async {
    try {
      await _client
          .from(ApiRoutes.notificationsTable)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to mark as read: ${e.toString()}');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == null) {
        throw const ServerException('User not authenticated');
      }

      await _client
          .from(ApiRoutes.notificationsTable)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', currentUserId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to mark all as read: ${e.toString()}');
    }
  }

  /// Delete notification
  Future<void> deleteNotification({required String notificationId}) async {
    try {
      await _client
          .from(ApiRoutes.notificationsTable)
          .delete()
          .eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to delete notification: ${e.toString()}');
    }
  }

  /// Create notification (useful for testing)
  Future<Map<String, dynamic>> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
  }) async {
    try {
      final response = await _client
          .from(ApiRoutes.notificationsTable)
          .insert({
            'user_id': userId,
            'title': title,
            'message': message,
            'type': type,
            'related_id': relatedId,
          })
          .select()
          .single();

      return response;
    } on PostgrestException catch (e) {
      throw ServerException(e.message, e.code);
    } catch (e) {
      throw ServerException('Failed to create notification: ${e.toString()}');
    }
  }
}
