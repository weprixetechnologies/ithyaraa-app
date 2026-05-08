import 'dart:convert';
import '../../domain/entities/variation.dart';
import 'product_attribute_model.dart';
import 'package:flutter/foundation.dart';

/// Variation model for data layer
class VariationModel extends VariationEntity {
  const VariationModel({
    required super.variationID,
    super.sku,
    super.regularPrice,
    super.salePrice,
    super.overridePrice,
    super.inStock,
    super.stockQuantity,
    required super.attributes,
    super.imageUrl,
  });

  factory VariationModel.fromJson(Map<String, dynamic> json) {
    // Parse prices (can be strings from API)
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Parse variationID (alphanumeric string)
    String variationIDStr = '';
    final variationIDValue = json['variationID'];
    if (variationIDValue is String) {
      variationIDStr = variationIDValue;
    } else if (variationIDValue is int) {
      variationIDStr = variationIDValue.toString();
    } else if (variationIDValue != null) {
      variationIDStr = variationIDValue.toString();
    }

    // Parse variationValues - JSON string like "[{\"Size\":\"S\"}]"
    List<ProductAttributeModel> attributes = [];
    final variationValuesData = json['variationValues'];
    if (variationValuesData is String) {
      try {
        final decoded = jsonDecode(variationValuesData) as List;
        for (final valueMap in decoded) {
          if (valueMap is Map<String, dynamic>) {
            valueMap.forEach((attrName, attrValue) {
              attributes.add(
                ProductAttributeModel(
                  attributeName: attrName,
                  attributeValue: attrValue.toString(),
                ),
              );
            });
          }
        }
      } catch (e) {
        debugPrint(
          '[VARIATION MODEL] Error parsing variationValues JSON string: $e',
        );
      }
    } else if (variationValuesData is List) {
      for (final valueMap in variationValuesData) {
        if (valueMap is Map<String, dynamic>) {
          valueMap.forEach((attrName, attrValue) {
            attributes.add(
              ProductAttributeModel(
                attributeName: attrName,
                attributeValue: attrValue.toString(),
              ),
            );
          });
        }
      }
    }

    // Parse stock - API uses variationStock
    final variationStock =
        json['variationStock'] as int? ??
        json['stock'] as int? ??
        json['stockQuantity'] as int? ??
        0;
    final inStock = variationStock > 0;

    return VariationModel(
      variationID: variationIDStr,
      sku: json['sku'] as String?,
      regularPrice:
          parsePrice(json['variationPrice']) ??
          parsePrice(json['regularPrice']),
      salePrice:
          parsePrice(json['variationSalePrice']) ??
          parsePrice(json['salePrice']),
      overridePrice: parsePrice(json['overridePrice']),
      inStock: inStock,
      stockQuantity: variationStock,
      attributes: attributes,
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variationID': variationID,
      'sku': sku,
      'regularPrice': regularPrice,
      'salePrice': salePrice,
      'overridePrice': overridePrice,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'attributes': attributes
          .map((a) => (a as ProductAttributeModel).toJson())
          .toList(),
      'imageUrl': imageUrl,
    };
  }
}
