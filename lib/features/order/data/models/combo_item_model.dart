import '../../domain/entities/combo_item.dart';
import 'dart:convert';

/// Combo item model for data layer
class ComboItemModel extends ComboItemEntity {
  const ComboItemModel({
    required super.productID,
    required super.name,
    super.imageUrl,
    super.featuredImages,
    super.brand,
    super.variationName,
    super.variationID,
    super.variationValues,
  });

  factory ComboItemModel.fromJson(Map<String, dynamic> json) {
    // Parse featuredImage: API returns as JSON string, needs to be decoded
    List<Map<String, dynamic>>? parseFeaturedImages(dynamic value) {
      if (value == null) return null;

      // Handle JSON string case - API returns featuredImage as stringified JSON
      dynamic parsedValue = value;
      if (value is String) {
        try {
          parsedValue = jsonDecode(value);
        } catch (e) {
          return null;
        }
      }

      if (parsedValue is List) {
        return parsedValue.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }

      return null;
    }

    // Get first image URL from featuredImage array
    String? getFirstImageUrl(List<Map<String, dynamic>>? featuredImages) {
      if (featuredImages != null && featuredImages.isNotEmpty) {
        final firstImage = featuredImages.first;
        return firstImage['imgUrl']?.toString();
      }
      return null;
    }

    // Parse variationValues
    List<Map<String, dynamic>>? parseVariationValues(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();
      }
      return null;
    }

    final featuredImages = parseFeaturedImages(json['featuredImage']);
    final firstImageUrl = getFirstImageUrl(featuredImages);

    return ComboItemModel(
      productID: json['productID']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: firstImageUrl,
      featuredImages: featuredImages,
      brand: json['brand']?.toString(),
      variationName: json['variationName']?.toString(),
      variationID: json['variationID']?.toString(),
      variationValues: parseVariationValues(json['variationValues']),
    );
  }
}
