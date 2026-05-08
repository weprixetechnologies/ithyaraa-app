import '../entities/search_response.dart';
import '../repositories/search_repository.dart';

/// Use case for searching products
class SearchProductsUseCase {
  final SearchRepository repository;

  SearchProductsUseCase(this.repository);

  Future<SearchResponseEntity> call(String query) async {
    return await repository.searchProducts(query);
  }
}
