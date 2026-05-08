import '../../domain/entities/offer_response.dart';
import '../../domain/entities/offer.dart';
import 'offer_model.dart';

/// Offer response model for data layer
class OfferResponseModel extends OfferResponseEntity {
  const OfferResponseModel({
    required super.offers,
    required super.count,
  });

  factory OfferResponseModel.fromJson(Map<String, dynamic> json) {
    final offersList = json['data'] as List? ?? [];
    final List<OfferEntity> offers = offersList
        .map<OfferEntity>((item) => OfferModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final count = json['count'] as int? ?? offers.length;

    return OfferResponseModel(
      offers: offers,
      count: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': offers.map((o) => (o as OfferModel).toJson()).toList(),
      'count': count,
    };
  }
}
