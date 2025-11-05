import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class GetUnreadCount implements UseCase<int, NoParams> {
  final NotificationRepository repository;

  GetUnreadCount(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    return await repository.getUnreadCount();
  }
}
