import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/message.dart';
import '../repositories/messaging_repository.dart';

/// Use case for sending a message
class SendMessageUseCase {
  final MessagingRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    return await repository.sendMessage(
      barterId: params.barterId,
      receiverId: params.receiverId,
      content: params.content,
    );
  }
}

class SendMessageParams extends Equatable {
  final String barterId;
  final String receiverId;
  final String content;

  const SendMessageParams({
    required this.barterId,
    required this.receiverId,
    required this.content,
  });

  @override
  List<Object?> get props => [barterId, receiverId, content];
}
