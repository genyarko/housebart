import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';

/// Base class for messaging states
abstract class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MessagingInitial extends MessagingState {
  const MessagingInitial();
}

/// Loading state
class MessagingLoading extends MessagingState {
  const MessagingLoading();
}

/// State when messages are loaded
class MessagingMessagesLoaded extends MessagingState {
  final List<Message> messages;

  const MessagingMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// State when conversations are loaded
class MessagingConversationsLoaded extends MessagingState {
  final List<Conversation> conversations;

  const MessagingConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

/// State when message is sent
class MessagingMessageSent extends MessagingState {
  final Message message;

  const MessagingMessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class MessagingError extends MessagingState {
  final String message;

  const MessagingError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state
class MessagingEmpty extends MessagingState {
  final String? message;

  const MessagingEmpty([this.message]);

  @override
  List<Object?> get props => [message];
}
