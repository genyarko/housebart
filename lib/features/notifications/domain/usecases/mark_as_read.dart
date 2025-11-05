import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAsRead implements UseCase<void, MarkAsReadParams> {
  final NotificationRepository repository;

  MarkAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    return await repository.markAsRead(notificationId: params.notificationId);
  }
}

class MarkAsReadParams {
  final String notificationId;

  MarkAsReadParams({required this.notificationId});
}
