import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/dashboard_data.dart';

enum ChartPeriod { day, week, month }

class SalesChart extends StatefulWidget {
  final List<SalesDataPoint> salesData;

  const SalesChart({
    super.key,
    required this.salesData,
  });

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart>
    with SingleTickerProviderStateMixin {
  int? _touchedIndex;
  ChartPeriod _selectedPeriod = ChartPeriod.week;
  List<SalesDataPoint> _currentData = [];
  late AnimationController _animationController;

  bool get _isExpanded => _selectedPeriod == ChartPeriod.day || _selectedPeriod == ChartPeriod.month;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );


    _updateData();
    if (_isExpanded) {
      _animationController.forward();
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateData() {
    setState(() {
      _currentData = _generateDataForPeriod(_selectedPeriod);
    });
    // Trigger animation when period changes
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  List<SalesDataPoint> _generateDataForPeriod(ChartPeriod period) {
    final random = Random();
    final now = DateTime.now();

    switch (period) {
      case ChartPeriod.day:
        // Generate 6 data points (every 4 hours: 0, 4, 8, 12, 16, 20)
        return List.generate(6, (index) {
          final hour = index * 4;
          final date = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
          );
          final baseAmount = 100 + random.nextDouble() * 400;
          final orders = 1 + random.nextInt(8);
          return SalesDataPoint(
            date: date,
            amount: baseAmount,
            orders: orders,
          );
        });
      case ChartPeriod.week:
        // Generate 7 days of data
        return List.generate(7, (index) {
          final date = now.subtract(Duration(days: 6 - index));
          final baseAmount = 2000 + random.nextDouble() * 3000;
          final orders = 30 + random.nextInt(50);
          return SalesDataPoint(
            date: date,
            amount: baseAmount,
            orders: orders,
          );
        });
      case ChartPeriod.month:
        // Generate 4 data points (every 7 days: day 0, 7, 14, 21, 28)
        return List.generate(4, (index) {
          final daysAgo = 28 - (index * 7);
          final date = now.subtract(Duration(days: daysAgo));
          final baseAmount = 1500 + random.nextDouble() * 3500;
          final orders = 20 + random.nextInt(60);
          return SalesDataPoint(
            date: date,
            amount: baseAmount,
            orders: orders,
          );
        });
    }
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return AppStrings.perDay;
      case ChartPeriod.week:
        return AppStrings.last7Days;
      case ChartPeriod.month:
        return AppStrings.perMonth;
    }
  }

  String _formatDateLabel(DateTime date) {
    switch (_selectedPeriod) {
      case ChartPeriod.day:
        return DateFormat('HH:mm').format(date);
      case ChartPeriod.week:
        return DateFormatter.shortDayOfWeek(date);
      case ChartPeriod.month:
        return DateFormat('MMM d').format(date);
    }
  }

