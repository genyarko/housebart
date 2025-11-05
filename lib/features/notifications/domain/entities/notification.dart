import 'package:equatable/equatable.dart';

/// Entity representing a user notification
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'barter', 'message', 'verification', 'review', etc.
  final String? relatedId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  /// Check if notification is unread
  bool get isUnread => !isRead;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        relatedId,
        isRead,
        readAt,
        createdAt,
      ];
}
