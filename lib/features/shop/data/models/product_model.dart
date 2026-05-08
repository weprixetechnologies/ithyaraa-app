import '../../domain/entities/product.dart';
import 'image_model.dart';
import 'category_model.dart';
import 'package:flutter/foundation.dart';

/// Product model for data layer
class ProductModel extends ProductEntity {
  const ProductModel({
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
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    debugPrint(
      '[PRODUCT MODEL] Parsing product: ${json['productID'] ?? json['name']}',
    );

    // Parse featuredImage - can be JSON string or List
    List<ImageModel> images = [];
    final featuredImageData = json['featuredImage'];
    if (featuredImageData is String && featuredImageData.isNotEmpty) {
      images = ImageModel.parseFromJsonString(featuredImageData);
    } else if (featuredImageData is List && featuredImageData.isNotEmpty) {
      images = featuredImageData
          .map((item) => ImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // FALLBACK: If featuredImages is still empty, check for direct URL fields
    if (images.isEmpty) {
      final fallbackUrl =
          json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          json['featured_image']?.toString();
      if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
        // Synthesize a virtual image model for the UI
        images = [
          ImageModel(
            imgUrl: fallbackUrl,
            imgAlt: json['name'] as String? ?? 'Product Image',
          ),
        ];
        debugPrint(
          '[PRODUCT MODEL] Synthesized 1 fallback image from direct URL',
        );
      }
    }
    debugPrint('[PRODUCT MODEL] Final parsed ${images.length} images');

    // Parse categories - can be JSON string or List
    List<CategoryModel> categories = [];
    final categoriesData = json['categories'];
    if (categoriesData is String) {
      categories = CategoryModel.parseFromJsonString(categoriesData);
    } else if (categoriesData is List) {
      categories = categoriesData
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    debugPrint('[PRODUCT MODEL] Parsed ${categories.length} categories');

    // Parse prices - handle both int and double
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    // Calculate discount percentage
    // API may provide discountPercentage directly, or discountValue with discountType
    double? discountPercentage = json['discountPercentage'] != null
        ? parsePrice(json['discountPercentage'])
        : null;

    final regularPrice = parsePrice(json['regularPrice']);
    final salePrice = parsePrice(json['salePrice']);

    // If discountPercentage not provided, calculate from discountValue
    if (discountPercentage == null) {
      final discountValue = parsePrice(json['discountValue']);
      final discountType = json['discountType'] as String?;

      if (discountValue != null && discountType == 'percentage') {
        discountPercentage = discountValue;
      } else if (regularPrice != null && salePrice != null) {
        // Calculate from price difference
        discountPercentage = ((regularPrice - salePrice) / regularPrice) * 100;
      }
    }

    // Parse productID (alphanumeric string) - can be string or int from API
    String productIDStr = '';
    final productIDValue =
        json['productID'] ??
        json['presaleProductID'] ??
        json['id'] ??
        json['ProductID'];

    if (productIDValue is String) {
      productIDStr = productIDValue;
    } else if (productIDValue is int) {
      productIDStr = productIDValue.toString();
    } else if (productIDValue != null) {
      productIDStr = productIDValue.toString();
    }

    // Parse productName - API uses 'name' field
    final productName =
        json['productName'] as String? ?? json['name'] as String? ?? '';

    // Parse inStock from status field
    bool? inStock;
    final status = json['status'] as String?;
    if (status != null) {
      inStock =
          status.toLowerCase().contains('stock') &&
          !status.toLowerCase().contains('out');
    } else {
      inStock = json['inStock'] as bool?;
    }

    DateTime? createdAt;
    try {
      final createdStr = json['createdAt'] as String?;
      if (createdStr != null) {
        createdAt = DateTime.parse(createdStr);
      }
    } catch (_) {}

    debugPrint(
      '[PRODUCT MODEL] Product: $productName, Price: ₹$salePrice, InStock: $inStock, ProductID: $productIDStr',
    );

    // Parse flash sale info
    final bool isFlashSale =
        json['isFlashSale'] == true || json['isFlashSale'] == 1;
    DateTime? flashSaleEndTime;
    if (json['flashSaleEndTime'] != null) {
      flashSaleEndTime = DateTime.tryParse(json['flashSaleEndTime'].toString());
    }
    final flashSalePrice = parsePrice(
      json['flashSalePrice'] ?? json['salePrice'],
    );

    return ProductModel(
      productID: productIDStr,
      productName: productName,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      type: json['type'] as String?,
      regularPrice: regularPrice,
      salePrice: salePrice,
      discountPercentage: discountPercentage,
      rating: parsePrice(json['rating']),
      reviewCount: json['reviewCount'] as int?,
      featuredImages: images,
      categories: categories,
      inStock: inStock,
      createdAt: createdAt,
      isFlashSale: isFlashSale,
      flashSaleEndTime: flashSaleEndTime,
      flashSalePrice: flashSalePrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'productName': productName,
      'description': description,
      'brand': brand,
      'type': type,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'reviewCount': reviewCount,
      'featuredImage': featuredImages
          .map((img) => (img as ImageModel).toJson())
          .toList(),
      'categories': categories
          .map((cat) => (cat as CategoryModel).toJson())
          .toList(),
      'inStock': inStock,
      'isFlashSale': isFlashSale,
      'flashSaleEndTime': flashSaleEndTime?.toIso8601String(),
      'flashSalePrice': flashSalePrice,
    };
  }
}
