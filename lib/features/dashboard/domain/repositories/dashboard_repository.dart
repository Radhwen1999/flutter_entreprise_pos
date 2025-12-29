import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_data.dart';

/// Dashboard repository interface
abstract class DashboardRepository {
  /// Get dashboard data
  Future<Either<Failure, DashboardData>> getDashboardData();

  /// Get sales data for date range
  Future<Either<Failure, List<SalesDataPoint>>> getSalesData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get top selling products
  Future<Either<Failure, List<TopProduct>>> getTopProducts({
    int limit = 5,
  });

  /// Get low stock alerts
  Future<Either<Failure, List<LowStockItem>>> getLowStockAlerts({
    int threshold = 10,
  });

  /// Refresh dashboard data from remote
  Future<Either<Failure, DashboardData>> refreshDashboard();
}
