import '../../../variable/domain/entities/product_image.dart';
import 'combo_product.dart';

/// Combo detail entity containing combo header and products array
class ComboDetailEntity {
  final String productID;
  final String productName;
  final String? brand;
  final String? description;
  final double? regularPrice;
  final double? salePrice;
  final double? discountPercentage;
  final double? rating;
  final int? reviewCount;
  final bool inStock;
  final List<ProductImageEntity> featuredImages;
  final List<ProductImageEntity> galleryImages;
  final List<ComboProductEntity> products;

  const ComboDetailEntity({
    required this.productID,
    required this.productName,
    this.brand,
    this.description,
    this.regularPrice,
    this.salePrice,
    this.discountPercentage,
    this.rating,
    this.reviewCount,
    this.inStock = true,
    required this.featuredImages,
    required this.galleryImages,
    required this.products,
  });
}
