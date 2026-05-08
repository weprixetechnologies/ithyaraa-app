import 'image.dart';
import 'category.dart';

/// Product entity representing a shop product
class ProductEntity {
  final String productID;
  final String productName;
  final String? description;
  final String? brand;
  final String? type; // 'variable', 'custom', 'makecombo', 'combo'
  final double? regularPrice;
  final double? salePrice;
  final double? discountPercentage;
  final double? rating;
  final int? reviewCount;
  final List<ImageEntity> featuredImages;
  final List<CategoryEntity> categories;
  final bool? inStock;
  final DateTime? createdAt;
  final bool? isFlashSale;
  final DateTime? flashSaleEndTime;
  final double? flashSalePrice;

  const ProductEntity({
    required this.productID,
    required this.productName,
    this.description,
    this.brand,
    this.type,
    this.regularPrice,
    this.salePrice,
    this.discountPercentage,
    this.rating,
    this.reviewCount,
    required this.featuredImages,
    required this.categories,
    this.inStock,
    this.createdAt,
    this.isFlashSale,
    this.flashSaleEndTime,
    this.flashSalePrice,
  });
}
