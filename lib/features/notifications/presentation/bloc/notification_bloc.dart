import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/delete_notification.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/get_unread_count.dart';
import '../../domain/usecases/mark_all_as_read.dart';
import '../../domain/usecases/mark_as_read.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotifications getNotifications;
  final GetUnreadCount getUnreadCount;
  final MarkAsRead markAsRead;
  final MarkAllAsRead markAllAsRead;
  final DeleteNotification deleteNotification;

  static const int _pageSize = 50;
  int _currentOffset = 0;

  NotificationBloc({
    required this.getNotifications,
    required this.getUnreadCount,
    required this.markAsRead,
    required this.markAllAsRead,
    required this.deleteNotification,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<RefreshUnreadCount>(_onRefreshUnreadCount);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (event.refresh) {
      _currentOffset = 0;
    }

    emit(NotificationLoading());

    final notificationsResult = await getNotifications(
      GetNotificationsParams(limit: _pageSize, offset: 0),
    );

    final unreadCountResult = await getUnreadCount(NoParams());

    await notificationsResult.fold(
      (failure) async {
        emit(NotificationError(message: failure.message));
      },
      (notifications) async {
        final unreadCount = await unreadCountResult.fold(
          (failure) => 0,
          (count) => count,
        );

        _currentOffset = notifications.length;

        emit(NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          hasMore: notifications.length >= _pageSize,
        ));
      },
    );
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      if (!currentState.hasMore || currentState.isLoadingMore) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      final result = await getNotifications(
        GetNotificationsParams(limit: _pageSize, offset: _currentOffset),
      );

      await result.fold(
        (failure) async {
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (newNotifications) async {
          _currentOffset += newNotifications.length;

          final updatedNotifications = [
            ...currentState.notifications,
            ...newNotifications,
          ];

          emit(NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: currentState.unreadCount,
            hasMore: newNotifications.length >= _pageSize,
            isLoadingMore: false,
          ));
        },
      );
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final result = await markAsRead(
        MarkAsReadParams(notificationId: event.notificationId),
      );

      await result.fold(
        (failure) async {
          emit(NotificationError(message: failure.message));
          emit(currentState);
        },
        (_) async {
          // Update the notification in the list
          final updatedNotifications = currentState.notifications.map((notif) {
            if (notif.id == event.notificationId) {
              return NotificationEntity(
                id: notif.id,
                userId: notif.userId,
                title: notif.title,
                message: notif.message,
                type: notif.type,
                relatedId: notif.relatedId,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: notif.createdAt,
              );
            }
            return notif;
          }).toList();

          // Decrease unread count if notification was unread
          final notification = currentState.notifications.firstWhere(
            (n) => n.id == event.notificationId,
          );
          final newUnreadCount = notification.isUnread
              ? currentState.unreadCount - 1
              : currentState.unreadCount;

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ));
        },
      );
    }
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final result = await markAllAsRead(NoParams());

      await result.fold(
        (failure) async {
          emit(NotificationError(message: failure.message));
          emit(currentState);
        },
        (_) async {
          // Mark all notifications as read
          final updatedNotifications = currentState.notifications.map((notif) {
            return NotificationEntity(
              id: notif.id,
              userId: notif.userId,
              title: notif.title,
              message: notif.message,
              type: notif.type,
              relatedId: notif.relatedId,
              isRead: true,
              readAt: notif.readAt ?? DateTime.now(),
              createdAt: notif.createdAt,
            );
          }).toList();

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ));

          emit(const NotificationActionSuccess(
            message: 'All notifications marked as read',
          ));

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ));
        },
      );
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final result = await deleteNotification(
        DeleteNotificationParams(notificationId: event.notificationId),
      );

      await result.fold(
        (failure) async {
          emit(NotificationError(message: failure.message));
          emit(currentState);
        },
        (_) async {
          // Remove notification from list
          final notification = currentState.notifications.firstWhere(
            (n) => n.id == event.notificationId,
          );

          final updatedNotifications = currentState.notifications
              .where((n) => n.id != event.notificationId)
              .toList();

          // Decrease unread count if notification was unread
          final newUnreadCount = notification.isUnread
              ? currentState.unreadCount - 1
              : currentState.unreadCount;

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshUnreadCount(
    RefreshUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      final result = await getUnreadCount(NoParams());

      await result.fold(
        (failure) async {
          // Silently fail, keep current state
        },
        (count) async {
          emit(currentState.copyWith(unreadCount: count));
        },
      );
    }
  }
}
