import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

/// Repository implementation for category operations
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getAllCategories({
    int page = 1,
    int limit = 50,
    String? categoryName,
  }) async {
    return await remoteDataSource.getAllCategories(
      page: page,
      limit: limit,
      categoryName: categoryName,
    );
  }
}
