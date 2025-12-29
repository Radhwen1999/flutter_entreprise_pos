import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

@HiveType(typeId: 1)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stock;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String? imageUrl;

  @HiveField(7)
  final String? sku;

  @HiveField(8)
  final String? barcode;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final bool needsSync;

  ProductModel({
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

  /// Convert from Entity to Model
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      stock: product.stock,
      category: product.category,
      imageUrl: product.imageUrl,
      sku: product.sku,
      barcode: product.barcode,
      isActive: product.isActive,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      needsSync: product.needsSync,
    );
  }

  /// Convert from JSON (Supabase response)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int? ?? 0,
      category: json['category'] as String? ?? 'Other',
      imageUrl: json['image_url'] as String?,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      needsSync: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'image_url': imageUrl,
      'sku': sku,
      'barcode': barcode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Entity
  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      stock: stock,
      category: category,
      imageUrl: imageUrl,
      sku: sku,
      barcode: barcode,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      needsSync: needsSync,
    );
  }

  ProductModel copyWith({
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
    return ProductModel(
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
}
