import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/api_routes.dart';

/// Service for messaging operations with Supabase
class MessagingService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user ID
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Send a message in a barter conversation
  Future<Map<String, dynamic>> sendMessage({
    required String barterId,
    required String receiverId,
    required String content,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(ApiRoutes.messagesTable)
        .insert({
          'barter_id': barterId,
          'sender_id': userId,
          'receiver_id': receiverId,
          'content': content,
          'is_read': false,
        })
        .select()
        .single();

    return response;
  }

  /// Get messages for a barter conversation
  Future<List<Map<String, dynamic>>> getMessages({
    required String barterId,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client
        .from(ApiRoutes.messagesTable)
        .select()
        .eq('barter_id', barterId)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Get all conversations for current user
  Future<List<Map<String, dynamic>>> getConversations() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get all barter requests where user is involved
    final barterRequests = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .or('requester_id.eq.$userId,owner_id.eq.$userId')
        .order('created_at', ascending: false);

    final barters = List<Map<String, dynamic>>.from(barterRequests as List);
    final conversations = <Map<String, dynamic>>[];

    // For each barter, get last message and unread count
    for (final barter in barters) {
      final barterId = barter['id'] as String;

      // Determine who the other user is
      final requesterId = barter['requester_id'] as String?;
      final ownerId = barter['owner_id'] as String?;
      final otherUserId = userId == requesterId ? ownerId : requesterId;

      // Get last message
      final lastMessageResponse = await _client
          .from(ApiRoutes.messagesTable)
          .select()
          .eq('barter_id', barterId)
          .order('created_at', ascending: false)
          .limit(1);

      final lastMessages = List<Map<String, dynamic>>.from(lastMessageResponse as List);
      final lastMessage = lastMessages.isNotEmpty ? lastMessages.first : null;

      // Get unread count
      final unreadResponse = await _client
          .from(ApiRoutes.messagesTable)
          .select('id')
          .eq('barter_id', barterId)
          .eq('receiver_id', userId)
          .eq('is_read', false)
          .count(CountOption.exact);

      final unreadCount = unreadResponse.count;

      // Get other user's profile information
      String? otherUserName;
      String? otherUserAvatar;

      if (otherUserId != null) {
        try {
          final profileResponse = await _client
              .from('profiles')
              .select('first_name, last_name, full_name, avatar_url')
              .eq('id', otherUserId)
              .maybeSingle();

          if (profileResponse != null) {
            // Try full_name first, then first_name + last_name, then first_name only
            if (profileResponse['full_name'] != null && (profileResponse['full_name'] as String).isNotEmpty) {
              otherUserName = profileResponse['full_name'] as String;
            } else if (profileResponse['first_name'] != null) {
              final firstName = profileResponse['first_name'] as String;
              final lastName = profileResponse['last_name'] as String?;
              otherUserName = lastName != null ? '$firstName $lastName' : firstName;
            }
            otherUserAvatar = profileResponse['avatar_url'] as String?;
          }
        } catch (e) {
          // If profile fetch fails, continue without profile info
          print('Failed to fetch profile for user $otherUserId: $e');
        }
      }

      // Build conversation object
      conversations.add({
        'barter_id': barterId,
        'user1_id': barter['requester_id'],
        'user2_id': barter['owner_id'],
        'last_message': lastMessage,
        'unread_count': unreadCount,
        'last_message_at': lastMessage?['created_at'],
        'other_user_id': otherUserId,
        'other_user_name': otherUserName,
        'other_user_avatar': otherUserAvatar,
      });
    }

    // Sort by last message time
    conversations.sort((a, b) {
      final aTime = a['last_message_at'] as String?;
      final bTime = b['last_message_at'] as String?;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return conversations;
  }

  /// Mark messages as read
  Future<void> markAsRead({required String barterId}) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await _client
        .from(ApiRoutes.messagesTable)
        .update({'is_read': true})
        .eq('barter_id', barterId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }

  /// Get total unread message count for user
  Future<int> getUnreadCount() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client
        .from(ApiRoutes.messagesTable)
        .select('id')
        .eq('receiver_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count;
  }

  /// Get a specific conversation
  Future<Map<String, dynamic>> getConversation(String barterId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get barter details
    final barter = await _client
        .from(ApiRoutes.barterRequestsTable)
        .select()
        .eq('id', barterId)
        .single();

    // Determine who the other user is
    final requesterId = barter['requester_id'] as String?;
    final ownerId = barter['owner_id'] as String?;
    final otherUserId = userId == requesterId ? ownerId : requesterId;

    // Get last message
    final lastMessageResponse = await _client
        .from(ApiRoutes.messagesTable)
        .select()
        .eq('barter_id', barterId)
        .order('created_at', ascending: false)
        .limit(1);

    final lastMessages = List<Map<String, dynamic>>.from(lastMessageResponse as List);
    final lastMessage = lastMessages.isNotEmpty ? lastMessages.first : null;

    // Get unread count
    final unreadResponse = await _client
        .from(ApiRoutes.messagesTable)
        .select('id')
        .eq('barter_id', barterId)
        .eq('receiver_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);

    // Get other user's profile information
    String? otherUserName;
    String? otherUserAvatar;

    if (otherUserId != null) {
      try {
        final profileResponse = await _client
            .from('profiles')
            .select('first_name, last_name, full_name, avatar_url')
            .eq('id', otherUserId)
            .maybeSingle();

        if (profileResponse != null) {
          // Try full_name first, then first_name + last_name, then first_name only
          if (profileResponse['full_name'] != null && (profileResponse['full_name'] as String).isNotEmpty) {
            otherUserName = profileResponse['full_name'] as String;
          } else if (profileResponse['first_name'] != null) {
            final firstName = profileResponse['first_name'] as String;
            final lastName = profileResponse['last_name'] as String?;
            otherUserName = lastName != null ? '$firstName $lastName' : firstName;
          }
          otherUserAvatar = profileResponse['avatar_url'] as String?;
        }
      } catch (e) {
        // If profile fetch fails, continue without profile info
        print('Failed to fetch profile for user $otherUserId: $e');
      }
    }

    return {
      'barter_id': barterId,
      'user1_id': barter['requester_id'],
      'user2_id': barter['owner_id'],
      'last_message': lastMessage,
      'unread_count': unreadResponse.count ?? 0,
      'last_message_at': lastMessage?['created_at'],
      'other_user_id': otherUserId,
      'other_user_name': otherUserName,
      'other_user_avatar': otherUserAvatar,
    };
  }

  /// Subscribe to real-time messages for a barter
  RealtimeChannel subscribeToMessages({
    required String barterId,
    required Function(Map<String, dynamic>) onNewMessage,
  }) {
    final channel = _client
        .channel('messages:$barterId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: ApiRoutes.messagesTable,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'barter_id',
            value: barterId,
          ),
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}
