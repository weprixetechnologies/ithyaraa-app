import '../../domain/entities/shop_response.dart';
import '../../domain/entities/shop_filters.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_datasource.dart';

/// Repository implementation for shop operations
class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource remoteDataSource;

  ShopRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ShopResponseEntity> getShopProducts({
    int page = 1,
    int limit = 20,
    ShopFilters? filters,
  }) async {
    return await remoteDataSource.getShopProducts(
      page: page,
      limit: limit,
      filters: filters,
    );
  }
}
