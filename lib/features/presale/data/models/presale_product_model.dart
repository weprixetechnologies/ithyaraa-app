import '../../domain/entities/presale_product.dart';
import '../../../shop/data/models/product_model.dart';
import '../../../shop/data/models/image_model.dart';
import '../../../shop/data/models/category_model.dart';

class PresaleProductModel extends PresaleProductEntity {
  const PresaleProductModel({
    required super.productID,
    required super.productName,
    super.description,
    super.brand,
    super.type,
    super.regularPrice,
    super.salePrice,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    required super.featuredImages,
    required super.categories,
    super.inStock,
    super.createdAt,
    super.isFlashSale,
    super.flashSaleEndTime,
    super.flashSalePrice,
    super.preSaleStartDate,
    super.preSaleEndDate,
    super.expectedDeliveryDate,
  });

  factory PresaleProductModel.fromJson(Map<String, dynamic> json) {
    // Reuse ProductModel parsing for common fields
    final standardProduct = ProductModel.fromJson(json);

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

    return PresaleProductModel(
      productID: standardProduct.productID.isNotEmpty 
          ? standardProduct.productID 
          : (json['presaleProductID']?.toString() ?? ''),
      productName: standardProduct.productName,
      description: standardProduct.description,
      brand: safeString(json['brand']) ?? standardProduct.brand,
      type: standardProduct.type,
      regularPrice: standardProduct.regularPrice,
      salePrice: standardProduct.salePrice,
      discountPercentage: standardProduct.discountPercentage,
      rating: standardProduct.rating,
      reviewCount: standardProduct.reviewCount,
      featuredImages: standardProduct.featuredImages.cast<ImageModel>(),
      categories: standardProduct.categories.cast<CategoryModel>(),
      inStock: standardProduct.inStock,
      createdAt: standardProduct.createdAt,
      isFlashSale: standardProduct.isFlashSale,
      flashSaleEndTime: standardProduct.flashSaleEndTime,
      flashSalePrice: standardProduct.flashSalePrice,
      preSaleStartDate: parseDate(json['preSaleStartDate']),
      preSaleEndDate: parseDate(json['preSaleEndDate']),
      expectedDeliveryDate: parseDate(json['expectedDeliveryDate']),
    );
  }
}
