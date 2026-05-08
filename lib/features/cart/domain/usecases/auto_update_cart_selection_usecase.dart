import '../repositories/cart_repository.dart';

class AutoUpdateCartSelectionUseCase {
  final CartRepository repository;

  AutoUpdateCartSelectionUseCase(this.repository);

  Future<void> call() async {
    return await repository.autoUpdateCartSelection();
  }
}
