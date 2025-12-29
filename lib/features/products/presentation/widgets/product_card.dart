import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              _buildImage(),

              // Product details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Name
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Price and stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatUSD(product.price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          StockIndicator(
                            stock: product.stock,
                            showText: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getCategoryColor().withOpacity(0.2),
            _getCategoryColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          // Icon placeholder
          Center(
            child: Icon(
              _getCategoryIcon(),
              size: 48,
              color: _getCategoryColor().withOpacity(0.5),
            ),
          ),

          // Stock status badge
          Positioned(
            top: 10,
            right: 10,
            child: _buildStockBadge(),
          ),

          // More options
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.more,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge() {
    if (product.stock == 0) {
      return StatusBadge.outOfStock();
    } else if (product.stock <= 10) {
      return StatusBadge.lowStock();
    }
    return const SizedBox.shrink();
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
