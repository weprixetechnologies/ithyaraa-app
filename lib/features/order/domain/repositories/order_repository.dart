import '../entities/order_detail.dart';
import '../entities/order_history_response.dart';

/// Repository interface for order operations
abstract class OrderRepository {
  /// Get paginated order history
  /// [orderID] is optional - if provided, filters to a specific order ID (partial match for search)
  /// [status] is optional - filters by order status (exact match)
  /// [paymentStatus] is optional - filters by payment status (exact match)
  /// [sortField] is optional - field to sort by (default: createdAt)
  /// [sortOrder] is optional - sort direction: "asc" or "desc" (default: desc)
  Future<OrderHistoryResponseEntity> getOrderHistory({
    required int page,
    int limit = 10,
    String? orderID,
    String? status,
    String? paymentStatus,
    String? sortField,
    String? sortOrder,
  });

  /// Get order detail by order ID (alphanumeric)
  Future<OrderDetailEntity> getOrderDetail(String orderID);

  /// Send invoice email for an order
  Future<void> sendInvoiceEmail(String orderID);

  /// Place order from current cart selection
  /// Returns raw response map as per API documentation
  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> body);

  /// Apply coupon against current cart
  /// Returns raw response map with server-calculated totals/discounts
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  });

  /// Submit return request for an item or entire order
  Future<void> returnOrder({
    required String orderID,
    String? orderItemID,
    required String returnType,
    required String returnReason,
    String? returnComments,
    List<String>? returnPhotos,
  });
}
