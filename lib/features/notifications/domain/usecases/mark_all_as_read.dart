import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAllAsRead implements UseCase<void, NoParams> {
  final NotificationRepository repository;

  MarkAllAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.markAllAsRead();
  }
}
