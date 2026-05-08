import 'package:ithyaraaapp/features/flash_sale/data/datasources/flash_sale_remote_datasource.dart';
import 'package:ithyaraaapp/features/shop/domain/entities/product.dart';
import 'package:ithyaraaapp/features/shop/data/models/product_model.dart';

abstract class FlashSaleRepository {
  Future<Map<String, dynamic>> getFlashSaleProducts({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filters,
  });
}

class FlashSaleRepositoryImpl implements FlashSaleRepository {
  final FlashSaleRemoteDataSource remoteDataSource;

  FlashSaleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getFlashSaleProducts({
    int page = 1,
    int limit = 12,
    Map<String, dynamic>? filters,
  }) async {
    final result = await remoteDataSource.getFlashSaleProducts(
      page: page,
      limit: limit,
      filters: filters,
    );

    final rawProducts = result['data'] as List;
    final List<ProductEntity> products = rawProducts
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return {
      'products': products,
      'pagination': result['pagination'],
    };
  }
}
