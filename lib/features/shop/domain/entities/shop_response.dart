import 'product.dart';
import 'pagination.dart';

/// Shop response entity containing products and pagination
class ShopResponseEntity {
  final List<ProductEntity> products;
  final PaginationEntity pagination;

  const ShopResponseEntity({
    required this.products,
    required this.pagination,
  });
}
