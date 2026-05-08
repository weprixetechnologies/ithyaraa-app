import '../../domain/entities/cart_state.dart';
import 'cart_item_model.dart';
import 'cart_summary_model.dart';

/// Cart state model for data layer
class CartStateModel extends CartState {
  const CartStateModel({
    super.items = const [],
    required super.summary,
    super.cartID,
  });

  factory CartStateModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final summaryJson = json['summary'] as Map<String, dynamic>?;
    final summary = summaryJson != null
        ? CartSummaryModel.fromJson(summaryJson)
        : const CartSummaryModel(
            subtotal: 0.0,
            total: 0.0,
            totalDiscount: 0.0,
          );

    String? parseStringNullable(dynamic value) {
      if (value == null) return null;
      if (value is String) return value.isEmpty ? null : value;
      if (value is int) return value.toString();
      if (value is num) return value.toString();
      return value.toString();
    }

    return CartStateModel(
      items: items,
      summary: summary,
      cartID: parseStringNullable(json['cartID']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => (item as CartItemModel).toJson()).toList(),
      'summary': (summary as CartSummaryModel).toJson(),
      'cartID': cartID,
    };
  }
}
