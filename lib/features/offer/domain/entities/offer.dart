import '../../../shop/domain/entities/product.dart';

/// Offer entity (domain layer)
class OfferEntity {
  final String offerID;
  final String offerName;
  final String offerType;
  final double? buyAt;
  final int? buyCount;
  final int? getCount;
  final String? offerMobileBanner;
  final String? offerBanner;
  final List<ProductEntity> products;
  final DateTime createdAt;

  const OfferEntity({
    required this.offerID,
    required this.offerName,
    required this.offerType,
    this.buyAt,
    this.buyCount,
    this.getCount,
    this.offerMobileBanner,
    this.offerBanner,
    required this.products,
    required this.createdAt,
  });
}
