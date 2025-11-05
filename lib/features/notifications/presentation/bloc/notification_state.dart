import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool hasMore;
  final bool isLoadingMore;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, isLoadingMore];

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  const NotificationActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
