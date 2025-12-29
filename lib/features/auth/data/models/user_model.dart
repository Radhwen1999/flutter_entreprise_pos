import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int roleIndex;

  @HiveField(4)
  final String? avatarUrl;

  @HiveField(5)
  final bool biometricEnabled;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? lastLoginAt;

  @HiveField(8)
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.roleIndex,
    this.avatarUrl,
    this.biometricEnabled = false,
    required this.createdAt,
    this.lastLoginAt,
    this.token,
  });

  /// Convert from Entity to Model
  factory UserModel.fromEntity(User user, {String? token}) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      roleIndex: user.role.index,
      avatarUrl: user.avatarUrl,
      biometricEnabled: user.biometricEnabled,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      token: token,
    );
  }

  /// Convert from JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? 'User',
      roleIndex: _parseRole(json['role'] as String?),
      avatarUrl: json['avatar_url'] as String?,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': UserRole.values[roleIndex].name,
      'avatar_url': avatarUrl,
      'biometric_enabled': biometricEnabled,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  /// Convert to Entity
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      role: UserRole.values[roleIndex],
      avatarUrl: avatarUrl,
      biometricEnabled: biometricEnabled,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Parse role string to index
  static int _parseRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return UserRole.owner.index;
      case 'manager':
        return UserRole.manager.index;
      case 'cashier':
        return UserRole.cashier.index;
      default:
        return UserRole.cashier.index;
    }
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    int? roleIndex,
    String? avatarUrl,
    bool? biometricEnabled,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      roleIndex: roleIndex ?? this.roleIndex,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      token: token ?? this.token,
    );
  }
}
