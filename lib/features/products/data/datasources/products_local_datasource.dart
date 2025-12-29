import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';

/// Local data source for products (Hive)
abstract class ProductsLocalDataSource {
  /// Get all products
  Future<List<ProductModel>> getProducts();

  /// Get product by ID
  Future<ProductModel?> getProduct(String id);

  /// Save product
  Future<void> saveProduct(ProductModel product);

  /// Delete product
  Future<void> deleteProduct(String id);

  /// Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category);

  /// Search products
  Future<List<ProductModel>> searchProducts(String query);

  /// Get products needing sync
  Future<List<ProductModel>> getProductsNeedingSync();

  /// Generate demo products
  List<ProductModel> generateDemoProducts();
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  static const String _boxName = 'products_box';

  Box<ProductModel>? _box;

  Future<Box<ProductModel>> get box async {
    if (_box != null && _box!.isOpen) {
      return _box!;
    }
    _box = await Hive.openBox<ProductModel>(_boxName);
    return _box!;
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final productsBox = await box;
      if (productsBox.isEmpty) {
        // Initialize with demo products
        final demoProducts = generateDemoProducts();
        for (final product in demoProducts) {
          await productsBox.put(product.id, product);
        }
        return demoProducts;
      }
      return productsBox.values.toList();
    } catch (e) {
      return generateDemoProducts();
    }
  }

  @override
  Future<ProductModel?> getProduct(String id) async {
    try {
      final productsBox = await box;
      return productsBox.get(id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    try {
      final productsBox = await box;
      await productsBox.put(product.id, product);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final productsBox = await box;
      await productsBox.delete(id);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final products = await getProducts();
    if (category == 'All') return products;
    return products.where((p) => p.category == category).toList();
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    final products = await getProducts();
    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
          p.category.toLowerCase().contains(lowerQuery) ||
          (p.sku?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  @override
  Future<List<ProductModel>> getProductsNeedingSync() async {
    final products = await getProducts();
    return products.where((p) => p.needsSync).toList();
  }

  @override
  List<ProductModel> generateDemoProducts() {
    final random = Random();
    final now = DateTime.now();

    final products = <ProductModel>[
      // Beverages
      ProductModel(
        id: 'prod_001',
        name: 'Cappuccino',
        description: 'Rich espresso with steamed milk and foam',
        price: 4.99,
        stock: 100 + random.nextInt(50),
        category: 'Beverages',
        sku: 'BEV-CAP-001',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_002',
        name: 'Iced Latte',
        description: 'Cold espresso with milk over ice',
        price: 5.49,
        stock: 80 + random.nextInt(40),
        category: 'Beverages',
        sku: 'BEV-LAT-001',
        createdAt: now.subtract(const Duration(days: 85)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_003',
        name: 'Green Tea',
        description: 'Premium Japanese green tea',
        price: 3.49,
        stock: 60 + random.nextInt(30),
        category: 'Beverages',
        sku: 'BEV-TEA-001',
        createdAt: now.subtract(const Duration(days: 80)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_004',
        name: 'Fresh Orange Juice',
        description: 'Freshly squeezed orange juice',
        price: 4.29,
        stock: 25 + random.nextInt(15),
        category: 'Beverages',
        sku: 'BEV-JUI-001',
        createdAt: now.subtract(const Duration(days: 75)),
        updatedAt: now,
      ),
      // Food
      ProductModel(
        id: 'prod_005',
        name: 'Avocado Toast',
        description: 'Sourdough with smashed avocado and toppings',
        price: 9.99,
        stock: 35 + random.nextInt(20),
        category: 'Food',
        sku: 'FOO-AVO-001',
        createdAt: now.subtract(const Duration(days: 70)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_006',
        name: 'Caesar Salad',
        description: 'Romaine lettuce with Caesar dressing',
        price: 8.49,
        stock: 28 + random.nextInt(15),
        category: 'Food',
        sku: 'FOO-SAL-001',
        createdAt: now.subtract(const Duration(days: 65)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_007',
        name: 'Chicken Sandwich',
        description: 'Grilled chicken breast on ciabatta',
        price: 10.99,
        stock: 22 + random.nextInt(12),
        category: 'Food',
        sku: 'FOO-SAN-001',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      // Bakery
      ProductModel(
        id: 'prod_008',
        name: 'Croissant',
        description: 'Buttery French croissant',
        price: 3.99,
        stock: 45 + random.nextInt(25),
        category: 'Bakery',
        sku: 'BAK-CRO-001',
        createdAt: now.subtract(const Duration(days: 55)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_009',
        name: 'Chocolate Muffin',
        description: 'Double chocolate chip muffin',
        price: 3.49,
        stock: 38 + random.nextInt(20),
        category: 'Bakery',
        sku: 'BAK-MUF-001',
        createdAt: now.subtract(const Duration(days: 50)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_010',
        name: 'Blueberry Scone',
        description: 'Fresh baked blueberry scone',
        price: 3.29,
        stock: 8 + random.nextInt(5), // Low stock
        category: 'Bakery',
        sku: 'BAK-SCO-001',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now,
      ),
      // Snacks
      ProductModel(
        id: 'prod_011',
        name: 'Mixed Nuts',
        description: 'Premium roasted mixed nuts',
        price: 5.99,
        stock: 55 + random.nextInt(30),
        category: 'Snacks',
        sku: 'SNA-NUT-001',
        createdAt: now.subtract(const Duration(days: 40)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_012',
        name: 'Protein Bar',
        description: 'High protein energy bar',
        price: 3.99,
        stock: 65 + random.nextInt(35),
        category: 'Snacks',
        sku: 'SNA-BAR-001',
        createdAt: now.subtract(const Duration(days: 35)),
        updatedAt: now,
      ),
      // Desserts
      ProductModel(
        id: 'prod_013',
        name: 'Cheesecake Slice',
        description: 'New York style cheesecake',
        price: 6.99,
        stock: 12 + random.nextInt(8),
        category: 'Desserts',
        sku: 'DES-CHE-001',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_014',
        name: 'Tiramisu',
        description: 'Classic Italian tiramisu',
        price: 7.49,
        stock: 5 + random.nextInt(5), // Low stock
        category: 'Desserts',
        sku: 'DES-TIR-001',
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      ProductModel(
        id: 'prod_015',
        name: 'Gelato Cup',
        description: 'Artisan Italian gelato',
        price: 5.49,
        stock: 0, // Out of stock
        category: 'Desserts',
        sku: 'DES-GEL-001',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
    ];

    return products;
  }
}
