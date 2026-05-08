import '../entities/cart_state.dart';
import '../repositories/cart_repository.dart';

/// Use case for updating cart selection
class UpdateCartSelectionUseCase {
  final CartRepository repository;

  UpdateCartSelectionUseCase(this.repository);

  Future<CartState> call(List<String> selectedItems) async {
    return await repository.updateCartSelection(selectedItems);
  }
}
