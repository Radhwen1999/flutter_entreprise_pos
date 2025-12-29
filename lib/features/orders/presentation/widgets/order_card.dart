import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header row
                Row(
                  children: [
                    // Order icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: _getStatusGradient(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Order info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.orderNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              _buildStatusBadge(),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.customerName ?? 'Walk-in Customer',
                            style: TextStyle(
                              fontSize: 13,
                              color: order.customerName != null
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: AppColors.surfaceBorder, height: 1),
                const SizedBox(height: 14),

                // Footer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Items count
                    Row(
                      children: [
                        Icon(
                          Iconsax.shopping_bag,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${order.totalItems} items',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Date
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.smartDate(order.createdAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    // Total
                    Text(
                      CurrencyFormatter.formatUSD(order.total),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    switch (order.status) {
      case OrderStatus.pending:
        return StatusBadge.pending();
      case OrderStatus.processing:
        return StatusBadge.processing();
      case OrderStatus.completed:
        return StatusBadge.completed();
      case OrderStatus.cancelled:
        return StatusBadge.cancelled();
    }
  }

  Gradient _getStatusGradient() {
    switch (order.status) {
      case OrderStatus.pending:
        return const LinearGradient(
          colors: [AppColors.warning, Color(0xFFFFBE76)],
        );
      case OrderStatus.processing:
        return const LinearGradient(
          colors: [AppColors.info, Color(0xFF60A5FA)],
        );
      case OrderStatus.completed:
        return AppColors.successGradient;
      case OrderStatus.cancelled:
        return const LinearGradient(
          colors: [AppColors.error, Color(0xFFF87171)],
        );
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Iconsax.timer;
      case OrderStatus.processing:
        return Iconsax.refresh;
      case OrderStatus.completed:
        return Iconsax.tick_circle;
      case OrderStatus.cancelled:
        return Iconsax.close_circle;
    }
  }
}
