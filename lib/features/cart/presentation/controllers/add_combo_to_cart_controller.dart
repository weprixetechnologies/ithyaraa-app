import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/session_expired_exception.dart';
import '../../domain/entities/add_combo_to_cart_params.dart';
import '../../domain/usecases/add_combo_to_cart_usecase.dart';
import '../providers/cart_provider.dart';
import '../state/add_combo_to_cart_state.dart';

/// Add combo to cart controller (family by comboID)
class AddComboToCartController extends StateNotifier<AddComboToCartState> {
  final String comboID;
  final AddComboToCartUseCase addComboToCartUseCase;
  final Ref ref;
  bool _isProcessing = false;

  AddComboToCartController({
    required this.comboID,
    required this.addComboToCartUseCase,
    required this.ref,
  }) : super(const AddComboToCartState());

  /// Add combo to cart
  Future<void> addComboToCart({
    required int quantity,
    required List<Map<String, String>> products,
  }) async {
    // Prevent duplicate calls
    if (_isProcessing) return;
    _isProcessing = true;

    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      // comboID is the mainProductID (the combo product ID)
      final params = AddComboToCartParams(
        mainProductID: comboID,
        quantity: quantity,
        products: products,
      );
      await addComboToCartUseCase(params);
      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh cart after successful add
      final cartController = ref.read(cartControllerProvider.notifier);
      await cartController.refresh();
    } on SessionExpiredException {
      // Session expired; interceptor navigates to login. Do not set error (no snackbar).
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    } finally {
      _isProcessing = false;
    }
  }

  void reset() {
    state = const AddComboToCartState();
  }
}
