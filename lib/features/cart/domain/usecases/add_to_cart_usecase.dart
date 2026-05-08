import '../entities/add_to_cart_params.dart';
import '../entities/add_to_cart_response.dart';
import '../repositories/cart_repository.dart';

/// Use case for adding item to cart
class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<AddToCartResponse> call(AddToCartParams params) async {
    return await repository.addToCart(params);
  }
}
