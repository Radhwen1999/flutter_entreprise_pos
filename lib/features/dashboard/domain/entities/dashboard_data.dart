import 'package:equatable/equatable.dart';

/// Dashboard data entity
class DashboardData extends Equatable {
  final double todaysSales;
  final int totalOrders;
  final double avgOrderValue;
  final double totalRevenue;
  final List<SalesDataPoint> salesChart;
  final List<TopProduct> topProducts;
  final List<LowStockItem> lowStockAlerts;
  final double salesChange; // Percentage change from yesterday
  final double ordersChange;
  final DateTime lastUpdated;

  const DashboardData({
    required this.todaysSales,
    required this.totalOrders,
    required this.avgOrderValue,
    required this.totalRevenue,
    required this.salesChart,
    required this.topProducts,
    required this.lowStockAlerts,
    required this.salesChange,
    required this.ordersChange,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        todaysSales,
        totalOrders,
        avgOrderValue,
        totalRevenue,
        salesChart,
        topProducts,
        lowStockAlerts,
        salesChange,
        ordersChange,
        lastUpdated,
      ];
}

/// Sales data point for charts
class SalesDataPoint extends Equatable {
  final DateTime date;
  final double amount;
  final int orders;

  const SalesDataPoint({
    required this.date,
    required this.amount,
    required this.orders,
  });

  @override
  List<Object?> get props => [date, amount, orders];
}

/// Top selling product
class TopProduct extends Equatable {
  final String id;
  final String name;
  final String category;
  final int unitsSold;
  final double revenue;
  final String? imageUrl;

  const TopProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, category, unitsSold, revenue, imageUrl];
}

/// Low stock alert item
class LowStockItem extends Equatable {
  final String id;
  final String name;
  final int currentStock;
  final int minStock;
  final String? imageUrl;

  const LowStockItem({
    required this.id,
    required this.name,
    required this.currentStock,
    required this.minStock,
    this.imageUrl,
  });

  bool get isCritical => currentStock <= minStock ~/ 2;
  bool get isOutOfStock => currentStock == 0;

  @override
  List<Object?> get props => [id, name, currentStock, minStock, imageUrl];
}
