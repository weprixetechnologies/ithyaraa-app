import '../../domain/repositories/product_detail_repository.dart';
import '../../domain/entities/product_detail.dart';
import '../datasources/product_detail_remote_datasource.dart';

/// Repository implementation for product detail
class ProductDetailRepositoryImpl implements ProductDetailRepository {
  final ProductDetailRemoteDataSource remoteDataSource;

  ProductDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProductDetailEntity> getProductDetail(String productID) async {
    return await remoteDataSource.getProductDetail(productID);
  }
}
