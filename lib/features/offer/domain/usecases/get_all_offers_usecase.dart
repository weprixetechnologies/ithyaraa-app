import '../entities/offer_response.dart';
import '../entities/offer_filters.dart';
import '../repositories/offer_repository.dart';

/// Use case for getting all offers
class GetAllOffersUseCase {
  final OfferRepository repository;

  GetAllOffersUseCase(this.repository);

  Future<OfferResponseEntity> call({
    int page = 1,
    int limit = 10,
    OfferFilters? filters,
  }) async {
    return await repository.getAllOffers(
      page: page,
      limit: limit,
      filters: filters,
    );
  }
}
