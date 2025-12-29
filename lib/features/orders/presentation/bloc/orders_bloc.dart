import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/orders_local_datasource.dart';
import '../../domain/entities/order.dart';

// ═══════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoadRequested extends OrdersEvent {}

class OrdersRefreshRequested extends OrdersEvent {}

class OrdersFilterChanged extends OrdersEvent {
  final OrdersFilter filter;

  const OrdersFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

class OrdersSearchChanged extends OrdersEvent {
  final String query;

  const OrdersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

// ═══════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════

enum OrdersFilter { all, today, thisWeek, thisMonth }

extension OrdersFilterExtension on OrdersFilter {
  String get label {
    switch (this) {
      case OrdersFilter.all:
        return 'All';
      case OrdersFilter.today:
        return 'Today';
      case OrdersFilter.thisWeek:
        return 'This Week';
      case OrdersFilter.thisMonth:
        return 'This Month';
    }
  }
}

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<Order> orders;
  final List<Order> filteredOrders;
  final OrdersFilter filter;
  final String searchQuery;
  final OrdersSummary summary;

  const OrdersLoaded({
    required this.orders,
    required this.filteredOrders,
    required this.filter,
    required this.searchQuery,
    required this.summary,
  });

  OrdersLoaded copyWith({
    List<Order>? orders,
    List<Order>? filteredOrders,
    OrdersFilter? filter,
    String? searchQuery,
    OrdersSummary? summary,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [orders, filteredOrders, filter, searchQuery, summary];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Orders summary for quick stats
class OrdersSummary extends Equatable {
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;

  const OrdersSummary({
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        pendingOrders,
        completedOrders,
        cancelledOrders,
        totalRevenue,
      ];
}

// ═══════════════════════════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════════════════════════

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrdersLocalDataSource localDataSource;

  OrdersBloc({
    required this.localDataSource,
  }) : super(OrdersInitial()) {
    on<OrdersLoadRequested>(_onLoadRequested);
    on<OrdersRefreshRequested>(_onRefreshRequested);
    on<OrdersFilterChanged>(_onFilterChanged);
    on<OrdersSearchChanged>(_onSearchChanged);
  }

  Future<void> _onLoadRequested(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    try {
      final orders = await localDataSource.getOrders();
      final summary = _calculateSummary(orders);

      emit(OrdersLoaded(
        orders: orders,
        filteredOrders: orders,
        filter: OrdersFilter.all,
        searchQuery: '',
        summary: summary,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    OrdersRefreshRequested event,
    Emitter<OrdersState> emit,
  ) async {
    add(OrdersLoadRequested());
  }

  void _onFilterChanged(
    OrdersFilterChanged event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final filtered = _filterOrders(
        currentState.orders,
        event.filter,
        currentState.searchQuery,
      );
      final summary = _calculateSummary(filtered);

      emit(currentState.copyWith(
        filter: event.filter,
        filteredOrders: filtered,
        summary: summary,
      ));
    }
  }

  void _onSearchChanged(
    OrdersSearchChanged event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final filtered = _filterOrders(
        currentState.orders,
        currentState.filter,
        event.query,
      );
      final summary = _calculateSummary(filtered);

      emit(currentState.copyWith(
        searchQuery: event.query,
        filteredOrders: filtered,
        summary: summary,
      ));
    }
  }

  List<Order> _filterOrders(
    List<Order> orders,
    OrdersFilter filter,
    String query,
  ) {
    var filtered = orders;
    final now = DateTime.now();

    // Filter by date range
    switch (filter) {
      case OrdersFilter.today:
        filtered = filtered.where((o) {
          return o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day;
        }).toList();
        break;
      case OrdersFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((o) {
          return o.createdAt.isAfter(weekStart.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case OrdersFilter.thisMonth:
        filtered = filtered.where((o) {
          return o.createdAt.year == now.year && o.createdAt.month == now.month;
        }).toList();
        break;
      case OrdersFilter.all:
        break;
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      filtered = filtered.where((o) {
        return o.orderNumber.toLowerCase().contains(lowerQuery) ||
            (o.customerName?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    return filtered;
  }

  OrdersSummary _calculateSummary(List<Order> orders) {
    return OrdersSummary(
      totalOrders: orders.length,
      pendingOrders: orders.where((o) => o.status == OrderStatus.pending).length,
      completedOrders: orders.where((o) => o.status == OrderStatus.completed).length,
      cancelledOrders: orders.where((o) => o.status == OrderStatus.cancelled).length,
      totalRevenue: orders
          .where((o) => o.status == OrderStatus.completed)
          .fold(0.0, (sum, o) => sum + o.total),
    );
  }
}
