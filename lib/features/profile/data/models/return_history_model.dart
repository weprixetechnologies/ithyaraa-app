import 'dart:convert';
import '../../domain/entities/return_history.dart';

class ReturnHistoryResponse extends ReturnHistoryResponseEntity {
  ReturnHistoryResponse({
    required super.success,
    required super.returns,
  });

  factory ReturnHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReturnHistoryResponse(
      success: json['success'] as bool? ?? false,
      returns: (json['returns'] as List? ?? [])
          .map((e) => ReturnedOrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReturnedOrderModel extends ReturnedOrderEntity {
  ReturnedOrderModel({
    required super.orderID,
    required super.orderCreatedAt,
    super.deliveredAt,
    required super.items,
  });

  factory ReturnedOrderModel.fromJson(Map<String, dynamic> json) {
    return ReturnedOrderModel(
      orderID: json['orderID']?.toString() ?? '',
      orderCreatedAt: DateTime.parse(json['orderCreatedAt'] as String? ?? DateTime.now().toIso8601String()),
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      items: (json['items'] as List? ?? [])
          .map((e) => ReturnedItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReturnedItemModel extends ReturnedItemEntity {
  ReturnedItemModel({
    required super.orderItemID,
    required super.name,
    super.variationName,
    required super.quantity,
    required super.lineTotalAfter,
    super.featuredImage,
    required super.returnStatus,
    super.returnRequestedAt,
    super.returnRejectionReason,
    super.returnTrackingCode,
    super.returnTrackingUrl,
    super.returnDeliveryCompany,
  });

  factory ReturnedItemModel.fromJson(Map<String, dynamic> json) {
    return ReturnedItemModel(
      orderItemID: json['orderItemID']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      variationName: json['variationName'] as String?,
      quantity: _parseInt(json['quantity']),
      lineTotalAfter: _parseDouble(json['lineTotalAfter']),
      featuredImage: _parseFeaturedImage(json['featuredImage']),
      returnStatus: json['returnStatus'] as String? ?? '',
      returnRequestedAt: json['returnRequestedAt'] != null ? DateTime.parse(json['returnRequestedAt'] as String) : null,
      returnRejectionReason: json['returnRejectionReason'] as String?,
      returnTrackingCode: json['returnTrackingCode'] as String?,
      returnTrackingUrl: json['returnTrackingUrl'] as String?,
      returnDeliveryCompany: json['returnDeliveryCompany'] as String?,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String? _parseFeaturedImage(dynamic featuredImage) {
    if (featuredImage == null) return null;
    
    // If it's already a simple URL string
    if (featuredImage is String && !featuredImage.startsWith('{') && !featuredImage.startsWith('[')) {
      return featuredImage;
    }

    if (featuredImage is String) {
      try {
        final decoded = json.decode(featuredImage);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded[0]['imgUrl'] as String? ?? decoded[0]['url'] as String?;
        } else if (decoded is Map) {
          return decoded['imgUrl'] as String? ?? decoded['url'] as String?;
        }
      } catch (_) {}
      return featuredImage; // Fallback to raw string
    }

    if (featuredImage is List && featuredImage.isNotEmpty) {
      final first = featuredImage[0];
      if (first is Map) {
        return first['imgUrl'] as String? ?? first['url'] as String?;
      }
    }
    
    if (featuredImage is Map) {
      return featuredImage['imgUrl'] as String? ?? featuredImage['url'] as String?;
    }

    return null;
  }
}
