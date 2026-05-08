import 'order_summary.dart';

/// Paginated order history response entity
class OrderHistoryResponseEntity {
  final List<OrderSummaryEntity> orders;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  const OrderHistoryResponseEntity({
    required this.orders,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });
}
