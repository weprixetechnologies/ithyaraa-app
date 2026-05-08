import 'cart_item.dart';
import 'cart_summary.dart';

/// Cart state entity
class CartState {
  final List<CartItem> items;
  final CartSummary summary;
  final String? cartID;

  const CartState({
    this.items = const [],
    required this.summary,
    this.cartID,
  });

  CartState copyWith({
    List<CartItem>? items,
    CartSummary? summary,
    String? cartID,
  }) {
    return CartState(
      items: items ?? this.items,
      summary: summary ?? this.summary,
      cartID: cartID ?? this.cartID,
    );
  }

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}
