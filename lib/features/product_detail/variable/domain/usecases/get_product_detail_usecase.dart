import '../entities/product_detail.dart';
import '../repositories/product_detail_repository.dart';

/// Use case for fetching product detail
class GetProductDetailUseCase {
  final ProductDetailRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<ProductDetailEntity> call(String productID) async {
    return await repository.getProductDetail(productID);
  }
}
