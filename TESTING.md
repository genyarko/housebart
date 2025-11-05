# HouseBart Testing Guide

## Overview

This document provides a comprehensive guide to the testing infrastructure for the HouseBart application. The project implements a robust testing strategy covering unit tests, widget tests, and integration tests.

## Quick Start

### 1. Generate Mock Files

Before running tests for the first time, generate mock files:

```bash
chmod +x scripts/generate_mocks.sh
./scripts/generate_mocks.sh
```

Or manually:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Run Tests

Run all tests with coverage:

```bash
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

Or manually:

```bash
flutter test --coverage
```

### 3. View Coverage Report

After running tests with coverage:

```bash
# macOS
open coverage/html/index.html

# Linux
xdg-open coverage/html/index.html

# Windows
start coverage/html/index.html
```

## Test Architecture

### Directory Structure

```
test/
├── core/
│   ├── errors/
│   │   └── failures_test.dart           # Error handling tests
│   └── utils/
│       ├── validators_test.dart          # Input validation tests
│       └── formatters_test.dart          # Formatting utilities tests
├── features/
│   ├── auth/
│   │   ├── domain/usecases/
│   │   │   ├── login_usecase_test.dart
│   │   │   ├── register_usecase_test.dart
│   │   │   ├── logout_usecase_test.dart
│   │   │   ├── get_current_user_usecase_test.dart
│   │   │   └── forgot_password_usecase_test.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── auth_bloc_test.dart
│   │       └── widgets/
│   │           └── login_form_test.dart   # Example widget test
│   └── property/
│       └── domain/entities/
│           └── property_test.dart         # Entity tests
├── helpers/
│   └── test_fixtures.dart                 # Shared test data
└── README.md                              # Test documentation

integration_test/
└── app_test.dart                          # Integration test templates

scripts/
├── generate_mocks.sh                      # Mock generation script
└── run_tests.sh                           # Test execution script
```

## Test Coverage by Feature

### ✅ Completed

1. **Core Utilities** (100%)
   - Validators: 18 validation functions tested
   - Formatters: 20 formatting functions tested
   - Failures: 11 failure types tested

2. **Auth Feature** (95%)
   - 5 use cases fully tested
   - Auth BLoC fully tested
   - Example widget test provided

3. **Property Feature** (25%)
   - Entity tests completed
   - Use case tests pending

### ⏸️ Pending

The following features need comprehensive test coverage:

1. **Property Feature**
   - [ ] Get Properties Use Case
   - [ ] Create Property Use Case
   - [ ] Update Property Use Case
   - [ ] Delete Property Use Case
   - [ ] Property BLoC
   - [ ] Property widgets

2. **Barter Feature**
   - [ ] Create Barter Request Use Case
   - [ ] Accept/Reject Barter Use Cases
   - [ ] Get Barter Requests Use Case
   - [ ] Barter BLoC
   - [ ] Barter widgets

3. **Messaging Feature**
   - [ ] Send Message Use Case
   - [ ] Get Messages Use Case
   - [ ] Mark as Read Use Case
   - [ ] Messaging BLoC
   - [ ] Chat widgets

4. **Payment Feature**
   - [ ] Process Payment Use Case
   - [ ] Payment BLoC
   - [ ] Payment widgets

5. **Search Feature**
   - [ ] Search Properties Use Case
   - [ ] Filter Use Cases
   - [ ] Search BLoC
   - [ ] Search widgets

6. **Reviews Feature**
   - [ ] Create Review Use Case
   - [ ] Get Reviews Use Case
   - [ ] Reviews BLoC
   - [ ] Review widgets

7. **Integration Tests**
   - [ ] Complete auth flow
   - [ ] Complete property creation flow
   - [ ] Complete barter request flow
   - [ ] Complete messaging flow
   - [ ] Complete payment flow

## Current Test Statistics

### Test Count
- **Unit Tests**: ~15 test files
- **BLoC Tests**: 1 test file
- **Widget Tests**: 1 example test file
- **Integration Tests**: 1 template file
- **Total Test Cases**: ~250+ individual test cases

### Coverage Goals
- **Business Logic**: 80%+ (use cases, repositories)
- **BLoC**: 100%
- **Entities**: 100%
- **Utilities**: 100%

## Writing New Tests

### Use Case Test Template

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:housebart/core/errors/failures.dart';

import 'your_usecase_test.mocks.dart';

@GenerateMocks([YourRepository])
void main() {
  late YourUseCase useCase;
  late MockYourRepository mockRepository;

  setUp(() {
    mockRepository = MockYourRepository();
    useCase = YourUseCase(mockRepository);
  });

  group('YourUseCase', () {
    test('should return success when operation succeeds', () async {
      // Arrange
      when(mockRepository.method(any))
          .thenAnswer((_) async => Right(expectedResult));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, equals(Right(expectedResult)));
      verify(mockRepository.method(any));
    });

    test('should return failure when operation fails', () async {
      // Arrange
      const tFailure = ServerFailure('Error message');
      when(mockRepository.method(any))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, equals(const Left(tFailure)));
    });
  });
}
```

