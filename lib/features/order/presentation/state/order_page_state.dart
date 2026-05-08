import '../../domain/entities/order_summary.dart';

/// State for a single page of orders
class OrderPageState {
  final List<OrderSummaryEntity> orders;
  final DateTime? fetchedAt;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const OrderPageState({
    this.orders = const [],
    this.fetchedAt,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  OrderPageState copyWith({
    List<OrderSummaryEntity>? orders,
    DateTime? fetchedAt,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
  }) {
    return OrderPageState(
      orders: orders ?? this.orders,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }

  /// Check if page data is stale (older than 90 seconds)
  bool get isStale {
    if (fetchedAt == null) return true;
    final age = DateTime.now().difference(fetchedAt!);
    return age.inSeconds > 90;
  }

  /// Check if page has data
  bool get hasData => orders.isNotEmpty;

  /// Check if page is currently being fetched
  bool get isFetching => isLoading || isRefreshing;
}
