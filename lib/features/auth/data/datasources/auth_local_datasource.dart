import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'dart:convert';

/// Abstract class defining authentication local data source contract
abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<bool> isUserCached();
}

/// Implementation of authentication local data source using SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  static const String _cachedUserKey = 'CACHED_USER';

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final userJson = sharedPreferences.getString(_cachedUserKey);

      if (userJson == null) {
        return null;
      }

      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw CacheException(
        'Failed to get cached user: ${e.toString()}',
        'GET_CACHE_ERROR',
      );
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userJson = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, userJson);
    } catch (e) {
      throw CacheException(
        'Failed to cache user: ${e.toString()}',
        'CACHE_ERROR',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedUserKey);
      await sharedPreferences.remove(AppConstants.authTokenKey);
      await sharedPreferences.remove(AppConstants.refreshTokenKey);
      await sharedPreferences.remove(AppConstants.userIdKey);
    } catch (e) {
      throw CacheException(
        'Failed to clear cache: ${e.toString()}',
        'CLEAR_CACHE_ERROR',
      );
    }
  }

  @override
  Future<bool> isUserCached() async {
    try {
      return sharedPreferences.containsKey(_cachedUserKey);
    } catch (e) {
      return false;
    }
  }
}
