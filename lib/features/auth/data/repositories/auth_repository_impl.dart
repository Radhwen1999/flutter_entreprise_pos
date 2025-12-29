import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      // Try remote login first
      if (await networkInfo.isConnected) {
        final userModel = await remoteDataSource.login(
          email: email,
          password: password,
          role: role,
        );
        
        // Cache user data for offline access
        await localDataSource.cacheUser(userModel);
        
        return Right(userModel.toEntity());
      } else {
        // Offline mode - check cached credentials
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null && cachedUser.email == email) {
          return Right(cachedUser.toEntity());
        }
        return const Left(NetworkFailure());
      }
    } on AuthException catch (e) {
      return Left(InvalidCredentialsFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear local cache
      await localDataSource.clearCache();
      
      // Logout from remote if connected
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First check local cache
      final cachedUser = await localDataSource.getCachedUser();
      
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }
      
      // If connected, try to get from remote
      if (await networkInfo.isConnected) {
        final remoteUser = await remoteDataSource.getCurrentUser();
        if (remoteUser != null) {
          await localDataSource.cacheUser(remoteUser);
          return Right(remoteUser.toEntity());
        }
      }
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.hasCache();
  }

  @override
  Future<Either<Failure, void>> enableBiometric(bool enable) async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        final updatedUser = cachedUser.copyWith(biometricEnabled: enable);
        await localDataSource.cacheUser(updatedUser);
      }
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithBiometric() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null && cachedUser.biometricEnabled) {
        return Right(cachedUser.toEntity());
      }
      return const Left(AuthFailure(message: 'Biometric login not available'));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser == null) {
        return const Left(AuthFailure(message: 'No user logged in'));
      }

      UserModel updatedUser;

      if (await networkInfo.isConnected) {
        updatedUser = await remoteDataSource.updateProfile(
          userId: cachedUser.id,
          name: name,
          avatarUrl: avatarUrl,
        );
      } else {
        // Update locally only
        updatedUser = cachedUser.copyWith(
          name: name ?? cachedUser.name,
          avatarUrl: avatarUrl ?? cachedUser.avatarUrl,
        );
      }

      await localDataSource.cacheUser(updatedUser);
      return Right(updatedUser.toEntity());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
