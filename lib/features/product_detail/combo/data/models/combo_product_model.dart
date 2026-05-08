import 'dart:convert';
import '../../domain/entities/combo_product.dart';
import '../../../variable/data/models/product_image_model.dart';
import '../../../variable/data/models/variation_model.dart';
import '../../../variable/data/models/product_attribute_model.dart';
import 'package:flutter/foundation.dart';

/// Combo product model for data layer
class ComboProductModel extends ComboProductEntity {
  const ComboProductModel({
    required super.productID,
    required super.name,
    required super.featuredImage,
    required super.variations,
    required super.productAttributes,
  });

  factory ComboProductModel.fromJson(Map<String, dynamic> json) {
    debugPrint(
      '[COMBO PRODUCT MODEL] Parsing combo product for ID: ${json['productID']}',
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

    // Parse variations
    List<VariationModel> variations = [];
    final variationsData = json['variations'];
    if (variationsData is List) {
      variations = variationsData
          .map((item) => VariationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Parse productAttributes - structure: [{"name":"Size","values":["S","M","L"]}]
    List<ProductAttributeModel> productAttributes = [];
    final productAttributesData = json['productAttributes'];
    if (productAttributesData is String) {
      try {
        final decoded = jsonDecode(productAttributesData) as List;
        for (final attrDef in decoded) {
          if (attrDef is Map<String, dynamic>) {
            final attrName = attrDef['name'] as String? ?? '';
            final values = attrDef['values'] as List?;
            if (values != null) {
              for (final value in values) {
                productAttributes.add(
                  ProductAttributeModel(
                    attributeName: attrName,
                    attributeValue: value.toString(),
                  ),
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint(
          '[COMBO PRODUCT MODEL] Error parsing productAttributes JSON string: $e',
        );
      }
    } else if (productAttributesData is List) {
      for (final attrDef in productAttributesData) {
        if (attrDef is Map<String, dynamic>) {
          final attrName = attrDef['name'] as String? ?? '';
          final values = attrDef['values'] as List?;
          if (values != null) {
            for (final value in values) {
              productAttributes.add(
                ProductAttributeModel(
                  attributeName: attrName,
                  attributeValue: value.toString(),
                ),
              );
            }
          }
        }
      }
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

    return ComboProductModel(
      productID: productIDStr,
      name: json['name'] as String? ?? json['productName'] as String? ?? '',
      featuredImage: featuredImages,
      variations: variations,
      productAttributes: productAttributes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productID': productID,
      'name': name,
      'featuredImage': featuredImage
          .map((img) => (img as ProductImageModel).toJson())
          .toList(),
      'variations': variations
          .map((v) => (v as VariationModel).toJson())
          .toList(),
      'productAttributes': productAttributes
          .map((attr) => (attr as ProductAttributeModel).toJson())
          .toList(),
    };
  }
}
