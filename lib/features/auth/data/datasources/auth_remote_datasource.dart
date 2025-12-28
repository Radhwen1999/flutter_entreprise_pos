import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart' as domain;
import '../models/user_model.dart';

/// Remote data source for auth (Supabase)
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
    required domain.UserRole role,
  });

  /// Logout
  Future<void> logout();

  /// Get current user from Supabase
  Future<UserModel?> getCurrentUser();

  /// Update user profile
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
    required domain.UserRole role,
  }) async {
    try {
      // For demo purposes, we'll simulate login with predefined credentials
      // In production, this would authenticate against Supabase Auth
      
      final demoUsers = _getDemoUsers();
      final user = demoUsers.firstWhere(
        (u) => u.email == email && u.roleIndex == role.index,
        orElse: () => throw const AuthException(
          message: 'Invalid email or password',
        ),
      );

      // Simulate password check (in demo, any password works for demo accounts)
      if (!_validateDemoCredentials(email, password)) {
        throw const AuthException(message: 'Invalid email or password');
      }

      // Update last login time
      return user.copyWith(lastLoginAt: DateTime.now());
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(message: 'Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) return null;

      final userId = session.user.id;
      final response = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      final response = await supabaseClient
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  /// Demo users for testing
  List<UserModel> _getDemoUsers() {
    return [
      UserModel(
        id: 'owner_001',
        email: 'owner@pos.com',
        name: 'John Owner',
        roleIndex: domain.UserRole.owner.index,
        avatarUrl: null,
        biometricEnabled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        token: 'demo_token_owner',
      ),
      UserModel(
        id: 'manager_001',
        email: 'manager@pos.com',
        name: 'Sarah Manager',
        roleIndex: domain.UserRole.manager.index,
        avatarUrl: null,
        biometricEnabled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        token: 'demo_token_manager',
      ),
      UserModel(
        id: 'cashier_001',
        email: 'cashier@pos.com',
        name: 'Mike Cashier',
        roleIndex: domain.UserRole.cashier.index,
        avatarUrl: null,
        biometricEnabled: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        token: 'demo_token_cashier',
      ),
    ];
  }

  /// Validate demo credentials
  bool _validateDemoCredentials(String email, String password) {
    // Demo passwords
    const demoCredentials = {
      'owner@pos.com': 'owner123',
      'manager@pos.com': 'manager123',
      'cashier@pos.com': 'cashier123',
    };

    return demoCredentials[email] == password;
  }
}
