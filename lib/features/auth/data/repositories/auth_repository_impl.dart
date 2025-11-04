import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache user locally
      await localDataSource.cacheUser(user);

      return Right(user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Cache user locally
      await localDataSource.cacheUser(user);

      return Right(user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Registration failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      // Clear local cache
      await localDataSource.clearCache();

      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Logout failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser();

      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // If not cached, fetch from remote
      final user = await remoteDataSource.getCurrentUser();

      // Cache for next time
      await localDataSource.cacheUser(user);

      return Right(user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } on CacheException catch (e) {
      // If cache fails, try remote
      try {
        final user = await remoteDataSource.getCurrentUser();
        return Right(user.toEntity());
      } catch (remoteError) {
        return Left(CacheFailure(e.message, e.code));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await remoteDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Password reset failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Password update failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
  }) async {
    try {
      final user = await remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        bio: bio,
      );

      // Update cache
      await localDataSource.cacheUser(user);

      return Right(user.toEntity());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message, e.code));
    } catch (e) {
      return Left(ServerFailure('Profile update failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> updateAvatar(String imagePath) async {
    // TODO: Implement avatar upload to Supabase Storage
    // This will be implemented when we add the storage service
    return const Left(ServerFailure('Avatar upload not yet implemented'));
  }
}
