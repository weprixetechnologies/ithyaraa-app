class ReturnHistoryResponseEntity {
  final bool success;
  final List<ReturnedOrderEntity> returns;

  const ReturnHistoryResponseEntity({
    required this.success,
    required this.returns,
  });
}

class ReturnedOrderEntity {
  final String orderID;
  final DateTime orderCreatedAt;
  final DateTime? deliveredAt;
  final List<ReturnedItemEntity> items;

  const ReturnedOrderEntity({
    required this.orderID,
    required this.orderCreatedAt,
    this.deliveredAt,
    required this.items,
  });
}

class ReturnedItemEntity {
  final String orderItemID;
  final String name;
  final String? variationName;
  final int quantity;
  final double lineTotalAfter;
  final String? featuredImage;
  final String returnStatus;
  final DateTime? returnRequestedAt;
  final String? returnRejectionReason;
  final String? returnTrackingCode;
  final String? returnTrackingUrl;
  final String? returnDeliveryCompany;

  const ReturnedItemEntity({
    required this.orderItemID,
    required this.name,
    this.variationName,
    required this.quantity,
    required this.lineTotalAfter,
    this.featuredImage,
    required this.returnStatus,
    this.returnRequestedAt,
    this.returnRejectionReason,
    this.returnTrackingCode,
    this.returnTrackingUrl,
    this.returnDeliveryCompany,
  });
}
