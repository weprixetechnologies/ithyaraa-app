import '../entities/category.dart';

/// Repository interface for category operations
abstract class CategoryRepository {
  /// Fetches all categories
  /// 
  /// [page] - Current page number (default: 1)
  /// [limit] - Items per page (default: 50)
  /// [categoryName] - Filter by category name (optional)
  Future<List<CategoryEntity>> getAllCategories({
    int page = 1,
    int limit = 50,
    String? categoryName,
  });
}
