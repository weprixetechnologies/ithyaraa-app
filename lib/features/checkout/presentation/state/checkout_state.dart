/// Checkout state for managing checkout flow
class CheckoutState {
  final bool loading;
  final String? selectedAddressID;
  final String paymentMode; // "COD" or "PREPAID"
  final String? couponCode;
  final double walletApplied;
  final String? error;
  final Map<String, dynamic>? couponResponse; // Store coupon apply response

  CheckoutState({
    this.loading = false,
    this.selectedAddressID,
    this.paymentMode = "COD",
    this.couponCode,
    this.walletApplied = 0,
    this.error,
    this.couponResponse,
  });

  CheckoutState copyWith({
    bool? loading,
    String? selectedAddressID,
    String? paymentMode,
    String? couponCode,
    double? walletApplied,
    String? error,
    Map<String, dynamic>? couponResponse,
    bool clearCoupon = false,
  }) {
    return CheckoutState(
      loading: loading ?? this.loading,
      selectedAddressID: selectedAddressID ?? this.selectedAddressID,
      paymentMode: paymentMode ?? this.paymentMode,
      couponCode: clearCoupon ? null : (couponCode ?? this.couponCode),
      walletApplied: walletApplied ?? this.walletApplied,
      error: error,
      couponResponse: clearCoupon ? null : (couponResponse ?? this.couponResponse),
    );
  }
}
