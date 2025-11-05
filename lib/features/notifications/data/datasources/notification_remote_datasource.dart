import '../../../../services/notification_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    int offset = 0,
  });
  Future<int> getUnreadCount();
  Future<void> markAsRead({required String notificationId});
  Future<void> markAllAsRead();
  Future<void> deleteNotification({required String notificationId});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final NotificationService notificationService;

  NotificationRemoteDataSourceImpl({required this.notificationService});

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await notificationService.getNotifications(
      limit: limit,
      offset: offset,
    );
    return data.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    return await notificationService.getUnreadCount();
  }

  @override
  Future<void> markAsRead({required String notificationId}) async {
    await notificationService.markAsRead(notificationId: notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await notificationService.markAllAsRead();
  }

  @override
  Future<void> deleteNotification({required String notificationId}) async {
    await notificationService.deleteNotification(
      notificationId: notificationId,
    );
  }
}
