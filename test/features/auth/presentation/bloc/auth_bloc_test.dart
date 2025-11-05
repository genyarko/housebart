import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:housebart/core/errors/failures.dart';
import 'package:housebart/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:housebart/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:housebart/features/auth/domain/usecases/login_usecase.dart';
import 'package:housebart/features/auth/domain/usecases/logout_usecase.dart';
import 'package:housebart/features/auth/domain/usecases/register_usecase.dart';
import 'package:housebart/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:housebart/features/auth/presentation/bloc/auth_event.dart';
import 'package:housebart/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/test_fixtures.dart';
import 'auth_bloc_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  ForgotPasswordUseCase,
])
void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockForgotPasswordUseCase mockForgotPasswordUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockForgotPasswordUseCase = MockForgotPasswordUseCase();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      forgotPasswordUseCase: mockForgotPasswordUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when user is authenticated',
        build: () {
          when(mockGetCurrentUserUseCase(any))
              .thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(tUser),
        ],
        verify: (_) {
          verify(mockGetCurrentUserUseCase(NoParams()));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when user is not authenticated',
        build: () {
          when(mockGetCurrentUserUseCase(any))
              .thenAnswer((_) async => const Left(AuthenticationFailure()));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when network failure occurs',
        build: () {
          when(mockGetCurrentUserUseCase(any))
              .thenAnswer((_) async => const Left(NetworkFailure()));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
      );
    });

    group('AuthLoginRequested', () {
      const tEmail = tUserEmail;
      const tPassword = tUserPassword;

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login is successful',
        build: () {
          when(mockLoginUseCase(any))
              .thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(tUser),
        ],
        verify: (_) {
          verify(mockLoginUseCase(const LoginParams(
            email: tEmail,
            password: tPassword,
          )));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with invalid credentials',
        build: () {
          const tFailure = AuthenticationFailure('Invalid credentials');
          when(mockLoginUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid credentials'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when network failure occurs',
        build: () {
          const tFailure = NetworkFailure();
          when(mockLoginUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthLoginRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('No internet connection'),
        ],
      );
    });

    group('AuthRegisterRequested', () {
      const tEmail = tUserEmail;
      const tPassword = tUserPassword;
      const tFirstName = tUserFirstName;
      const tLastName = tUserLastName;

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when registration is successful',
        build: () {
          when(mockRegisterUseCase(any))
              .thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
        )),
        expect: () => [
          AuthLoading(),
          AuthAuthenticated(tUser),
        ],
        verify: (_) {
          verify(mockRegisterUseCase(const RegisterParams(
            email: tEmail,
            password: tPassword,
            firstName: tFirstName,
            lastName: tLastName,
          )));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when email is already in use',
        build: () {
          const tFailure = ValidationFailure('Email already in use');
          when(mockRegisterUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Email already in use'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when server error occurs',
        build: () {
          const tFailure = ServerFailure('Registration failed');
          when(mockRegisterUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthRegisterRequested(
          email: tEmail,
          password: tPassword,
          firstName: tFirstName,
          lastName: tLastName,
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Registration failed'),
        ],
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
        build: () {
          when(mockLogoutUseCase(any))
              .thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(mockLogoutUseCase(NoParams()));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when logout fails',
        build: () {
          const tFailure = ServerFailure('Logout failed');
          when(mockLogoutUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          AuthLoading(),
          const AuthError('Logout failed'),
        ],
      );
    });

    group('AuthForgotPasswordRequested', () {
      const tEmail = tUserEmail;

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthPasswordResetEmailSent] when password reset email is sent',
        build: () {
          when(mockForgotPasswordUseCase(any))
              .thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthForgotPasswordRequested(email: tEmail)),
        expect: () => [
          AuthLoading(),
          const AuthPasswordResetEmailSent(tEmail),
        ],
        verify: (_) {
          verify(mockForgotPasswordUseCase(
              const ForgotPasswordParams(email: tEmail)));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when email is not found',
        build: () {
          const tFailure = ValidationFailure('Email not found');
          when(mockForgotPasswordUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthForgotPasswordRequested(email: tEmail)),
        expect: () => [
          AuthLoading(),
          const AuthError('Email not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when network failure occurs',
        build: () {
          const tFailure = NetworkFailure();
          when(mockForgotPasswordUseCase(any))
              .thenAnswer((_) async => const Left(tFailure));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthForgotPasswordRequested(email: tEmail)),
        expect: () => [
          AuthLoading(),
          const AuthError('No internet connection'),
        ],
      );
    });
  });
}
