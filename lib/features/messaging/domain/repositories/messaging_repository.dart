import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// Repository interface for messaging operations
abstract class MessagingRepository {
  /// Send a message in a barter conversation
  Future<Either<Failure, Message>> sendMessage({
    required String barterId,
    required String receiverId,
    required String content,
  });

  /// Get all messages for a barter conversation
  Future<Either<Failure, List<Message>>> getMessages({
    required String barterId,
    int limit = 50,
    int offset = 0,
  });

  /// Get all conversations for the current user
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Mark messages as read
  Future<Either<Failure, void>> markAsRead({
    required String barterId,
  });

  /// Get unread message count for a user
  Future<Either<Failure, int>> getUnreadCount();

  /// Get a specific conversation
  Future<Either<Failure, Conversation>> getConversation(String barterId);

  /// Subscribe to new messages in a conversation
  Stream<Message> subscribeToMessages(String barterId);

  /// Unsubscribe from messages
  Future<Either<Failure, void>> unsubscribeFromMessages();
}
