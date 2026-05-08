import 'offer.dart';

/// Offer response entity containing list of offers and count
class OfferResponseEntity {
  final List<OfferEntity> offers;
  final int count;

  const OfferResponseEntity({
    required this.offers,
    required this.count,
  });
}
