/// Offer entity for products
class OfferEntity {
  final String offerID;
  final String offerName;
  final String offerType;
  final int buyCount;
  final int getCount;

  const OfferEntity({
    required this.offerID,
    required this.offerName,
    required this.offerType,
    required this.buyCount,
    required this.getCount,
  });
}
