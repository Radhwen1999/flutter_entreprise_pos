import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../bloc/products_bloc.dart';
import '../widgets/category_chips.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_tile.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(ProductsLoadRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SearchTextField(
                controller: _searchController,
                hint: AppStrings.searchProducts,
                onChanged: (query) {
                  context.read<ProductsBloc>().add(ProductsSearchChanged(query));
                },
                onClear: () {
                  _searchController.clear();
                  context.read<ProductsBloc>().add(const ProductsSearchChanged(''));
                },
              ),
            ),

            // Category chips
            BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if (state is ProductsLoaded) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: CategoryChips(
                      categories: state.categories,
                      selectedCategory: state.selectedCategory,
                      onCategorySelected: (category) {
                        context
                            .read<ProductsBloc>()
                            .add(ProductsCategoryChanged(category));
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Products grid/list
            Expanded(
              child: BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  if (state is ProductsLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: ShimmerProductGrid(),
                    );
                  }

                  if (state is ProductsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.warning_2,
                            size: 64,
                            color: AppColors.error.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductsLoaded) {
                    if (state.filteredProducts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<ProductsBloc>()
                            .add(ProductsRefreshRequested());
                      },
                      color: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      child: state.isGridView
                          ? _buildGridView(state)
                          : _buildListView(state),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add product
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ).animate().scale(delay: 300.ms, duration: 200.ms),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.products,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  final count = state is ProductsLoaded
                      ? state.filteredProducts.length
                      : 0;
                  return Text(
                    '$count items',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              // View mode toggle
              BlocBuilder<ProductsBloc, ProductsState>(
                builder: (context, state) {
                  final isGridView =
                      state is ProductsLoaded ? state.isGridView : true;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        _ViewModeButton(
                          icon: Iconsax.grid_1,
                          isActive: isGridView,
                          onTap: () {
                            context.read<ProductsBloc>().add(
                                  const ProductsViewModeChanged(true),
                                );
                          },
                        ),
                        _ViewModeButton(
                          icon: Iconsax.menu_1,
                          isActive: !isGridView,
                          onTap: () {
                            context.read<ProductsBloc>().add(
                                  const ProductsViewModeChanged(false),
                                );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              // Filter button
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: IconButton(
                  icon: const Icon(Iconsax.filter, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    // TODO: Show filters
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(ProductsLoaded state) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            // TODO: Navigate to product details
          },
        ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1);
      },
    );
  }

  Widget _buildListView(ProductsLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: state.filteredProducts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = state.filteredProducts[index];
        return ProductListTile(
          product: product,
          onTap: () {
            // TODO: Navigate to product details
          },
        ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Iconsax.box_1,
              size: 40,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.15) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
