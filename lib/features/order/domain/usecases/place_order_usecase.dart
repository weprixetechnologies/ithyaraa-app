import '../repositories/order_repository.dart';

/// Use case for placing an order from cart
class PlaceOrderUseCase {
  final OrderRepository repository;

  PlaceOrderUseCase(this.repository);

  /// Place order with the given parameters
  ///
  /// [body] should contain:
  /// - addressID: String | number (required)
  /// - paymentMode: "COD" | "PREPAID" | "phonepe" (required)
  /// - couponCode: String? (optional)
  /// - walletApplied: double? (optional)
  ///
  /// Returns raw response map as per API documentation
  Future<Map<String, dynamic>> call(Map<String, dynamic> body) async {
    return await repository.placeOrder(body);
  }
}
