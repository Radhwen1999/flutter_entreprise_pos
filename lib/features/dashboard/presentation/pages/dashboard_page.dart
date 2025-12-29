import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/top_products_list.dart';
import '../widgets/low_stock_alerts.dart';
import '../widgets/quick_actions.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardLoadRequested());
  }

  Future<void> _onRefresh() async {
    context.read<DashboardBloc>().add(DashboardRefreshRequested());
    // Wait for state change
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is DashboardError) {
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
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<DashboardBloc>()
                          .add(DashboardLoadRequested());
                    },
                    icon: const Icon(Iconsax.refresh),
                    label: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded || state is DashboardRefreshing) {
            final data = state is DashboardLoaded
                ? state.data
                : (state as DashboardRefreshing).currentData;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: const DashboardHeader()
                        .animate()
                        .fadeIn(duration: 400.ms),
                  ),

                  // Stats cards
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildListDelegate([
                        StatsCard(
                          title: AppStrings.todaysSales,
                          value: CurrencyFormatter.formatUSD(data.todaysSales),
                          change: data.salesChange,
                          icon: Iconsax.money,
                          gradient: AppColors.primaryGradient,
                        )
                            .animate()
                            .fadeIn(delay: 100.ms)
                            .slideX(begin: -0.2),
                        StatsCard(
                          title: AppStrings.totalOrders,
                          value: data.totalOrders.toString(),
                          change: data.ordersChange,
                          icon: Iconsax.shopping_bag5,
                          gradient: AppColors.accentGradient,
                        )
                            .animate()
                            .fadeIn(delay: 150.ms)
                            .slideX(begin: 0.2),
                        StatsCard(
                          title: AppStrings.avgOrderValue,
                          value:
                              CurrencyFormatter.formatUSD(data.avgOrderValue),
                          icon: Iconsax.chart5,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideX(begin: -0.2),
                        StatsCard(
                          title: AppStrings.totalRevenue,
                          value: CurrencyFormatter.formatUSDCompact(
                              data.totalRevenue),
                          subtitle: AppStrings.thisWeek,
                          icon: Iconsax.money_45,
                          gradient: AppColors.successGradient,
                        )
                            .animate()
                            .fadeIn(delay: 250.ms)
                            .slideX(begin: 0.2),
                      ]),
                    ),
                  ),

                  // Sales Chart
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: SalesChart(salesData: data.salesChart)
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.2),
                    ),
                  ),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: const QuickActions()
                          .animate()
                          .fadeIn(delay: 350.ms)
                          .slideY(begin: 0.2),
                    ),
                  ),

                  // Top Products
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: TopProductsList(products: data.topProducts)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.2),
                    ),
                  ),

                  // Low Stock Alerts
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: LowStockAlerts(items: data.lowStockAlerts)
                          .animate()
                          .fadeIn(delay: 450.ms)
                          .slideY(begin: 0.2),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
