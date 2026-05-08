import '../entities/category.dart';
import '../repositories/category_repository.dart';

/// Use case for fetching all categories
class GetAllCategoriesUseCase {
  final CategoryRepository repository;

  GetAllCategoriesUseCase(this.repository);

  Future<List<CategoryEntity>> call({
    int page = 1,
    int limit = 50,
    String? categoryName,
  }) {
    return repository.getAllCategories(
      page: page,
      limit: limit,
      categoryName: categoryName,
    );
  }
}
