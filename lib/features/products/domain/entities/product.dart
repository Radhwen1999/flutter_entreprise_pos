import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String? imageUrl;
  final String? sku;
  final String? barcode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool needsSync;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    this.imageUrl,
    this.sku,
    this.barcode,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.needsSync = false,
  });

  /// Stock status
  StockStatus get stockStatus {
    if (stock == 0) return StockStatus.outOfStock;
    if (stock <= 10) return StockStatus.low;
    if (stock <= 30) return StockStatus.medium;
    return StockStatus.high;
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    String? sku,
    String? barcode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? needsSync,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        stock,
        category,
        imageUrl,
        sku,
        barcode,
        isActive,
        createdAt,
        updatedAt,
        needsSync,
      ];
}

/// Stock status enum
enum StockStatus {
  outOfStock,
  low,
  medium,
  high,
}

extension StockStatusExtension on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.low:
        return 'Low Stock';
      case StockStatus.medium:
        return 'Medium';
      case StockStatus.high:
        return 'In Stock';
    }
  }
}

/// Product category
class ProductCategory extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final int productCount;

  const ProductCategory({
    required this.id,
    required this.name,
    this.icon,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id, name, icon, productCount];
}
