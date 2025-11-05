import '../../domain/entities/conversation.dart';
import 'message_model.dart';

/// Model for Conversation with JSON serialization
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.barterId,
    required super.user1Id,
    required super.user2Id,
    super.lastMessage,
    super.unreadCount,
    super.lastMessageAt,
  });

  /// Create ConversationModel from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      barterId: json['barter_id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
    );
  }

  /// Convert ConversationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'barter_id': barterId,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': lastMessage != null
          ? (lastMessage as MessageModel).toJson()
          : null,
      'unread_count': unreadCount,
      'last_message_at': lastMessageAt?.toIso8601String(),
    };
  }

  /// Convert model to entity
  Conversation toEntity() {
    return Conversation(
      barterId: barterId,
      user1Id: user1Id,
      user2Id: user2Id,
      lastMessage: lastMessage,
      unreadCount: unreadCount,
      lastMessageAt: lastMessageAt,
    );
  }

  /// Create model from entity
  factory ConversationModel.fromEntity(Conversation entity) {
    return ConversationModel(
      barterId: entity.barterId,
      user1Id: entity.user1Id,
      user2Id: entity.user2Id,
      lastMessage: entity.lastMessage,
      unreadCount: entity.unreadCount,
      lastMessageAt: entity.lastMessageAt,
    );
  }
}
