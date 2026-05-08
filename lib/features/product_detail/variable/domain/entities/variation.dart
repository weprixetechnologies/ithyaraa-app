import 'product_attribute.dart';

/// Product variation entity (specific combination of attributes)
class VariationEntity {
  final String variationID;
  final String? sku;
  final double? regularPrice;
  final double? salePrice;
  final double? overridePrice;
  final bool inStock;
  final int stockQuantity;
  final List<ProductAttributeEntity> attributes;
  final String? imageUrl;

  const VariationEntity({
    required this.variationID,
    this.sku,
    this.regularPrice,
    this.salePrice,
    this.overridePrice,
    this.inStock = true,
    this.stockQuantity = 0,
    required this.attributes,
    this.imageUrl,
  });
}
