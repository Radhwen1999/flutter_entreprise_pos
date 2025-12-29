import 'dart:convert';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/dashboard_data.dart';

/// Local data source for dashboard (Hive)
abstract class DashboardLocalDataSource {
  /// Get cached dashboard data
  Future<DashboardData?> getCachedDashboard();

  /// Cache dashboard data
  Future<void> cacheDashboard(DashboardData data);

  /// Generate demo dashboard data
  DashboardData generateDemoData();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  static const String _boxName = 'dashboard_box';
  static const String _dataKey = 'dashboard_data';

  Box? _box;

  Future<Box> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<DashboardData?> getCachedDashboard() async {
    try {
      final dashboardBox = await box;
      final jsonString = dashboardBox.get(_dataKey);
      if (jsonString == null) return null;

      // For demo, always return fresh demo data
      return generateDemoData();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheDashboard(DashboardData data) async {
    try {
      final dashboardBox = await box;
      await dashboardBox.put(_dataKey, 'cached');
    } catch (e) {
      // Silent fail for cache
    }
  }

  @override
  DashboardData generateDemoData() {
    final random = Random();
    final now = DateTime.now();

    // Generate last 7 days of sales data
    final salesChart = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final baseAmount = 2000 + random.nextDouble() * 3000;
      final orders = 30 + random.nextInt(50);
      
      return SalesDataPoint(
        date: date,
        amount: baseAmount,
        orders: orders,
      );
    });

    // Today's data
    final todaysSales = 3500 + random.nextDouble() * 2000;
    final totalOrders = 45 + random.nextInt(30);
    final avgOrderValue = todaysSales / totalOrders;

    // Top products
    final topProducts = [
      TopProduct(
        id: 'prod_1',
        name: 'Cappuccino',
        category: 'Beverages',
        unitsSold: 156 + random.nextInt(50),
        revenue: 780 + random.nextDouble() * 200,
      ),
      TopProduct(
        id: 'prod_2',
        name: 'Avocado Toast',
        category: 'Food',
        unitsSold: 89 + random.nextInt(30),
        revenue: 890 + random.nextDouble() * 150,
      ),
      TopProduct(
        id: 'prod_3',
        name: 'Iced Latte',
        category: 'Beverages',
        unitsSold: 124 + random.nextInt(40),
        revenue: 620 + random.nextDouble() * 180,
      ),
      TopProduct(
        id: 'prod_4',
        name: 'Croissant',
        category: 'Bakery',
        unitsSold: 98 + random.nextInt(25),
        revenue: 392 + random.nextDouble() * 100,
      ),
      TopProduct(
        id: 'prod_5',
        name: 'Smoothie Bowl',
        category: 'Food',
        unitsSold: 67 + random.nextInt(20),
        revenue: 536 + random.nextDouble() * 120,
      ),
    ];

    // Low stock alerts
    final lowStockAlerts = [
      const LowStockItem(
        id: 'stock_1',
        name: 'Coffee Beans (1kg)',
        currentStock: 3,
        minStock: 10,
      ),
      const LowStockItem(
        id: 'stock_2',
        name: 'Oat Milk',
        currentStock: 5,
        minStock: 15,
      ),
      const LowStockItem(
        id: 'stock_3',
        name: 'Paper Cups (L)',
        currentStock: 8,
        minStock: 20,
      ),
      const LowStockItem(
        id: 'stock_4',
        name: 'Avocados',
        currentStock: 2,
        minStock: 10,
      ),
    ];

    return DashboardData(
      todaysSales: todaysSales,
      totalOrders: totalOrders,
      avgOrderValue: avgOrderValue,
      totalRevenue: salesChart.fold(0.0, (sum, item) => sum + item.amount),
      salesChart: salesChart,
      topProducts: topProducts,
      lowStockAlerts: lowStockAlerts,
      salesChange: -5 + random.nextDouble() * 25, // -5% to +20%
      ordersChange: -3 + random.nextDouble() * 18, // -3% to +15%
      lastUpdated: now,
    );
  }
}
