import '../entities/offer_response.dart';
import '../entities/offer_filters.dart';

/// Offer repository interface
abstract class OfferRepository {
  Future<OfferResponseEntity> getAllOffers({
    int page = 1,
    int limit = 10,
    OfferFilters? filters,
  });
}
