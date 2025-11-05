import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:housebart/core/errors/failures.dart';
import 'package:housebart/features/auth/domain/entities/user.dart';
import 'package:housebart/features/auth/domain/repositories/auth_repository.dart';
import 'package:housebart/features/auth/domain/usecases/register_usecase.dart';

import '../../../../helpers/test_fixtures.dart';
import 'register_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockAuthRepository);
  });

  group('RegisterUseCase', () {
    const tParams = RegisterParams(
      email: tUserEmail,
      password: tUserPassword,
      firstName: tUserFirstName,
      lastName: tUserLastName,
    );

    test('should call repository register with correct parameters', () async {
      // Arrange
      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => Right(tUser));

      // Act
      await useCase(tParams);

      // Assert
      verify(mockAuthRepository.register(
        email: tUserEmail,
        password: tUserPassword,
        firstName: tUserFirstName,
        lastName: tUserLastName,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return User when registration is successful', () async {
      // Arrange
      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => Right(tUser));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(Right(tUser)));
    });

    test('should return ValidationFailure when email is already in use',
        () async {
      // Arrange
      const tFailure = ValidationFailure('Email already in use');
      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // Arrange
      const tFailure = NetworkFailure();
      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });

    test('should return ServerFailure when server error occurs', () async {
      // Arrange
      const tFailure = ServerFailure('Internal server error');
      when(mockAuthRepository.register(
        email: anyNamed('email'),
        password: anyNamed('password'),
        firstName: anyNamed('firstName'),
        lastName: anyNamed('lastName'),
      )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(tParams);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });
  });

  group('RegisterParams', () {
    test('should support equality', () {
      const params1 = RegisterParams(
        email: 'test@example.com',
        password: 'pass',
        firstName: 'John',
        lastName: 'Doe',
      );
      const params2 = RegisterParams(
        email: 'test@example.com',
        password: 'pass',
        firstName: 'John',
        lastName: 'Doe',
      );
      const params3 = RegisterParams(
        email: 'other@example.com',
        password: 'pass',
        firstName: 'John',
        lastName: 'Doe',
      );

      expect(params1, equals(params2));
      expect(params1, isNot(equals(params3)));
    });

    test('should contain all fields in props', () {
      const params = RegisterParams(
        email: 'test@example.com',
        password: 'pass',
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(params.props, contains('test@example.com'));
      expect(params.props, contains('pass'));
      expect(params.props, contains('John'));
      expect(params.props, contains('Doe'));
    });
  });
}
