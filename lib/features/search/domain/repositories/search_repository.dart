import '../entities/search_response.dart';

/// Search repository interface
abstract class SearchRepository {
  Future<SearchResponseEntity> searchProducts(String query);
}
