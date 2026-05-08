/// Offer filters entity for filtering offers
class OfferFilters {
  final String? offerID;
  final String? offerName;
  final String? offerType;
  final double? buyAt;
  final int? buyCount;
  final int? getCount;

  const OfferFilters({
    this.offerID,
    this.offerName,
    this.offerType,
    this.buyAt,
    this.buyCount,
    this.getCount,
  });

  OfferFilters copyWith({
    String? offerID,
    String? offerName,
    String? offerType,
    double? buyAt,
    int? buyCount,
    int? getCount,
  }) {
    return OfferFilters(
      offerID: offerID ?? this.offerID,
      offerName: offerName ?? this.offerName,
      offerType: offerType ?? this.offerType,
      buyAt: buyAt ?? this.buyAt,
      buyCount: buyCount ?? this.buyCount,
      getCount: getCount ?? this.getCount,
    );
  }

  /// Check if any filter is active
  bool get hasActiveFilters {
    return offerID != null ||
        offerName != null ||
        offerType != null ||
        buyAt != null ||
        buyCount != null ||
        getCount != null;
  }
}