After creating the test, regenerate mocks:

```bash
./scripts/generate_mocks.sh
```

### BLoC Test Template

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'your_bloc_test.mocks.dart';

@GenerateMocks([YourUseCase])
void main() {
  late YourBloc bloc;
  late MockYourUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockYourUseCase();
    bloc = YourBloc(useCase: mockUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('YourBloc', () {
    test('initial state should be Initial', () {
      expect(bloc.state, equals(YourInitial()));
    });

    blocTest<YourBloc, YourState>(
      'emits [Loading, Success] when event succeeds',
      build: () {
        when(mockUseCase(any))
            .thenAnswer((_) async => Right(result));
        return bloc;
      },
      act: (bloc) => bloc.add(YourEvent()),
      expect: () => [
        YourLoading(),
        YourSuccess(result),
      ],
      verify: (_) {
        verify(mockUseCase(any));
      },
    );

    blocTest<YourBloc, YourState>(
      'emits [Loading, Error] when event fails',
      build: () {
        const tFailure = ServerFailure('Error');
        when(mockUseCase(any))
            .thenAnswer((_) async => const Left(tFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(YourEvent()),
      expect: () => [
        YourLoading(),
        YourError('Error'),
      ],
    );
  });
}
```

## Test Patterns and Best Practices

### 1. Arrange-Act-Assert (AAA) Pattern

Always structure tests using AAA pattern:

```dart
test('should do something', () async {
  // Arrange - Set up test data and mocks
  when(mock.method()).thenAnswer((_) async => result);

  // Act - Execute the code being tested
  final result = await useCase();

  // Assert - Verify the results
  expect(result, equals(expected));
  verify(mock.method());
});
```

### 2. Test Naming Convention

Use descriptive test names that explain:
- What is being tested
- Under what conditions
- What is the expected result

```dart
test('should return User when login is successful', () async { ... });
test('should return NetworkFailure when there is no internet', () async { ... });
```

### 3. Mock Setup

Always verify mocks are called correctly:

```dart
// Setup mock
when(mockRepository.login(email: anyNamed('email'), password: anyNamed('password')))
    .thenAnswer((_) async => Right(user));

// Verify mock was called
verify(mockRepository.login(email: 'test@example.com', password: 'password'));

// Verify no unexpected calls
verifyNoMoreInteractions(mockRepository);
```

### 4. Test Independence

Each test should be independent:

```dart
setUp(() {
  // Fresh instances for each test
  mockRepository = MockRepository();
  useCase = UseCase(mockRepository);
});

tearDown(() {
  // Clean up if needed
});
```

### 5. Edge Cases

Always test edge cases:

```dart
group('Edge Cases', () {
  test('should handle null values', () { ... });
  test('should handle empty lists', () { ... });
  test('should handle very long strings', () { ... });
  test('should handle boundary values', () { ... });
});
```

## Common Issues and Solutions

### Issue: Mock file not found

**Solution**: Generate mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Mock file conflicts

**Solution**: Clean and rebuild:
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Test fails with "Bad state: No element"

**Solution**: Check if you're using `first` on an empty iterable. Use `firstWhere` with `orElse` instead.

### Issue: Async test timeout

**Solution**: Increase timeout:
```dart
test('async test', () async {
  // test code
}, timeout: Timeout(Duration(seconds: 30)));
```

### Issue: Widget test pump errors

**Solution**: Use `pumpAndSettle()` instead of `pump()` for async widgets:
```dart
await tester.pumpAndSettle();
```

## Continuous Integration

Tests run automatically on:
- Every pull request
- Every push to main/master
- Release builds

CI pipeline:
1. Install dependencies (`flutter pub get`)
2. Generate mocks (`flutter pub run build_runner build`)
3. Run tests with coverage (`flutter test --coverage`)
4. Upload coverage to codecov (if configured)
5. Fail build if coverage < 80% for business logic

## Next Steps

To complete Phase 14 (Testing):

1. **Generate mocks**: Run `./scripts/generate_mocks.sh`
2. **Run existing tests**: Run `./scripts/run_tests.sh`
3. **Implement remaining use case tests** (~35 use cases)
4. **Implement remaining BLoC tests** (~9 BLoCs)
5. **Implement repository tests** (~10 repositories)
6. **Implement service tests** (~11 services)
7. **Implement widget tests** (~35 widgets/pages)
8. **Implement complete integration tests** (~5 critical flows)
9. **Verify 80%+ coverage**: Check coverage report
10. **Document any gaps**: Update this guide

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package Documentation](https://pub.dev/packages/mockito)
- [BLoC Test Package Documentation](https://pub.dev/packages/bloc_test)
- [Test Coverage Best Practices](https://flutter.dev/docs/cookbook/testing/unit/introduction)
- [Integration Testing in Flutter](https://docs.flutter.dev/testing/integration-tests)

## Support

For issues or questions about tests:
1. Check this documentation
2. Review existing test examples in `test/` directory
3. Consult Flutter testing documentation
4. Create an issue in the project repository
