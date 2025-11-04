import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/messaging_repository.dart';

/// Use case for marking messages as read
class MarkAsReadUseCase {
  final MessagingRepository repository;

  MarkAsReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String barterId) async {
    return await repository.markAsRead(barterId: barterId);
  }
}
