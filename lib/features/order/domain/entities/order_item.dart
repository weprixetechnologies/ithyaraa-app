import 'combo_item.dart';

/// Order item entity representing a single item in an order
class OrderItemEntity {
  final String orderItemID;
  final String orderID;
  final String productID;
  final String productName;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? variationID;
  final String? storedVariationName;
  final List<Map<String, dynamic>>? variationValues;
  final double? salePrice;
  final double? regularPrice;
  final double? unitPriceBefore;
  final double? unitPriceAfter;
  final double? lineTotalBefore;
  final double? lineTotalAfter;
  final String? trackingCode;
  final String? deliveryCompany;
  final String? itemStatus;
  final String? productType;
  final DateTime? createdAt;
  final List<Map<String, dynamic>>? featuredImages;
  final Map<String, dynamic>? variant; // For variable products
  final String? shippingAddress;
  final String? email;
  final String? contactNumber;
  // Combo product support: nested items for both pre-defined combos and make-combo products
  // API returns item.comboItems[] as lightweight product snapshots (NOT full order items)
  final List<ComboItemEntity>? comboItems;
  // Custom product inputs: user-provided custom data (text, images, etc.)
  // API returns item.custom_inputs as Map<String, dynamic>
  final Map<String, dynamic>? customInputs;
  // Brand name: displayed for combo sub-items and main products
  final String? brand;
  // Return support
  final String? returnStatus;
  final DateTime? returnRequestedAt;
  final String? returnRejectionReason;
  final String? returnTrackingCode;
  final String? returnTrackingUrl;
  final String? returnDeliveryCompany;

  const OrderItemEntity({
    required this.orderItemID,
    required this.orderID,
    required this.productID,
    required this.productName,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.variationID,
    this.storedVariationName,
    this.variationValues,
    this.salePrice,
    this.regularPrice,
    this.unitPriceBefore,
    this.unitPriceAfter,
    this.lineTotalBefore,
    this.lineTotalAfter,
    this.trackingCode,
    this.deliveryCompany,
    this.itemStatus,
    this.productType,
    this.createdAt,
    this.featuredImages,
    this.variant,
    this.shippingAddress,
    this.email,
    this.contactNumber,
    this.comboItems,
    this.customInputs,
    this.brand,
    this.returnStatus,
    this.returnRequestedAt,
    this.returnRejectionReason,
    this.returnTrackingCode,
    this.returnTrackingUrl,
    this.returnDeliveryCompany,
  });
}
