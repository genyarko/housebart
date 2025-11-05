import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications implements UseCase<List<NotificationEntity>, GetNotificationsParams> {
  final NotificationRepository repository;

  GetNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(GetNotificationsParams params) async {
    return await repository.getNotifications(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetNotificationsParams {
  final int limit;
  final int offset;

  GetNotificationsParams({
    this.limit = 50,
    this.offset = 0,
  });
}
