import '../../domain/entities/combo_detail.dart';
import '../../../variable/data/models/product_image_model.dart';
import 'combo_product_model.dart';
import 'package:flutter/foundation.dart';

/// Combo detail model for data layer
class ComboDetailModel extends ComboDetailEntity {
  const ComboDetailModel({
    required super.productID,
    required super.productName,
    super.brand,
    super.description,
    super.regularPrice,
    super.salePrice,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    super.inStock,
    required super.featuredImages,
    required super.galleryImages,
    required super.products,
  });

  factory ComboDetailModel.fromJson(Map<String, dynamic> json) {
    debugPrint(
      '[COMBO DETAIL MODEL] Parsing combo detail for ID: ${json['productID']}',
    );

    // Parse featuredImage - can be JSON string or List
    List<ProductImageModel> featuredImages = [];
    final featuredImage = json['featuredImage'];
    if (featuredImage is String) {
      featuredImages = ProductImageModel.parseFromJsonString(featuredImage);
    } else if (featuredImage is List) {
      featuredImages = featuredImage
          .map(
            (item) => ProductImageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    debugPrint(
      '[COMBO DETAIL MODEL] Parsed ${featuredImages.length} featured images',
    );

    // Parse galleryImage - can be JSON string or List (API: galleryImage)
    List<ProductImageModel> galleryImages = [];
    final galleryImage = json['galleryImage'];
    if (galleryImage is String) {
      galleryImages = ProductImageModel.parseFromJsonString(galleryImage);
    } else if (galleryImage is List) {
      galleryImages = galleryImage
          .map(
            (item) => ProductImageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    debugPrint('[COMBO DETAIL MODEL] Parsed ${galleryImages.length} gallery images');

    // Parse products array
    List<ComboProductModel> products = [];
    final productsData = json['products'];
    if (productsData is List) {
      products = productsData
          .map(
            (item) => ComboProductModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    debugPrint('[COMBO DETAIL MODEL] Parsed ${products.length} products');

    // Parse prices
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Parse prices (can be strings from API)
    final regularPrice = parsePrice(json['regularPrice']);
    final salePrice = parsePrice(json['salePrice']);

    // Calculate discount percentage
    double? discountPercentage = parsePrice(json['discountPercentage']);
    if (discountPercentage == null) {
      final discountType = json['discountType'] as String?;
      final discountValue = parsePrice(json['discountValue']);
      if (discountType == 'percentage' && discountValue != null) {
        discountPercentage = discountValue;
      } else if (regularPrice != null &&
          salePrice != null &&
          regularPrice > 0) {
        discountPercentage = ((regularPrice - salePrice) / regularPrice) * 100;
      }
    }

    // Parse stock status
    bool inStock = true;
    final stockStatus =
        json['inStock'] ?? json['stockStatus'] ?? json['status'];
    if (stockStatus is bool) {
      inStock = stockStatus;
    } else if (stockStatus is int) {
      // Handle int values: 0 = false, non-zero = true
      inStock = stockStatus != 0;
    } else if (stockStatus is String) {
      inStock =
          stockStatus.toLowerCase().contains('stock') &&
          !stockStatus.toLowerCase().contains('out');
    }

    // Parse productID (alphanumeric string)
    String productIDStr = '';
    final productIDValue = json['productID'];
    if (productIDValue is String) {
      productIDStr = productIDValue;
    } else if (productIDValue is int) {
      productIDStr = productIDValue.toString();
    } else if (productIDValue != null) {
      productIDStr = productIDValue.toString();
    }

    return ComboDetailModel(
      productID: productIDStr,
      productName:
          json['productName'] as String? ?? json['name'] as String? ?? '',
      brand: json['brand'] as String?,
      description: json['description'] as String?,
      regularPrice: regularPrice,
      salePrice: salePrice,
      discountPercentage: discountPercentage,
      rating: parsePrice(json['rating']),
      reviewCount: json['reviewCount'] as int?,
      inStock: inStock,
      featuredImages: featuredImages,
      galleryImages: galleryImages,
      products: products,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'brand': brand,
      'description': description,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'featuredImage': featuredImages
          .map((img) => (img as ProductImageModel).toJson())
          .toList(),
      'galleryImage': galleryImages
          .map((img) => (img as ProductImageModel).toJson())
          .toList(),
      'products': products
          .map((p) => (p as ComboProductModel).toJson())
          .toList(),
    };
  }
}
