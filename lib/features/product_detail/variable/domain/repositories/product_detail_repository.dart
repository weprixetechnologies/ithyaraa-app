import '../entities/product_detail.dart';

/// Repository interface for product detail operations
abstract class ProductDetailRepository {
  Future<ProductDetailEntity> getProductDetail(String productID);
}
