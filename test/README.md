# HouseBart Test Suite

This directory contains comprehensive tests for the HouseBart application, covering unit tests, widget tests, and integration tests.

## Test Structure

```
test/
├── core/
│   ├── errors/          # Tests for error handling (failures, exceptions)
│   └── utils/           # Tests for utilities (validators, formatters)
├── features/
│   ├── auth/           # Authentication feature tests
│   │   ├── domain/
│   │   │   └── usecases/      # Use case tests
│   │   └── presentation/
│   │       ├── bloc/          # BLoC tests
│   │       └── widgets/       # Widget tests
│   ├── property/       # Property feature tests
│   ├── barter/         # Barter feature tests
│   ├── messaging/      # Messaging feature tests
│   └── payment/        # Payment feature tests
├── helpers/            # Test helpers and fixtures
└── README.md          # This file

integration_test/
└── app_test.dart      # End-to-end integration tests
```

## Test Coverage Goals

- **Unit Tests**: 80%+ coverage for business logic (use cases, repositories, services)
- **BLoC Tests**: 100% coverage for all state management
- **Widget Tests**: Coverage for all custom widgets and critical UI components
- **Integration Tests**: Coverage for all critical user flows

## Running Tests

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### View Coverage Report

```bash
# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

# Open in browser (macOS)
open coverage/html/index.html

# Open in browser (Linux)
xdg-open coverage/html/index.html

# Open in browser (Windows)
start coverage/html/index.html
```

### Run Specific Test File

```bash
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

### Run Integration Tests

```bash
flutter test integration_test/app_test.dart
```

### Run Tests with Verbose Output

```bash
flutter test --verbose
```

## Generating Mocks

This project uses `mockito` for generating mock classes. After adding `@GenerateMocks` annotations to test files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or for continuous watching:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Test Categories

### 1. Core Tests

Tests for core utilities and error handling that are used across the application.

**Coverage:**
- ✅ Validators (validators_test.dart)
- ✅ Formatters (formatters_test.dart)
- ✅ Failures (failures_test.dart)

### 2. Feature Tests

Tests organized by feature modules following clean architecture layers.

#### Auth Feature

**Use Cases:**
- ✅ Login Use Case (login_usecase_test.dart)
- ✅ Register Use Case (register_usecase_test.dart)
- ✅ Logout Use Case (logout_usecase_test.dart)
- ✅ Get Current User Use Case (get_current_user_usecase_test.dart)
- ✅ Forgot Password Use Case (forgot_password_usecase_test.dart)

**BLoC:**
- ✅ Auth BLoC (auth_bloc_test.dart)

**Widgets:**
- ✅ Login Form Widget (login_form_test.dart) - Example

#### Property Feature

**Entities:**
- ✅ Property Entity (property_test.dart)
- ✅ Property Location Entity (property_test.dart)
- ✅ Property Details Entity (property_test.dart)
- ✅ Date Range Entity (property_test.dart)

**Use Cases:**
- ⏸️ To be implemented for remaining use cases

**BLoC:**
- ⏸️ To be implemented

#### Other Features

- ⏸️ Barter feature tests to be implemented
- ⏸️ Messaging feature tests to be implemented
- ⏸️ Payment feature tests to be implemented
- ⏸️ Search feature tests to be implemented
- ⏸️ Reviews feature tests to be implemented

### 3. Integration Tests

End-to-end tests for critical user flows.

**Implemented Templates:**
- ✅ Auth flow template (registration, login)
- ✅ Property creation flow template
- ✅ Barter request flow template
- ✅ Messaging flow template
- ✅ Payment processing flow template

## Writing Tests

### Unit Test Pattern

```dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([Repository])
void main() {
  late UseCase useCase;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    useCase = UseCase(mockRepository);
  });

  group('UseCase', () {
    test('should return expected result when successful', () async {
      // Arrange
      when(mockRepository.method()).thenAnswer((_) async => Right(result));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, equals(Right(expected)));
      verify(mockRepository.method());
    });
  });
}
```

### BLoC Test Pattern

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([UseCase])
void main() {
  late Bloc bloc;
  late MockUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockUseCase();
    bloc = Bloc(useCase: mockUseCase);
  });

  blocTest<Bloc, State>(
    'emits [Loading, Success] when event succeeds',
    build: () {
      when(mockUseCase(any)).thenAnswer((_) async => Right(result));
      return bloc;
    },
    act: (bloc) => bloc.add(Event()),
    expect: () => [Loading(), Success(result)],
  );
}
```

### Widget Test Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget should display correctly', (tester) async {
    // Build widget
    await tester.pumpWidget(MaterialApp(home: Widget()));

    // Find elements
    expect(find.text('Expected Text'), findsOneWidget);

    // Interact
    await tester.tap(find.byKey(Key('button')));
    await tester.pump();

    // Verify
    expect(find.text('Result'), findsOneWidget);
  });
}
```

### Integration Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete user flow test', (tester) async {
    // 1. Start app
    await tester.pumpWidget(MyApp());

    // 2. Navigate and interact
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // 3. Verify final state
    expect(find.text('Home'), findsOneWidget);
  });
}
```

## Test Helpers

### Test Fixtures

Common test data is defined in `test/helpers/test_fixtures.dart`:

```dart
// User test data
const tUserEmail = 'test@example.com';
const tUserPassword = 'Password123';
final tUser = User(...);

// Property test data
final tProperty = Property(...);
```

## Continuous Integration

Tests are automatically run in CI/CD pipeline on:
- Pull requests
- Commits to main branch
- Release tags

## Best Practices

1. **Arrange-Act-Assert Pattern**: Structure tests clearly with setup, execution, and verification
2. **One Assertion Focus**: Each test should verify one specific behavior
3. **Descriptive Names**: Test names should clearly describe what is being tested
4. **Mock External Dependencies**: Use mocks for repositories, APIs, and external services
5. **Test Edge Cases**: Include tests for error conditions, empty states, and boundary values
6. **Keep Tests Fast**: Unit tests should run quickly; use integration tests for slower E2E scenarios
7. **Maintain Test Independence**: Tests should not depend on each other's state or execution order

## Current Test Statistics

### Completed Tests

- Core utilities: 3 test files
- Auth feature: 6 test files (5 use cases + 1 BLoC)
- Property feature: 1 test file (entities)
- Widget tests: 1 example file
- Integration tests: 1 template file

### Total Coverage

Run `flutter test --coverage` to see current coverage metrics.

## Next Steps

To complete the test suite:

1. ✅ Generate mocks using build_runner
2. ⏸️ Implement remaining use case tests for all features
3. ⏸️ Implement BLoC tests for all features
4. ⏸️ Implement repository tests
5. ⏸️ Implement service tests
6. ⏸️ Implement widget tests for all pages
7. ⏸️ Implement complete integration tests
8. ⏸️ Achieve 80%+ code coverage

## Troubleshooting

### Mock Generation Issues

If you encounter issues with mock generation:

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test Failures

For failing tests:

1. Check error messages carefully
2. Verify mock setup is correct
3. Ensure test data matches expected values
4. Check for async timing issues (use `pumpAndSettle()` for widgets)

### Coverage Issues

If coverage is not generated:

```bash
# Ensure lcov is installed (Linux/macOS)
sudo apt-get install lcov  # Ubuntu/Debian
brew install lcov          # macOS
```

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [BLoC Test Package](https://pub.dev/packages/bloc_test)
- [Integration Test Package](https://pub.dev/packages/integration_test)
