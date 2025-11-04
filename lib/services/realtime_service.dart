import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling real-time subscriptions with Supabase
class RealtimeService {
  final SupabaseClient _client = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  /// Subscribe to messages for a specific barter request
  void subscribeToMessages({
    required String barterId,
    required Function(Map<String, dynamic>) onNewMessage,
  }) {
    final channel = _client.channel('messages-$barterId').onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'barter_request_id',
            value: barterId,
          ),
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        ).subscribe();

    _channels['messages-$barterId'] = channel;
  }

  /// Subscribe to barter request updates
  void subscribeToBarterUpdates({
    required String barterId,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    final channel = _client.channel('barter-$barterId').onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'barter_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: barterId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        ).subscribe();

    _channels['barter-$barterId'] = channel;
  }

  /// Subscribe to user notifications
  void subscribeToNotifications({
    required String userId,
    required Function(Map<String, dynamic>) onNewNotification,
  }) {
    final channel = _client.channel('notifications-$userId').onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onNewNotification(payload.newRecord);
          },
        ).subscribe();

    _channels['notifications-$userId'] = channel;
  }

  /// Subscribe to property updates (for property owners)
  void subscribeToPropertyUpdates({
    required String propertyId,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    final channel = _client.channel('property-$propertyId').onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'properties',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: propertyId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        ).subscribe();

    _channels['property-$propertyId'] = channel;
  }

  /// Subscribe to new barter requests for user's properties
  void subscribeToNewBarterRequests({
    required String userId,
    required Function(Map<String, dynamic>) onNewRequest,
  }) {
    // This requires a more complex query
    // We need to subscribe to barter_requests where target_property_id
    // belongs to properties owned by the user
    // This might require a custom RPC function or filtering on the client side

    final channel = _client.channel('new-barters-$userId').onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'barter_requests',
          callback: (payload) {
            // Client-side filtering might be needed here
            onNewRequest(payload.newRecord);
          },
        ).subscribe();

    _channels['new-barters-$userId'] = channel;
  }

  /// Unsubscribe from a specific channel
  void unsubscribe(String channelName) {
    final channel = _channels[channelName];
    if (channel != null) {
      _client.removeChannel(channel);
      _channels.remove(channelName);
    }
  }

  /// Unsubscribe from messages channel
  void unsubscribeFromMessages(String barterId) {
    unsubscribe('messages-$barterId');
  }

  /// Unsubscribe from barter updates channel
  void unsubscribeFromBarterUpdates(String barterId) {
    unsubscribe('barter-$barterId');
  }

  /// Unsubscribe from notifications channel
  void unsubscribeFromNotifications(String userId) {
    unsubscribe('notifications-$userId');
  }

  /// Unsubscribe from property updates channel
  void unsubscribeFromPropertyUpdates(String propertyId) {
    unsubscribe('property-$propertyId');
  }

  /// Unsubscribe from new barter requests channel
  void unsubscribeFromNewBarterRequests(String userId) {
    unsubscribe('new-barters-$userId');
  }

  /// Dispose all subscriptions
  void dispose() {
    for (final channel in _channels.values) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }

  /// Get active channels count
  int get activeChannelsCount => _channels.length;

  /// Check if a channel is active
  bool isChannelActive(String channelName) {
    return _channels.containsKey(channelName);
  }
}
