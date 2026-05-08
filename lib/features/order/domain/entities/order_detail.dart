import 'order_item.dart';

/// Order detail entity containing full order information
class OrderDetailEntity {
  final String orderID; // Alphanumeric order ID
  final double total;
  final String paymentMode;
  final String paymentStatus;
  final String orderStatus;
  final DateTime orderCreatedAt;
  final DateTime? deliveredAt;
  final List<OrderItemEntity> items;
  final Map<String, dynamic>? userMeta; // User metadata if provided
  final Map<String, dynamic>? orderMeta; // Additional order metadata

  const OrderDetailEntity({
    required this.orderID,
    required this.total,
    required this.paymentMode,
    required this.paymentStatus,
    required this.orderStatus,
    required this.orderCreatedAt,
    this.deliveredAt,
    required this.items,
    this.userMeta,
    this.orderMeta,
  });
}
