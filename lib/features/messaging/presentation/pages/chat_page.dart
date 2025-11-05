import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/message.dart';
import '../bloc/messaging_bloc.dart';
import '../bloc/messaging_event.dart';
import '../bloc/messaging_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

/// Page for displaying and sending messages in a conversation
class ChatPage extends StatefulWidget {
  final String barterId;
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserAvatar;

  const ChatPage({
    super.key,
    required this.barterId,
    required this.otherUserId,
    this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  RealtimeChannel? _subscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;

    // Load messages
    context.read<MessagingBloc>().add(
          MessagingLoadMessagesEvent(widget.barterId),
        );

    // Mark messages as read
    context.read<MessagingBloc>().add(
          MessagingMarkAsReadEvent(widget.barterId),
        );

    // Subscribe to real-time messages
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToMessages() {
    _subscription = Supabase.instance.client
        .channel('messages:${widget.barterId}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'barter_id',
            value: widget.barterId,
          ),
          callback: (payload) {
            // Notify bloc of new message
            context.read<MessagingBloc>().add(
                  MessagingNewMessageReceivedEvent(widget.barterId),
                );

            // Mark as read if not own message
            final senderId = payload.newRecord['sender_id'] as String?;
            if (senderId != null && senderId != _currentUserId) {
              context.read<MessagingBloc>().add(
                    MessagingMarkAsReadEvent(widget.barterId),
                  );
            }
          },
        )
        .subscribe();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage(String content) {
    context.read<MessagingBloc>().add(
          MessagingSendMessageEvent(
            barterId: widget.barterId,
            receiverId: widget.otherUserId,
            content: content,
          ),
        );
  }

  String _shouldShowAvatar(List<Message> messages, int index) {
    if (index == 0) return 'show';

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    // Show avatar if sender changed
    if (currentMessage.senderId != previousMessage.senderId) {
      return 'show';
    }

    // Show avatar if more than 5 minutes passed
    final timeDiff = currentMessage.createdAt.difference(previousMessage.createdAt);
    if (timeDiff.inMinutes > 5) {
      return 'show';
    }

    return 'hide';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: widget.otherUserAvatar != null
                  ? NetworkImage(widget.otherUserAvatar!)
                  : null,
              child: widget.otherUserAvatar == null
                  ? Text(
                      widget.otherUserName?.isNotEmpty == true
                          ? widget.otherUserName![0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.otherUserName ?? 'Chat',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: BlocConsumer<MessagingBloc, MessagingState>(
              listener: (context, state) {
                if (state is MessagingMessagesLoaded ||
                    state is MessagingMessageSent) {
                  // Scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
              builder: (context, state) {
                if (state is MessagingLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is MessagingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load messages',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<MessagingBloc>().add(
                                  MessagingLoadMessagesEvent(widget.barterId),
                                );
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                List<Message> messages = [];
                if (state is MessagingMessagesLoaded) {
                  messages = state.messages;
                } else if (state is MessagingMessageSent) {
                  // Keep existing messages and add the sent one
                  // This is a simplified approach; in production you'd want better state management
                  messages = [state.message];
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isOwnMessage = message.senderId == _currentUserId;
                    final showAvatar = _shouldShowAvatar(messages, index) == 'show';

                    return MessageBubble(
                      message: message,
                      isOwnMessage: isOwnMessage,
                      showAvatar: showAvatar,
                      senderName: isOwnMessage ? 'You' : widget.otherUserName,
                      senderAvatar:
                          isOwnMessage ? null : widget.otherUserAvatar,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          ChatInput(
            onSend: _handleSendMessage,
            enabled: _currentUserId != null,
          ),
        ],
      ),
    );
  }
}
