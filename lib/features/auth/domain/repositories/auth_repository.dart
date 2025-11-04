import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Authentication repository interface
/// Defines the contract for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Sign out current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Check if user is logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Send password reset email
  Future<Either<Failure, void>> forgotPassword(String email);

  /// Update password
  Future<Either<Failure, void>> updatePassword(String newPassword);

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
  });

  /// Update avatar
  Future<Either<Failure, String>> updateAvatar(String imagePath);
}
