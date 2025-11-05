import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/api_routes.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/main/presentation/pages/main_page.dart';
import '../features/property/presentation/pages/properties_list_page.dart';
import '../features/property/presentation/pages/property_details_page.dart';
import '../features/property/presentation/pages/add_property_page.dart';
import '../features/property/presentation/pages/edit_property_page.dart';
import '../features/property/presentation/pages/my_properties_page.dart';
import '../features/messaging/presentation/pages/conversations_page.dart';
import '../features/messaging/presentation/pages/chat_page.dart';
import '../features/verification/presentation/pages/request_verification_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/saved_properties/presentation/pages/saved_properties_page.dart';
import '../features/search/presentation/pages/search_page.dart';

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
        builder: (context, state) => const MainPage(),
      ),

      // Property Routes
      GoRoute(
        path: AppRoutes.properties,
        name: 'properties',
        builder: (context, state) => const PropertiesListPage(),
      ),
      // Note: addProperty must come BEFORE propertyDetails to avoid route conflict
      // where "add" gets captured as an :id parameter
      GoRoute(
        path: AppRoutes.addProperty,
        name: 'addProperty',
        builder: (context, state) => const AddPropertyPage(),
      ),
      GoRoute(
        path: '${AppRoutes.propertyDetails}/:id/edit',
        name: 'editProperty',
        builder: (context, state) {
          final property = state.extra;
          if (property == null) {
            // If no property is passed, redirect to home
            return const MainPage();
          }
          return EditPropertyPage(property: property as dynamic);
        },
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
        path: AppRoutes.myProperties,
        name: 'myProperties',
        builder: (context, state) => const MyPropertiesPage(),
      ),

      // Messaging Routes
      GoRoute(
        path: AppRoutes.conversations,
        name: 'conversations',
        builder: (context, state) => const ConversationsPage(),
      ),
      GoRoute(
        path: '/messages/:barterId',
        name: 'chat',
        builder: (context, state) {
          final barterId = state.pathParameters['barterId']!;
          // Extract optional query parameters
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
          final otherUserName = state.uri.queryParameters['otherUserName'];
          final otherUserAvatar = state.uri.queryParameters['otherUserAvatar'];

          return ChatPage(
            barterId: barterId,
            otherUserId: otherUserId,
            otherUserName: otherUserName,
            otherUserAvatar: otherUserAvatar,
          );
        },
      ),

      // Verification Routes
      GoRoute(
        path: '/verification/request/:propertyId',
        name: 'requestVerification',
        builder: (context, state) {
          final propertyId = state.pathParameters['propertyId']!;
          return RequestVerificationPage(propertyId: propertyId);
        },
      ),

      // Notifications Routes
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // Saved Properties Routes
      GoRoute(
        path: AppRoutes.savedProperties,
        name: 'savedProperties',
        builder: (context, state) => const SavedPropertiesPage(),
      ),

      // Search Routes
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchPage(),
      ),

      // TODO: Add more routes as features are implemented
      // - Barter requests
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
