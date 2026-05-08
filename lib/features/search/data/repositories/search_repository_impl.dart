import '../../domain/repositories/search_repository.dart';
import '../../domain/entities/search_response.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/search_response_model.dart';

/// Search repository implementation
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SearchResponseEntity> searchProducts(String query) async {
    final response = await remoteDataSource.searchProducts(query);
    return response;
  }
}
