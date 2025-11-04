import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/errors/exceptions.dart';

/// Service for handling authentication with Supabase
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.user == null) {
        throw const AuthenticationException(
          'Failed to create account',
          'SIGNUP_FAILED',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred during signup',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthenticationException(
          'Invalid email or password',
          'INVALID_CREDENTIALS',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred during login',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred during logout',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred while resetting password',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw const AuthenticationException(
          'Failed to update password',
          'UPDATE_FAILED',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred while updating password',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['first_name'] = firstName;
      if (lastName != null) data['last_name'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _client.auth.updateUser(
        UserAttributes(data: data),
      );

      if (response.user == null) {
        throw const AuthenticationException(
          'Failed to update profile',
          'UPDATE_FAILED',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred while updating profile',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Get access token
  String? get accessToken {
    final session = _client.auth.currentSession;
    return session?.accessToken;
  }

  /// Refresh session
  Future<AuthResponse> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();

      if (response.session == null) {
        throw const AuthenticationException(
          'Failed to refresh session',
          'REFRESH_FAILED',
        );
      }

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred while refreshing session',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Sign in with Google (optional - requires configuration)
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred during Google sign in',
        'UNKNOWN_ERROR',
      );
    }
  }

  /// Sign in with Apple (optional - requires configuration)
  Future<AuthResponse> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );

      return response;
    } on AuthException catch (e) {
      throw AuthenticationException(
        e.message,
        e.statusCode,
      );
    } catch (e) {
      throw AuthenticationException(
        'An unexpected error occurred during Apple sign in',
        'UNKNOWN_ERROR',
      );
    }
  }
}