  void _showFullscreenChart() {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              // Fullscreen chart container
              Center(
                child: Container(
                  width: screenSize.width,
                  height: screenSize.height,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // Header with title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              AppStrings.salesOverview,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Period filters
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PeriodFilterButton(
                              label: AppStrings.perDay,
                              isSelected: _selectedPeriod == ChartPeriod.day,
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = ChartPeriod.day;
                                  _updateData();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _PeriodFilterButton(
                              label: AppStrings.perWeek,
                              isSelected: _selectedPeriod == ChartPeriod.week,
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = ChartPeriod.week;
                                  _updateData();
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _PeriodFilterButton(
                              label: AppStrings.perMonth,
                              isSelected: _selectedPeriod == ChartPeriod.month,
                              onTap: () {
                                setState(() {
                                  _selectedPeriod = ChartPeriod.month;
                                  _updateData();
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LegendItem(
                              color: AppColors.primary,
                              label: AppStrings.revenue,
                            ),
                            const SizedBox(width: 16),
                            _LegendItem(
                              color: AppColors.secondary,
                              label: AppStrings.orders,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Fullscreen chart
                        Expanded(
                          child: LineChart(_buildChartData()),
                        ),
                      ],
                    ),
                  ),
              ),
              // Close button
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(
                    Iconsax.close_circle,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = constraints.maxWidth;
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final expandedWidth = baseWidth;
            // When expanded, chart scales with expanded width for better label visibility
            final chartHeight =  200.0;
            return Container(
                width: expandedWidth,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  AppStrings.salesOverview,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getPeriodLabel(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Legend and fullscreen button
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _LegendItem(
                                color: AppColors.primary,
                                label: AppStrings.revenue,
                              ),
                              const SizedBox(width: 12),
                              _LegendItem(
                                color: AppColors.secondary,
                                label: AppStrings.orders,
                              ),
                              const SizedBox(width: 8),
                              // Fullscreen button
                              IconButton(
                                icon: const Icon(
                                  Iconsax.maximize_4,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: _showFullscreenChart,
                                tooltip: 'Fullscreen',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                  const SizedBox(height: 16),

                  // Period filters
                  Row(
                    children: [
                      _PeriodFilterButton(
                        label: AppStrings.perDay,
                        isSelected: _selectedPeriod == ChartPeriod.day,
                        onTap: () {
                          setState(() {
                            _selectedPeriod = ChartPeriod.day;
                          });
                          _updateData();
                        },
                      ),
                      const SizedBox(width: 8),
                      _PeriodFilterButton(
                        label: AppStrings.perWeek,
                        isSelected: _selectedPeriod == ChartPeriod.week,
                        onTap: () {
                          setState(() {
                            _selectedPeriod = ChartPeriod.week;
                          });
                          _updateData();
                        },
                      ),
                      const SizedBox(width: 8),
                      _PeriodFilterButton(
                        label: AppStrings.perMonth,
                        isSelected: _selectedPeriod == ChartPeriod.month,
                        onTap: () {
                          setState(() {
                            _selectedPeriod = ChartPeriod.month;
                          });
                          _updateData();
                        },
                      ),
                    ],
                  ),

                    const SizedBox(height: 24),

                    // Chart - scales with expanded width for better visibility
                    SizedBox(
                      height: chartHeight,
                      child: LineChart(
                        _buildChartData(),
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),
                  ],
                ),
            );
          },
        );
      },
    );
  }

  LineChartData _buildChartData() {
    // Calculate spots for revenue (in thousands) and orders (scaled for visibility)
    final revenueSpots = _currentData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.amount / 1000, // Convert to thousands
      );
    }).toList();

    // Scale orders to match revenue scale (divide by appropriate factor)
    // Revenue is in thousands (divided by 1000), orders need similar scaling
    // Typical orders: 30-80, typical revenue: $2000-$5000 (2-5 after /1000)
    // To get orders in similar range: divide by ~20 to get 1.5-4 range
    final orderSpots = _currentData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.orders.toDouble() / 20, // Scale to match revenue scale
      );
    }).toList();

    // Calculate max revenue for grid intervals
    final maxRevenue = revenueSpots.map((s) => s.y).reduce(max);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxRevenue / 4, // Use revenue scale for grid
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.surfaceBorder,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toInt()}k',
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _isExpanded ? 40 : 28, // More space when expanded for better labels
            interval: 1, // Show all points since we're generating fewer data points
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= _currentData.length) {
                return const SizedBox.shrink();
              }
              final date = _currentData[index].date;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatDateLabel(date),
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: _isExpanded ? 12 : 11, // Larger font when expanded
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => AppColors.surfaceLight,
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.all(12),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final dataPoint = _currentData[spot.spotIndex];
              return LineTooltipItem(
                '${DateFormatter.shortDate(dataPoint.date)}\n',
                const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                children: [
                  TextSpan(
                    text: CurrencyFormatter.formatUSD(dataPoint.amount),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: '\n${dataPoint.orders} ${AppStrings.orders.toLowerCase()}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
        touchCallback: (event, response) {
          if (event is FlTapUpEvent || event is FlPanEndEvent) {
            setState(() => _touchedIndex = null);
          } else if (response?.lineBarSpots != null) {
            setState(() => _touchedIndex = response?.lineBarSpots?.first.spotIndex);
          }
        },
      ),
      lineBarsData: [
        // Revenue line (purple)
        LineChartBarData(
          spots: revenueSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isSelected = _touchedIndex == index;
              return FlDotCirclePainter(
                radius: isSelected ? 6 : 4,
                color: AppColors.primary,
                strokeWidth: isSelected ? 3 : 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.3),
                AppColors.primary.withOpacity(0),
              ],
            ),
          ),
        ),
        // Orders line (green/cyan)
        LineChartBarData(
          spots: orderSpots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: AppColors.secondary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isSelected = _touchedIndex == index;
              return FlDotCirclePainter(
                radius: isSelected ? 6 : 4,
                color: AppColors.secondary,
                strokeWidth: isSelected ? 3 : 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PeriodFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
