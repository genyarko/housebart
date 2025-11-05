import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:housebart/core/errors/failures.dart';
import 'package:housebart/features/auth/domain/repositories/auth_repository.dart';
import 'package:housebart/features/auth/domain/usecases/forgot_password_usecase.dart';

import '../../../../helpers/test_fixtures.dart';
import 'forgot_password_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late ForgotPasswordUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = ForgotPasswordUseCase(mockAuthRepository);
  });

  group('ForgotPasswordUseCase', () {
    const tParams = ForgotPasswordParams(email: tUserEmail);

    test('should call repository forgotPassword with correct email', () async {
      // Arrange
      when(mockAuthRepository.forgotPassword(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(tParams);

      // Assert
      verify(mockAuthRepository.forgotPassword(tUserEmail));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Right(null) when password reset email is sent successfully',
        () async {
      // Arrange
      when(mockAuthRepository.forgotPassword(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Right(null)));
    });

    test('should return ValidationFailure when email is not found', () async {
      // Arrange
      const tFailure = ValidationFailure('Email not found');
      when(mockAuthRepository.forgotPassword(any))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const tFailure = NetworkFailure();
      when(mockAuthRepository.forgotPassword(any))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const tFailure = ServerFailure('Internal server error');
      when(mockAuthRepository.forgotPassword(any))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });
  });

  group('ForgotPasswordParams', () {
    test('should support equality', () {
      const params1 = ForgotPasswordParams(email: 'test@example.com');
      const params2 = ForgotPasswordParams(email: 'test@example.com');
      const params3 = ForgotPasswordParams(email: 'other@example.com');

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should contain email in props', () {
      const params = ForgotPasswordParams(email: 'test@example.com');
      expect(params.props, contains('test@example.com'));
    });
  });
}
