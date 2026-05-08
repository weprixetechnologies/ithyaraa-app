import '../../../variable/domain/entities/product_image.dart';
import '../../../variable/domain/entities/cross_sell_product.dart';
import '../../../variable/domain/entities/offer.dart';
import 'custom_input.dart';
import 'dress_type.dart';

/// Product detail entity for custom products
class CustomProductDetailEntity {
  final String productID;
  final String productName;
  final String? brand;
  final String? brandID;
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
  final List<CrossSellProductEntity> crossSellProducts;
  final String? tab1;
  final String? tab2;
  final OfferEntity? offer;
  
  // Custom specific
  final List<CustomInputEntity> customInputs;
  final List<DressTypeEntity> dressTypes;
  final bool allowCustomerImageUpload;
  final String? sizeChartUrl;

  const CustomProductDetailEntity({
    required this.productID,
    required this.productName,
    this.brand,
    this.brandID,
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
    required this.crossSellProducts,
    this.tab1,
    this.tab2,
    this.offer,
    
    // Custom specific
    this.customInputs = const [],
    this.dressTypes = const [],
    this.allowCustomerImageUpload = false,
    this.sizeChartUrl,
  });
}
