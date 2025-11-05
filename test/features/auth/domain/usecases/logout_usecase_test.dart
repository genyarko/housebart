import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:housebart/core/errors/failures.dart';
import 'package:housebart/features/auth/domain/repositories/auth_repository.dart';
import 'package:housebart/features/auth/domain/usecases/logout_usecase.dart';

import 'logout_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockAuthRepository);
  });

  group('LogoutUseCase', () {
    test('should call repository logout', () async {
      // Arrange
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase(NoParams());

      // Assert
      verify(mockAuthRepository.logout());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return Right(null) when logout is successful', () async {
      // Arrange
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, equals(const Right(null)));
    });

    test('should return ServerFailure when logout fails', () async {
      // Arrange
      const tFailure = ServerFailure('Logout failed');
      when(mockAuthRepository.logout())
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
      when(mockAuthRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, equals(const Left(tFailure)));
    });
  });

  group('NoParams', () {
    test('should have empty props', () {
      final params = NoParams();
      expect(params.props, isEmpty);
    });

    test('should support equality', () {
      final params1 = NoParams();
      final params2 = NoParams();
      expect(params1, equals(params2));
    });
  });
}
