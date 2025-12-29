import 'package:equatable/equatable.dart';

/// Order status enum
enum OrderStatus {
  pending,
  processing,
  completed,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Order entity
class Order extends Equatable {
  final String id;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final OrderStatus status;
  final String? customerName;
  final String? customerEmail;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool needsSync;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    this.customerName,
    this.customerEmail,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.needsSync = false,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Order copyWith({
    String? id,
    String? orderNumber,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? discount,
    double? total,
    OrderStatus? status,
    String? customerName,
    String? customerEmail,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? needsSync,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        items,
        subtotal,
        tax,
        discount,
        total,
        status,
        customerName,
        customerEmail,
        notes,
        createdAt,
        updatedAt,
        createdBy,
        needsSync,
      ];
}

/// Order item entity
class OrderItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  @override
  List<Object?> get props => [productId, productName, price, quantity, total];
}
