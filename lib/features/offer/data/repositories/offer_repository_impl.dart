import '../../domain/entities/offer_response.dart';
import '../../domain/entities/offer_filters.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/offer_remote_datasource.dart';

/// Offer repository implementation
class OfferRepositoryImpl implements OfferRepository {
  final OfferRemoteDataSource remoteDataSource;

  OfferRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OfferResponseEntity> getAllOffers({
    int page = 1,
    int limit = 10,
    OfferFilters? filters,
  }) async {
    final response = await remoteDataSource.getAllOffers(
      page: page,
      limit: limit,
      filters: filters,
    );
    return response;
  }
}
