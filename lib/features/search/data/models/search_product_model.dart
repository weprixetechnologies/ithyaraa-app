import 'dart:convert';
import '../../domain/entities/search_product.dart';
import '../../../shop/data/models/image_model.dart';

/// Search product model for data layer
class SearchProductModel extends SearchProductEntity {
  const SearchProductModel({
    required super.productID,
    required super.name,
    super.description,
    super.regularPrice,
    super.salePrice,
    super.discountType,
    super.discountValue,
    super.type,
    super.status,
    super.brand,
    required super.featuredImages,
    super.categories,
    super.createdAt,
  });

  factory SearchProductModel.fromJson(Map<String, dynamic> json) {
    // Parse featuredImage - can be JSON string or List
    List<ImageModel> images = [];
    final featuredImage = json['featuredImage'];
    if (featuredImage is String) {
      images = ImageModel.parseFromJsonString(featuredImage);
    } else if (featuredImage is List) {
      images = featuredImage
          .map((item) => ImageModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

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

    return SearchProductModel(
      productID: json['productID'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      regularPrice: parsePrice(json['regularPrice']),
      salePrice: parsePrice(json['salePrice']),
      discountType: json['discountType'] as String?,
      discountValue: parsePrice(json['discountValue']),
      type: json['type'] as String?,
      status: json['status'] as String?,
      brand: json['brand'] as String?,
      featuredImages: images,
      categories: json['categories'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
