import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  Timer? _realtimeTimer;
  double _liveSales = 0;
  int _liveOrders = 0;
  DateTime _lastSync = DateTime.now();
  bool _isSyncing = false;

  final List<_RealtimeSale> _recentSales = [];

  @override
  void initState() {
    super.initState();
    _initializeLiveData();
    _startRealtimeSimulation();
  }

  void _initializeLiveData() {
    final random = Random();
    _liveSales = 2500 + random.nextDouble() * 1500;
    _liveOrders = 35 + random.nextInt(20);
  }

  void _startRealtimeSimulation() {
    _realtimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final random = Random();
      final saleAmount = 5 + random.nextDouble() * 45;
      final products = [
        'Cappuccino',
        'Latte',
        'Croissant',
        'Sandwich',
        'Salad'
      ];

      setState(() {
        _liveSales += saleAmount;
        _liveOrders++;
        _recentSales.insert(
          0,
          _RealtimeSale(
            product: products[random.nextInt(products.length)],
            amount: saleAmount,
            time: DateTime.now(),
          ),
        );
        if (_recentSales.length > 5) {
          _recentSales.removeLast();
        }
      });
    });
  }

  void _syncData() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSyncing = false;
      _lastSync = DateTime.now();
    });
  }

  @override
  void dispose() {
    _realtimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Live stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildLiveStats(),
              ),
            ),

            // Recent sales feed
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildRecentSalesFeed(),
              ),
            ),

            // Revenue by category
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildCategoryChart(),
              ),
            ),

            // Peak hours
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: _buildPeakHoursChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.analytics,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Real-time insights',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Sync button
          GestureDetector(
            onTap: _isSyncing ? null : _syncData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_isSyncing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  else
                    const Icon(
                      Iconsax.refresh,
                      size: 18,
                      color: Colors.white,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    _isSyncing ? 'Syncing...' : 'Sync',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.success.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3))
                .then()
                .scale(begin: const Offset(1.3, 1.3), end: const Offset(1, 1)),
            const SizedBox(width: 8),
            const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _LiveStatCard(
                title: "Today's Sales",
                value: CurrencyFormatter.formatUSD(_liveSales),
                icon: Iconsax.dollar_circle5,
                gradient: AppColors.primaryGradient,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _LiveStatCard(
                title: 'Orders',
                value: _liveOrders.toString(),
                icon: Iconsax.shopping_bag5,
                gradient: AppColors.accentGradient,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentSalesFeed() {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Sales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Live Feed',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentSales.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Waiting for sales...',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            )
          else
            ...List.generate(
              _recentSales.length,
              (index) => _SaleItem(sale: _recentSales[index])
                  .animate()
                  .fadeIn()
                  .slideX(begin: -0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart() {
    final categoryData = [
      _CategoryData('Beverages', 4500, AppColors.primary),
      _CategoryData('Food', 3200, AppColors.accent),
      _CategoryData('Bakery', 1800, const Color(0xFFE67E22)),
      _CategoryData('Snacks', 900, AppColors.secondary),
      _CategoryData('Desserts', 600, const Color(0xFFFF6B9D)),
    ];

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.revenueByCategory,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: categoryData.map((data) {
                        return PieChartSectionData(
                          value: data.value,
                          color: data.color,
                          title: '',
                          radius: 35,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryData.map((data) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: data.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data.category,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHoursChart() {
    final hourlyData = List.generate(12, (index) {
      final random = Random(index);
      return _HourlyData(
        hour: '${8 + index}:00',
        orders: 5 + random.nextInt(45),
      );
    });

    final maxOrders = hourlyData.map((e) => e.orders).reduce(max).toDouble();

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.peakHours,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Orders per hour today',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxOrders + 10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.surface,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${hourlyData[group.x].hour}\n',
                        const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${hourlyData[group.x].orders} orders',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= hourlyData.length) {
                          return const SizedBox.shrink();
                        }
                        final hour = hourlyData[value.toInt()].hour;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            hour.split(':')[0],
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: hourlyData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final isPeak = data.orders > maxOrders * 0.7;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.orders.toDouble(),
                        gradient: isPeak
                            ? AppColors.primaryGradient
                            : LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.4),
                                  AppColors.primary.withOpacity(0.2),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _LiveStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn()
        .scale(begin: const Offset(0.95, 0.95), duration: 300.ms);
  }
}

class _RealtimeSale {
  final String product;
  final double amount;
  final DateTime time;

  _RealtimeSale({
    required this.product,
    required this.amount,
    required this.time,
  });
}

class _SaleItem extends StatelessWidget {
  final _RealtimeSale sale;

  const _SaleItem({required this.sale});

  @override
  Widget build(BuildContext context) {
    final timeAgo = DateTime.now().difference(sale.time);
    final timeText = timeAgo.inSeconds < 60
        ? '${timeAgo.inSeconds}s ago'
        : '${timeAgo.inMinutes}m ago';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              sale.product,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.formatUSD(sale.amount),
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            timeText,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String category;
  final double value;
  final Color color;

  _CategoryData(this.category, this.value, this.color);
}

class _HourlyData {
  final String hour;
  final int orders;

  _HourlyData({required this.hour, required this.orders});
}
