import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/dashboard_data.dart';

class TopProductsList extends StatelessWidget {
  final List<TopProduct> products;

  const TopProductsList({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.topProducts,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to products
                },
                child: Row(
                  children: [
                    Text(
                      AppStrings.viewAll,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Iconsax.arrow_right_3,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Products list
          ...products.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return _ProductItem(
              rank: index + 1,
              product: product,
              isLast: index == products.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final int rank;
  final TopProduct product;
  final bool isLast;

  const _ProductItem({
    required this.rank,
    required this.product,
    required this.isLast,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Rank
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _rankColor.withOpacity(rank <= 3 ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: _rankColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Product image placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.chartColors[rank % AppColors.chartColors.length]
                          .withOpacity(0.3),
                      AppColors.chartColors[rank % AppColors.chartColors.length]
                          .withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(product.category),
                  color: AppColors
                      .chartColors[rank % AppColors.chartColors.length],
                  size: 22,
                ),
              ),

              const SizedBox(width: 14),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.unitsSold} units • ${product.category}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Revenue
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatUSD(product.revenue),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.revenue.toLowerCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: AppColors.surfaceBorder,
            height: 1,
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beverages':
        return Iconsax.coffee;
      case 'food':
        return Iconsax.reserve;
      case 'bakery':
        return Iconsax.cake;
      case 'snacks':
        return Iconsax.box_1;
      default:
        return Iconsax.shopping_bag;
    }
  }
}
