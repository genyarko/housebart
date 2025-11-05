import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:housebart/core/errors/failures.dart';
import 'package:housebart/features/auth/domain/repositories/auth_repository.dart';
import 'package:housebart/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:housebart/features/auth/domain/usecases/logout_usecase.dart';

import '../../../../helpers/test_fixtures.dart';
import 'get_current_user_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockAuthRepository);
  });

  group('GetCurrentUserUseCase', () {
    test('should call repository getCurrentUser', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUser));

      // Act
      await useCase(NoParams());

      // Assert
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return User when current user exists', () async {
      // Arrange
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, equals(Right(tUser)));
    });

    test('should return AuthenticationFailure when user is not authenticated',
        () async {
      // Arrange
      const tFailure = AuthenticationFailure('User not authenticated');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, equals(const Left(tFailure)));
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const tFailure = NetworkFailure();
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, equals(const Left(tFailure)));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const tFailure = ServerFailure('Internal server error');
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, equals(const Left(tFailure)));
    });
  });
}
