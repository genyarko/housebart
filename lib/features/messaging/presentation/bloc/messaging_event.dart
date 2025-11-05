import 'package:equatable/equatable.dart';

/// Base class for messaging events
abstract class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to send a message
class MessagingSendMessageEvent extends MessagingEvent {
  final String barterId;
  final String receiverId;
  final String content;

  const MessagingSendMessageEvent({
    required this.barterId,
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object?> get props => [barterId, receiverId, content];
}

/// Event to load messages
class MessagingLoadMessagesEvent extends MessagingEvent {
  final String barterId;

  const MessagingLoadMessagesEvent(this.barterId);

  @override
  List<Object?> get props => [barterId];
}

/// Event to load conversations
class MessagingLoadConversationsEvent extends MessagingEvent {
  const MessagingLoadConversationsEvent();
}

/// Event to mark messages as read
class MessagingMarkAsReadEvent extends MessagingEvent {
  final String barterId;

  const MessagingMarkAsReadEvent(this.barterId);

  @override
  List<Object?> get props => [barterId];
}

/// Event for new message received via real-time
class MessagingNewMessageReceivedEvent extends MessagingEvent {
  final String barterId;

  const MessagingNewMessageReceivedEvent(this.barterId);

  @override
  List<Object?> get props => [barterId];
}
