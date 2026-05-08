import '../../domain/entities/order_summary.dart';

/// Order summary model for data layer
class OrderSummaryModel extends OrderSummaryEntity {
  const OrderSummaryModel({
    required super.orderID,
    required super.total,
    required super.paymentMode,
    required super.paymentStatus,
    required super.orderStatus,
    required super.orderCreatedAt,
    required super.itemCount,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse numeric values (handles both String and num)
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    // Helper function to safely parse orderID (handles int, String, and null)
    String _parseOrderID(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is num) return value.toString();
      return value.toString();
    }

    return OrderSummaryModel(
      orderID: _parseOrderID(
        json['orderID'],
      ), // Alphanumeric order ID (handles int/String)
      total: _parseDouble(json['total']),
      paymentMode: json['paymentMode']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      orderCreatedAt: DateTime.parse(
        json['orderCreatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      itemCount: _parseInt(json['itemCount']),
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
      'itemCount': itemCount,
    };
  }
}
