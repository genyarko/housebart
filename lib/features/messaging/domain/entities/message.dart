import 'package:equatable/equatable.dart';

/// Entity representing a message in a conversation
class Message extends Equatable {
  final String id;
  final String barterId; // The barter request this message belongs to
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.barterId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
  });

  @override
  List<Object?> get props => [
        id,
        barterId,
        senderId,
        receiverId,
        content,
        createdAt,
        isRead,
      ];

  /// Create a copy with updated fields
  Message copyWith({
    String? id,
    String? barterId,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      barterId: barterId ?? this.barterId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Check if the message is sent by the given user
  bool isSentBy(String userId) => senderId == userId;

  /// Check if the message is received by the given user
  bool isReceivedBy(String userId) => receiverId == userId;
}
