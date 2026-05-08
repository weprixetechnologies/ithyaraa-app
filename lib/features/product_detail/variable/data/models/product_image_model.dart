import 'dart:convert';
import '../../domain/entities/product_image.dart';
import 'package:flutter/foundation.dart';

/// Product image model for data layer
class ProductImageModel extends ProductImageEntity {
  const ProductImageModel({required super.imgUrl, super.imgAlt});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      imgUrl: json['imgUrl'] as String? ?? json['imageUrl'] as String? ?? '',
      imgAlt: json['imgAlt'] as String? ?? json['alt'] as String?,
    );
  }

  /// Parse from JSON string (for fields that arrive as JSON strings)
  static List<ProductImageModel> parseFromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded
          .map(
            (item) => ProductImageModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('[PRODUCT IMAGE MODEL] Error parsing JSON string: $e');
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {'imgUrl': imgUrl, 'imgAlt': imgAlt};
  }
}
