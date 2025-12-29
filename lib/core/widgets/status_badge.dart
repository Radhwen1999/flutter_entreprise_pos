import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Status badge for orders and products
class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.fontSize = 12,
    this.padding,
    this.icon,
  });

  /// Pending status badge
  factory StatusBadge.pending() => const StatusBadge(
        text: 'Pending',
        backgroundColor: AppColors.warningBg,
        textColor: AppColors.warning,
        icon: Icons.schedule_rounded,
      );

  /// Completed status badge
  factory StatusBadge.completed() => const StatusBadge(
        text: 'Completed',
        backgroundColor: AppColors.successBg,
        textColor: AppColors.success,
        icon: Icons.check_circle_outline_rounded,
      );

  /// Cancelled status badge
  factory StatusBadge.cancelled() => const StatusBadge(
        text: 'Cancelled',
        backgroundColor: AppColors.errorBg,
        textColor: AppColors.error,
        icon: Icons.cancel_outlined,
      );

  /// Processing status badge
  factory StatusBadge.processing() =>  StatusBadge(
        text: 'Processing',
        backgroundColor: AppColors.info.withOpacity(0.1),
        textColor: AppColors.info,
        icon: Icons.sync_rounded,
      );

  /// In stock status badge
  factory StatusBadge.inStock() => const StatusBadge(
        text: 'In Stock',
        backgroundColor: AppColors.successBg,
        textColor: AppColors.success,
      );

  /// Low stock status badge
  factory StatusBadge.lowStock() => const StatusBadge(
        text: 'Low Stock',
        backgroundColor: AppColors.warningBg,
        textColor: AppColors.warning,
      );

  /// Out of stock status badge
  factory StatusBadge.outOfStock() => const StatusBadge(
        text: 'Out of Stock',
        backgroundColor: AppColors.errorBg,
        textColor: AppColors.error,
      );

  /// Online status badge
  factory StatusBadge.online() => const StatusBadge(
        text: 'Online',
        backgroundColor: AppColors.successBg,
        textColor: AppColors.success,
        icon: Icons.wifi_rounded,
      );

  /// Offline status badge
  factory StatusBadge.offline() => const StatusBadge(
        text: 'Offline',
        backgroundColor: AppColors.errorBg,
        textColor: AppColors.error,
        icon: Icons.wifi_off_rounded,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: textColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stock indicator with color-coded level
class StockIndicator extends StatelessWidget {
  final int stock;
  final int lowStockThreshold;
  final bool showText;

  const StockIndicator({
    super.key,
    required this.stock,
    this.lowStockThreshold = 10,
    this.showText = true,
  });

  Color get _color {
    if (stock == 0) return AppColors.stockLow;
    if (stock <= lowStockThreshold) return AppColors.stockLow;
    if (stock <= lowStockThreshold * 3) return AppColors.stockMedium;
    return AppColors.stockHigh;
  }

  String get _status {
    if (stock == 0) return 'Out of Stock';
    if (stock <= lowStockThreshold) return 'Low Stock';
    return 'In Stock';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            '$stock in stock',
            style: TextStyle(
              color: _color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Sync status indicator
class SyncIndicator extends StatelessWidget {
  final int pendingSyncs;
  final bool isSyncing;

  const SyncIndicator({
    super.key,
    required this.pendingSyncs,
    this.isSyncing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: pendingSyncs > 0 ? AppColors.warningBg : AppColors.successBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSyncing)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
              ),
            )
          else
            Icon(
              pendingSyncs > 0
                  ? Icons.cloud_upload_outlined
                  : Icons.cloud_done_outlined,
              size: 16,
              color: pendingSyncs > 0 ? AppColors.warning : AppColors.success,
            ),
          const SizedBox(width: 8),
          Text(
            pendingSyncs > 0 ? '$pendingSyncs pending' : 'Synced',
            style: TextStyle(
              color: pendingSyncs > 0 ? AppColors.warning : AppColors.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
