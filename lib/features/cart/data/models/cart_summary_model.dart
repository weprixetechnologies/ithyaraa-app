import '../../domain/entities/cart_summary.dart';

/// Cart summary model for data layer
class CartSummaryModel extends CartSummary {
  const CartSummaryModel({
    required super.subtotal,
    required super.total,
    required super.totalDiscount,
    super.shipping,
    super.anyModifications,
  });

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    double parsePrice(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) {
        return value != 0; // Handle int values: 0 = false, non-zero = true
      }
      if (value is String) {
        final lower = value.toLowerCase();
        return lower == 'true' || lower == '1' || lower == 'yes';
      }
      return false;
    }

    return CartSummaryModel(
      subtotal: parsePrice(json['subtotal']),
      total: parsePrice(json['total']),
      totalDiscount: parsePrice(json['totalDiscount']),
      shipping: parsePrice(json['shipping']),
      anyModifications: parseBool(json['anyModifications']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'total': total,
      'totalDiscount': totalDiscount,
      'shipping': shipping,
      'anyModifications': anyModifications,
    };
  }
}
