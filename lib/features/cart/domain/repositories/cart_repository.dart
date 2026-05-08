import '../entities/add_to_cart_params.dart';
import '../entities/add_to_cart_response.dart';
import '../entities/cart_state.dart';
import '../entities/add_combo_to_cart_params.dart';

/// Repository interface for cart operations
abstract class CartRepository {
  Future<AddToCartResponse> addToCart(AddToCartParams params);
  Future<AddToCartResponse> addComboToCart(AddComboToCartParams params);
  Future<CartState> getCart();
  Future<void> removeCartItem(String cartItemID);
  Future<CartState> updateCartSelection(List<String> selectedItems);
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  });

  Future<void> autoUpdateCartSelection();
}
