import '../../../variable/domain/entities/product_image.dart';
import '../../../variable/domain/entities/variation.dart';
import '../../../variable/domain/entities/product_attribute.dart';

/// Combo product entity representing a product within a combo
class ComboProductEntity {
  final String productID;
  final String name;
  final List<ProductImageEntity> featuredImage;
  final List<VariationEntity> variations;
  final List<ProductAttributeEntity> productAttributes;

  const ComboProductEntity({
    required this.productID,
    required this.name,
    required this.featuredImage,
    required this.variations,
    required this.productAttributes,
  });
}
