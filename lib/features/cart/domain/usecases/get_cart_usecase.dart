import '../entities/cart_state.dart';
import '../repositories/cart_repository.dart';

/// Use case for getting cart
class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<CartState> call() async {
    return await repository.getCart();
  }
}
