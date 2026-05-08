import '../entities/shop_response.dart';
import '../entities/shop_filters.dart';
import '../repositories/shop_repository.dart';

/// Use case for fetching shop products
class GetShopProductsUseCase {
  final ShopRepository repository;

  GetShopProductsUseCase(this.repository);

  Future<ShopResponseEntity> call({
    int page = 1,
    int limit = 20,
    ShopFilters? filters,
  }) {
    return repository.getShopProducts(
      page: page,
      limit: limit,
      filters: filters,
    );
  }
}
