import 'search_product.dart';

/// Search response entity
class SearchResponseEntity {
  final List<SearchProductEntity> products;
  final int total;
  final String? message;

  const SearchResponseEntity({
    required this.products,
    required this.total,
    this.message,
  });
}
