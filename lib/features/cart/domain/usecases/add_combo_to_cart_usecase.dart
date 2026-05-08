import '../entities/add_combo_to_cart_params.dart';
import '../entities/add_to_cart_response.dart';
import '../repositories/cart_repository.dart';

/// Use case for adding combo product to cart
class AddComboToCartUseCase {
  final CartRepository repository;

  AddComboToCartUseCase(this.repository);

  Future<AddToCartResponse> call(AddComboToCartParams params) async {
    return await repository.addComboToCart(params);
  }
}
