class PresaleBookingEntity {
  final String preBookingID;
  final String uid;
  final String? paymentMode;
  final String paymentStatus;
  final String orderStatus;
  final String status;
  final double subtotal;
  final double totalDiscount;
  final double total;
  final DateTime createdAt;
  final int itemCount;
  final List<PresaleBookingItemEntity>? items;
  final PresaleAddressEntity? deliveryAddress;

  PresaleBookingEntity({
    required this.preBookingID,
    required this.uid,
    this.paymentMode,
    required this.paymentStatus,
    required this.orderStatus,
    required this.status,
    required this.subtotal,
    required this.totalDiscount,
    required this.total,
    required this.createdAt,
    this.itemCount = 0,
    this.items,
    this.deliveryAddress,
  });
}

class PresaleBookingItemEntity {
  final String productID;
  final String name;
  final int quantity;
  final String? variationID;
  final String? variationName;
  final double salePrice;
  final double regularPrice;
  final double lineTotalBefore;
  final double lineTotalAfter;
  final List<String> featuredImage;

  PresaleBookingItemEntity({
    required this.productID,
    required this.name,
    required this.quantity,
    this.variationID,
    this.variationName,
    required this.salePrice,
    required this.regularPrice,
    required this.lineTotalBefore,
    required this.lineTotalAfter,
    required this.featuredImage,
  });
}

class PresaleAddressEntity {
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final String? phoneNumber;

  PresaleAddressEntity({
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    this.phoneNumber,
  });
}
