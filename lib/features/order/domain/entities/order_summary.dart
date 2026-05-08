/// Order summary entity for order history list
class OrderSummaryEntity {
  final String orderID; // Alphanumeric order ID
  final double total;
  final String paymentMode;
  final String paymentStatus;
  final String orderStatus;
  final DateTime orderCreatedAt;
  final int itemCount;

  const OrderSummaryEntity({
    required this.orderID,
    required this.total,
    required this.paymentMode,
    required this.paymentStatus,
    required this.orderStatus,
    required this.orderCreatedAt,
    required this.itemCount,
  });
}
