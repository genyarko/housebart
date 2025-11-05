import 'package:housebart/features/auth/domain/entities/user.dart';

/// Test fixtures for commonly used test data

// Auth fixtures
const tUserEmail = 'test@example.com';
const tUserPassword = 'Password123';
const tUserId = 'user-123';
const tUserFirstName = 'John';
const tUserLastName = 'Doe';

final tUser = User(
  id: tUserId,
  email: tUserEmail,
  firstName: tUserFirstName,
  lastName: tUserLastName,
  phone: '+1234567890',
  avatarUrl: 'https://example.com/avatar.jpg',
  bio: 'Test user bio',
  isVerified: true,
  createdAt: DateTime(2024, 1, 1),
);

final tUnverifiedUser = User(
  id: tUserId,
  email: tUserEmail,
  firstName: tUserFirstName,
  lastName: tUserLastName,
  isVerified: false,
  createdAt: DateTime(2024, 1, 1),
);
