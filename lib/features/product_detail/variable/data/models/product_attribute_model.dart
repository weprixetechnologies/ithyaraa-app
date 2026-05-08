import 'dart:convert';
import '../../domain/entities/product_attribute.dart';
import 'package:flutter/foundation.dart';

/// Product attribute model for data layer
class ProductAttributeModel extends ProductAttributeEntity {
  const ProductAttributeModel({
    required super.attributeName,
    required super.attributeValue,
    super.attributeSlug,
  });

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      attributeName: json['attributeName'] as String? ?? 
                    json['name'] as String? ?? 
                    json['attribute'] as String? ?? '',
      attributeValue: json['attributeValue'] as String? ?? 
                     json['value'] as String? ?? '',
      attributeSlug: json['attributeSlug'] as String? ?? 
                     json['slug'] as String?,
    );
  }

  /// Parse from JSON string (for fields that arrive as JSON strings)
  static List<ProductAttributeModel> parseFromJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((item) => ProductAttributeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[PRODUCT ATTRIBUTE MODEL] Error parsing JSON string: $e');
      return [];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'attributeName': attributeName,
      'attributeValue': attributeValue,
      'attributeSlug': attributeSlug,
    };
  }
}
