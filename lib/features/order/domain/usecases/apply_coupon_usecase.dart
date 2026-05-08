import '../repositories/order_repository.dart';

/// Use case for applying a coupon code to the cart
class ApplyCouponUseCase {
  final OrderRepository repository;

  ApplyCouponUseCase(this.repository);

  /// Apply coupon code to current cart
  ///
  /// [couponCode] - The coupon code to apply
  /// [cartID] - Optional cart ID (backend finds it if not provided)
  ///
  /// Returns raw response map with server-calculated totals/discounts
  Future<Map<String, dynamic>> call({
    required String couponCode,
    int? cartID,
  }) async {
    return await repository.applyCoupon(
      couponCode: couponCode,
      cartID: cartID,
    );
  }
}
