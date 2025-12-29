import 'dart:math';
import '../../../orders/domain/entities/order.dart';

/// Local data source for orders
abstract class OrdersLocalDataSource {
  /// Get all orders
  Future<List<Order>> getOrders();

  /// Get orders by status
  Future<List<Order>> getOrdersByStatus(OrderStatus status);

  /// Get orders by date range
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end);

  /// Search orders
  Future<List<Order>> searchOrders(String query);

  /// Generate demo orders
  List<Order> generateDemoOrders();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  List<Order>? _cachedOrders;

  @override
  Future<List<Order>> getOrders() async {
    _cachedOrders ??= generateDemoOrders();
    return _cachedOrders!;
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final orders = await getOrders();
    return orders.where((o) => o.status == status).toList();
  }

  @override
  Future<List<Order>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final orders = await getOrders();
    return orders.where((o) {
      return o.createdAt.isAfter(start) && o.createdAt.isBefore(end);
    }).toList();
  }

  @override
  Future<List<Order>> searchOrders(String query) async {
    final orders = await getOrders();
    final lowerQuery = query.toLowerCase();
    return orders.where((o) {
      return o.orderNumber.toLowerCase().contains(lowerQuery) ||
          (o.customerName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  List<Order> generateDemoOrders() {
    final random = Random();
    final now = DateTime.now();
    final orders = <Order>[];

    final productNames = [
      'Cappuccino',
      'Iced Latte',
      'Avocado Toast',
      'Croissant',
      'Caesar Salad',
      'Chicken Sandwich',
      'Green Tea',
      'Chocolate Muffin',
    ];

    final customerNames = [
      'John Smith',
      'Emma Johnson',
      'Michael Brown',
      'Sarah Davis',
      'James Wilson',
      'Emily Taylor',
      'Robert Martinez',
      'Olivia Anderson',
      'William Thomas',
      'Sophia Garcia',
    ];

    // Generate orders for the last 30 days
    for (int day = 0; day < 30; day++) {
      final ordersPerDay = 5 + random.nextInt(15);

      for (int i = 0; i < ordersPerDay; i++) {
        final orderDate = now.subtract(Duration(
          days: day,
          hours: random.nextInt(12),
          minutes: random.nextInt(60),
        ));

        // Generate order items
        final itemCount = 1 + random.nextInt(4);
        final items = <OrderItem>[];
        double subtotal = 0;

        for (int j = 0; j < itemCount; j++) {
          final productName = productNames[random.nextInt(productNames.length)];
          final price = 3.0 + random.nextDouble() * 10;
          final quantity = 1 + random.nextInt(3);
          final total = price * quantity;

          items.add(OrderItem(
            productId: 'prod_${random.nextInt(15).toString().padLeft(3, '0')}',
            productName: productName,
            price: double.parse(price.toStringAsFixed(2)),
            quantity: quantity,
            total: double.parse(total.toStringAsFixed(2)),
          ));

          subtotal += total;
        }

        final tax = subtotal * 0.08; // 8% tax
        final discount = random.nextDouble() > 0.8 ? subtotal * 0.1 : 0; // 20% chance of 10% discount
        final total = subtotal + tax - discount;

        // Determine status based on date
        OrderStatus status;
        if (day == 0 && i < 3) {
          status = OrderStatus.pending;
        } else if (day == 0 && i < 5) {
          status = OrderStatus.processing;
        } else if (random.nextDouble() > 0.95) {
          status = OrderStatus.cancelled;
        } else {
          status = OrderStatus.completed;
        }

        orders.add(Order(
          id: 'order_${(day * 20 + i).toString().padLeft(5, '0')}',
          orderNumber: '#${(10000 + day * 20 + i).toString()}',
          items: items,
          subtotal: double.parse(subtotal.toStringAsFixed(2)),
          tax: double.parse(tax.toStringAsFixed(2)),
          discount: double.parse(discount.toStringAsFixed(2)),
          total: double.parse(total.toStringAsFixed(2)),
          status: status,
          customerName: random.nextDouble() > 0.3
              ? customerNames[random.nextInt(customerNames.length)]
              : null,
          createdAt: orderDate,
          updatedAt: orderDate,
          createdBy: 'user_001',
        ));
      }
    }

    // Sort by date descending
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }
}
