import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/add_to_cart_params.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../providers/cart_provider.dart';

/// Add to cart button state (per product)
class AddToCartButtonState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AddToCartButtonState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddToCartButtonState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AddToCartButtonState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Add to cart controller (family by productID)
class AddToCartController extends StateNotifier<AddToCartButtonState> {
  final String productID;
  final AddToCartUseCase addToCartUseCase;
  final Ref ref;
  bool _isProcessing = false;

  AddToCartController({
    required this.productID,
    required this.addToCartUseCase,
    required this.ref,
  }) : super(const AddToCartButtonState());

  /// Add item to cart
  Future<void> addToCart({
    required int quantity,
    String? variationID,
    String? variationName,
    String? referBy,
    Map<String, dynamic>? customInputs,
    Map<String, dynamic>? selectedDressType,
  }) async {
    // Prevent duplicate calls
    if (_isProcessing) return;
    _isProcessing = true;

    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    try {
      final params = AddToCartParams(
        productID: productID,
        quantity: quantity,
        variationID: variationID,
        variationName: variationName,
        referBy: referBy,
        customInputs: customInputs,
        selectedDressType: selectedDressType,
      );
      await addToCartUseCase(params);
      state = state.copyWith(isLoading: false, isSuccess: true);

      // Refresh cart after successful add
      final cartController = ref.read(cartControllerProvider.notifier);
      await cartController.refresh();
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
    state = const AddToCartButtonState();
  }
}
