import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_enterprise_pos/core/services/biometric_service.dart' show BiometricService;
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/network/network_info.dart';

// Auth
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard
import 'features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Products
import 'features/products/data/datasources/products_local_datasource.dart';
import 'features/products/presentation/bloc/products_bloc.dart';


// Settings
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ═══════════════════════════════════════════════════════════════
  // EXTERNAL
  // ═══════════════════════════════════════════════════════════════
  
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => Supabase.instance.client);

  // ═══════════════════════════════════════════════════════════════
  // CORE
  // ═══════════════════════════════════════════════════════════════
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl()),
  );

  sl.registerLazySingleton(() => BiometricService());

  // ═══════════════════════════════════════════════════════════════
  // AUTH FEATURE
  // ═══════════════════════════════════════════════════════════════
  
  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════
  // DASHBOARD FEATURE
  // ═══════════════════════════════════════════════════════════════

  // Data sources
  sl.registerLazySingleton<DashboardLocalDataSource>(
        () => DashboardLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<DashboardRepository>(
        () => DashboardRepositoryImpl(
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardData(sl()));

  // Bloc
  sl.registerFactory(
        () => DashboardBloc(getDashboardData: sl()),
  );
  // ═══════════════════════════════════════════════════════════════
  // PRODUCTS FEATURE
  // ═══════════════════════════════════════════════════════════════

  // Data sources
  sl.registerLazySingleton<ProductsLocalDataSource>(
        () => ProductsLocalDataSourceImpl(),
  );

  // Bloc
  sl.registerFactory(
        () => ProductsBloc(localDataSource: sl()),
  );



  // ═══════════════════════════════════════════════════════════════
  // SETTINGS FEATURE
  // ═══════════════════════════════════════════════════════════════

  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
        () => SettingsLocalDataSourceImpl(),
  );

  // Bloc
  sl.registerFactory(
        () => SettingsBloc(
      localDataSource: sl(),
      biometricService: sl(),
    ),
  );
}
