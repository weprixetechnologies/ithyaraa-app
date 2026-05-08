import '../../domain/entities/add_to_cart_params.dart';
import '../../domain/entities/add_to_cart_response.dart';
import '../../domain/entities/cart_state.dart';
import '../../domain/entities/add_combo_to_cart_params.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

/// Repository implementation for cart operations
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AddToCartResponse> addToCart(AddToCartParams params) async {
    final response = await remoteDataSource.addToCart(
      productID: params.productID,
      quantity: params.quantity,
      variationID: params.variationID,
      variationName: params.variationName,
      referBy: params.referBy,
      customInputs: params.customInputs,
      selectedDressType: params.selectedDressType,
    );
    return response;
  }

  @override
  Future<AddToCartResponse> addComboToCart(AddComboToCartParams params) async {
    final response = await remoteDataSource.addComboToCart(
      mainProductID: params.mainProductID,
      quantity: params.quantity,
      products: params.products,
    );
    return response;
  }

  @override
  Future<CartState> getCart() async {
    return await remoteDataSource.getCart();
  }

  @override
  Future<void> removeCartItem(String cartItemID) async {
    await remoteDataSource.removeCartItem(cartItemID: cartItemID);
  }

  @override
  Future<CartState> updateCartSelection(List<String> selectedItems) async {
    return await remoteDataSource.updateCartSelection(
      selectedItems: selectedItems,
    );
  }

  @override
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    int? cartID,
  }) async {
    return await remoteDataSource.applyCoupon(
      couponCode: couponCode,
      cartID: cartID,
    );
  }

  @override
  Future<void> autoUpdateCartSelection() async {
    await remoteDataSource.autoUpdateCartSelection();
  }
}
