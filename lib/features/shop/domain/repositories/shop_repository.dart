import '../entities/shop_response.dart';
import '../entities/shop_filters.dart';

/// Repository interface for shop operations
abstract class ShopRepository {
  /// Fetches products from the shop API
  /// 
  /// [page] - Current page number (default: 1)
  /// [limit] - Items per page (default: 20)
  /// [filters] - Shop filters object
  Future<ShopResponseEntity> getShopProducts({
    int page = 1,
    int limit = 20,
    ShopFilters? filters,
  });
}
