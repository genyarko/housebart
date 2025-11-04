import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging out the current user
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}

/// No parameters needed for logout
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}
