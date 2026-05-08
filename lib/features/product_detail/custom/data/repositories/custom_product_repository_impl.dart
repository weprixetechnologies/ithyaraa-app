import '../../domain/entities/custom_product_detail.dart';
import '../../domain/repositories/custom_product_repository.dart';
import '../datasources/custom_product_remote_datasource.dart';

class CustomProductRepositoryImpl implements CustomProductRepository {
  final CustomProductRemoteDataSource remoteDataSource;

  CustomProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CustomProductDetailEntity> getProductDetail(String productID) async {
    return await remoteDataSource.getProductDetail(productID);
  }
}
