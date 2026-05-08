import '../../domain/entities/presale_product_detail.dart';
import '../../../product_detail/variable/data/models/product_detail_model.dart';
import '../../../product_detail/variable/data/models/product_image_model.dart';
import '../../../product_detail/variable/data/models/product_attribute_model.dart';
import '../../../product_detail/variable/data/models/variation_model.dart';
import '../../../product_detail/variable/data/models/cross_sell_product_model.dart';

class PresaleProductDetailModel extends PresaleProductDetailEntity {
  const PresaleProductDetailModel({
    required super.productID,
    required super.productName,
    super.brand,
    super.description,
    super.regularPrice,
    super.salePrice,
    super.overridePrice,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    super.inStock = true,
    super.stockQuantity = 0,
    required super.featuredImages,
    required super.galleryImages,
    required super.productAttributes,
    required super.variations,
    required super.crossSellProducts,
    super.tab1,
    super.tab2,
    super.offer,
    super.isFlashSale = false,
    super.flashSaleEndTime,
    super.preSaleStartDate,
    super.preSaleEndDate,
    super.expectedDeliveryDate,
    super.sizeChartUrl,
  });

  factory PresaleProductDetailModel.fromJson(Map<String, dynamic> json) {
    // Reuse ProductDetailModel parsing for common fields
    final standardDetail = ProductDetailModel.fromJson(json);

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    String? safeString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is List && value.isEmpty) return null;
      return value.toString();
    }

    return PresaleProductDetailModel(
      productID: standardDetail.productID.isNotEmpty 
          ? standardDetail.productID 
          : (json['presaleProductID']?.toString() ?? ''),
      productName: standardDetail.productName,
      brand: safeString(json['brand']) ?? standardDetail.brand,
      description: safeString(json['description']) ?? standardDetail.description,
      regularPrice: standardDetail.regularPrice,
      salePrice: standardDetail.salePrice,
      overridePrice: standardDetail.overridePrice,
      discountPercentage: standardDetail.discountPercentage,
      rating: standardDetail.rating,
      reviewCount: standardDetail.reviewCount,
      inStock: standardDetail.inStock,
      stockQuantity: standardDetail.stockQuantity,
      featuredImages: standardDetail.featuredImages.cast<ProductImageModel>(),
      galleryImages: standardDetail.galleryImages.cast<ProductImageModel>(),
      productAttributes: standardDetail.productAttributes.cast<ProductAttributeModel>(),
      variations: standardDetail.variations.cast<VariationModel>(),
      crossSellProducts: standardDetail.crossSellProducts.cast<CrossSellProductModel>(),
      tab1: safeString(json['tab1']) ?? standardDetail.tab1,
      tab2: safeString(json['tab2']) ?? standardDetail.tab2,
      offer: standardDetail.offer,
      isFlashSale: standardDetail.isFlashSale,
      flashSaleEndTime: standardDetail.flashSaleEndTime,
      preSaleStartDate: parseDate(json['preSaleStartDate']),
      preSaleEndDate: parseDate(json['preSaleEndDate']),
      expectedDeliveryDate: parseDate(json['expectedDeliveryDate']),
      sizeChartUrl: safeString(json['sizeChartUrl']),
    );
  }
}
