import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/products_local_datasource.dart';
import '../../domain/entities/product.dart';

// ═══════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

class ProductsLoadRequested extends ProductsEvent {}

class ProductsRefreshRequested extends ProductsEvent {}

class ProductsCategoryChanged extends ProductsEvent {
  final String category;

  const ProductsCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class ProductsSearchChanged extends ProductsEvent {
  final String query;

  const ProductsSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductsViewModeChanged extends ProductsEvent {
  final bool isGridView;

  const ProductsViewModeChanged(this.isGridView);

  @override
  List<Object?> get props => [isGridView];
}

class ProductDeleted extends ProductsEvent {
  final String productId;

  const ProductDeleted(this.productId);

  @override
  List<Object?> get props => [productId];
}

// ═══════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final String selectedCategory;
  final String searchQuery;
  final bool isGridView;
  final List<String> categories;

  const ProductsLoaded({
    required this.products,
    required this.filteredProducts,
    required this.selectedCategory,
    required this.searchQuery,
    required this.isGridView,
    required this.categories,
  });

  ProductsLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    String? selectedCategory,
    String? searchQuery,
    bool? isGridView,
    List<String>? categories,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [
        products,
        filteredProducts,
        selectedCategory,
        searchQuery,
        isGridView,
        categories,
      ];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ═══════════════════════════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════════════════════════

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsLocalDataSource localDataSource;

  ProductsBloc({
    required this.localDataSource,
  }) : super(ProductsInitial()) {
    on<ProductsLoadRequested>(_onLoadRequested);
    on<ProductsRefreshRequested>(_onRefreshRequested);
    on<ProductsCategoryChanged>(_onCategoryChanged);
    on<ProductsSearchChanged>(_onSearchChanged);
    on<ProductsViewModeChanged>(_onViewModeChanged);
    on<ProductDeleted>(_onProductDeleted);
  }

  Future<void> _onLoadRequested(
    ProductsLoadRequested event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());

    try {
      final productModels = await localDataSource.getProducts();
      final products = productModels.map((m) => m.toEntity()).toList();
      
      final categories = ['All', ...products.map((p) => p.category).toSet()];

      emit(ProductsLoaded(
        products: products,
        filteredProducts: products,
        selectedCategory: 'All',
        searchQuery: '',
        isGridView: true,
        categories: categories,
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    ProductsRefreshRequested event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      add(ProductsLoadRequested());
    }
  }

  void _onCategoryChanged(
    ProductsCategoryChanged event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final filtered = _filterProducts(
        currentState.products,
        event.category,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        selectedCategory: event.category,
        filteredProducts: filtered,
      ));
    }
  }

  void _onSearchChanged(
    ProductsSearchChanged event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      final filtered = _filterProducts(
        currentState.products,
        currentState.selectedCategory,
        event.query,
      );

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredProducts: filtered,
      ));
    }
  }

  void _onViewModeChanged(
    ProductsViewModeChanged event,
    Emitter<ProductsState> emit,
  ) {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(currentState.copyWith(isGridView: event.isGridView));
    }
  }

  Future<void> _onProductDeleted(
    ProductDeleted event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      
      await localDataSource.deleteProduct(event.productId);
      
      final updatedProducts = currentState.products
          .where((p) => p.id != event.productId)
          .toList();
      
      final filtered = _filterProducts(
        updatedProducts,
        currentState.selectedCategory,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        products: updatedProducts,
        filteredProducts: filtered,
      ));
    }
  }

  List<Product> _filterProducts(
    List<Product> products,
    String category,
    String query,
  ) {
    var filtered = products;

    // Filter by category
    if (category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(lowerQuery) ||
            p.category.toLowerCase().contains(lowerQuery) ||
            (p.sku?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    return filtered;
  }
}
