import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example widget test demonstrating testing patterns
/// This file shows how to test a login form widget
void main() {
  group('LoginForm Widget Tests', () {
    testWidgets('should display email and password fields', (tester) async {
      // Build a simple login form for testing
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('emailField'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: const Key('passwordField'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                ElevatedButton(
                  key: const Key('loginButton'),
                  onPressed: () {},
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify email field exists
      expect(find.byKey(const Key('emailField')), findsOneWidget);

      // Verify password field exists
      expect(find.byKey(const Key('passwordField')), findsOneWidget);

      // Verify login button exists
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('should accept text input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TextFormField(
                  key: const Key('emailField'),
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  key: const Key('passwordField'),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );

      // Enter text in email field
      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.pump();

      // Enter text in password field
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'Password123',
      );
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('password field should obscure text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFormField(
              key: const Key('passwordField'),
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
          ),
        ),
      );

      final passwordField = tester.widget<TextFormField>(
        find.byKey(const Key('passwordField')),
      );

      expect(passwordField.obscureText, isTrue);
    });
  });
}
