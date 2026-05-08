import '../entities/custom_product_detail.dart';
import '../repositories/custom_product_repository.dart';

class GetCustomProductDetailUseCase {
  final CustomProductRepository repository;

  GetCustomProductDetailUseCase(this.repository);

  Future<CustomProductDetailEntity> call(String productID) async {
    return await repository.getProductDetail(productID);
  }
}
