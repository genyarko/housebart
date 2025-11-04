import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment variables
class AppConfig {
  // Supabase Configuration
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Stripe Configuration
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'HouseBart';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // API Configuration
  static int get apiTimeout =>
      int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;

  // Feature Flags
  static bool get enableSocialLogin =>
      dotenv.env['ENABLE_SOCIAL_LOGIN']?.toLowerCase() == 'true';
  static bool get enablePushNotifications =>
      dotenv.env['ENABLE_PUSH_NOTIFICATIONS']?.toLowerCase() == 'true';

  /// Validate that all required configuration is present
  static bool validate() {
    if (supabaseUrl.isEmpty) {
      throw Exception('SUPABASE_URL is not configured');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not configured');
    }
    return true;
  }

  /// Check if running in production mode
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  /// Check if running in debug mode
  static bool get isDebug => !isProduction;
}
