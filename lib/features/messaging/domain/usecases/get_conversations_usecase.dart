import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/conversation.dart';
import '../repositories/messaging_repository.dart';

/// Use case for getting all conversations
class GetConversationsUseCase {
  final MessagingRepository repository;

  GetConversationsUseCase(this.repository);

  Future<Either<Failure, List<Conversation>>> call() async {
    return await repository.getConversations();
  }
}
