import '../../domain/entities/custom_product_detail.dart';

abstract class CustomProductRepository {
  Future<CustomProductDetailEntity> getProductDetail(String productID);
}
