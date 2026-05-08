import '../entities/order_history_response.dart';
import '../repositories/order_repository.dart';

/// Use case for fetching paginated order history
/// [orderID] is optional - if provided, filters to a specific order ID (partial match for search)
/// [status] is optional - filters by order status (exact match)
/// [paymentStatus] is optional - filters by payment status (exact match)
/// [sortField] is optional - field to sort by (default: createdAt)
/// [sortOrder] is optional - sort direction: "asc" or "desc" (default: desc)
class GetOrderHistoryUseCase {
  final OrderRepository repository;

  GetOrderHistoryUseCase(this.repository);

  Future<OrderHistoryResponseEntity> call({
    required int page,
    int limit = 10,
    String? orderID,
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  }) async {
    return await repository.getOrderHistory(
      page: page,
      limit: limit,
      orderID: orderID,
      status: status,
      paymentStatus: paymentStatus,
      sortField: sortField,
      sortOrder: sortOrder,
    );
  }
}
