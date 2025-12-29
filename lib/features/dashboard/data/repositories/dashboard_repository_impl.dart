import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      // For demo, always return generated data
      final data = localDataSource.generateDemoData();
      await localDataSource.cacheDashboard(data);
      return Right(data);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesDataPoint>>> getSalesData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final data = localDataSource.generateDemoData();
      return Right(data.salesChart);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopProduct>>> getTopProducts({
    int limit = 5,
  }) async {
    try {
      final data = localDataSource.generateDemoData();
      return Right(data.topProducts.take(limit).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LowStockItem>>> getLowStockAlerts({
    int threshold = 10,
  }) async {
    try {
      final data = localDataSource.generateDemoData();
      return Right(data.lowStockAlerts);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DashboardData>> refreshDashboard() async {
    return getDashboardData();
  }
}
