import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Local data source for auth (Hive)
abstract class AuthLocalDataSource {
  /// Get cached user
  Future<UserModel?> getCachedUser();

  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Clear cached user (logout)
  Future<void> clearCache();

  /// Check if user is cached
  Future<bool> hasCache();

  /// Get cached token
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _boxName = 'auth_box';
  static const String _userKey = 'current_user';

  Box<UserModel>? _box;

  Future<Box<UserModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<UserModel>(_boxName);
    return _box!;
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final authBox = await box;
      return authBox.get(_userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final authBox = await box;
      await authBox.put(_userKey, user);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      final authBox = await box;
      await authBox.delete(_userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> hasCache() async {
    try {
      final authBox = await box;
      return authBox.containsKey(_userKey);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final user = await getCachedUser();
      return user?.token;
    } catch (e) {
      return null;
    }
  }
}
