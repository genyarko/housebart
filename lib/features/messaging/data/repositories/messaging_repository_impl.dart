import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../datasources/messaging_remote_datasource.dart';

/// Implementation of messaging repository
class MessagingRepositoryImpl implements MessagingRepository {
  final MessagingRemoteDataSource remoteDataSource;

  MessagingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String barterId,
    required String receiverId,
    required String content,
  }) async {
    try {
      final messageModel = await remoteDataSource.sendMessage(
        barterId: barterId,
        receiverId: receiverId,
        content: content,
      );

      return Right(messageModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Failed to send message: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages({
    required String barterId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messageModels = await remoteDataSource.getMessages(
        barterId: barterId,
        limit: limit,
        offset: offset,
      );

      final messages = messageModels.map((model) => model.toEntity()).toList();
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get messages: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final conversationModels = await remoteDataSource.getConversations();

      final conversations =
          conversationModels.map((model) => model.toEntity()).toList();
      return Right(conversations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get conversations: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({required String barterId}) async {
    try {
      await remoteDataSource.markAsRead(barterId: barterId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to mark as read: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get unread count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Conversation>> getConversation(
    String barterId,
  ) async {
    try {
      final conversationModel =
          await remoteDataSource.getConversation(barterId);
      return Right(conversationModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get conversation: ${e.toString()}'));
    }
  }

  @override
  Stream<Message> subscribeToMessages(String barterId) {
    // This will be implemented in the presentation layer via BLoC
    // For now, return empty stream
    return const Stream.empty();
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromMessages() async {
    // Handled in presentation layer
    return const Right(null);
  }
}
