/// Cross-sell product entity (related/recommended products)
class CrossSellProductEntity {
  final String productID;
  final String productName;
  final String? imageUrl;
  final double? salePrice;
  final double? regularPrice;
  final String productType; // 'variable', 'custom', 'makecombo', 'combo'

  const CrossSellProductEntity({
    required this.productID,
    required this.productName,
    this.imageUrl,
    this.salePrice,
    this.regularPrice,
    required this.productType,
  });
}
