import '../../domain/entities/order_history_response.dart';
import 'order_summary_model.dart';

/// Order history response model for data layer
class OrderHistoryResponseModel extends OrderHistoryResponseEntity {
  const OrderHistoryResponseModel({
    required super.orders,
    required super.page,
    required super.limit,
    required super.total,
    required super.hasMore,
  });

  factory OrderHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse integer values (handles both String and num)
    int _parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    bool _parseBool(dynamic value, bool defaultValue) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return defaultValue;
    }

    final dataList = json['data'] as List? ?? [];
    
    return OrderHistoryResponseModel(
      orders: dataList
          .map((item) => OrderSummaryModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: _parseInt(json['page'], 1),
      limit: _parseInt(json['limit'], 10),
      total: _parseInt(json['total'], 0),
      hasMore: _parseBool(json['hasMore'], false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': orders.map((o) => (o as OrderSummaryModel).toJson()).toList(),
      'page': page,
      'limit': limit,
      'total': total,
      'hasMore': hasMore,
    };
  }
}
