import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class DeleteNotification implements UseCase<void, DeleteNotificationParams> {
  final NotificationRepository repository;

  DeleteNotification(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) async {
    return await repository.deleteNotification(notificationId: params.notificationId);
  }
}

class DeleteNotificationParams {
  final String notificationId;

  DeleteNotificationParams({required this.notificationId});
}
