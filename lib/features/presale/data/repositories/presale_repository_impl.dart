import '../../domain/repositories/presale_repository.dart';
import '../../domain/entities/presale_product_detail.dart';
import '../../domain/entities/presale_booking.dart';
import '../datasources/presale_remote_datasource.dart';
import '../models/presale_response_model.dart';

class PresaleRepositoryImpl implements PresaleRepository {
  final PresaleRemoteDataSource remoteDataSource;

  PresaleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PresaleResponseModel> getPresaleProducts({int page = 1, int limit = 10}) {
    return remoteDataSource.getPresaleProducts(page: page, limit: limit);
  }

  @override
  Future<PresaleProductDetailEntity> getPresaleProductDetail(String productID) {
    return remoteDataSource.getPresaleProductDetail(productID);
  }

  @override
  Future<Map<String, dynamic>> placePrebookingOrder({
    required String addressID,
    required String productID,
    required String paymentMode,
    required int quantity,
    String? variationID,
  }) {
    return remoteDataSource.placePrebookingOrder(
      addressID: addressID,
      productID: productID,
      paymentMode: paymentMode,
      quantity: quantity,
      variationID: variationID,
    );
  }

  @override
  Future<List<PresaleBookingEntity>> getUserPresaleBookings() {
    return remoteDataSource.getUserPresaleBookings();
  }

  @override
  Future<PresaleBookingEntity> getPresaleBookingDetails(String preBookingID) {
    return remoteDataSource.getPresaleBookingDetails(preBookingID);
  }
}
