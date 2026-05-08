import '../repositories/cart_repository.dart';

/// Use case for removing item from cart
class RemoveCartItemUseCase {
  final CartRepository repository;

  RemoveCartItemUseCase(this.repository);

  Future<void> call(String cartItemID) async {
    await repository.removeCartItem(cartItemID);
  }
}
