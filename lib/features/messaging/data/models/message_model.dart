import '../../domain/entities/message.dart';

/// Model for Message with JSON serialization
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.barterId,
    required super.senderId,
    required super.receiverId,
    required super.content,
    required super.createdAt,
    required super.isRead,
  });

  /// Create MessageModel from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      barterId: json['barter_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool,
    );
  }

  /// Convert MessageModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barter_id': barterId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  /// Convert model to entity
  Message toEntity() {
    return Message(
      id: id,
      barterId: barterId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      createdAt: createdAt,
      isRead: isRead,
    );
  }

  /// Create model from entity
  factory MessageModel.fromEntity(Message entity) {
    return MessageModel(
      id: entity.id,
      barterId: entity.barterId,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      content: entity.content,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }
}
