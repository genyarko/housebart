import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/messaging_repository.dart';

/// Use case for getting messages in a conversation
class GetMessagesUseCase {
  final MessagingRepository repository;

  GetMessagesUseCase(this.repository);

  Future<Either<Failure, List<Message>>> call(GetMessagesParams params) async {
    return await repository.getMessages(
      barterId: params.barterId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetMessagesParams extends Equatable {
  final String barterId;
  final int limit;
  final int offset;

  const GetMessagesParams({
    required this.barterId,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [barterId, limit, offset];
}
