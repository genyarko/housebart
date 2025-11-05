import 'package:equatable/equatable.dart';
import 'message.dart';

/// Entity representing a conversation between two users about a barter
class Conversation extends Equatable {
  final String barterId;
  final String user1Id;
  final String user2Id;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;

  const Conversation({
    required this.barterId,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageAt,
  });

  @override
  List<Object?> get props => [
        barterId,
        user1Id,
        user2Id,
        lastMessage,
        unreadCount,
        lastMessageAt,
      ];

  /// Get the other user's ID given current user ID
  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  /// Check if the conversation has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  /// Create a copy with updated fields
  Conversation copyWith({
    String? barterId,
    String? user1Id,
    String? user2Id,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastMessageAt,
  }) {
    return Conversation(
      barterId: barterId ?? this.barterId,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    );
  }
}
