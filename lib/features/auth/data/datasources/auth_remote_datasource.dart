import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/constants/api_routes.dart';
import '../models/user_model.dart';

/// Abstract class defining authentication remote data source contract
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();

  Future<bool> isLoggedIn();

  Future<void> forgotPassword(String email);

  Future<void> updatePassword(String newPassword);

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
  });
}

/// Implementation of authentication remote data source using Supabase
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthService authService;
  final SupabaseClient _client = Supabase.instance.client;

  AuthRemoteDataSourceImpl({required this.authService});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthenticationException(
          'Login failed',
          'LOGIN_FAILED',
        );
      }

      // Fetch user profile from profiles table
      final profileData = await _fetchUserProfile(response.user!.id);

      return UserModel.fromSupabaseUser(
        response.user!.toJson(),
        profileData,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Login failed: ${e.toString()}',
        'LOGIN_ERROR',
      );
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.user == null) {
        throw const AuthenticationException(
          'Registration failed',
          'REGISTER_FAILED',
        );
      }

      // Note: Profile is auto-created by database trigger
      // Wait a moment for trigger to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Fetch user profile from profiles table
      final profileData = await _fetchUserProfile(response.user!.id);

      return UserModel.fromSupabaseUser(
        response.user!.toJson(),
        profileData,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Registration failed: ${e.toString()}',
        'REGISTER_ERROR',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await authService.signOut();
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Logout failed: ${e.toString()}',
        'LOGOUT_ERROR',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw const AuthenticationException(
          'No user logged in',
          'NO_USER',
        );
      }

      // Fetch user profile from profiles table
      final profileData = await _fetchUserProfile(currentUser.id);

      return UserModel.fromSupabaseUser(
        currentUser.toJson(),
        profileData,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Failed to get current user: ${e.toString()}',
        'GET_USER_ERROR',
      );
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return authService.isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await authService.resetPassword(email);
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Password reset failed: ${e.toString()}',
        'RESET_PASSWORD_ERROR',
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await authService.updatePassword(newPassword);
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Password update failed: ${e.toString()}',
        'UPDATE_PASSWORD_ERROR',
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? bio,
  }) async {
    try {
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw const AuthenticationException(
          'No user logged in',
          'NO_USER',
        );
      }

      // Update profile in profiles table
      final updates = <String, dynamic>{};
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;

      if (updates.isNotEmpty) {
        await _client
            .from(ApiRoutes.profilesTable)
            .update(updates)
            .eq('id', currentUser.id);
      }

      // Also update user metadata
      if (firstName != null || lastName != null || phone != null) {
        await authService.updateProfile(
          firstName: firstName,
          lastName: lastName,
          phone: phone,
        );
      }

      // Fetch updated profile
      final profileData = await _fetchUserProfile(currentUser.id);

      return UserModel.fromSupabaseUser(
        currentUser.toJson(),
        profileData,
      );
    } on AuthenticationException {
      rethrow;
    } catch (e) {
      throw AuthenticationException(
        'Profile update failed: ${e.toString()}',
        'UPDATE_PROFILE_ERROR',
      );
    }
  }

  /// Fetch user profile from profiles table
  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    try {
      final response = await _client
          .from(ApiRoutes.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      // Return null if profile doesn't exist yet
      return null;
    }
  }
}
