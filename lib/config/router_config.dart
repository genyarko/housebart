import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/api_routes.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/home_page.dart';
import '../features/property/presentation/pages/properties_list_page.dart';
import '../features/property/presentation/pages/property_details_page.dart';
import '../features/property/presentation/pages/add_property_page.dart';
import '../features/property/presentation/pages/my_properties_page.dart';

/// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Main Routes
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Property Routes
      GoRoute(
        path: AppRoutes.properties,
        name: 'properties',
        builder: (context, state) => const PropertiesListPage(),
      ),
      GoRoute(
        path: '${AppRoutes.propertyDetails}/:id',
        name: 'propertyDetails',
        builder: (context, state) {
          final propertyId = state.pathParameters['id']!;
          return PropertyDetailsPage(propertyId: propertyId);
        },
      ),
      GoRoute(
        path: AppRoutes.addProperty,
        name: 'addProperty',
        builder: (context, state) => const AddPropertyPage(),
      ),
      GoRoute(
        path: AppRoutes.myProperties,
        name: 'myProperties',
        builder: (context, state) => const MyPropertiesPage(),
      ),

      // TODO: Add more routes as features are implemented
      // - Barter requests
      // - Messages
      // - Profile
      // - etc.
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),

    // Redirect logic (can be expanded for auth guards)
    redirect: (context, state) {
      // Add auth guard logic here if needed
      return null; // No redirect
    },
  );
}
