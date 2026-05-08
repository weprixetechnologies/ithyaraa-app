import '../../domain/entities/offer.dart';

/// Offer model for data layer
class OfferModel extends OfferEntity {
  const OfferModel({
    required super.offerID,
    required super.offerName,
    required super.offerType,
    required super.buyCount,
    required super.getCount,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      offerID: json['offerID'] as String? ?? '',
      offerName: json['offerName'] as String? ?? '',
      offerType: json['offerType'] as String? ?? '',
      buyCount: json['buyCount'] as int? ?? 0,
      getCount: json['getCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offerID': offerID,
      'offerName': offerName,
      'offerType': offerType,
      'buyCount': buyCount,
      'getCount': getCount,
    };
  }
}
