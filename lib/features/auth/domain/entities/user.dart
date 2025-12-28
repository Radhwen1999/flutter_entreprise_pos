import 'package:equatable/equatable.dart';

/// User roles in the POS system
enum UserRole {
  owner,
  manager,
  cashier,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
    }
  }

  String get description {
    switch (this) {
      case UserRole.owner:
        return 'Full access to all features';
      case UserRole.manager:
        return 'Manage products, orders & staff';
      case UserRole.cashier:
        return 'Process sales & view orders';
    }
  }

  String get icon {
    switch (this) {
      case UserRole.owner:
        return '👑';
      case UserRole.manager:
        return '📊';
      case UserRole.cashier:
        return '💳';
    }
  }
}

/// User entity (domain layer)
class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? avatarUrl;
  final bool biometricEnabled;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.biometricEnabled = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? avatarUrl,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Check if user has specific permission
  bool hasPermission(Permission permission) {
    switch (role) {
      case UserRole.owner:
        return true; // Owner has all permissions
      case UserRole.manager:
        return permission != Permission.manageStaff;
      case UserRole.cashier:
        return permission == Permission.viewOrders ||
            permission == Permission.createOrder ||
            permission == Permission.viewProducts;
    }
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        avatarUrl,
        biometricEnabled,
        createdAt,
        lastLoginAt,
      ];
}

/// Permissions enum
enum Permission {
  viewDashboard,
  viewProducts,
  manageProducts,
  viewOrders,
  manageOrders,
  createOrder,
  viewAnalytics,
  viewReports,
  manageStaff,
  manageSettings,
}
