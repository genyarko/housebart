import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/router_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/matching/presentation/bloc/matching_bloc.dart';
import 'features/messaging/presentation/bloc/messaging_bloc.dart';
import 'features/verification/presentation/bloc/verification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/saved_properties/presentation/bloc/saved_property_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Make sure to create .env file from .env.example');
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    debugPrint('Supabase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
    debugPrint('Please check your .env file configuration');
  }

  // Initialize dependency injection
  await di.init();
  debugPrint('Dependency injection initialized');

  // Run the app
  runApp(const HouseBartApp());
}

/// Main application widget
class HouseBartApp extends StatelessWidget {
  const HouseBartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<AuthBloc>(),
        ),

        // Property BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<PropertyBloc>(),
        ),

        // Matching/Barter BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<MatchingBloc>(),
        ),

        // Messaging BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<MessagingBloc>(),
        ),

        // Verification BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<VerificationBloc>(),
        ),

        // Notification BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<NotificationBloc>(),
        ),

        // Saved Properties BLoC - available throughout the app
        BlocProvider(
          create: (_) => di.sl<SavedPropertyBloc>(),
        ),

        // TODO: Add more BLoCs as features are implemented
        // - Reviews BLoC
        // - etc.
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Router
        routerConfig: AppRouter.router,

        // Locale
        locale: const Locale('en', 'US'),
        supportedLocales: const [
          Locale('en', 'US'),
        ],

        // Builder for additional wrappers if needed
        builder: (context, child) {
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}
