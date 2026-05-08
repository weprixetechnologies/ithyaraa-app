import '../entities/presale_product.dart';
import '../entities/presale_product_detail.dart';
import '../entities/presale_booking.dart';
import '../../data/models/presale_response_model.dart';

abstract class PresaleRepository {
  Future<PresaleResponseModel> getPresaleProducts({
    int page = 1,
    int limit = 10,
  });
  Future<PresaleProductDetailEntity> getPresaleProductDetail(String productID);

  /// Place a prebooking order
  Future<Map<String, dynamic>> placePrebookingOrder({
    required String addressID,
    required String productID,
    required String paymentMode,
    required int quantity,
    String? variationID,
  });

  /// Get user's presale bookings
  Future<List<PresaleBookingEntity>> getUserPresaleBookings();

  /// Get specific presale booking details
  Future<PresaleBookingEntity> getPresaleBookingDetails(String preBookingID);
}
