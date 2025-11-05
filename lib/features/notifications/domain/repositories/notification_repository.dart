import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    int limit = 50,
    int offset = 0,
  });

  /// Get unread notifications count
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead({required String notificationId});

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification({required String notificationId});

  /// Create a notification (typically done by backend, but useful for testing)
  Future<Either<Failure, NotificationEntity>> createNotification({
    required String title,
    required String message,
    required String type,
    String? relatedId,
  });
}
