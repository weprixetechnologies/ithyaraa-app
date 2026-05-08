import '../../domain/entities/order_detail.dart';
import 'order_item_model.dart';
import 'dart:developer' as developer;

/// Order detail model for data layer
class OrderDetailModel extends OrderDetailEntity {
  const OrderDetailModel({
    required super.orderID,
    required super.total,
    required super.paymentMode,
    required super.paymentStatus,
    required super.orderStatus,
    required super.orderCreatedAt,
    super.deliveredAt,
    required super.items,
    super.userMeta,
    super.orderMeta,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values (handles both String and num)
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Handle different response structures
    final orderDetail = json['orderDetail'] as Map<String, dynamic>? ?? json;
    final itemsList = json['items'] as List? ?? [];

    // Helper function to safely parse orderID (handles int, String, and null)
    String _parseOrderID(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is num) return value.toString();
      return value.toString();
    }

    // Parse orderID from first item if not in root
    String orderID = '';
    if (itemsList.isNotEmpty) {
      final firstItem = itemsList.first;
      if (firstItem is Map) {
        orderID = _parseOrderID(firstItem['orderID']);
      }
    }
    orderID = orderID.isEmpty 
        ? _parseOrderID(orderDetail['orderID'] ?? json['orderID'])
        : orderID;

    // Calculate total from items if not provided
    double total = _parseDouble(orderDetail['total'] ?? json['total']);
    if (total == 0.0 && itemsList.isNotEmpty) {
      for (final item in itemsList) {
        if (item is Map<String, dynamic>) {
          total += _parseDouble(item['lineTotalAfter'] ?? item['price']);
        }
      }
    }

    // Parse date safely
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    DateTime? parseDateOptional(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        return null;
      }
    }

    return OrderDetailModel(
      orderID: orderID,
      total: total,
      paymentMode: orderDetail['paymentMode']?.toString() ?? 
                   json['paymentMode']?.toString() ?? '',
      paymentStatus: orderDetail['paymentStatus']?.toString() ?? 
                     json['paymentStatus']?.toString() ?? '',
      orderStatus: orderDetail['orderStatus']?.toString() ?? 
                   json['orderStatus']?.toString() ?? '',
      orderCreatedAt: parseDate(orderDetail['orderCreatedAt'] ?? json['orderCreatedAt']),
      deliveredAt: parseDateOptional(orderDetail['deliveredAt'] ?? json['deliveredAt']),
      items: itemsList.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value as Map<String, dynamic>;
        
        // Log variationValues for each item with index
        developer.log(
          'OrderDetailModel - Parsing item[$index]',
          name: 'OrderDetailModel',
        );
        developer.log(
          '  item[$index].variationValues: ${item['variationValues']}',
          name: 'OrderDetailModel',
        );
        
        return OrderItemModel.fromJson(item);
      }).toList(),
      userMeta: json['userMeta'] as Map<String, dynamic>?,
      orderMeta: orderDetail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'total': total,
      'paymentMode': paymentMode,
      'paymentStatus': paymentStatus,
      'orderStatus': orderStatus,
      'orderCreatedAt': orderCreatedAt.toIso8601String(),
      'items': items.map((item) => (item as OrderItemModel).toJson()).toList(),
      if (userMeta != null) 'userMeta': userMeta,
      if (orderMeta != null) 'orderMeta': orderMeta,
    };
  }
}
