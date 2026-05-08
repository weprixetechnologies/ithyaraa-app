import 'product_image.dart';
import 'product_attribute.dart';
import 'variation.dart';
import 'cross_sell_product.dart';
import 'offer.dart';

/// Product detail entity for variable products
class ProductDetailEntity {
  final String productID;
  final String productName;
  final String? brand;
  final String? description;
  final double? regularPrice;
  final double? salePrice;
  final double? overridePrice;
  final double? discountPercentage;
  final double? rating;
  final int? reviewCount;
  final bool inStock;
  final int stockQuantity;
  final List<ProductImageEntity> featuredImages;
  final List<ProductImageEntity> galleryImages;
  final List<ProductAttributeEntity> productAttributes;
  final List<VariationEntity> variations;
  final List<CrossSellProductEntity> crossSellProducts;
  final String? tab1; // First tab content
  final String? tab2; // Second tab content;
  final OfferEntity? offer;
  final bool isFlashSale;
  final DateTime? flashSaleEndTime;

  const ProductDetailEntity({
    required this.productID,
    required this.productName,
    this.brand,
    this.description,
    this.regularPrice,
    this.salePrice,
    this.overridePrice,
    this.discountPercentage,
    this.rating,
    this.reviewCount,
    this.inStock = true,
    this.stockQuantity = 0,
    required this.featuredImages,
    required this.galleryImages,
    required this.productAttributes,
    required this.variations,
    required this.crossSellProducts,
    this.tab1,
    this.tab2,
    this.offer,
    this.isFlashSale = false,
    this.flashSaleEndTime,
  });
}
