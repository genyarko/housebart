import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'messaging_event.dart';
import 'messaging_state.dart';

/// BLoC for managing messaging state
class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final SendMessageUseCase sendMessageUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final GetConversationsUseCase getConversationsUseCase;
  final MarkAsReadUseCase markAsReadUseCase;

  MessagingBloc({
    required this.sendMessageUseCase,
    required this.getMessagesUseCase,
    required this.getConversationsUseCase,
    required this.markAsReadUseCase,
  }) : super(const MessagingInitial()) {
    on<MessagingSendMessageEvent>(_onSendMessage);
    on<MessagingLoadMessagesEvent>(_onLoadMessages);
    on<MessagingLoadConversationsEvent>(_onLoadConversations);
    on<MessagingMarkAsReadEvent>(_onMarkAsRead);
    on<MessagingNewMessageReceivedEvent>(_onNewMessageReceived);
  }

  Future<void> _onSendMessage(
    MessagingSendMessageEvent event,
    Emitter<MessagingState> emit,
  ) async {
    final result = await sendMessageUseCase(
      SendMessageParams(
        barterId: event.barterId,
        receiverId: event.receiverId,
        content: event.content,
      ),
    );

    result.fold(
      (failure) => emit(MessagingError(failure.message)),
      (message) {
        // Reload messages after sending to keep the list updated
        add(MessagingLoadMessagesEvent(event.barterId));
      },
    );
  }

  Future<void> _onLoadMessages(
    MessagingLoadMessagesEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(const MessagingLoading());

    final result = await getMessagesUseCase(
      GetMessagesParams(barterId: event.barterId),
    );

    result.fold(
      (failure) => emit(MessagingError(failure.message)),
      (messages) {
        if (messages.isEmpty) {
          emit(const MessagingEmpty('No messages yet'));
        } else {
          emit(MessagingMessagesLoaded(messages));
        }
      },
    );
  }

  Future<void> _onLoadConversations(
    MessagingLoadConversationsEvent event,
    Emitter<MessagingState> emit,
  ) async {
    emit(const MessagingLoading());

    final result = await getConversationsUseCase();

    result.fold(
      (failure) => emit(MessagingError(failure.message)),
      (conversations) {
        if (conversations.isEmpty) {
          emit(const MessagingEmpty('No conversations yet'));
        } else {
          emit(MessagingConversationsLoaded(conversations));
        }
      },
    );
  }

  Future<void> _onMarkAsRead(
    MessagingMarkAsReadEvent event,
    Emitter<MessagingState> emit,
  ) async {
    await markAsReadUseCase(event.barterId);
  }

  Future<void> _onNewMessageReceived(
    MessagingNewMessageReceivedEvent event,
    Emitter<MessagingState> emit,
  ) async {
    // Reload messages when new message is received
    add(MessagingLoadMessagesEvent(event.barterId));
  }
}
