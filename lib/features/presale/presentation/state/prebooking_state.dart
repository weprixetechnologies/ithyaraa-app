class PrebookingState {
  final bool isLoading;
  final String? error;
  final String? selectedAddressID;
  final String paymentMode; // 'COD' or 'PREPAID'
  final bool isPlacingOrder;
  final String? successPreBookingID;

  const PrebookingState({
    this.isLoading = false,
    this.error,
    this.selectedAddressID,
    this.paymentMode = 'COD',
    this.isPlacingOrder = false,
    this.successPreBookingID,
  });

  PrebookingState copyWith({
    bool? isLoading,
    String? error,
    String? selectedAddressID,
    String? paymentMode,
    bool? isPlacingOrder,
    String? successPreBookingID,
  }) {
    return PrebookingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedAddressID: selectedAddressID ?? this.selectedAddressID,
      paymentMode: paymentMode ?? this.paymentMode,
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      successPreBookingID: successPreBookingID ?? this.successPreBookingID,
    );
  }
}
