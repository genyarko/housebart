import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/messaging_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Remote datasource for messaging operations
abstract class MessagingRemoteDataSource {
  Future<MessageModel> sendMessage({
    required String barterId,
    required String receiverId,
    required String content,
  });

  Future<List<MessageModel>> getMessages({
    required String barterId,
    int limit = 50,
    int offset = 0,
  });

  Future<List<ConversationModel>> getConversations();

  Future<void> markAsRead({required String barterId});

  Future<int> getUnreadCount();

  Future<ConversationModel> getConversation(String barterId);

  RealtimeChannel subscribeToMessages({
    required String barterId,
    required Function(MessageModel) onNewMessage,
  });

  Future<void> unsubscribeFromChannel(RealtimeChannel channel);
}

/// Implementation of MessagingRemoteDataSource
class MessagingRemoteDataSourceImpl implements MessagingRemoteDataSource {
  final MessagingService messagingService;

  MessagingRemoteDataSourceImpl({required this.messagingService});

  @override
  Future<MessageModel> sendMessage({
    required String barterId,
    required String receiverId,
    required String content,
  }) async {
    final messageData = await messagingService.sendMessage(
      barterId: barterId,
      receiverId: receiverId,
      content: content,
    );

    return MessageModel.fromJson(messageData);
  }

  @override
  Future<List<MessageModel>> getMessages({
    required String barterId,
    int limit = 50,
    int offset = 0,
  }) async {
    final messagesData = await messagingService.getMessages(
      barterId: barterId,
      limit: limit,
      offset: offset,
    );

    return messagesData.map((data) => MessageModel.fromJson(data)).toList();
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final conversationsData = await messagingService.getConversations();

    return conversationsData
        .map((data) => ConversationModel.fromJson(data))
        .toList();
  }

  @override
  Future<void> markAsRead({required String barterId}) async {
    await messagingService.markAsRead(barterId: barterId);
  }

  @override
  Future<int> getUnreadCount() async {
    return await messagingService.getUnreadCount();
  }

  @override
  Future<ConversationModel> getConversation(String barterId) async {
    final conversationData = await messagingService.getConversation(barterId);
    return ConversationModel.fromJson(conversationData);
  }

  @override
  RealtimeChannel subscribeToMessages({
    required String barterId,
    required Function(MessageModel) onNewMessage,
  }) {
    return messagingService.subscribeToMessages(
      barterId: barterId,
      onNewMessage: (data) {
        onNewMessage(MessageModel.fromJson(data));
      },
    );
  }

  @override
  Future<void> unsubscribeFromChannel(RealtimeChannel channel) async {
    await messagingService.unsubscribeFromChannel(channel);
  }
}
