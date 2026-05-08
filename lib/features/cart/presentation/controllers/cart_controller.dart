import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_state.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/update_cart_selection_usecase.dart';
import '../../domain/usecases/auto_update_cart_selection_usecase.dart';

/// Cart page state
class CartPageState {
  final CartState? cartState;
  final bool isLoading;
  final bool isDeleting;
  final bool isUpdatingSelection;
  final String? error;
  final Set<String>? localSelectedItems;

  const CartPageState({
    this.cartState,
    this.isLoading = false,
    this.isDeleting = false,
    this.isUpdatingSelection = false,
    this.error,
    this.localSelectedItems,
  });

  CartPageState copyWith({
    CartState? cartState,
    bool? isLoading,
    bool? isDeleting,
    bool? isUpdatingSelection,
    String? error,
    Set<String>? localSelectedItems,
  }) {
    return CartPageState(
      cartState: cartState ?? this.cartState,
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      isUpdatingSelection: isUpdatingSelection ?? this.isUpdatingSelection,
      error: error,
      localSelectedItems: localSelectedItems ?? this.localSelectedItems,
    );
  }

  bool get hasChanges {
    if (cartState == null || localSelectedItems == null) return false;
    final serverSelected = cartState!.items
        .where((i) => i.isSelected)
        .map((i) => i.cartItemID)
        .toSet();
    
    if (serverSelected.length != localSelectedItems!.length) return true;
    return !serverSelected.every((id) => localSelectedItems!.contains(id));
  }
}

/// Cart controller managing cart page state
class CartController extends StateNotifier<CartPageState> {
  final GetCartUseCase getCartUseCase;
  final RemoveCartItemUseCase removeCartItemUseCase;
  final UpdateCartSelectionUseCase updateCartSelectionUseCase;
  final AutoUpdateCartSelectionUseCase autoUpdateCartSelectionUseCase;

  CartController({
    required this.getCartUseCase,
    required this.removeCartItemUseCase,
    required this.updateCartSelectionUseCase,
    required this.autoUpdateCartSelectionUseCase,
  }) : super(const CartPageState());

  /// Load cart
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cartState = await getCartUseCase();
      
      // Initialize local selection from server state
      final initialSelection = cartState.items
          .where((i) => i.isSelected)
          .map((i) => i.cartItemID)
          .toSet();
          
      state = state.copyWith(
        cartState: cartState, 
        isLoading: false,
        localSelectedItems: initialSelection,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh cart
  Future<void> refresh() async {
    await loadCart();
  }

  /// Remove item from cart
  ///
  /// UPDATED: Implements Optmistic UI to satisfy Dismissible requirement.
  /// The item is removed from the local list immediately to ensure the
  /// Dismissible widget is correctly removed from the tree during rebuild.
  Future<void> removeItem(String cartItemID) async {
    final oldState = state;

    // Step 1: Optimistically remove item from local state
    if (state.cartState != null) {
      final updatedItems = state.cartState!.items
          .where((item) => item.cartItemID != cartItemID)
          .toList();

      final updatedCartState = state.cartState!.copyWith(items: updatedItems);
      
      // Also update local selection set
      final updatedLocalSelection = Set<String>.from(state.localSelectedItems ?? {})
          ..remove(cartItemID);

      state = state.copyWith(
        cartState: updatedCartState,
        localSelectedItems: updatedLocalSelection,
        isDeleting: true, // Show the blocking loader overlay
        error: null,
      );
    } else {
      state = state.copyWith(isDeleting: true, error: null);
    }

    try {
      // Step 2: Call delete API
      await removeCartItemUseCase(cartItemID);

      // Step 3: Fetch fresh cart from server to sync final totals/summary
      await loadCart(); // This will also re-init localSelectedItems correctly
      state = state.copyWith(isDeleting: false);
    } catch (e) {
      // Step 4: On error, restore previous state and show error
      state = oldState.copyWith(isDeleting: false, error: e.toString());
    }
  }

  /// Update local selection (Deferred)
  void updateLocalSelection(String cartItemID, bool selected) {
    if (state.localSelectedItems == null) return;
    
    final newSelection = Set<String>.from(state.localSelectedItems!);
    if (selected) {
      newSelection.add(cartItemID);
    } else {
      newSelection.remove(cartItemID);
    }
    
    state = state.copyWith(localSelectedItems: newSelection);
  }

  /// Toggle all local selection (Deferred)
  void toggleAllLocalSelection(bool selected) {
    if (state.cartState == null) return;
    
    final newSelection = selected 
        ? state.cartState!.items.map((i) => i.cartItemID).toSet()
        : <String>{}.toSet();
        
    state = state.copyWith(localSelectedItems: newSelection);
  }

  /// Apply the local selection changes to the server
  Future<void> applySelectionUpdate() async {
    if (state.localSelectedItems == null) return;
    
    state = state.copyWith(isUpdatingSelection: true);
    try {
      final cartState = await updateCartSelectionUseCase(
        state.localSelectedItems!.toList(),
      );
      state = state.copyWith(
        cartState: cartState,
        isUpdatingSelection: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdatingSelection: false,
        error: e.toString(),
      );
    }
  }

  /// Auto update cart selection based on stock
  Future<void> autoUpdateSelection() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await autoUpdateCartSelectionUseCase();
      await loadCart();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
