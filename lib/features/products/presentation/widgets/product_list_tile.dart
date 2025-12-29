import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/product.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Product image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor().withOpacity(0.2),
                        _getCategoryColor().withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    size: 28,
                    color: _getCategoryColor(),
                  ),
                ),

                const SizedBox(width: 14),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (product.stock == 0)
                            StatusBadge.outOfStock()
                          else if (product.stock <= 10)
                            StatusBadge.lowStock(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _getCategoryColor(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (product.sku != null)
                            Text(
                              product.sku!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(product.price),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          StockIndicator(stock: product.stock),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Chevron
                Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (product.category.toLowerCase()) {
      case 'beverages':
        return AppColors.primary;
      case 'food':
        return AppColors.accent;
      case 'bakery':
        return const Color(0xFFE67E22);
      case 'snacks':
        return AppColors.secondary;
      case 'desserts':
        return const Color(0xFFFF6B9D);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getCategoryIcon() {
    switch (product.category.toLowerCase()) {
      case 'beverages':
        return Iconsax.coffee;
      case 'food':
        return Iconsax.reserve;
      case 'bakery':
        return Iconsax.cake;
      case 'snacks':
        return Iconsax.box_1;
      case 'desserts':
        return Iconsax.lovely;
      default:
        return Iconsax.shopping_bag;
    }
  }
}
