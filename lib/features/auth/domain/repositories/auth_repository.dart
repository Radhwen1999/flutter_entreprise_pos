import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Auth repository interface (domain layer)
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required UserRole role,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current logged in user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is logged in
  Future<bool> isLoggedIn();

  /// Enable biometric authentication
  Future<Either<Failure, void>> enableBiometric(bool enable);

  /// Authenticate with biometrics
  Future<Either<Failure, User>> loginWithBiometric();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? avatarUrl,
  });
}
