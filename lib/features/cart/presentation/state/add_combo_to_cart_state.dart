/// State for combo add-to-cart button
class AddComboToCartState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AddComboToCartState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddComboToCartState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return AddComboToCartState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
